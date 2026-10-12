import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/foto.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/lista.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';
import 'package:te_tengo/features/perfil/data/selector_foto.dart';
import 'package:te_tengo/features/perfil/domain/perfil.dart';
import 'package:te_tengo/features/perfil/presentation/pantalla_recorte.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'perfil_falso.dart';

/// The picture an [Avatar] draws, if any.
String? urlDe(WidgetTester tester, Finder avatar) {
  final imagenes = find.descendant(of: avatar, matching: find.byType(Image));
  if (imagenes.evaluate().isEmpty) return null;
  final proveedor = tester.widget<Image>(imagenes.first).image;
  return switch (proveedor) {
    ResizeImage(imageProvider: NetworkImage(:final url)) => url,
    NetworkImage(:final url) => url,
    _ => null,
  };
}

void main() {
  late PerfilRepositorioFalso perfil;
  late SelectorFotoFalso selector;
  late HogarRepositorioFalso hogar;
  final recortadas = <Uint8List>[];
  final recortada = Uint8List.fromList([9, 9, 9]);

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        perfil: perfil,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(hogar),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          selectorFotoProvider.overrideWithValue(selector),
          // The square crop is a screen of its own; here it hands back a fixed picture.
          recortadorFotoProvider.overrideWithValue((context, original) async {
            recortadas.add(original);
            return recortada;
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    perfil = PerfilRepositorioFalso(perfilCarmen());
    selector = SelectorFotoFalso();
    hogar = HogarRepositorioFalso();
    recortadas.clear();
  });

  group('«Cambiar foto» en Tu perfil (pantalla 103)', () {
    testWidgets('la hoja ofrece tomar o elegir una foto; «Quitar la foto» solo '
        'si hay una', (tester) async {
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      expect(find.text('Foto de Carmen'), findsOneWidget);
      expect(find.text('La ve toda la familia.'), findsOneWidget);
      expect(find.text('Tomar una foto'), findsOneWidget);
      expect(find.text('Elegir de la galería'), findsOneWidget);
      expect(find.text('Quitar la foto'), findsNothing);
    });

    testWidgets('elegida de la galería, se recorta, se sube y se ve', (
      tester,
    ) async {
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Elegir de la galería'));
      expect(selector.pedidos, [(OrigenFoto.galeria, true)]);
      expect(recortadas.single, selector.imagen);
      final (de, bytes, tipo) = perfil.subidas.single;
      expect(de, DuenoFoto.yo);
      expect(bytes, recortada);
      expect(tipo, 'image/png');
      expect(find.text('Foto actualizada'), findsOneWidget);
      expect(find.text('La verá toda la familia.'), findsOneWidget);
      expect(urlDe(tester, find.byType(Avatar).first), urlEstable(fotoCarmen));
    });

    testWidgets('«Tomar una foto» usa la cámara frontal para la propia', (
      tester,
    ) async {
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Tomar una foto'));
      expect(selector.pedidos, [(OrigenFoto.camara, true)]);
      expect(perfil.subidas, hasLength(1));
    });

    testWidgets('cancelar la cámara o el recorte no sube nada', (tester) async {
      selector.imagen = null;
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Tomar una foto'));
      expect(perfil.subidas, isEmpty);
      expect(find.text('Foto actualizada'), findsNothing);
    });

    testWidgets('muestra el avance mientras sube', (tester) async {
      final semantica = tester.ensureSemantics();
      perfil.pausaSubida = Completer<void>();
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tester.tap(find.text('Elegir de la galería'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Subiendo… 50 %'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Subiendo la foto')), findsOneWidget);
      perfil.pausaSubida!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Cambiar foto'), findsOneWidget);
      expect(find.text('Foto actualizada'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets(
      'si falla, lo dice y «Volver a intentarlo» sube la misma foto',
      (tester) async {
        perfil.erroresSubida.add(
          const ProblemaApi(
            codigo: 'FOTO_MUY_GRANDE',
            detalle: 'La foto pesa más de 5 MB.',
            estado: 413,
          ),
        );
        await abrir(tester, Rutas.tuPerfil);
        await tocar(tester, find.text('Cambiar foto'));
        await tocar(tester, find.text('Elegir de la galería'));
        expect(find.text('No se pudo cambiar la foto'), findsOneWidget);
        expect(find.text('La foto pesa más de 5 MB.'), findsOneWidget);
        expect(find.text('Foto actualizada'), findsNothing);
        await tocar(tester, find.text('Volver a intentarlo'));
        expect(perfil.subidas, hasLength(2));
        expect(perfil.subidas.last.$2, recortada);
        expect(find.text('No se pudo cambiar la foto'), findsNothing);
        expect(find.text('Foto actualizada'), findsOneWidget);
      },
    );

    testWidgets('«Quitar la foto» vuelve a las iniciales', (tester) async {
      perfil.perfil = perfilCarmen(foto: fotoCarmen);
      await abrir(tester, Rutas.tuPerfil);
      expect(urlDe(tester, find.byType(Avatar).first), urlEstable(fotoCarmen));
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Quitar la foto'));
      expect(perfil.quitadas, [DuenoFoto.yo]);
      expect(find.text('Foto quitada'), findsOneWidget);
      expect(find.text('Se verán las iniciales.'), findsOneWidget);
      expect(urlDe(tester, find.byType(Avatar).first), isNull);
      expect(find.text('CH'), findsOneWidget);
    });
  });

  group('permisos de la cámara y de las fotos', () {
    testWidgets('bloqueada: explica cómo permitirla en los ajustes', (
      tester,
    ) async {
      selector.error = const PermisoFotoDenegado(
        origen: OrigenFoto.camara,
        bloqueado: true,
      );
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Tomar una foto'));
      expect(find.text('La cámara del celular está bloqueada'), findsOneWidget);
      expect(find.text('Abrir los ajustes del celular'), findsOneWidget);
      await tocar(tester, find.text('Ahora no'));
      expect(perfil.subidas, isEmpty);
    });

    testWidgets('negada una vez: lo dice y deja elegir otra opción', (
      tester,
    ) async {
      selector.error = const PermisoFotoDenegado(
        origen: OrigenFoto.galeria,
        bloqueado: false,
      );
      await abrir(tester, Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Elegir de la galería'));
      expect(find.text('Sin permiso para ver tus fotos'), findsOneWidget);
      expect(find.text('Puedes elegir otra opción.'), findsOneWidget);
    });
  });

  group('la foto de la persona cuidada (pantalla 105)', () {
    testWidgets('el titular la cambia con la cámara trasera', (tester) async {
      await abrir(tester, Rutas.personaCuidada);
      expect(find.text('Teléfono de Rosa'), findsOneWidget);
      expect(find.text('Lo usa «Llamar a Rosa».'), findsOneWidget);
      await tocar(tester, find.text('Cambiar foto'));
      expect(find.text('Foto de Rosa'), findsOneWidget);
      await tocar(tester, find.text('Tomar una foto'));
      expect(selector.pedidos, [(OrigenFoto.camara, false)]);
      expect(perfil.subidas.single.$1, DuenoFoto.adultoMayor);
      expect(find.text('Foto actualizada'), findsOneWidget);
    });

    testWidgets('el titular la quita', (tester) async {
      hogar.hogar = Hogar(
        hogarId: 'h-1',
        adultoMayor: rosa.conFoto(fotoRosa),
        rol: Rol.titular,
      );
      await abrir(tester, Rutas.personaCuidada);
      await tocar(tester, find.text('Cambiar foto'));
      await tocar(tester, find.text('Quitar la foto'));
      expect(perfil.quitadas, [DuenoFoto.adultoMayor]);
    });

    testWidgets('el familiar invitado la ve, sin «Cambiar foto»', (
      tester,
    ) async {
      hogar.hogar = Hogar(
        hogarId: 'h-1',
        adultoMayor: rosa.conFoto(fotoRosa),
        rol: Rol.invitado,
      );
      await abrir(tester, Rutas.personaCuidada, sesion: sesionInvitado);
      expect(urlDe(tester, find.byType(Avatar).first), urlEstable(fotoRosa));
      expect(find.text('Cambiar foto'), findsNothing);
    });

    testWidgets('con un servidor sin fotos no ofrece cambiarla', (
      tester,
    ) async {
      hogar.hogar = Hogar(
        hogarId: 'h-1',
        adultoMayor: AdultoMayor.desdeJson(const {
          'nombre': 'Rosa Huamán',
          'direccion': 'Jr. Los Pinos 482',
          'convivencia': 'SOLO',
          'edad': 78,
        }),
        rol: Rol.titular,
      );
      await abrir(tester, Rutas.personaCuidada);
      expect(find.text('Cambiar foto'), findsNothing);
      expect(find.text('RH'), findsOneWidget);
    });
  });

  group('las fotos en toda la app', () {
    testWidgets('Ajustes muestra la de Rosa y la propia', (tester) async {
      perfil.perfil = perfilCarmen(foto: fotoCarmen);
      hogar.hogar = Hogar(
        hogarId: 'h-1',
        adultoMayor: rosa.conFoto(fotoRosa),
        rol: Rol.titular,
      );
      await abrir(tester, Rutas.ajustes);
      expect(urlDe(tester, find.byType(Avatar).first), urlEstable(fotoRosa));
      await verHasta(tester, find.text('Tu cuenta · Titular'));
      final cuenta = find.ancestor(
        of: find.text('Tu cuenta · Titular'),
        matching: find.byType(FilaLista),
      );
      expect(
        urlDe(
          tester,
          find.descendant(of: cuenta, matching: find.byType(Avatar)),
        ),
        urlEstable(fotoCarmen),
      );
    });

    testWidgets('la familia muestra la foto de cada uno', (tester) async {
      final fotoLuis = Foto(
        url: 'https://fotos.test/fotos/usuarios/u-luis/f3.jpg?firma=1',
        expiraEn: DateTime(2026, 9, 23, 11, 42),
      );
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: Rutas.familia,
          sesion: sesionTitular,
          perfil: perfil,
          overrides: [
            hogarRepositorioProvider.overrideWithValue(hogar),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso([
                carmen,
                Familiar(
                  usuarioId: luis.usuarioId,
                  nombre: luis.nombre,
                  correo: luis.correo,
                  rol: luis.rol,
                  parentesco: 'Hijo',
                  foto: fotoLuis,
                ),
              ]),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final filaLuis = find.ancestor(
        of: find.text('Luis Huamán'),
        matching: find.byType(FilaLista),
      );
      expect(
        urlDe(
          tester,
          find.descendant(of: filaLuis, matching: find.byType(Avatar)),
        ),
        urlEstable(fotoLuis),
      );
      // Carmen has none: her initials.
      final filaCarmen = find.ancestor(
        of: find.text('Carmen Huamán (tú)'),
        matching: find.byType(FilaLista),
      );
      expect(
        urlDe(
          tester,
          find.descendant(of: filaCarmen, matching: find.byType(Avatar)),
        ),
        isNull,
      );
    });
  });
}
