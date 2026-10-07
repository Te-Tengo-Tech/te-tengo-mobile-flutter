import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../familia/familia_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  final escalada = DateTime(2026, 9, 23, 10, 47);

  FamiliaRepositorioFalso sinSecundario() =>
      FamiliaRepositorioFalso([carmen])
        ..avisoActual = const ConfiguracionAviso(principalId: 'u-carmen');

  testWidgets('antes de escalar dice a quién y a qué hora se avisará', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await verHasta(
      tester,
      find.textContaining('antes de las 10:47', findRichText: true),
    );
    expect(
      find.textContaining(
        'Si nadie la marca como atendida antes de las 10:47, avisaremos a '
        'Luis Huamán (contacto secundario).',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'CA-20.1: sin respuesta en el tiempo de espera, se avisa al secundario',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([caidaSala(escaladaEn: escalada)]),
        ahora: DateTime(2026, 9, 23, 10, 48),
      );
      await verHasta(tester, find.text('Avisamos a Luis Huamán'));
      expect(
        find.textContaining(
          'Nadie marcó la alerta en 5 minutos, así que a las 10:47 se la '
          'enviamos al contacto secundario. Tú todavía puedes atenderla.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await verHasta(
        tester,
        find.text(
          'Sin respuesta en 5 min: aviso urgente a Luis Huamán (secundario)',
        ),
      );
    },
  );

  testWidgets('CA-20.1: el contacto secundario ve que le toca atenderla', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala(escaladaEn: escalada)]),
      sesion: sesionInvitado,
      ahora: DateTime(2026, 9, 23, 10, 48),
    );
    await verHasta(tester, find.text('Te toca atenderla'));
    expect(
      find.textContaining(
        'a las 10:47 te avisamos como contacto secundario.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Marcar alerta'), findsOneWidget);
  });

  testWidgets(
    'CA-20.2: si se atendió a tiempo, no hizo falta avisar al secundario',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.detalleAlerta('a-1'),
        alertas: AlertasRepositorioFalso([
          caidaSala(
            estado: EstadoAlerta.atendida,
            atendidaPor: 'Carmen Huamán',
            atendidaPorId: 'u-carmen',
            atendidaEn: DateTime(2026, 9, 23, 10, 44),
          ),
        ]),
      );
      await verHasta(
        tester,
        find.text(
          'Se atendió antes de los 5 min: no hizo falta avisar a Luis '
          '(secundario)',
        ),
      );
      expect(find.textContaining('aviso urgente'), findsNothing);
    },
  );

  testWidgets(
    'CA-20.3: sin contacto secundario, la alerta sigue con el principal',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([caidaSala(escaladaEn: escalada)]),
        familia: sinSecundario(),
        ahora: DateTime(2026, 9, 23, 10, 48),
      );
      await verHasta(tester, find.text('No hay a quién escalar'));
      expect(
        find.text(
          'Pasaron 5 minutos sin respuesta y no hay contacto secundario. Esta '
          'alerta sigue siendo tuya.',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.text('Agregar contacto secundario'));
      expect(find.text('Invitar a un familiar'), findsWidgets);
    },
  );

  testWidgets('CA-20.3: antes de escalar avisa que no hay secundario', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
      familia: sinSecundario(),
    );
    await verHasta(tester, find.text('Sin contacto secundario'));
    expect(
      find.text(
        'Si nadie atiende esta alerta, no habrá nadie más a quién avisar.',
      ),
      findsOneWidget,
    );
    expect(find.text('Agregar contacto'), findsOneWidget);
  });

  testWidgets('fuera de la alerta, llega el aviso de escalamiento', (
    tester,
  ) async {
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.ajustes,
      alertas: AlertasRepositorioFalso([
        caidaSala(estado: EstadoAlerta.atendida, escaladaEn: escalada),
      ]),
      push: push,
    );
    push.recibir(
      const MensajePush(tipo: TipoPush.alertaEscalada, alertaId: 'a-1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alerta escalada a Luis Huamán'), findsOneWidget);
    expect(
      find.text('Nadie la marcó en 5 min. Tú todavía puedes atenderla.'),
      findsOneWidget,
    );
  });

  testWidgets('el secundario recibe el aviso de que le toca', (tester) async {
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.ajustes,
      alertas: AlertasRepositorioFalso([
        caidaSala(estado: EstadoAlerta.atendida, escaladaEn: escalada),
      ]),
      sesion: sesionInvitado,
      push: push,
    );
    push.recibir(
      const MensajePush(tipo: TipoPush.alertaEscalada, alertaId: 'a-1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nadie atendió la alerta: te toca'), findsOneWidget);
    expect(
      find.text('Pasaron 5 min sin respuesta. Eres el contacto secundario.'),
      findsOneWidget,
    );
  });

  testWidgets('SIN_CONTACTO_SECUNDARIO avisa que la alerta sigue siendo tuya', (
    tester,
  ) async {
    final push = NotificacionesPushFalsas();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.ajustes,
      alertas: AlertasRepositorioFalso([
        caidaSala(estado: EstadoAlerta.atendida),
      ]),
      familia: sinSecundario(),
      push: push,
    );
    push.recibir(
      const MensajePush(tipo: TipoPush.sinContactoSecundario, alertaId: 'a-1'),
    );
    await tester.pumpAndSettle();
    expect(find.text('No hay contacto secundario'), findsOneWidget);
    expect(
      find.text('Pasaron 5 min sin respuesta. La alerta sigue siendo tuya.'),
      findsOneWidget,
    );
  });
}
