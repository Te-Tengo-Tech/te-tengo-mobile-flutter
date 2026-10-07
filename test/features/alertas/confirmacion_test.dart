import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/push_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  testWidgets(
    'CA-13.1: tras 30 s en el suelo la caída queda confirmada y sigue activa',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([caidaSala(confirmada: true)]),
        ahora: DateTime(2026, 9, 23, 10, 43, 10),
      );
      expect(find.text('Rosa se cayó y sigue en el suelo'), findsOneWidget);
      expect(find.text('Sigue en el suelo · confirmada'), findsOneWidget);
      expect(find.text('Comprobando si sigue en el suelo'), findsNothing);
      expect(find.text('1 min'), findsOneWidget);
      await verHasta(tester, find.text('Sigue en el suelo: caída confirmada'));
      expect(
        find.text(
          'Pasaron 30 segundos y Rosa no se ha levantado. La alerta sigue activa '
          'hasta que alguien la marque. Si se pone de pie, te avisaremos.',
        ),
        findsOneWidget,
      );
      await verHasta(
        tester,
        find.text('Sigue en el suelo tras 30 s: caída confirmada'),
      );
      expect(find.text('Marcar alerta'), findsOneWidget);
    },
  );

  testWidgets(
    'el chip pasa de «Comprobando» a «confirmada» con el aviso del sistema',
    (tester) async {
      final alertas = AlertasRepositorioFalso([caidaSala()]);
      final push = NotificacionesPushFalsas();
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: alertas,
        push: push,
      );
      expect(find.text('Comprobando si sigue en el suelo'), findsOneWidget);
      alertas.alertas = [caidaSala(confirmada: true)];
      push.recibir(
        const MensajePush(tipo: TipoPush.caidaConfirmada, alertaId: 'a-1'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sigue en el suelo · confirmada'), findsOneWidget);
      expect(find.text('Rosa sigue en el suelo'), findsNothing);
    },
  );

  testWidgets('sin aviso, la alerta abierta se actualiza sola', (tester) async {
    final alertas = AlertasRepositorioFalso([caidaSala()]);
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
    );
    alertas.alertas = [caidaSala(confirmada: true)];
    await tester.pump(PantallaAlerta.refresco);
    await tester.pumpAndSettle();
    expect(find.text('Sigue en el suelo · confirmada'), findsOneWidget);
  });

  testWidgets(
    'fuera de la alerta, la confirmación llega como aviso en la app',
    (tester) async {
      final alertas = AlertasRepositorioFalso([caidaSala()]);
      final push = NotificacionesPushFalsas();
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.inicio,
        alertas: alertas,
        push: push,
      );
      await tester.tap(find.byTooltip('Cerrar la alerta y volver al inicio'));
      await tester.pumpAndSettle();
      alertas.alertas = [caidaSala(confirmada: true)];
      push.recibir(
        const MensajePush(tipo: TipoPush.caidaConfirmada, alertaId: 'a-1'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rosa sigue en el suelo'), findsOneWidget);
      expect(
        find.text('Caída confirmada a las 10:42. La alerta sigue activa.'),
        findsOneWidget,
      );
      expect(find.text('Caída confirmada en la Sala'), findsOneWidget);
      await tester.tap(find.text('Rosa sigue en el suelo'));
      await tester.pumpAndSettle();
      expect(find.text('Rosa se cayó y sigue en el suelo'), findsOneWidget);
    },
  );
}
