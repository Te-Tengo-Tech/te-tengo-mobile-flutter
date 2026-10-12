import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../alertas/alertas_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'repositorio_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;
  late NotificacionesPushFalsas push;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesionTitular,
        push: push,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 41, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Camara noConfiable({DateTime? desde}) => Camara(
    id: 'c1',
    nombreHabitacion: 'Sala',
    estado: EstadoConexion.enLinea,
    ultimaSenal: DateTime(2026, 9, 23, 10, 41),
    deteccionConfiable: false,
    noConfiableDesde: desde,
  );

  setUp(() {
    camaras = CamarasRepositorioFalso();
    push = NotificacionesPushFalsas();
  });

  testWidgets(
    'CA-15.3: llega el aviso de que la detección no es confiable y qué revisar',
    (tester) async {
      await abrir(tester, Rutas.inicio);
      camaras.camaras = [noConfiable()];
      push.recibir(
        const MensajePush(
          tipo: TipoPush.deteccionNoConfiable,
          camaraId: 'c1',
          habitacion: 'Sala',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('La detección no es confiable en la Sala'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Hace más de 5 minutos que la cámara no ve bien a Rosa. Revisa la '
          'luz y el encuadre.',
        ),
        findsOneWidget,
      );
      // The home card and the «Cámaras» tile show it too.
      expect(find.text('La detección no es confiable'), findsOneWidget);
      expect(
        find.text('Hace más de 5 min que no ve bien a Rosa.'),
        findsOneWidget,
      );
      expect(find.text('Detección no confiable'), findsOneWidget);
      await tester.tap(find.text('La detección no es confiable en la Sala'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaCamara), findsOneWidget);
    },
  );

  testWidgets('CA-15.3: el detalle de la cámara dice qué revisar', (
    tester,
  ) async {
    camaras.camaras = [noConfiable(desde: DateTime(2026, 9, 23, 10, 36))];
    await abrir(tester, Rutas.inicio);
    await tocar(tester, find.text('Ver qué revisar'));
    expect(find.text('Detección no confiable'), findsOneWidget);
    await tocar(tester, find.text('Qué revisar'));
    expect(find.text('La luz'), findsOneWidget);
    expect(find.text('De noche, una lámpara pequeña'), findsOneWidget);
    expect(find.text('El encuadre'), findsOneWidget);
    expect(find.text('Que se vea a Rosa de cuerpo entero'), findsOneWidget);
    // It can still be paused.
    await tocar(tester, find.text('Ajustes de la cámara'));
    expect(find.text('Pausar'), findsOneWidget);
  });
}
