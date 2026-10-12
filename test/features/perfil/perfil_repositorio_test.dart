import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/foto.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';
import 'package:te_tengo/features/perfil/data/perfil_repositorio.dart';
import 'package:te_tengo/features/perfil/domain/perfil.dart';
import 'package:te_tengo/features/perfil/presentation/pantalla_recorte.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/datos.dart';

const _fotoJson = {
  'url': 'https://r2.test/fotos/usuarios/u-carmen/f1.jpg?X-Amz-Signature=a',
  'expiraEn': '2026-09-23T16:42:00Z',
};

const _perfilJson = {
  'id': 'u-carmen',
  'nombre': 'Carmen Huamán',
  'correo': 'carmen.huaman@gmail.com',
  'telefono': '981 220 417',
  'parentesco': 'Hija',
  'foto': _fotoJson,
};

const _subida = 'https://r2.test/fotos/subidas/s-1?X-Amz-Signature=b';

void main() {
  late AdaptadorFalso http;
  late PerfilRepositorio repo;

  setUp(() {
    http = AdaptadorFalso();
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    repo = c.read(perfilRepositorioProvider);
  });

  group('cuenta (contrato §13)', () {
    test('GET /api/cuenta', () async {
      http.cuando('GET', '/api/cuenta', const Respuesta(200, _perfilJson));
      final p = (await repo.obtener())!;
      expect(p.nombre, 'Carmen Huamán');
      expect(p.telefono, '981 220 417');
      expect(p.parentesco, 'Hija');
      expect(p.foto!.url, _fotoJson['url']);
      expect(p.foto!.expiraEn, DateTime.utc(2026, 9, 23, 16, 42).toLocal());
    });

    test('un servidor sin perfiles (404) da null, sin error', () async {
      http.cuando(
        'GET',
        '/api/cuenta',
        Respuesta.problema(404, 'NO_ENCONTRADO'),
      );
      expect(await repo.obtener(), isNull);
    });

    test('PUT /api/cuenta envía los tres campos; vacío borra', () async {
      http.cuando('PUT', '/api/cuenta', const Respuesta(200, _perfilJson));
      await repo.guardar(nombre: 'Carmen Huamán', parentesco: 'Hija');
      expect(http.hechas('PUT', '/api/cuenta').single.data, {
        'nombre': 'Carmen Huamán',
        'telefono': null,
        'parentesco': 'Hija',
      });
    });

    test('PUT /api/cuenta/contrasena', () async {
      http.cuando('PUT', '/api/cuenta/contrasena', const Respuesta(204));
      await repo.cambiarContrasena(actual: 'rosa2026', nueva: 'cuidamos2026');
      expect(http.hechas('PUT', '/api/cuenta/contrasena').single.data, {
        'actual': 'rosa2026',
        'nueva': 'cuidamos2026',
      });
    });
  });

  group('contraseña incorrecta', () {
    test('422 CONTRASENA_ACTUAL_INCORRECTA', () async {
      http.cuando(
        'PUT',
        '/api/cuenta/contrasena',
        Respuesta.problema(422, 'CONTRASENA_ACTUAL_INCORRECTA'),
      );
      await expectLater(
        repo.cambiarContrasena(actual: 'x', nueva: 'cuidamos2026'),
        throwsA(
          isA<ProblemaApi>().having(
            (p) => p.codigo,
            'codigo',
            'CONTRASENA_ACTUAL_INCORRECTA',
          ),
        ),
      );
    });
  });

  group('fotos (contrato §13)', () {
    test(
      'pide la subida, envía la foto a la URL firmada y la confirma',
      () async {
        http
          ..cuando(
            'POST',
            '/api/fotos/subidas',
            const Respuesta(201, {
              'subidaId': 's-1',
              'url': _subida,
              'cabeceras': {'Content-Type': 'image/png'},
              'expiraEn': '2026-09-23T15:52:00Z',
            }),
          )
          ..cuando('PUT', _subida, const Respuesta(200))
          ..cuando(
            'POST',
            '/api/fotos/subidas/s-1/confirmacion',
            const Respuesta(200, _fotoJson),
          );
        final avances = <double>[];
        final foto = await repo.subirFoto(
          DuenoFoto.adultoMayor,
          Uint8List.fromList(List.filled(1000, 7)),
          tipo: 'image/png',
          alProgreso: avances.add,
        );
        expect(http.hechas('POST', '/api/fotos/subidas').single.data, {
          'de': 'ADULTO_MAYOR',
          'tipo': 'image/png',
          'tamanoBytes': 1000,
        });
        final put = http.hechas('PUT', _subida).single;
        expect(put.headers['Content-Type'], 'image/png');
        // Straight to the object store: neither the session nor the API version.
        expect(put.headers.containsKey('Authorization'), isFalse);
        expect(put.headers.containsKey('Api-Version'), isFalse);
        expect(avances, isNotEmpty);
        expect(avances.last, 1);
        expect(
          http.hechas('POST', '/api/fotos/subidas/s-1/confirmacion'),
          hasLength(1),
        );
        expect(foto.url, _fotoJson['url']);
      },
    );

    test('un fallo al enviarla no confirma nada', () async {
      http
        ..cuando(
          'POST',
          '/api/fotos/subidas',
          const Respuesta(201, {
            'subidaId': 's-1',
            'url': _subida,
            'cabeceras': {'Content-Type': 'image/png'},
          }),
        )
        ..cuando('PUT', _subida, const Respuesta(403, 'AccessDenied'));
      await expectLater(
        repo.subirFoto(
          DuenoFoto.yo,
          Uint8List.fromList([1, 2, 3]),
          tipo: 'image/png',
        ),
        throwsA(isA<ProblemaApi>()),
      );
      expect(
        http.hechas('POST', '/api/fotos/subidas/s-1/confirmacion'),
        isEmpty,
      );
    });

    test('DELETE /api/fotos/yo y /api/fotos/adulto-mayor', () async {
      http
        ..cuando('DELETE', '/api/fotos/yo', const Respuesta(204))
        ..cuando('DELETE', '/api/fotos/adulto-mayor', const Respuesta(204));
      await repo.quitarFoto(DuenoFoto.yo);
      await repo.quitarFoto(DuenoFoto.adultoMayor);
      expect(http.hechas('DELETE', '/api/fotos/yo'), hasLength(1));
      expect(http.hechas('DELETE', '/api/fotos/adulto-mayor'), hasLength(1));
    });
  });

  group('la foto en el hogar y en la familia', () {
    test('adultoMayor y familiares traen `foto`, teléfono y parentesco', () {
      final a = AdultoMayor.desdeJson({
        'nombre': 'Rosa Huamán',
        'direccion': 'Jr. Los Pinos 482',
        'convivencia': 'SOLO',
        'foto': _fotoJson,
      });
      expect(a.admiteFoto, isTrue);
      expect(a.foto!.url, _fotoJson['url']);
      final f = Familiar.desdeJson({
        'usuarioId': 'u-luis',
        'nombre': 'Luis Huamán',
        'correo': 'luis.huaman.r@gmail.com',
        'rol': 'INVITADO',
        'telefono': '994 318 052',
        'parentesco': 'Hijo',
        'foto': null,
      });
      expect(f.telefono, '994 318 052');
      expect(f.parentesco, 'Hijo');
      expect(f.foto, isNull);
    });

    test('un servidor anterior no manda `foto`: iniciales y sin cambiarla', () {
      final a = AdultoMayor.desdeJson({
        'nombre': 'Rosa Huamán',
        'direccion': 'Jr. Los Pinos 482',
        'convivencia': 'SOLO',
      });
      expect(a.foto, isNull);
      expect(a.admiteFoto, isFalse);
      final f = Familiar.desdeJson({
        'usuarioId': 'u-luis',
        'nombre': 'Luis Huamán',
        'correo': 'luis.huaman.r@gmail.com',
        'rol': 'INVITADO',
      });
      expect(f.foto, isNull);
      expect(f.parentesco, isNull);
    });

    test('la misma foto con otra firma reusa la imagen ya descargada', () {
      final ahora = DateTime(2026, 9, 23, 10);
      final primera = Foto(
        url: 'https://r2.test/fotos/hogares/h-1/adulto-mayor/x.jpg?firma=1',
        expiraEn: ahora.add(const Duration(hours: 1)),
      );
      final otraFirma = Foto(
        url: 'https://r2.test/fotos/hogares/h-1/adulto-mayor/x.jpg?firma=2',
        expiraEn: ahora.add(const Duration(hours: 1)),
      );
      final nueva = Foto(
        url: 'https://r2.test/fotos/hogares/h-1/adulto-mayor/y.jpg?firma=3',
        expiraEn: ahora.add(const Duration(hours: 1)),
      );
      expect(urlEstable(primera, ahora: ahora), primera.url);
      expect(urlEstable(otraFirma, ahora: ahora), primera.url);
      expect(urlEstable(nueva, ahora: ahora), nueva.url);
      // Once the first signature is about to end, the new one is used.
      final despues = ahora.add(const Duration(minutes: 59, seconds: 30));
      expect(urlEstable(otraFirma, ahora: despues), otraFirma.url);
    });
  });

  group('recorte cuadrado', () {
    test(
      'sin mover ni acercar, toma el centro… del borde superior izquierdo',
      () {
        // A 1600 × 1200 picture covering a 300 px square: scale 0.25.
        final area = areaVisible(
          vista: Matrix4.identity(),
          lado: 300,
          escalaBase: .25,
          imagen: const Size(1600, 1200),
        );
        expect(area, const Rect.fromLTWH(0, 0, 1200, 1200));
      },
    );

    test('acercado al doble y movido, toma esa parte', () {
      final vista = Matrix4.identity()
        ..translateByDouble(-100, -50, 0, 1)
        ..scaleByDouble(2, 2, 1, 1);
      final area = areaVisible(
        vista: vista,
        lado: 300,
        escalaBase: .25,
        imagen: const Size(1600, 1200),
      );
      expect(area.left, closeTo(200, .001));
      expect(area.top, closeTo(100, .001));
      expect(area.width, closeTo(600, .001));
      expect(area.height, area.width);
    });

    testWidgets('dibuja 512 × 512 como PNG', (tester) async {
      await tester.runAsync(() async {
        final grabador = ui.PictureRecorder();
        Canvas(grabador).drawColor(Colors.purple, BlendMode.src);
        final imagen = await grabador.endRecording().toImage(1600, 1200);
        final png = await recortarImagen(
          imagen,
          const Rect.fromLTWH(200, 0, 1200, 1200),
        );
        final codec = await ui.instantiateImageCodec(png);
        final cuadro = (await codec.getNextFrame()).image;
        expect(png.sublist(1, 4), 'PNG'.codeUnits);
        expect((cuadro.width, cuadro.height), (512, 512));
      });
    });
  });
}
