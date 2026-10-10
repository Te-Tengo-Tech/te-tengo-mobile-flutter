import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/ajustes/data/preferencias.dart';
import 'package:te_tengo/features/ajustes/presentation/pantalla_notificaciones.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../../apoyo/push_falso.dart';
import '../alertas/alertas_falso.dart';
import '../alertas/apoyo_alertas.dart';
import '../camaras/repositorio_falso.dart';

void main() {
  late AlmacenPreferenciasMemoria preferencias;
  late NotificacionesPushFalsas push;

  Future<AlertasRepositorioFalso> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    List<Alerta> alertas = const [],
    bool permiso = true,
  }) async {
    final repo = AlertasRepositorioFalso([...alertas]);
    await abrirConAlertas(
      tester,
      ubicacion: ubicacion,
      alertas: repo,
      sesion: sesion,
      push: push,
      permiso: PermisoFalso(activas: permiso),
      overrides: [almacenPreferenciasProvider.overrideWithValue(preferencias)],
    );
    return repo;
  }

  setUp(() {
    preferencias = AlmacenPreferenciasMemoria();
    push = NotificacionesPushFalsas(tokenActual: 'fcm-1');
  });

  testWidgets(
    'con permiso pero sin registro en el backend no dice que llegarán',
    (tester) async {
      push.errorToken = Exception('messaging/token-subscribe-failed');
      await abrir(tester, Rutas.notificaciones);
      expect(find.text('Notificaciones activadas'), findsNothing);
      expect(
        find.text('Recibirás las alertas aunque tengas la app cerrada.'),
        findsNothing,
      );
      expect(find.text('Este celular no recibe las alertas'), findsOneWidget);
      expect(find.text('Activar notificaciones'), findsOneWidget);
    },
  );

  testWidgets('desde Ajustes abre las preferencias de este celular', (
    tester,
  ) async {
    await abrir(tester, Rutas.ajustes);
    expect(find.text('Activadas en este celular'), findsOneWidget);
    await tocar(tester, find.text('Notificaciones'));
    expect(find.byType(PantallaNotificaciones), findsOneWidget);
    expect(find.text('Notificaciones activadas'), findsOneWidget);
    expect(
      find.text('Recibirás las alertas aunque tengas la app cerrada.'),
      findsOneWidget,
    );
    expect(find.text('Qué te avisamos en este celular'), findsOneWidget);
    expect(
      find.text('Siempre activas. No se pueden silenciar.'),
      findsOneWidget,
    );
    expect(find.text('Severidad media'), findsOneWidget);
    expect(
      find.text(
        'Desconectada, reconectada o detección no confiable. Siempre activas, '
        'para que Rosa no quede sin monitoreo.',
      ),
      findsOneWidget,
    );
    final interruptores = tester.widgetList<Switch>(find.byType(Switch));
    expect(interruptores.map((s) => s.value), [true, true, true, true]);
    // Falls and camera state cannot be turned off.
    expect(interruptores.map((s) => s.onChanged != null), [
      false,
      true,
      false,
      true,
    ]);
    await verHasta(tester, find.text('Esperar 5 minutos antes de escalar'));
    expect(
      find.text('Se define en el orden de aviso de la familia'),
      findsOneWidget,
    );
  });

  testWidgets('silenciar los movimientos inestables se guarda y no abre la '
      'alerta sola', (tester) async {
    await abrir(
      tester,
      Rutas.notificaciones,
      alertas: [caidaSala(tipo: TipoAlerta.movimientoInestable)],
    );
    // An active alert opens by itself; go back to the preferences.
    if (find.byType(PantallaAlerta).evaluate().isNotEmpty) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect((await preferencias.cargar()).inestables, isFalse);
    push.recibir(
      const MensajePush(
        tipo: TipoPush.alertaMovimientoInestable,
        alertaId: 'a-2',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaAlerta), findsNothing);
  });

  testWidgets('sin «Fin de una pausa» no llega el aviso de reactivación', (
    tester,
  ) async {
    preferencias = AlmacenPreferenciasMemoria(
      const PreferenciasNotificaciones(finPausa: false),
    );
    await abrir(tester, Rutas.ajustes);
    push.recibir(
      MensajePush(
        tipo: TipoPush.pausaFinalizada,
        camaraId: camaraSala.id,
        habitacion: 'Sala',
        ocurridaEn: DateTime(2026, 9, 23, 11, 42),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('La cámara de la Sala se reactivó'), findsNothing);
  });

  testWidgets('sin permiso ofrece activarlas', (tester) async {
    await abrir(tester, Rutas.notificaciones, permiso: false);
    expect(find.text('Desactivadas en tu celular'), findsOneWidget);
    expect(find.text('Activar notificaciones'), findsOneWidget);
  });

  testWidgets('el invitado ve el escalamiento con candado', (tester) async {
    await abrir(tester, Rutas.notificaciones, sesion: sesionInvitado);
    await verHasta(tester, find.text('Esperar 5 minutos antes de escalar'));
    expect(find.byType(Switch), findsNWidgets(4));
  });
}
