import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/push.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/dispositivos_repositorio.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/inicio/presentation/pantalla_inicio.dart';

import '../apoyo/adaptador_falso.dart';
import '../apoyo/app_de_prueba.dart';
import '../apoyo/datos.dart';
import '../apoyo/push_falso.dart';
import '../features/camaras/repositorio_falso.dart';
import '../features/familia/familia_falso.dart';
import '../features/hogar/hogar_falso.dart';

class _SesionesFalsas implements SesionRepositorio {
  @override
  Future<void> cerrar(String tokenAcceso) async {}

  @override
  Future<Sesion> cambiarHogar(String hogarId) => throw UnimplementedError();

  @override
  Future<List<HogarResumen>> hogares() async => [];
}

void main() {
  group('MensajePush', () {
    test('lee el payload de datos del contrato', () {
      final m = MensajePush.desdeDatos({
        'tipo': 'ALERTA_CAIDA',
        'alertaId': 'a-1',
        'camaraId': 'c1',
        'habitacion': 'Sala',
        'ocurridaEn': '2026-10-07T15:04:31Z',
      })!;
      expect(m.tipo, TipoPush.alertaCaida);
      expect(m.alertaId, 'a-1');
      expect(m.ocurridaEn, isNotNull);
      expect(MensajePush.desdeDatos({'tipo': 'OTRO'}), isNull);
    });

    test('cada tipo abre su pantalla', () {
      MensajePush m(TipoPush t) =>
          MensajePush(tipo: t, alertaId: 'a-1', camaraId: 'c1');
      for (final t in [
        TipoPush.alertaCaida,
        TipoPush.alertaMovimientoInestable,
        TipoPush.alertaActualizadaACaida,
        TipoPush.caidaConfirmada,
        TipoPush.seLevanto,
        TipoPush.alertaEscalada,
        TipoPush.sinContactoSecundario,
      ]) {
        expect(rutaDePush(m(t)), Rutas.alerta('a-1'), reason: t.codigo);
      }
      expect(
        rutaDePush(m(TipoPush.alertaAtendida)),
        Rutas.detalleAlerta('a-1'),
      );
      for (final t in [
        TipoPush.camaraDesconectada,
        TipoPush.camaraReconectada,
        TipoPush.deteccionNoConfiable,
        TipoPush.pausaFinalizada,
      ]) {
        expect(rutaDePush(m(t)), Rutas.camara('c1'), reason: t.codigo);
      }
      expect(rutaDePush(m(TipoPush.datosEliminados)), Rutas.privacidad);
      expect(
        rutaDePush(const MensajePush(tipo: TipoPush.alertaCaida)),
        Rutas.inicio,
      );
    });
  });

  group('en la app', () {
    late NotificacionesPushFalsas push;
    late DispositivosFalsos dispositivos;
    late AlmacenSesionMemoria almacen;

    Future<void> abrir(
      WidgetTester tester, {
      String ubicacion = Rutas.inicio,
    }) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: ubicacion,
          almacen: almacen,
          push: push,
          dispositivos: dispositivos,
          overrides: [
            camarasRepositorioProvider.overrideWithValue(
              CamarasRepositorioFalso(),
            ),
            hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso(),
            ),
            sesionRepositorioProvider.overrideWithValue(_SesionesFalsas()),
            relojProvider.overrideWithValue(
              () => DateTime(2026, 9, 23, 10, 42),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      push = NotificacionesPushFalsas(tokenActual: 'fcm-1');
      dispositivos = DispositivosFalsos();
      almacen = AlmacenSesionMemoria(sesionTitular);
    });

    testWidgets('registra el celular al abrir la app con sesión', (
      tester,
    ) async {
      await abrir(tester);
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
      push.renovar('fcm-2');
      await tester.pumpAndSettle();
      expect(dispositivos.registrados, ['fcm-1|ANDROID', 'fcm-2|ANDROID']);
    });

    testWidgets('sin sesión no registra; al iniciar sesión, sí', (
      tester,
    ) async {
      almacen = AlmacenSesionMemoria();
      await abrir(tester, ubicacion: Rutas.bienvenida);
      expect(dispositivos.registrados, isEmpty);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      await c.read(sesionControllerProvider.notifier).iniciar(sesionTitular);
      await tester.pumpAndSettle();
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
    });

    testWidgets('al cerrar sesión deja de recibir alertas en este celular', (
      tester,
    ) async {
      await abrir(tester);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(PantallaInicio)),
      );
      await c.read(sesionControllerProvider.notifier).cerrar();
      await tester.pumpAndSettle();
      expect(dispositivos.eliminados, ['fcm-1|acceso-1']);
    });

    testWidgets('tocar la notificación de la cámara abre su detalle', (
      tester,
    ) async {
      await abrir(tester);
      push.tocar(
        const MensajePush(
          tipo: TipoPush.camaraDesconectada,
          camaraId: 'c1',
          habitacion: 'Sala',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cámara · Sala'), findsOneWidget);
    });

    testWidgets(
      'una notificación que abrió la app cerrada lleva a su pantalla',
      (tester) async {
        push.mensajeInicial = const MensajePush(tipo: TipoPush.datosEliminados);
        await abrir(tester, ubicacion: Rutas.arranque);
        expect(find.text('Privacidad'), findsOneWidget);
      },
    );

    testWidgets('con la app abierta, la desconexión se avisa en la app', (
      tester,
    ) async {
      await abrir(tester);
      push.recibir(
        const MensajePush(
          tipo: TipoPush.camaraDesconectada,
          camaraId: 'c1',
          habitacion: 'Sala',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('La cámara de la Sala se desconectó'), findsOneWidget);
      await tester.tap(find.text('La cámara de la Sala se desconectó'));
      await tester.pumpAndSettle();
      expect(find.text('Cámara · Sala'), findsOneWidget);
    });
  });

  group('DispositivosRepositorioApi', () {
    test(
      'POST /api/dispositivos y DELETE /api/dispositivos/{tokenPush}',
      () async {
        final http = AdaptadorFalso()
          ..cuando('POST', '/api/dispositivos', const Respuesta(201))
          ..cuando('DELETE', '/api/dispositivos/fcm-1', const Respuesta(204));
        final c = ProviderContainer(
          overrides: [
            almacenSesionProvider.overrideWithValue(
              AlmacenSesionMemoria(sesionTitular),
            ),
            adaptadorHttpProvider.overrideWithValue(http),
          ],
        );
        addTearDown(c.dispose);
        final repo = c.read(dispositivosRepositorioProvider);
        await repo.registrar(tokenPush: 'fcm-1', plataforma: 'IOS');
        await repo.eliminar('fcm-1', tokenAcceso: 'viejo');
        expect(http.peticiones.first.data, {
          'tokenPush': 'fcm-1',
          'plataforma': 'IOS',
        });
        expect(http.peticiones.last.headers['Authorization'], 'Bearer viejo');
      },
    );
  });
}
