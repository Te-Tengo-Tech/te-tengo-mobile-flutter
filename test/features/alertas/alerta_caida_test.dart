import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  testWidgets('CA-16.1: la alerta muestra habitación, hora y qué hacer', (
    tester,
  ) async {
    final llamadas = await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    expect(find.text('ALERTA DE CAÍDA · URGENTE'), findsOneWidget);
    expect(find.text('Rosa pudo haberse caído'), findsOneWidget);
    expect(find.text('Comprobando si sigue en el suelo'), findsOneWidget);
    expect(find.text('Habitación'), findsOneWidget);
    expect(find.text('Sala'), findsOneWidget);
    expect(find.text('10:42'), findsWidgets);
    expect(find.text('instantes'), findsOneWidget);
    expect(find.text('Jr. Los Pinos 482, San Miguel, Lima'), findsOneWidget);
    expect(find.text('Ver en vivo · Sala'), findsOneWidget);
    await tocar(tester, find.text('Llamar a Rosa'));
    expect(llamadas, [null]);
    await verHasta(tester, find.text('Si no contesta, pide ayuda cerca'));
    expect(find.text('Qué hacer ahora'), findsOneWidget);
    expect(find.text('Llama a Rosa'), findsOneWidget);
    expect(
      find.text(
        'A un vecino o a quien esté más cerca de San Miguel. Emergencias: SAMU 106 o Bomberos 116.',
      ),
      findsOneWidget,
    );
    await verHasta(
      tester,
      find.text(
        'Aviso enviado a Carmen (principal) y Luis, 6 s después de la caída',
      ),
    );
    expect(find.text('Caída detectada en la Sala'), findsOneWidget);
    expect(find.text('Marcar alerta'), findsOneWidget);
  });

  testWidgets('muestra cuánto tiempo pasó desde la caída', (tester) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
      ahora: DateTime(2026, 9, 23, 10, 44, 10),
    );
    expect(find.text('2 min'), findsOneWidget);
  });

  testWidgets(
    'CA-16.4: la alerta activa se ve al abrir aunque el envío haya fallado',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.inicio,
        alertas: AlertasRepositorioFalso([caidaSala(sinNotificar: true)]),
      );
      expect(find.byType(PantallaAlerta), findsOneWidget);
      expect(
        find.text('Esta alerta no te llegó como notificación'),
        findsOneWidget,
      );
      await verHasta(
        tester,
        find.text('La notificación no se pudo entregar; reintentando el envío'),
      );
      expect(
        find.text('La notificación no se pudo entregar; reintentando el envío'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'si el backend dejó de reintentar no dice «Seguimos reintentando»',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([
          caidaSala(sinNotificar: true, estadoAviso: EstadoAviso.noEntregado),
        ]),
      );
      expect(
        find.text('Esta alerta no te llegó como notificación'),
        findsOneWidget,
      );
      expect(find.textContaining('Seguimos reintentando'), findsNothing);
      await verHasta(tester, find.text('La notificación no se pudo entregar'));
      expect(
        find.text('La notificación no se pudo entregar; reintentando el envío'),
        findsNothing,
      );
    },
  );

  testWidgets('mientras se envía, o sin estado del backend, no avisa nada', (
    tester,
  ) async {
    for (final estado in [EstadoAviso.enviando, null]) {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([
          Alerta(
            id: 'a-1',
            tipo: TipoAlerta.caida,
            estado: EstadoAlerta.activa,
            camaraId: 'c1',
            habitacion: 'Sala',
            ocurridaEn: DateTime(2026, 9, 23, 10, 42),
            estadoAviso: estado,
          ),
        ]),
      );
      expect(
        find.text('Esta alerta no te llegó como notificación'),
        findsNothing,
        reason: '$estado',
      );
      expect(find.textContaining('reintentando'), findsNothing);
    }
  });

  testWidgets('al cerrarla, el inicio sigue mostrando la alerta activa', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.inicio,
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tester.tap(find.byTooltip('Cerrar la alerta y volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAlerta), findsNothing);
    expect(find.text('Posible caída en la Sala'), findsOneWidget);
    expect(
      find.textContaining('Alerta activa desde las 10:42', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Alerta de caída activa'), findsOneWidget);
    expect(
      find.text(
        'Caída en la Sala a las 10:42. Aún nadie la marcó como atendida.',
      ),
      findsOneWidget,
    );
    expect(find.byType(Badge), findsOneWidget);
    await tocar(tester, find.text('Ver la alerta'));
    expect(find.byType(PantallaAlerta), findsOneWidget);
  });

  testWidgets(
    'CA-16.2: tocar la notificación con la app cerrada abre la alerta',
    (tester) async {
      final push = NotificacionesPushFalsas(
        mensajeInicial: const MensajePush(
          tipo: TipoPush.alertaCaida,
          alertaId: 'a-1',
        ),
      );
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.arranque,
        alertas: AlertasRepositorioFalso([caidaSala()]),
        push: push,
      );
      expect(find.text('Rosa pudo haberse caído'), findsOneWidget);
    },
  );

  testWidgets('con la app abierta, una caída nueva ocupa toda la pantalla', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso();
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.familia,
      alertas: alertas,
      push: push,
    );
    alertas.alertas = [caidaSala()];
    push.recibir(
      const MensajePush(tipo: TipoPush.alertaCaida, alertaId: 'a-1'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAlerta), findsOneWidget);
    expect(find.text('Rosa pudo haberse caído'), findsOneWidget);
  });

  group('AlertasRepositorioApi', () {
    ProviderContainer contenedor(AdaptadorFalso http) {
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    const json = {
      'id': 'a-1',
      'tipo': 'CAIDA',
      'severidad': 'ALTA',
      'estado': 'ACTIVA',
      'confirmada': true,
      'camaraId': 'c1',
      'habitacion': 'Sala',
      'ocurridaEn': '2026-09-23T15:42:00Z',
      'notificadaEn': null,
      'estadoAviso': 'REINTENTANDO',
      'recuperadaEn': null,
      'atendidaPor': null,
      'atendidaEn': null,
      'escaladaEn': null,
      'origenInestable': false,
      'clip': 'NO_DISPONIBLE',
    };

    test('GET /api/alertas/{id} lee la Alerta del contrato', () async {
      final http = AdaptadorFalso()
        ..cuando('GET', '/api/alertas/a-1', const Respuesta(200, json));
      final a = await contenedor(
        http,
      ).read(alertasRepositorioProvider).obtener('a-1');
      expect(a.tipo, TipoAlerta.caida);
      expect(a.sigueEnElSuelo, isTrue);
      expect(a.notificadaEn, isNull);
      expect(a.estadoAviso, EstadoAviso.reintentando);
      expect(a.avisoReintentando, isTrue);
      expect(a.clip, EstadoClip.noDisponible);
    });

    test('la alerta activa se pide con estado=ACTIVA', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/alertas',
          const Respuesta(200, {
            'elementos': [json],
            'total': 1,
          }),
        );
      final c = contenedor(http);
      final a = await c.read(alertaActivaProvider.future);
      expect(a?.id, 'a-1');
      expect(http.peticiones.single.queryParameters, {
        'estado': 'ACTIVA',
        'pagina': 0,
        'tamano': 1,
      });
    });
  });
}
