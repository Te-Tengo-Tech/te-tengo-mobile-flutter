import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/ui/chips.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/etiquetas.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_detalle_alerta.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/historial/domain/filtro_historial.dart';

import '../apoyo/app_de_prueba.dart';
import 'alertas/alertas_falso.dart';
import 'alertas/apoyo_alertas.dart';
import 'camaras/repositorio_falso.dart';

/// Past alerts of the prototype seed (dates of September 2026).
List<Alerta> historialRosa() => [
  caidaSala(
    id: 'h1',
    tipo: TipoAlerta.movimientoInestable,
    estado: EstadoAlerta.atendida,
    ocurridaEn: DateTime(2026, 9, 21, 12, 5),
    atendidaPor: 'Carmen Huamán',
    atendidaEn: DateTime(2026, 9, 21, 12, 9),
  ),
  caidaSala(
    id: 'h4',
    estado: EstadoAlerta.atendida,
    ocurridaEn: DateTime(2026, 9, 15, 7, 55),
    atendidaPor: 'Luis Huamán',
    atendidaEn: DateTime(2026, 9, 15, 8, 3),
  ),
  caidaSala(
    id: 'h5',
    estado: EstadoAlerta.falsaAlarma,
    ocurridaEn: DateTime(2026, 9, 14, 16, 10),
    atendidaPor: 'Carmen Huamán',
    atendidaEn: DateTime(2026, 9, 14, 16, 12),
  ),
  caidaSala(
    id: 'h6',
    tipo: TipoAlerta.movimientoInestable,
    estado: EstadoAlerta.atendida,
    ocurridaEn: DateTime(2026, 8, 28, 20, 41),
    atendidaPor: 'Carmen Huamán',
    atendidaEn: DateTime(2026, 8, 28, 20, 44),
  ),
];

