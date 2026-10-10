import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/router.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/ui/iconos.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/push_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

Alerta inestable({bool comoCaida = false}) => caidaSala(
  tipo: comoCaida ? TipoAlerta.caida : TipoAlerta.movimientoInestable,
  ocurridaEn: DateTime(2026, 9, 23, 10, 39),
  origenInestable: comoCaida,
  confirmada: comoCaida,
);

void main() {
  testWidgets('CA-17.1: alerta de severidad media con habitación y hora', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([inestable()]),
      ahora: DateTime(2026, 9, 23, 10, 40, 10),
    );
    expect(find.text('INESTABLE · SEVERIDAD MEDIA'), findsOneWidget);
    expect(find.text('Rosa tuvo un movimiento inestable'), findsOneWidget);
    expect(find.text('Sala'), findsOneWidget);
    expect(find.text('10:39'), findsWidgets);
    expect(find.text('1 min'), findsOneWidget);
    expect(find.text('Comprobando si sigue en el suelo'), findsNothing);
    // No SAMU card for an unstable movement, and its clip is open from the start.
    expect(find.text('Llamar al SAMU · 106'), findsNothing);
    expect(find.text('12 s, antes y después'), findsNothing);
    await tocar(tester, find.text('Más detalles'));
    expect(
      find.text(
        'No es una caída. Si termina en una, te enviamos una alerta urgente.',
      ),
      findsOneWidget,
    );
    expect(find.text('Bomberos'), findsNothing);
  });

  testWidgets('CA-17.2: no comparte color, ícono ni etiqueta con una caída', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([inestable()]),
    );
    final iconos = tester
        .widgetList<Icono>(find.byType(Icono))
        .map((i) => i.icono);
    expect(iconos, contains(Ico.unsteady));
    expect(iconos, isNot(contains(Ico.fall)));
    expect(find.textContaining('CAÍDA'), findsNothing);
    await tester.tap(find.byTooltip('Cerrar la alerta y volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Movimiento inestable en la Sala'), findsOneWidget);
    expect(find.text('Movimiento inestable activo'), findsOneWidget);
  });

  testWidgets('CA-17.3: si termina en caída, la alerta se actualiza a caída', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso([inestable()]);
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      push: push,
      ahora: DateTime(2026, 9, 23, 10, 42),
    );
    expect(find.text('Rosa tuvo un movimiento inestable'), findsOneWidget);
    alertas.alertas = [inestable(comoCaida: true)];
    push.recibir(
      const MensajePush(
        tipo: TipoPush.alertaActualizadaACaida,
        alertaId: 'a-1',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAlerta), findsOneWidget);
    expect(find.text('CAÍDA · URGENTE'), findsOneWidget);
    expect(find.text('Rosa se cayó y sigue en el suelo'), findsOneWidget);
    await tocar(tester, find.text('Más detalles'));
    await verHasta(tester, find.text('Empezó como movimiento inestable'));
    expect(
      find.textContaining(
        'A las 10:39 en la Sala. La situación terminó en una caída.',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'una alerta abierta por un push se actualiza en su lugar, sin abrirse dos veces',
    (tester) async {
      final alertas = AlertasRepositorioFalso([inestable()]);
      final push = NotificacionesPushFalsas();
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.inicio,
        alertas: alertas,
        push: push,
        ahora: DateTime(2026, 9, 23, 10, 42),
      );
      await tester.tap(find.byTooltip('Cerrar la alerta y volver al inicio'));
      await tester.pumpAndSettle();
      push.recibir(
        const MensajePush(
          tipo: TipoPush.alertaMovimientoInestable,
          alertaId: 'a-1',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rosa tuvo un movimiento inestable'), findsOneWidget);
      alertas.alertas = [inestable(comoCaida: true)];
      push.recibir(
        const MensajePush(
          tipo: TipoPush.alertaActualizadaACaida,
          alertaId: 'a-1',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rosa se cayó y sigue en el suelo'), findsOneWidget);
      // One alert screen on the stack: going back leaves it.
      final router = ProviderScope.containerOf(
        tester.element(find.byType(PantallaAlerta)),
      ).read(routerProvider);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(PantallaAlerta), findsNothing);
    },
  );
}
