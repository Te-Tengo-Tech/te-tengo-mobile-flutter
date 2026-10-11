import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_detalle_alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';
import 'package:te_tengo/features/familia/presentation/pantalla_familiar.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_accesos.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../hogar/hogar_falso.dart';
import '../vivo/vivo_falso.dart';
import 'familia_falso.dart';

void main() {
  late FamiliaRepositorioFalso familia;
  late AlertasRepositorioFalso alertas;
  late VistaEnVivoRepositorioFalso vivo;

  setUp(() {
    familia = FamiliaRepositorioFalso();
    alertas = AlertasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
  });

  Future<void> abrir(
    WidgetTester tester, {
    Sesion sesion = sesionTitular,
    String ubicacion = Rutas.familia,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          familiaRepositorioProvider.overrideWithValue(familia),
          alertasRepositorioProvider.overrideWithValue(alertas),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Carmen ve a Luis: contacto, papel y lo que hizo', (
    tester,
  ) async {
    alertas.alertas = [
      caidaSala(
        id: 'h1',
        tipo: TipoAlerta.movimientoInestable,
        estado: EstadoAlerta.atendida,
        ocurridaEn: DateTime(2026, 9, 17, 18, 24),
        atendidaPor: 'Luis Huamán',
        atendidaPorId: 'u-luis',
        atendidaEn: DateTime(2026, 9, 17, 18, 26),
      ),
      caidaSala(
        id: 'h2',
        estado: EstadoAlerta.falsaAlarma,
        ocurridaEn: DateTime(2026, 9, 8, 22, 30),
        atendidaPor: 'Luis Huamán',
        atendidaPorId: 'u-luis',
        atendidaEn: DateTime(2026, 9, 8, 22, 31),
      ),
      caidaSala(
        id: 'h3',
        estado: EstadoAlerta.atendida,
        atendidaPor: 'Carmen Huamán',
        atendidaPorId: 'u-carmen',
      ),
    ];
    vivo.lista = [
      AccesoVivo(
        usuarioId: 'u-luis',
        nombre: 'Luis Huamán',
        inicio: DateTime(2026, 9, 23, 10, 31),
        duracionSegundos: 120,
      ),
      AccesoVivo(
        usuarioId: 'u-carmen',
        nombre: 'Carmen Huamán',
        inicio: DateTime(2026, 9, 23, 9, 0),
        duracionSegundos: 30,
      ),
    ];
    await abrir(tester);
    await tocar(tester, find.text('Luis Huamán'));
    expect(find.byType(PantallaFamiliar), findsOneWidget);
    expect(find.text('Familiar'), findsOneWidget);
    expect(find.text('luis.huaman.r@gmail.com'), findsOneWidget);
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Secundario'), findsWidgets);
    expect(find.text('Le avisamos si nadie atiende en 5 min'), findsOneWidget);
    await verHasta(tester, find.text('2 alertas marcadas'));
    expect(
      find.text(
        'Última: Inestable en la Sala · jue 17 sep · 18:26',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('1 acceso a la cámara'), findsOneWidget);
    expect(
      find.text('Último: hoy 10:31 · 2\u00a0min', findRichText: true),
      findsOneWidget,
    );
    await verHasta(tester, find.text('Retirar acceso'));
    expect(find.text('Hacer contacto principal'), findsOneWidget);
    expect(find.text('Hacer contacto secundario'), findsNothing);

    await tocar(tester, find.text('2 alertas marcadas'));
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
    // The clip player's timers end with the tree.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('los accesos abren el registro de accesos', (tester) async {
    vivo.lista = [
      AccesoVivo(
        usuarioId: 'u-luis',
        nombre: 'Luis Huamán',
        inicio: DateTime(2026, 9, 21, 8, 0),
        duracionSegundos: 45,
      ),
    ];
    await abrir(tester, ubicacion: Rutas.familiar('u-luis'));
    expect(find.text('Aún no marcó alertas'), findsOneWidget);
    expect(
      find.text('Último: lun 21 sep 08:00 · 45\u00a0s', findRichText: true),
      findsOneWidget,
    );
    await tocar(tester, find.text('1 acceso a la cámara'));
    expect(find.byType(PantallaAccesos), findsOneWidget);
  });

  testWidgets('Carmen se ve a sí misma', (tester) async {
    await abrir(tester, ubicacion: Rutas.familiar('u-carmen'));
    expect(find.text('Tu perfil en la familia'), findsOneWidget);
    expect(find.text('Carmen Huamán (tú)'), findsOneWidget);
    expect(find.text('Titular de la cuenta'), findsOneWidget);
    expect(find.text('Recibe cada alerta primero'), findsOneWidget);
    expect(find.text('Aún no abrió la vista en vivo'), findsOneWidget);
    await verHasta(
      tester,
      find.text('Para dejar de ser principal, elige a otro contacto.'),
    );
    expect(find.text('Retirar acceso'), findsNothing);
    expect(find.text('Opciones'), findsNothing);
  });

  testWidgets('quita el acceso y vuelve a la familia', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Luis Huamán'));
    await tocar(tester, find.text('Retirar acceso'));
    await tocar(tester, find.text('Retirar acceso').last);
    expect(familia.retirados, ['u-luis']);
    expect(find.byType(PantallaFamiliar), findsNothing);
    expect(find.text('Luis ya no recibe alertas'), findsOneWidget);
  });

  testWidgets('un familiar que solo recibe alertas puede ser secundario', (
    tester,
  ) async {
    familia.avisoActual = const ConfiguracionAviso(principalId: 'u-carmen');
    await abrir(tester, ubicacion: Rutas.familiar('u-luis'));
    expect(find.text('Recibe alertas'), findsWidgets);
    expect(find.text('Se entera de todo, sin escalamiento'), findsOneWidget);
    await tocar(tester, find.text('Hacer contacto secundario'));
    expect(familia.avisosGuardados.single.secundarioId, 'u-luis');
    expect(find.text('Luis ahora es contacto secundario'), findsOneWidget);
  });

  testWidgets('Luis (invitado) ve a Carmen sin opciones', (tester) async {
    await abrir(tester, sesion: sesionInvitado);
    await tocar(tester, find.text('Carmen Huamán'));
    expect(find.byType(PantallaFamiliar), findsOneWidget);
    expect(find.text('Principal'), findsWidgets);
    await verHasta(
      tester,
      find.text(
        'Solo Carmen (titular) puede cambiar el papel de un familiar o '
        'retirar su acceso.',
      ),
    );
    expect(find.text('Hacer contacto principal'), findsNothing);
    expect(find.text('Retirar acceso'), findsNothing);
  });
}
