import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';

import '../apoyo/adaptador_falso.dart';
import '../apoyo/datos.dart';

ProviderContainer _contenedor(AdaptadorFalso http, AlmacenSesion almacen) {
  final c = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      almacenSesionProvider.overrideWithValue(almacen),
      adaptadorHttpProvider.overrideWithValue(http),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('lee la Sesion del contrato', () {
    final s = Sesion.desdeJson(sesionJson());
    expect(s.tokenAcceso, 'acceso-2');
    expect(s.usuario.nombrePila, 'Carmen');
    expect(s.hogarId, 'h-1');
    expect(s.rol, Rol.titular);
    expect(s.esTitular, isTrue);
    expect(Sesion.desdeJson(s.aJson()).tokenRefresco, 'refresco-2');
    final sinHogar = Sesion.desdeJson(sesionJson(hogarId: null, rol: null));
    expect(sinHogar.tieneHogar, isFalse);
    expect(sinHogar.rol, isNull);
  });

  group('cliente HTTP', () {
    test('envía Api-Version y el token de acceso', () async {
      final http = AdaptadorFalso()
        ..cuando('GET', '/api/camaras', const Respuesta(200, []));
      final c = _contenedor(http, AlmacenSesionMemoria(sesionTitular));
      await c.read(clienteApiProvider).get<List<dynamic>>('/api/camaras');
      final p = http.peticiones.single;
      expect(p.headers['Api-Version'], '1');
      expect(p.headers['Authorization'], 'Bearer acceso-1');
    });

    test('ante 401 SESION_EXPIRADA renueva los tokens y reintenta', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/camaras',
          Respuesta.problema(401, 'SESION_EXPIRADA'),
        )
        ..cuando('GET', '/api/camaras', const Respuesta(200, []))
        ..cuando(
          'POST',
          '/api/sesiones/refresco',
          Respuesta(200, sesionJson()),
        );
      final almacen = AlmacenSesionMemoria(sesionTitular);
      final c = _contenedor(http, almacen);
      final r = await c
          .read(clienteApiProvider)
          .get<List<dynamic>>('/api/camaras');
      expect(r.statusCode, 200);
      final refresco = http.hechas('POST', '/api/sesiones/refresco').single;
      expect(refresco.data, {'tokenRefresco': 'refresco-1'});
      expect(
        http.hechas('GET', '/api/camaras').last.headers['Authorization'],
        'Bearer acceso-2',
      );
      expect(almacen.actual!.tokenAcceso, 'acceso-2');
      expect(c.read(sesionControllerProvider)!.tokenAcceso, 'acceso-2');
    });

    test('si la renovación falla, cierra la sesión', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/camaras',
          Respuesta.problema(401, 'SESION_EXPIRADA'),
        )
        ..cuando(
          'POST',
          '/api/sesiones/refresco',
          Respuesta.problema(401, 'SESION_EXPIRADA'),
        );
      final almacen = AlmacenSesionMemoria(sesionTitular);
      final c = _contenedor(http, almacen);
      c.listen(sesionControllerProvider, (_, _) {});
      await expectLater(
        c.read(clienteApiProvider).get<List<dynamic>>('/api/camaras'),
        throwsA(isA<DioException>()),
      );
      expect(almacen.actual, isNull);
      expect(c.read(sesionControllerProvider), isNull);
    });

    test('otros 401 no renuevan la sesión', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/sesiones',
          Respuesta.problema(401, 'CREDENCIALES_INVALIDAS'),
        );
      final c = _contenedor(http, AlmacenSesionMemoria());
      await expectLater(
        c.read(clienteApiProvider).post<void>('/api/sesiones'),
        throwsA(isA<DioException>()),
      );
      expect(http.hechas('POST', '/api/sesiones/refresco'), isEmpty);
    });
  });

  group('SesionController', () {
    test(
      'cerrar revoca el token en el backend y olvida la sesión (CA-02.4)',
      () async {
        final http = AdaptadorFalso()
          ..cuando('DELETE', '/api/sesiones/actual', const Respuesta(204));
        final almacen = AlmacenSesionMemoria(sesionTitular);
        final c = _contenedor(http, almacen);
        await c.read(sesionControllerProvider.notifier).cerrar();
        expect(http.hechas('DELETE', '/api/sesiones/actual'), hasLength(1));
        expect(almacen.actual, isNull);
        expect(c.read(sesionControllerProvider), isNull);
      },
    );

    test('cerrar sin conexión igual cierra la sesión en el celular', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'DELETE',
          '/api/sesiones/actual',
          Respuesta.problema(500, 'X'),
        );
      final almacen = AlmacenSesionMemoria(sesionTitular);
      final c = _contenedor(http, almacen);
      await c.read(sesionControllerProvider.notifier).cerrar();
      expect(c.read(sesionControllerProvider), isNull);
    });

    test('lista los hogares y cambia de hogar', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/hogares',
          const Respuesta(200, [
            {
              'hogarId': 'h-1',
              'nombreAdultoMayor': 'Rosa Huamán',
              'rol': 'TITULAR',
            },
            {
              'hogarId': 'h-2',
              'nombreAdultoMayor': 'Juan Pérez',
              'rol': 'INVITADO',
            },
          ]),
        )
        ..cuando(
          'POST',
          '/api/sesiones/hogar',
          Respuesta(
            200,
            sesionJson(acceso: 'acceso-h2', hogarId: 'h-2', rol: 'INVITADO'),
          ),
        );
      final c = _contenedor(http, AlmacenSesionMemoria(sesionTitular));
      final hogares = await c.read(sesionRepositorioProvider).hogares();
      expect(hogares.map((h) => h.nombreAdultoMayor), [
        'Rosa Huamán',
        'Juan Pérez',
      ]);
      expect(hogares.last.rol, Rol.invitado);
      await c.read(sesionControllerProvider.notifier).cambiarHogar('h-2');
      expect(http.hechas('POST', '/api/sesiones/hogar').single.data, {
        'hogarId': 'h-2',
      });
      final s = c.read(sesionControllerProvider)!;
      expect(s.hogarId, 'h-2');
      expect(s.esTitular, isFalse);
    });

    test('cambiar a un hogar ajeno devuelve SIN_MEMBRESIA', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/sesiones/hogar',
          Respuesta.problema(403, 'SIN_MEMBRESIA'),
        );
      final c = _contenedor(http, AlmacenSesionMemoria(sesionTitular));
      await expectLater(
        c.read(sesionControllerProvider.notifier).cambiarHogar('h-9'),
        throwsA(
          isA<ProblemaApi>().having((p) => p.codigo, 'codigo', 'SIN_MEMBRESIA'),
        ),
      );
      expect(c.read(sesionControllerProvider)!.hogarId, 'h-1');
    });
  });
}
