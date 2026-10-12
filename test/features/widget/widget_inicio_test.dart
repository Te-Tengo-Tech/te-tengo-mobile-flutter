import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/app.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/camaras_en_casa.dart';
import 'package:te_tengo/features/pcs/presentation/pantalla_camaras.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/presentation/elegir_habitacion.dart';
import 'package:te_tengo/features/widget/data/widget_sistema.dart';
import 'package:te_tengo/features/widget/domain/estado_widget.dart';
import 'package:te_tengo/features/widget/presentation/pasos_widget.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/camaras_y_pcs_test.dart' show casaDeRosa, camara;
import '../pcs/pcs_falso.dart';
import '../vivo/vivo_falso.dart';

class _WidgetFalso implements WidgetDelSistema {
  final mostrados = <EstadoWidget>[];
  final toquesCtl = StreamController<Uri?>.broadcast();
  Uri? inicial;

  @override
  bool get disponible => true;

  @override
  Future<void> mostrar(EstadoWidget estado, DateTime actualizado) async =>
      mostrados.add(estado);

  @override
  Future<EstadoWidget?> leer() async => mostrados.lastOrNull;

  @override
  Future<Uri?> abiertaDesde() async => inicial;

  @override
  Stream<Uri?> get toques => toquesCtl.stream;
}

