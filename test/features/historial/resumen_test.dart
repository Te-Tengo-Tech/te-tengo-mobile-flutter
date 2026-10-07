import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/app/tema/colores.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/historial/data/resumen_repositorio.dart';
import 'package:te_tengo/features/historial/domain/resumen_semanal.dart';
import 'package:te_tengo/features/historial/presentation/resumen_semanal.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

class ResumenRepositorioFalso implements ResumenRepositorio {
  final pedidas = <String>[];
  final semanas = <String, ResumenSemanal>{};

  @override
  Future<ResumenSemanal> obtener(String semana) async {
    pedidas.add(semana);
    return semanas[semana] ??
        ResumenSemanal(
          semana: semana,
          conteos: const Conteos(),
          semanaAnterior: const Conteos(),
        );
  }
}

void main() {
  late ResumenRepositorioFalso resumen;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesionTitular,
        overrides: [
          resumenRepositorioProvider.overrideWithValue(resumen),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso([
              caidaSala(
                id: 'h1',
                tipo: TipoAlerta.movimientoInestable,
                estado: EstadoAlerta.atendida,
                ocurridaEn: DateTime(2026, 9, 21, 12, 5),
              ),
              caidaSala(
                id: 'h2',
                estado: EstadoAlerta.atendida,
                ocurridaEn: DateTime(2026, 9, 15, 7, 55),
              ),
              caidaSala(
                id: 'h3',
                estado: EstadoAlerta.falsaAlarma,
                ocurridaEn: DateTime(2026, 9, 14, 18, 20),
              ),
            ]),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    resumen = ResumenRepositorioFalso()
      ..semanas['2026-W39'] = const ResumenSemanal(
        semana: '2026-W39',
        conteos: Conteos(movimientosInestables: 1),
        semanaAnterior: Conteos(caidas: 1, movimientosInestables: 2),
        tendenciaCaidas: Tendencia.disminucion,
        tendenciaInestables: Tendencia.disminucion,
      )
      ..semanas['2026-W38'] = const ResumenSemanal(
        semana: '2026-W38',
        conteos: Conteos(caidas: 1, movimientosInestables: 2, falsasAlarmas: 1),
        semanaAnterior: Conteos(movimientosInestables: 2, falsasAlarmas: 2),
        tendenciaCaidas: Tendencia.aumento,
        tendenciaFalsas: Tendencia.disminucion,
      );
  });

  Color colorDe(WidgetTester tester, String texto) =>
      tester.widget<Text>(find.text(texto)).style!.color!;

  testWidgets('CA-27.1 y CA-27.3: conteos por tipo y comparación con la '
      'semana anterior', (tester) async {
    await abrir(tester, Rutas.historial);
    await tocar(tester, find.text('Resumen semanal'));
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('21 – 27 septiembre 2026'), findsOneWidget);
    expect(resumen.pedidas, ['2026-W39']);
    await tocar(tester, find.byTooltip('Semana anterior'));
    expect(resumen.pedidas.last, '2026-W38');
    expect(find.text('Semana pasada'), findsOneWidget);
    expect(find.text('14 – 20 septiembre 2026'), findsOneWidget);
    expect(find.text('vs. 7 – 13 sep'), findsOneWidget);
    expect(find.text('Caídas'), findsOneWidget);
    expect(find.text('Movimientos inestables'), findsOneWidget);
    expect(find.text('Falsas alarmas'), findsOneWidget);
    const aumento = 'Aumentó: 1 más que la semana anterior (0)';
    const igual = 'Igual que la semana anterior';
    const disminucion = 'Disminuyó: 1 menos que la semana anterior (2)';
    expect(find.text(aumento), findsOneWidget);
    expect(find.text(igual), findsOneWidget);
    expect(find.text(disminucion), findsOneWidget);
    // Amber when falls increase, green when they decrease.
    expect(colorDe(tester, aumento), Colores.aviso);
    expect(colorDe(tester, disminucion), Colores.calmaTinta);
    expect(colorDe(tester, igual), Colores.tinta3);
    await verHasta(
      tester,
      find.text(
        'Las falsas alarmas no se suman a las caídas ni a los movimientos '
        'inestables.',
      ),
    );
  });

  testWidgets('CA-27.2: una semana sin eventos muestra el resumen en cero', (
    tester,
  ) async {
    await abrir(tester, Rutas.historial);
    await tocar(tester, find.text('Resumen semanal'));
    for (var i = 0; i < 3; i++) {
      await tocar(tester, find.byTooltip('Semana anterior'));
    }
    expect(resumen.pedidas.last, '2026-W36');
    expect(find.text('Hace 3 semanas'), findsOneWidget);
    expect(find.text('31 – 6 septiembre 2026'), findsOneWidget);
    expect(find.text('Semana sin eventos'), findsOneWidget);
    expect(
      find.text(
        'No hubo caídas ni movimientos inestables del 31 al 6 de septiembre.',
      ),
      findsOneWidget,
    );
    await verHasta(tester, find.text('vs. 24 – 30 ago'));
    await verHasta(tester, find.text('Falsas alarmas'));
    expect(find.text('Igual que la semana anterior'), findsWidgets);
  });

  testWidgets('no se puede pasar de la semana actual', (tester) async {
    await abrir(tester, Rutas.historial);
    await tocar(tester, find.text('Resumen semanal'));
    await tester.tap(find.byTooltip('Semana siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Esta semana'), findsOneWidget);
    expect(resumen.pedidas, ['2026-W39']);
  });

  testWidgets('el inicio muestra la semana y el último evento', (tester) async {
    await abrir(tester, Rutas.inicio);
    await verHasta(tester, find.text('Último evento'));
    expect(find.byType(SemanaEnInicio), findsOneWidget);
    expect(find.text('caídas'), findsOneWidget);
    expect(find.text('inestable'), findsOneWidget);
    expect(find.text('falsas'), findsOneWidget);
    expect(find.text('Movimiento inestable en la Sala'), findsOneWidget);
    await tocar(tester, find.text('Ver resumen'));
    expect(find.text('Resumen semanal'), findsOneWidget);
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('21 – 27 septiembre 2026'), findsOneWidget);
  });

  test('semana ISO como la escribe el contrato', () {
    expect(semanaIso(DateTime(2026, 9, 23)), '2026-W39');
    expect(semanaIso(DateTime(2026, 9, 21)), '2026-W39');
    expect(semanaIso(DateTime(2026, 9, 20)), '2026-W38');
    expect(semanaIso(DateTime(2026, 1, 1)), '2026-W01');
    expect(semanaIso(DateTime(2027, 1, 1)), '2026-W53');
    expect(lunesDe(DateTime(2026, 9, 27)), DateTime(2026, 9, 21));
  });

  test('GET /api/resumen-semanal', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'GET',
        '/api/resumen-semanal',
        const Respuesta(200, {
          'semana': '2026-W38',
          'conteos': {
            'caidas': 1,
            'movimientosInestables': 2,
            'falsasAlarmas': 1,
          },
          'semanaAnterior': {
            'caidas': 0,
            'movimientosInestables': 2,
            'falsasAlarmas': 2,
          },
          'tendencia': {
            'caidas': 'AUMENTO',
            'movimientosInestables': 'IGUAL',
            'falsasAlarmas': 'DISMINUCION',
          },
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
    final r = await c.read(resumenRepositorioProvider).obtener('2026-W38');
    expect(http.peticiones.single.queryParameters, {'semana': '2026-W38'});
    expect(r.conteos.movimientosInestables, 2);
    expect(r.tendenciaCaidas, Tendencia.aumento);
    expect(r.tendenciaFalsas, Tendencia.disminucion);
  });
}
