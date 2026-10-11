import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../pcs/pcs_falso.dart';
import 'hogar_falso.dart';

void main() {
  late HogarRepositorioFalso repo;
  late PcsRepositorioFalso pcs;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(repo),
          pcsRepositorioProvider.overrideWithValue(pcs),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repo = HogarRepositorioFalso(hogarDeRosa(consentimiento: false));
    pcs = PcsRepositorioFalso();
  });

  testWidgets(
    'CA-05.4: el formulario indica la vista en vivo en cualquier momento',
    (tester) async {
      await abrir(tester, Rutas.configConsentimiento);
      expect(find.text('Paso 2 de 5'), findsOneWidget);
      // The live-view clause goes first and open; the others are folded.
      expect(
        find.textContaining('La familia vinculada puede verla en vivo'),
        findsOneWidget,
      );
      expect(find.text('Caídas por la postura'), findsOneWidget);
      expect(find.text('Cuando la familia quiera'), findsNothing);
      expect(find.text('Vista en vivo en cualquier momento'), findsOneWidget);
      await verHasta(tester, find.textContaining('que su familia la vea'));
      expect(
        find.textContaining('que su familia la vea en vivo cuando quiera'),
        findsOneWidget,
      );
    },
  );

  testWidgets('CA-05.4: solo se registra si se marcan las dos casillas', (
    tester,
  ) async {
    await abrir(tester, Rutas.configConsentimiento);
    await tocar(tester, find.text('Registrar consentimiento'));
    expect(find.text('Marca las dos casillas.'), findsOneWidget);
    await tocar(tester, find.text('Leí el resumen y el documento completo.'));
    await tocar(tester, find.text('Registrar consentimiento'));
    expect(repo.consentimientos, isEmpty);
  });

  testWidgets(
    'CA-05.1 y CA-05.3: registra el consentimiento y muestra la constancia con fecha y hora',
    (tester) async {
      await abrir(tester, Rutas.configConsentimiento);
      await tocar(tester, find.textContaining('Rosa fue informada y acepta'));
      await tocar(tester, find.text('Leí el resumen y el documento completo.'));
      await tocar(tester, find.text('Registrar consentimiento'));
      expect(repo.consentimientos, ['Rosa Huamán']);
      expect(find.text('Consentimiento registrado'), findsOneWidget);
      expect(find.text('Constancia de consentimiento'), findsOneWidget);
      expect(find.text('23 sep 2026'), findsOneWidget);
      expect(find.text('09:14'), findsOneWidget);
      expect(
        find.text('Constancia exigida por la Ley N.° 29733.'),
        findsOneWidget,
      );
      pcs.pcs = [];
      await tocar(tester, find.text('Continuar con la PC de la casa'));
      expect(find.text('Vincula la PC de la casa'), findsOneWidget);
    },
  );

  testWidgets('lo puede otorgar su representante legal', (tester) async {
    await abrir(tester, Rutas.configConsentimiento);
    await tocar(tester, find.text('Su representante legal'));
    await tocar(tester, find.textContaining('Rosa fue informada y acepta'));
    await tocar(tester, find.text('Leí el resumen y el documento completo.'));
    await tocar(tester, find.text('Registrar consentimiento'));
    expect(repo.consentimientos, ['Representante legal de Rosa Huamán']);
  });

  testWidgets(
    'CA-05.2: sin consentimiento la cámara no envía video y se pide completarlo',
    (tester) async {
      await abrir(tester, Rutas.configConsentimiento);
      await tocar(tester, find.text('Ahora no'));
      // Screen 25: the PC is linked, and its cameras send nothing yet.
      expect(find.text('La PC Sala-Rosa está vinculada'), findsOneWidget);
      expect(find.text('Falta el consentimiento de Rosa'), findsOneWidget);
      expect(find.textContaining('Detenida', findRichText: true), findsWidgets);
      await tocar(tester, find.text('Completar el consentimiento'));
      expect(
        find.text(
          'Lo acepta Rosa o su representante. Sin él, no detectamos caídas.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('CA-05.2: el inicio indica que la detección está detenida', (
    tester,
  ) async {
    await abrir(tester, Rutas.inicio);
    expect(find.text('Detección detenida'), findsOneWidget);
    expect(find.text('Falta el consentimiento de Rosa.'), findsOneWidget);
    await tocar(tester, find.text('Registrar consentimiento'));
    expect(
      find.text(
        'Lo acepta Rosa o su representante. Sin él, no detectamos caídas.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('un familiar invitado ve la detención sin poder registrar', (
    tester,
  ) async {
    await abrir(tester, Rutas.inicio, sesion: sesionInvitado);
    expect(find.text('Detección detenida'), findsOneWidget);
    expect(find.text('Registrar consentimiento'), findsNothing);
  });

  testWidgets('tras revocar, el inicio lo dice', (tester) async {
    repo.hogar = Hogar(
      hogarId: 'h-1',
      adultoMayor: rosa,
      rol: Rol.titular,
      consentimiento: Consentimiento(
        otorgadoEn: DateTime(2026, 8, 3, 9, 12),
        otorgadoPor: 'Rosa Huamán',
        registradoPor: 'Carmen Huamán',
        vistaEnVivoAceptada: true,
        vigente: false,
      ),
    );
    await abrir(tester, Rutas.inicio);
    expect(find.text('Revocaste el consentimiento.'), findsOneWidget);
  });

  test(
    'POST /api/hogar/consentimiento con los dos permisos aceptados',
    () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/hogar/consentimiento',
          const Respuesta(201, {
            'otorgadoEn': '2026-09-23T14:14:00Z',
            'otorgadoPor': 'Rosa Huamán',
            'registradoPor': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
            'vistaEnVivoAceptada': true,
            'vigente': true,
          }),
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
      final consentimiento = await c
          .read(hogarRepositorioProvider)
          .registrarConsentimiento(otorgadoPor: 'Rosa Huamán');
      expect(consentimiento.vigente, isTrue);
      expect(http.peticiones.single.data, {
        'otorgadoPor': 'Rosa Huamán',
        'aceptadoPorAdultoMayor': true,
        'vistaEnVivoAceptada': true,
      });
    },
  );
}