void main() {
  group('lo que muestra el widget (CA-44.1)', () {
    List<CamaraEnCasa> enCasa(List<Camara> camaras) =>
        camarasEnCasa(camaras, const [], conConsentimiento: true);

    test('«Todo tranquilo · 4 cámaras», sin imágenes', () {
      final e = estadoDelHogar(
        alerta: null,
        camaras: enCasa(casaDeRosa().camaras),
        conConsentimiento: true,
        nombreAdulto: 'Rosa Huamán',
      );
      expect(e.tono, TonoWidget.calma);
      expect(e.titulo, 'Todo tranquilo');
      expect(e.linea, '4 cámaras');
      expect(e.iniciales, 'RH');
      expect(e.destino, Rutas.inicio);
    });

    test('«Posible caída · Sala · 10:42» abre la alerta', () {
      final e = estadoDelHogar(
        alerta: caidaSala(ocurridaEn: DateTime(2026, 9, 23, 10, 41)),
        camaras: enCasa(casaDeRosa().camaras),
        conConsentimiento: true,
        nombreAdulto: 'Rosa Huamán',
      );
      expect(e.tono, TonoWidget.caida);
      expect(e.titulo, 'Posible caída');
      expect(e.linea, 'Sala · 10:41');
      expect(e.destino, Rutas.alerta('a-1'));
      final inestable = estadoDelHogar(
        alerta: caidaSala(tipo: TipoAlerta.movimientoInestable),
        camaras: const [],
        conConsentimiento: true,
        nombreAdulto: 'Rosa',
      );
      expect(inestable.titulo, 'Movimiento inestable');
      expect(inestable.tono, TonoWidget.inestable);
    });

    test('«1 cámara no responde · Cocina» abre Cámaras', () {
      final e = estadoDelHogar(
        alerta: null,
        camaras: enCasa([
          camara('c1', 'Sala', 'pc-sala'),
          camara(
            'c4',
            'Cocina',
            'pc-cocina',
            estado: EstadoConexion.desconectada,
          ),
        ]),
        conConsentimiento: true,
        nombreAdulto: 'Rosa',
      );
      expect(e.tono, TonoWidget.aviso);
      expect(e.titulo, '1 cámara no responde');
      expect(e.linea, 'Cocina');
      expect(e.destino, Rutas.pcs);
    });

    test('sin cámaras o sin consentimiento', () {
      expect(
        estadoDelHogar(
          alerta: null,
          camaras: const [],
          conConsentimiento: true,
          nombreAdulto: 'Rosa',
        ).titulo,
        'Sin cámaras',
      );
      expect(
        estadoDelHogar(
          alerta: null,
          camaras: enCasa(casaDeRosa().camaras),
          conConsentimiento: false,
          nombreAdulto: 'Rosa',
        ).linea,
        'Falta el consentimiento',
      );
    });

    test('un push de alerta con la app cerrada lo cambia; otros no', () {
      const antes = EstadoWidget(
        tono: TonoWidget.calma,
        titulo: 'Todo tranquilo',
        linea: '4 cámaras',
        destino: '/inicio',
        iniciales: 'RH',
      );
      final caida = estadoDesdePush({
        'tipo': 'ALERTA_CAIDA',
        'alertaId': 'a-9',
        'habitacion': 'Cocina',
        'ocurridaEn': '2026-09-23T15:41:00Z',
      }, anterior: antes)!;
      expect(caida.titulo, 'Posible caída');
      expect(caida.linea, startsWith('Cocina · '));
      expect(caida.destino, Rutas.alerta('a-9'));
      expect(caida.iniciales, 'RH');
      expect(
        estadoDesdePush({'tipo': 'CAMARA_DESCONECTADA'}, anterior: antes),
        isNull,
      );
      // Signed out: nothing of the household.
      expect(
        estadoDesdePush({
          'tipo': 'ALERTA_CAIDA',
        }, anterior: EstadoWidget.sinSesion),
        isNull,
      );
    });

    test('solo se siguen rutas de la app', () {
      expect(
        Rutas.destinoDeWidget(Uri.parse('/?ir=%2Falerta%2Fa-1')),
        '/alerta/a-1',
      );
      expect(Rutas.destinoDeWidget(Uri.parse('/?ir=https://x.pe')), isNull);
      expect(Rutas.destinoDeWidget(Uri.parse('/?ir=//x.pe')), isNull);
      expect(Rutas.destinoDeWidget(Uri.parse('/inicio?ir=/pcs')), isNull);
    });
  });

  group('en la app', () {
    late _WidgetFalso sistema;
    late CamarasRepositorioFalso camaras;
    late PcsRepositorioFalso pcs;
    late VistaEnVivoRepositorioFalso vivo;

    setUp(() {
      sistema = _WidgetFalso();
      camaras = CamarasRepositorioFalso();
      pcs = PcsRepositorioFalso();
      vivo = VistaEnVivoRepositorioFalso();
      final casa = casaDeRosa();
      camaras.camaras = casa.camaras;
      pcs.pcs = casa.pcs;
    });

    Future<void> abrir(
      WidgetTester tester, {
      AlertasRepositorioFalso? alertas,
      String ubicacion = Rutas.inicio,
    }) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: ubicacion,
          sesion: sesionTitular,
          widget: sistema,
          overrides: [
            sesionRepositorioProvider.overrideWithValue(_SesionesFalsas()),
            camarasRepositorioProvider.overrideWithValue(camaras),
            pcsRepositorioProvider.overrideWithValue(pcs),
            vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
            hogarRepositorioProvider.overrideWithValue(
              HogarRepositorioFalso(hogarDeRosa()),
            ),
            alertasRepositorioProvider.overrideWithValue(
              alertas ?? AlertasRepositorioFalso(),
            ),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso(),
            ),
            relojProvider.overrideWithValue(
              () => DateTime(2026, 9, 23, 10, 42),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('guarda el estado que la app lee y lo cambia con una alerta', (
      tester,
    ) async {
      await abrir(tester);
      expect(sistema.mostrados.last.titulo, 'Todo tranquilo');
      expect(sistema.mostrados.last.linea, '4 cámaras');

      final alertas = AlertasRepositorioFalso([caidaSala()]);
      await abrir(tester, alertas: alertas, ubicacion: Rutas.historial);
      expect(sistema.mostrados.last.titulo, 'Posible caída');
      expect(sistema.mostrados.last.destino, Rutas.alerta('a-1'));
    });

    testWidgets('CA-44.3 al cerrar sesión no muestra datos de la casa', (
      tester,
    ) async {
      await abrir(tester);
      final contenedor = ProviderScope.containerOf(
        tester.element(find.byType(TeTengoApp)),
      );
      await contenedor.read(sesionControllerProvider.notifier).cerrar();
      await tester.pumpAndSettle();
      expect(sistema.mostrados.last, EstadoWidget.sinSesion);
      expect(sistema.mostrados.last.linea, 'Abre la app para ver el estado.');
    });

    testWidgets('CA-44.2 tocarlo abre lo que dice: Cámaras', (tester) async {
      await abrir(tester);
      sistema.toquesCtl.add(Uri.parse('tetengo-widget://abrir?ir=%2Fpcs'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaCamaras), findsOneWidget);
    });

    testWidgets('CA-44.2 «Ver en vivo» abre la hoja de habitaciones y nunca la '
        'vista en vivo por sí solo', (tester) async {
      camaras.camaras = [camara('c1', 'Sala', 'pc-sala')];
      await abrir(tester, ubicacion: Rutas.historial);
      sistema.toquesCtl.add(
        Uri.parse('tetengo-widget://abrir?ir=%2Finicio&vivo=1'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HojaElegirHabitacion), findsOneWidget);
      // One camera: no «Ver todas a la vez».
      expect(find.text('Ver todas a la vez'), findsNothing);
      expect(vivo.abiertas, isEmpty);
    });

    testWidgets('abrir la app desde el widget lleva a la alerta', (
      tester,
    ) async {
      sistema.inicial = Uri.parse('tetengo-widget://abrir?ir=%2Falerta%2Fa-1');
      await abrir(tester, alertas: AlertasRepositorioFalso([caidaSala()]));
      expect(find.byType(PantallaAlerta), findsOneWidget);
    });

    testWidgets('Ajustes explica cómo agregarlo', (tester) async {
      await abrir(tester, ubicacion: Rutas.ajustes);
      await tocar(tester, find.text('Agregar el widget'));
      for (final p in PasosWidget.pasos) {
        expect(find.text(p), findsOneWidget);
      }
      expect(
        find.text('Muestra el estado, nunca imágenes de la casa.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('en la web no hay widget ni pasos en Ajustes', (tester) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.ajustes,
        sesion: sesionTitular,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Agregar el widget'), findsNothing);
  });
}

class _SesionesFalsas implements SesionRepositorio {
  @override
  Future<void> cerrar(String tokenAcceso) async {}

  @override
  Future<Sesion> cambiarHogar(String hogarId) => throw UnimplementedError();

  @override
  Future<List<HogarResumen>> hogares() async => [];
}
