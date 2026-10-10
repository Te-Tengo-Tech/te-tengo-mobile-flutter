import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/botones.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import 'hogar_falso.dart';

void main() {
  late HogarRepositorioFalso hogar;
  late NotificacionesPushFalsas push;

  Future<void> abrir(
    WidgetTester tester, {
    Sesion sesion = sesionTitular,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.privacidad,
        sesion: sesion,
        push: push,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(hogar),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso([
              caidaSala(id: 'h1', estado: EstadoAlerta.atendida),
              caidaSala(
                id: 'h2',
                estado: EstadoAlerta.atendida,
                clip: EstadoClip.eliminado,
              ),
              caidaSala(id: 'h3', estado: EstadoAlerta.falsaAlarma),
            ]),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 50)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    hogar = HogarRepositorioFalso();
    push = NotificacionesPushFalsas();
  });

  testWidgets(
    'la privacidad muestra la constancia y cómo se cuidan los datos',
    (tester) async {
      await abrir(tester);
      expect(find.text('Constancia de consentimiento'), findsOneWidget);
      expect(find.text('3 ago 2026'), findsOneWidget);
      await verHasta(tester, find.text('Reconocimiento facial'));
      expect(
        find.text('Se guardan 30 días y luego se eliminan'),
        findsOneWidget,
      );
      expect(find.text('No se usa'), findsOneWidget);
      expect(
        find.text('Registro de accesos a la vista en vivo'),
        findsOneWidget,
      );
      await verHasta(tester, find.text('Revocar consentimiento'));
      expect(
        find.textContaining('privacidad@tetengo.pe', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CA-09.2: si no confirma, el consentimiento y la captura siguen activos',
    (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Revocar consentimiento'));
      expect(find.text('¿Revocar el consentimiento?'), findsOneWidget);
      expect(
        find.text(
          'La cámara de la Sala dejará de capturar de inmediato, ya no se podrá ver en vivo y se '
          'eliminarán las grabaciones guardadas. Nadie de la familia recibirá más alertas de '
          'caída. Esta acción no se puede deshacer.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar, mantenerlo'));
      await tester.pumpAndSettle();
      expect(hogar.revocaciones, 0);
      expect(find.text('Tu consentimiento sigue vigente'), findsOneWidget);
      expect(find.text('La cámara sigue detectando caídas.'), findsOneWidget);
      expect(find.text('Revocar consentimiento'), findsOneWidget);
    },
  );

  testWidgets(
    'CA-09.1 y CA-09.3: revoca, elimina las grabaciones y lo confirma',
    (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Revocar consentimiento'));
      await tester.tap(find.text('Sí, revocar y eliminar'));
      // The deletion spinner keeps animating: pump frames instead of settling.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(hogar.revocaciones, 1);
      expect(find.text('Revocando el consentimiento'), findsOneWidget);
      expect(
        find.text('No cierres la app. Esto toma unos segundos.'),
        findsOneWidget,
      );
      expect(find.text('Captura detenida'), findsOneWidget);
      expect(
        find.textContaining(
          'La cámara de la Sala dejó de capturar a las 10:50',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Eliminando las grabaciones…'), findsOneWidget);
      expect(find.text('2 clips guardados'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(
        tester
            .widget<Boton>(find.widgetWithText(Boton, 'Volver al inicio'))
            .alPresionar,
        isNull,
      );

      push.recibir(
        MensajePush(
          tipo: TipoPush.datosEliminados,
          ocurridaEn: DateTime(2026, 9, 23, 10, 51),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Consentimiento revocado'), findsOneWidget);
      expect(
        find.text(
          'La captura se detuvo y las grabaciones se eliminaron. Te enviamos la constancia a carmen.huaman@gmail.com.',
        ),
        findsOneWidget,
      );
      expect(find.text('Grabaciones eliminadas'), findsOneWidget);
      expect(
        find.textContaining(
          '2 clips borrados de forma permanente a las 10:51',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Enviada'), findsOneWidget);
      await tocar(tester, find.text('Volver al inicio'));
      expect(find.text('Detección detenida'), findsOneWidget);
      expect(
        find.text('Revocaste el consentimiento. No hay captura ni alertas.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '404 SIN_CONSENTIMIENTO: si ya estaba revocado, muestra que no hay consentimiento',
    (tester) async {
      await abrir(tester);
      expect(find.text('Constancia de consentimiento'), findsOneWidget);
      // Revoked meanwhile from another phone: the backend has no current consent.
      final c = hogar.hogar.consentimiento!;
      hogar
        ..errorRevocar = const ProblemaApi(
          codigo: 'SIN_CONSENTIMIENTO',
          detalle: 'No hay un consentimiento vigente.',
          estado: 404,
        )
        ..hogar = Hogar(
          hogarId: 'h-1',
          adultoMayor: rosa,
          rol: Rol.titular,
          consentimiento: Consentimiento(
            otorgadoEn: c.otorgadoEn,
            otorgadoPor: c.otorgadoPor,
            registradoPor: c.registradoPor,
            vistaEnVivoAceptada: true,
            vigente: false,
          ),
        );
      await tocar(tester, find.text('Revocar consentimiento'));
      await tester.tap(find.text('Sí, revocar y eliminar'));
      await tester.pumpAndSettle();
      expect(hogar.revocaciones, 1);
      expect(find.text('Revocando el consentimiento'), findsNothing);
      await tester.drag(
        find.byType(Scrollable).hitTestable().first,
        const Offset(0, 3000),
      );
      await tester.pumpAndSettle();
      expect(find.text('No hay un consentimiento vigente.'), findsNothing);
      expect(find.text('Sin consentimiento'), findsOneWidget);
      expect(
        find.text(
          'Revocado. La cámara no captura y las grabaciones fueron eliminadas.',
        ),
        findsOneWidget,
      );
      expect(find.text('Constancia de consentimiento'), findsNothing);
      expect(find.text('Revocar consentimiento'), findsNothing);
    },
  );

  testWidgets('un familiar invitado no puede revocar', (tester) async {
    await abrir(tester, sesion: sesionInvitado);
    await verHasta(
      tester,
      find.text(
        'Solo Carmen (titular) puede revocar el consentimiento. Si Rosa quiere retirarlo, avísale.',
      ),
    );
    expect(find.text('Revocar consentimiento'), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
  });

  test('DELETE /api/hogar/consentimiento', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'DELETE',
        '/api/hogar/consentimiento',
        const Respuesta(202, {'eliminacionProgramada': true}),
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
    await c.read(hogarRepositorioProvider).revocarConsentimiento();
    expect(http.peticiones.single.method, 'DELETE');
  });
}
