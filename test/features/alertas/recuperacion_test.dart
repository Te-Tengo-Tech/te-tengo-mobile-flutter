import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_detalle_alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/push_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  final levantada = DateTime(2026, 9, 23, 10, 45);

  MensajePush seLevanto() => MensajePush(
    tipo: TipoPush.seLevanto,
    alertaId: 'a-1',
    habitacion: 'Sala',
    ocurridaEn: levantada,
  );

  testWidgets('CA-21.1: en la alerta llega el aviso «se levantó» y la alerta '
      'sigue activa', (tester) async {
    final alertas = AlertasRepositorioFalso([caidaSala(confirmada: true)]);
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      push: push,
      ahora: levantada,
    );
    alertas.alertas = [caidaSala(confirmada: true, recuperadaEn: levantada)];
    push.recibir(seLevanto());
    await tester.pumpAndSettle();
    expect(find.text('Rosa se levantó'), findsWidgets);
    expect(
      find.text('10:45 · Se puso de pie en la Sala. Confirma cómo está.'),
      findsOneWidget,
    );
    expect(
      find.text('Se levantó a las 10:45', findRichText: true),
      findsOneWidget,
    );
    await tocar(tester, find.text('Más detalles'));
    expect(
      find.text(
        'Se puso de pie en la Sala. Confirma cómo está antes de marcar la '
        'alerta.',
      ),
      findsOneWidget,
    );
    expect(find.byType(PantallaAlerta), findsOneWidget);
    expect(find.text('Marcar alerta'), findsOneWidget);
  });

  testWidgets('CA-21.1: fuera de la alerta, el aviso la abre', (tester) async {
    final alertas = AlertasRepositorioFalso([
      caidaSala(
        confirmada: true,
        recuperadaEn: levantada,
        estado: EstadoAlerta.atendida,
      ),
    ]);
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.ajustes,
      alertas: alertas,
      push: push,
      ahora: levantada,
    );
    push.recibir(seLevanto());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rosa se levantó'));
    await tester.pumpAndSettle();
    // An alert that is no longer active opens as its detail.
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
  });

  testWidgets('CA-21.2: si sigue en el suelo no hay aviso y la caída sigue '
      'confirmada', (tester) async {
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala(confirmada: true)]),
      push: push,
    );
    push.recibir(
      const MensajePush(tipo: TipoPush.caidaConfirmada, alertaId: 'a-1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rosa se levantó'), findsNothing);
    expect(find.text('Sigue en el suelo · confirmada'), findsOneWidget);
  });
}
