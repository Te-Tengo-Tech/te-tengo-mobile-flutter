import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../hogar/hogar_falso.dart';
import 'familia_falso.dart';

void main() {
  late FamiliaRepositorioFalso familia;

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
          familiaRepositorioProvider.overrideWithValue(familia),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => familia = FamiliaRepositorioFalso());

  testWidgets('la familia muestra quién recibe las alertas y en qué orden', (
    tester,
  ) async {
    await abrir(tester, Rutas.familia);
    expect(find.text('Reciben las alertas de Rosa.'), findsOneWidget);
    expect(find.text('Carmen Huamán (tú)'), findsOneWidget);
    expect(find.text('titular de la cuenta'), findsOneWidget);
    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Luis Huamán'), findsOneWidget);
    expect(find.text('Secundario'), findsOneWidget);
    expect(find.text('Carmen → Luis · 5 min de espera'), findsOneWidget);
    expect(find.text('Invitar a un familiar'), findsOneWidget);
  });

  testWidgets(
    'CA-10.1: la titular define el contacto principal y el secundario',
    (tester) async {
      familia.familiares = [
        carmen,
        luis,
        const Familiar(
          usuarioId: 'u-mila',
          nombre: 'Milagros Quispe',
          correo: 'm@q.pe',
          rol: Rol.invitado,
        ),
      ];
      await abrir(tester, Rutas.ordenAviso);
      expect(find.text('Quién responde'), findsOneWidget);
      expect(find.text('Contacto principal'), findsOneWidget);
      expect(find.text('Contacto secundario · a los 5 min'), findsOneWidget);
      await tocar(tester, find.text('Cambiar').last);
      expect(find.text('¿Quién será el contacto secundario?'), findsOneWidget);
      expect(
        find.text('Le avisamos si nadie marca la alerta en 5 minutos.'),
        findsOneWidget,
      );
      expect(find.text('ahora: principal'), findsOneWidget);
      await tester.tap(find.text('Milagros Quispe'));
      await tester.pumpAndSettle();
      expect(familia.avisosGuardados.single.secundarioId, 'u-mila');
      expect(familia.avisosGuardados.single.principalId, 'u-carmen');
      expect(find.text('Milagros es contacto secundario'), findsOneWidget);
      expect(
        find.text('Usaremos este orden en las próximas alertas.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'el nuevo principal deja su lugar de secundario a quien era principal',
    (tester) async {
      await abrir(tester, Rutas.ordenAviso);
      await tocar(tester, find.text('Cambiar').first);
      await tester.tap(find.text('Luis Huamán').last);
      await tester.pumpAndSettle();
      final guardado = familia.avisosGuardados.single;
      expect(guardado.principalId, 'u-luis');
      expect(guardado.secundarioId, 'u-carmen');
    },
  );

  testWidgets('CA-10.2: elige esperar 3, 5 o 10 minutos', (tester) async {
    await abrir(tester, Rutas.ordenAviso);
    await verHasta(tester, find.text('Predeterminado'));
    await verHasta(
      tester,
      find.textContaining('avisamos a Luis a las 10:47', findRichText: true),
    );
    expect(find.text('3 minutos'), findsOneWidget);
    await tocar(tester, find.text('10 minutos'));
    expect(familia.avisosGuardados.single.esperaMinutos, 10);
    expect(find.text('Tiempo de espera: 10 minutos'), findsOneWidget);
    expect(find.text('Se aplicará en las próximas alertas.'), findsOneWidget);
    expect(
      find.textContaining('avisamos a Luis a las 10:52', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('CA-10.3: sin elección, la espera es de 5 minutos', (
    tester,
  ) async {
    await abrir(tester, Rutas.ordenAviso);
    await verHasta(tester, find.text('Predeterminado'));
    await verHasta(
      tester,
      find.textContaining('avisamos a Luis a las 10:47', findRichText: true),
    );
    expect(
      find.textContaining('avisamos a Luis a las 10:47', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('CA-10.4: con un solo familiar no hay contacto secundario', (
    tester,
  ) async {
    familia
      ..familiares = [carmen]
      ..avisoActual = const ConfiguracionAviso(principalId: 'u-carmen');
    await abrir(tester, Rutas.ordenAviso);
    expect(find.text('Sin contacto secundario'), findsOneWidget);
    expect(
      find.text('Si nadie atiende, no habrá a quién más avisar.'),
      findsOneWidget,
    );
    expect(find.text('Cambiar'), findsNothing);
    await verHasta(
      tester,
      find.text('Este tiempo se usará cuando tengas un contacto secundario.'),
    );
  });

  testWidgets('sin secundario, Familia lo advierte', (tester) async {
    familia
      ..familiares = [carmen]
      ..avisoActual = const ConfiguracionAviso(principalId: 'u-carmen');
    await abrir(tester, Rutas.familia);
    expect(find.text('Carmen · sin contacto secundario'), findsOneWidget);
    expect(find.text('No hay contacto secundario'), findsOneWidget);
    expect(
      find.text('Si Carmen no atiende a tiempo, nadie más será avisado.'),
      findsOneWidget,
    );
  });

  testWidgets('un familiar invitado solo ve el orden de aviso', (tester) async {
    await abrir(tester, Rutas.ordenAviso, sesion: sesionInvitado);
    expect(
      find.text(
        'Solo Carmen (titular) puede cambiar el orden de aviso y el tiempo de espera.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cambiar'), findsNothing);
    await tocar(tester, find.text('3 minutos'));
    expect(familia.avisosGuardados, isEmpty);
  });

  group('FamiliaRepositorioApi', () {
    test('GET y PUT /api/hogar/aviso', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/hogar/aviso',
          const Respuesta(200, {
            'principalId': 'u-carmen',
            'secundarioId': null,
            'esperaMinutos': 5,
          }),
        )
        ..cuando('PUT', '/api/hogar/aviso', const Respuesta(200));
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      final repo = c.read(familiaRepositorioProvider);
      final a = await repo.aviso();
      expect(a.secundarioId, isNull);
      await repo.guardarAviso(a.con(secundarioId: 'u-luis', esperaMinutos: 3));
      expect(http.peticiones.last.data, {
        'principalId': 'u-carmen',
        'secundarioId': 'u-luis',
        'esperaMinutos': 3,
      });
    });
  });
}