void main() {
  final hoy = DateTime(2026, 9, 23, 10, 42);

  testWidgets('CA-25.1: lista fecha, hora, habitación, tipo y estado', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso(historialRosa());
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: alertas,
      ahora: hoy,
    );
    expect(find.text('Historial'), findsWidgets);
    expect(find.text('Alertas'), findsOneWidget);
    expect(find.text('Resumen semanal'), findsOneWidget);
    expect(find.text('lunes 21 de septiembre'), findsOneWidget);
    expect(find.text('12:05'), findsOneWidget);
    expect(find.text('Inestable'), findsWidgets);
    // With one camera the room adds nothing: who marked it is enough.
    expect(find.text('por Carmen'), findsWidgets);
    expect(find.text('Sala · por Carmen'), findsNothing);
    expect(find.text('ATENDIDA'), findsWidgets);
    await verHasta(tester, find.text('lunes 14 de septiembre'));
    expect(find.text('FALSA ALARMA'), findsOneWidget);
    expect(alertas.filtros.firstWhere((f) => f.tamano == 50).estado, isNull);
  });

  testWidgets('CA-25.1: con más de una cámara, cada fila dice la habitación', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: AlertasRepositorioFalso(historialRosa()),
      camaras: CamarasRepositorioFalso()
        ..camaras = const [
          Camara(
            id: 'c1',
            nombreHabitacion: 'Sala',
            estado: EstadoConexion.enLinea,
          ),
          Camara(
            id: 'c2',
            nombreHabitacion: 'Dormitorio',
            estado: EstadoConexion.enLinea,
          ),
        ],
      ahora: hoy,
    );
    expect(find.text('Sala · por Carmen'), findsWidgets);
  });

  testWidgets('una alerta activa dice que nadie la marcó', (tester) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: AlertasRepositorioFalso([caidaSala(), ...historialRosa()]),
      ahora: hoy,
    );
    // The active alert opens by itself: go back to the history.
    await tester.tap(find.byTooltip('Cerrar la alerta y volver al inicio'));
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Historial'));
    expect(find.text('Sin marcar'), findsOneWidget);
  });

  testWidgets('CA-17.2: caídas e inestables se distinguen por marca y texto', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: AlertasRepositorioFalso(historialRosa()),
      ahora: hoy,
    );
    final marcas = tester
        .widgetList<MarcaAlerta>(find.byType(MarcaAlerta))
        .toList();
    expect(
      marcas.map((m) => m.tipo),
      containsAll([TipoAlerta.caida, TipoAlerta.movimientoInestable]),
    );
    expect(find.text('Caída'), findsWidgets);
  });

  testWidgets('CA-25.2: el filtro muestra solo las alertas que coinciden', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso(historialRosa());
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: alertas,
      ahora: hoy,
    );
    await tocar(tester, find.text('Filtrar'));
    expect(find.text('Filtrar alertas'), findsOneWidget);
    await tester.tap(find.text('Últimos 30 días'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChipOpcion, 'Caída'));
    await tester.pumpAndSettle();
    expect(find.text('Ver 2 alertas'), findsOneWidget);
    await tester.tap(find.text('Ver 2 alertas'));
    await tester.pumpAndSettle();
    final consulta = alertas.filtros.last;
    expect(consulta.tipo, TipoAlerta.caida);
    expect(consulta.desde, DateTime(2026, 8, 25));
    expect(find.text('Filtrar (2)'), findsOneWidget);
    expect(find.text('Últimos 30 días'), findsOneWidget);
    expect(find.text('Caídas'), findsOneWidget);
    expect(find.text('07:55'), findsOneWidget);
    expect(find.text('12:05'), findsNothing);
    await tocar(tester, find.bySemanticsLabel('Quitar filtro Caídas'));
    expect(find.text('Filtrar (1)'), findsOneWidget);
    expect(find.text('12:05'), findsOneWidget);
  });

  testWidgets('sin coincidencias ofrece quitar los filtros', (tester) async {
    final alertas = AlertasRepositorioFalso(historialRosa());
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: alertas,
      ahora: hoy,
    );
    await tocar(tester, find.text('Filtrar'));
    await tester.tap(find.text('Últimos 7 días'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChipOpcion, 'Caída'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChipOpcion, 'Falsa alarma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver 0 alertas'));
    await tester.pumpAndSettle();
    expect(find.text('Ninguna alerta coincide'), findsOneWidget);
    expect(
      find.text('Prueba con otro rango de fechas, tipo o estado.'),
      findsOneWidget,
    );
    expect(find.text('Filtrar (3)'), findsOneWidget);
    await tocar(tester, find.text('Quitar filtros'));
    expect(find.text('Filtrar'), findsOneWidget);
    expect(find.text('12:05'), findsOneWidget);
  });

  testWidgets('CA-25.3: sin alertas muestra «Sin eventos registrados»', (
    tester,
  ) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: AlertasRepositorioFalso(),
      ahora: hoy,
    );
    expect(find.text('Sin eventos registrados'), findsOneWidget);
    expect(
      find.text('Aquí verás cada caída y movimiento inestable.'),
      findsOneWidget,
    );
    expect(find.text('Filtrar'), findsNothing);
  });

  testWidgets('mientras carga muestra el esqueleto', (tester) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.inicio,
      alertas: AlertasRepositorioFalso(historialRosa()),
      ahora: hoy,
    );
    await tester.tap(find.text('Historial'));
    await tester.pump();
    expect(find.bySemanticsLabel('Cargando historial'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('12:05'), findsOneWidget);
  });

  testWidgets('tocar una alerta abre su detalle', (tester) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.historial,
      alertas: AlertasRepositorioFalso(historialRosa()),
      ahora: hoy,
    );
    await tocar(tester, find.text('12:05'));
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
    expect(find.text('Alerta del lun 21 sep'), findsOneWidget);
  });

  test('FiltroHistorial pide los últimos 7 días desde hace 6 días', () {
    const f = FiltroHistorial(
      rango: RangoFecha.siete,
      estado: EstadoAlerta.activa,
    );
    final c = f.aConsulta(DateTime(2026, 9, 23, 10, 42));
    expect(c.desde, DateTime(2026, 9, 17));
    expect(c.consulta['estado'], 'ACTIVA');
    expect(f.activos, 2);
  });
}
