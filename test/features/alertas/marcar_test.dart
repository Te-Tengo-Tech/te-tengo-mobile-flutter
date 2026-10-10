import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_detalle_alerta.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  Future<void> abrirHoja(WidgetTester tester) async {
    await tester.tap(find.text('Marcar alerta'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo terminó esta alerta?'), findsOneWidget);
  }

  testWidgets('CA-19.1: marcarla como atendida registra quién y a qué hora', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso([caidaSala(confirmada: true)]);
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      ahora: DateTime(2026, 9, 23, 10, 46),
    );
    await abrirHoja(tester);
    expect(
      find.textContaining('Caída en la Sala a las 10:42.', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Rosa recibió ayuda o está bien'), findsOneWidget);
    expect(
      find.text('No hubo caída. No contará en el resumen.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Quedará registrado: Carmen Huamán · 10:46',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Elige una opción.'), findsOneWidget);
    await tester.tap(find.text('Atendida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(alertas.marcadas, {'a-1': EstadoAlerta.atendida});
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
    expect(find.text('Alerta del mié 23 sep'), findsOneWidget);
    expect(find.text('Alerta atendida'), findsOneWidget);
    expect(
      find.text('La familia verá que la marcaste a las 10:46.'),
      findsOneWidget,
    );
    expect(find.text('ATENDIDA'), findsOneWidget);
    expect(find.text('Marcada como atendida'), findsOneWidget);
    expect(
      find.textContaining('por Carmen Huamán a las 10:46', findRichText: true),
      findsOneWidget,
    );
    await verHasta(tester, find.textContaining(' momentos'));
    await tocar(tester, find.text('Registro del evento'));
    await verHasta(
      tester,
      find.text('Marcada como atendida por Carmen Huamán'),
    );
    expect(
      find.text('Marcada como atendida por Carmen Huamán'),
      findsOneWidget,
    );
  });

  testWidgets('CA-19.2: la falsa alarma no cuenta en el resumen de caídas', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso([caidaSala()]);
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
    );
    await abrirHoja(tester);
    await tester.tap(find.text('Falsa alarma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(alertas.marcadas, {'a-1': EstadoAlerta.falsaAlarma});
    expect(find.text('Marcada como falsa alarma'), findsWidgets);
    expect(find.text('FALSA ALARMA'), findsOneWidget);
    expect(find.text('No cuenta en el resumen de caídas.'), findsOneWidget);
  });

  testWidgets('un familiar invitado también puede marcarla', (tester) async {
    final alertas = AlertasRepositorioFalso([caidaSala()])
      ..marcaNombre = 'Luis Huamán'
      ..marcaId = 'u-luis';
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      sesion: sesionInvitado,
    );
    await abrirHoja(tester);
    await tester.tap(find.text('Atendida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(alertas.marcadas, {'a-1': EstadoAlerta.atendida});
  });

  testWidgets(
    'CA-19.3: si otro familiar la atendió, se ve quién y a qué hora',
    (tester) async {
      final alertas = AlertasRepositorioFalso([caidaSala()]);
      final push = NotificacionesPushFalsas();
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: alertas,
        push: push,
      );
      expect(find.byType(PantallaAlerta), findsOneWidget);
      alertas.alertas = [
        caidaSala(
          estado: EstadoAlerta.atendida,
          atendidaPor: 'Luis Huamán',
          atendidaPorId: 'u-luis',
          atendidaEn: DateTime(2026, 9, 23, 10, 44),
        ),
      ];
      push.recibir(
        const MensajePush(tipo: TipoPush.alertaAtendida, alertaId: 'a-1'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
      // The card says who marked it and when; no notice repeats it.
      expect(find.text('Marcada como atendida'), findsOneWidget);
      expect(
        find.textContaining('por Luis Huamán a las 10:44', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CA-19.3: fuera de la alerta, llega un aviso con quién la atendió',
    (tester) async {
      final alertas = AlertasRepositorioFalso([
        caidaSala(
          estado: EstadoAlerta.atendida,
          atendidaPor: 'Luis Huamán',
          atendidaPorId: 'u-luis',
          atendidaEn: DateTime(2026, 9, 23, 10, 44),
        ),
      ]);
      final push = NotificacionesPushFalsas();
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.inicio,
        alertas: alertas,
        push: push,
      );
      push.recibir(
        const MensajePush(tipo: TipoPush.alertaAtendida, alertaId: 'a-1'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Luis atendió la alerta'), findsOneWidget);
      expect(find.text('10:44 · Caída en la Sala.'), findsOneWidget);
      await tester.tap(find.text('Luis atendió la alerta'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
    },
  );

  testWidgets('409 ALERTA_CERRADA lleva al detalle', (tester) async {
    final alertas = AlertasRepositorioFalso([caidaSala()])
      ..errorMarcar = const ProblemaApi(
        codigo: 'ALERTA_CERRADA',
        detalle: 'Otro familiar ya la marcó.',
        estado: 409,
      );
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
    );
    await abrirHoja(tester);
    await tester.tap(find.text('Atendida'));
    await tester.pumpAndSettle();
    alertas
      ..errorMarcar = null
      ..alertas = [
        caidaSala(
          estado: EstadoAlerta.atendida,
          atendidaPor: 'Luis Huamán',
          atendidaPorId: 'u-luis',
          atendidaEn: DateTime(2026, 9, 23, 10, 44),
        ),
      ]
      ..errorMarcar = const ProblemaApi(
        codigo: 'ALERTA_CERRADA',
        detalle: 'Otro familiar ya la marcó.',
        estado: 409,
      );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Otro familiar ya la marcó.'), findsOneWidget);
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
  });

  test('POST /api/alertas/{id}/atencion y /falsa-alarma', () async {
    const json = {
      'id': 'a-1',
      'tipo': 'CAIDA',
      'estado': 'ATENDIDA',
      'camaraId': 'c1',
      'habitacion': 'Sala',
      'ocurridaEn': '2026-09-23T15:42:00Z',
      'atendidaPor': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
      'atendidaEn': '2026-09-23T15:46:00Z',
      'clip': 'DISPONIBLE',
    };
    final http = AdaptadorFalso()
      ..cuando('POST', '/api/alertas/a-1/atencion', const Respuesta(200, json))
      ..cuando(
        'POST',
        '/api/alertas/a-1/falsa-alarma',
        Respuesta(200, Map.of(json)..['estado'] = 'FALSA_ALARMA'),
      );
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    final repo = c.read(alertasRepositorioProvider);
    final atendida = await repo.atender('a-1');
    expect(atendida.atendidaPor, 'Carmen Huamán');
    expect(atendida.atendidaPorId, 'u-carmen');
    expect(
      (await repo.marcarFalsaAlarma('a-1')).estado,
      EstadoAlerta.falsaAlarma,
    );
    expect(http.peticiones.map((p) => p.path), [
      '/api/alertas/a-1/atencion',
      '/api/alertas/a-1/falsa-alarma',
    ]);
  });
}
