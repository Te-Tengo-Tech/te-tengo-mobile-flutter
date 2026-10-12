import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/botones.dart';
import 'package:te_tengo/core/ui/chips.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/movimientos/data/movimientos_repositorio.dart';
import 'package:te_tengo/features/reportes/data/reportes_repositorio.dart';
import 'package:te_tengo/features/reportes/domain/reporte_caida.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../alertas/alertas_falso.dart';
import '../alertas/apoyo_alertas.dart';
import '../camaras/repositorio_falso.dart';
import '../movimientos/movimientos_falso.dart';
import 'reportes_falso.dart';

final _cocina = Camara(
  id: 'c2',
  nombreHabitacion: 'Cocina',
  estado: EstadoConexion.enLinea,
  ultimaSenal: DateTime(2026, 9, 23, 10, 42),
  instaladaEn: DateTime(2026, 9, 22),
);

void main() {
  late ReportesRepositorioFalso reportes;
  late MovimientosRepositorioFalso movimientos;
  late ConectividadFalsa conectividad;
  late CacheMemoria cache;

  setUp(() {
    reportes = ReportesRepositorioFalso();
    movimientos = MovimientosRepositorioFalso();
    conectividad = ConectividadFalsa();
    cache = CacheMemoria();
  });

  Future<List<String?>> abrir(
    WidgetTester tester,
    String ubicacion, {
    List<Alerta> alertas = const [],
    Sesion sesion = sesionTitular,
  }) => abrirConAlertas(
    tester,
    ubicacion: ubicacion,
    alertas: AlertasRepositorioFalso([...alertas]),
    sesion: sesion,
    camaras: CamarasRepositorioFalso([camaraSala, _cocina]),
    conectividad: conectividad,
    cache: cache,
    overrides: [
      reportesRepositorioProvider.overrideWithValue(reportes),
      movimientosRepositorioProvider.overrideWithValue(movimientos),
    ],
  );

  Future<void> escribirHora(WidgetTester tester, String hora) async {
    await tester.enterText(find.widgetWithText(TextField, 'HH:MM'), hora);
    await tester.pumpAndSettle();
  }

  Future<void> enviar(WidgetTester tester) =>
      tocar(tester, find.widgetWithText(Boton, 'Enviar'));

  ChipOpcion chip(WidgetTester tester, String texto) => tester.widget(
    find.ancestor(of: find.text(texto), matching: find.byType(ChipOpcion)),
  );

  testWidgets('CA-40.4: el enlace al pie del historial abre el formulario', (
    tester,
  ) async {
    await abrir(
      tester,
      Rutas.historial,
      alertas: [caidaSala(estado: EstadoAlerta.atendida)],
    );
    await tocar(tester, find.text('¿Hubo una caída y no avisó?'));
    expect(find.text('Contarnos qué pasó'), findsOneWidget);
    expect(
      find.text('Si Rosa necesita ayuda ahora, llama al SAMU · 106'),
      findsOneWidget,
    );
    expect(find.text('¿Hubo una caída y no te avisamos?'), findsOneWidget);
    for (final h in ['Sala', 'Cocina', 'No sé']) {
      expect(chip(tester, h).elegido, isFalse);
    }
    // Now rounded down to 5 minutes, today.
    expect(find.text('10:40'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
  });

  testWidgets('el aviso del SAMU llama al 106', (tester) async {
    final llamadas = await abrir(tester, Rutas.reportar());
    await tocar(tester, find.text('Llamar al SAMU · 106'));
    expect(llamadas, ['106']);
  });

  testWidgets('envía la cámara de la habitación, la hora y la nota', (
    tester,
  ) async {
    await abrir(tester, Rutas.reportar());
    await tocar(tester, find.text('Cocina'));
    await escribirHora(tester, '0730');
    expect(find.text('07:30'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Ej.: Se resbaló al salir de la cama'),
      'Se resbaló al salir de la cama. ',
    );
    await tester.pumpAndSettle();
    expect(find.text('32/300'), findsOneWidget);
    await enviar(tester);
    final r = reportes.enviados.single;
    expect(r.camaraId, 'c2');
    expect(r.habitacion, isNull);
    expect(r.ocurridaAproximadamenteEn, DateTime(2026, 9, 23, 7, 30));
    expect(r.nota, 'Se resbaló al salir de la cama.');
    expect(find.text('Gracias, Carmen. Lo revisaremos.'), findsOneWidget);
    expect(
      find.text('Esto no genera una alerta ni avisa a la familia.'),
      findsOneWidget,
    );
    expect(find.text('No pudimos enviarlo'), findsNothing);
    await tocar(tester, find.text('Volver al historial'));
    expect(find.text('Historial'), findsWidgets);
    expect(find.text('Alertas'), findsOneWidget);
  });

  testWidgets('pide la habitación y una hora que ya pasó', (tester) async {
    await abrir(tester, Rutas.reportar());
    await enviar(tester);
    expect(find.text('Elige la habitación o «No sé».'), findsOneWidget);
    await tocar(tester, find.text('No sé'));
    expect(find.text('Elige la habitación o «No sé».'), findsNothing);
    await escribirHora(tester, '11:30');
    await enviar(tester);
    expect(find.text('Elige una hora que ya pasó.'), findsOneWidget);
    await escribirHora(tester, '7');
    await enviar(tester);
    expect(find.text('Escribe la hora así: 07:30.'), findsOneWidget);
    expect(reportes.enviados, isEmpty);
    // The same time yesterday has passed.
    await escribirHora(tester, '1130');
    await tocar(tester, find.text('Hoy'));
    await tocar(tester, find.text('Ayer').last);
    await enviar(tester);
    final r = reportes.enviados.single;
    expect(r.camaraId, isNull);
    expect(r.habitacion, isNull);
    expect(r.ocurridaAproximadamenteEn, DateTime(2026, 9, 22, 11, 30));
    expect(r.nota, isNull);
  });

  testWidgets('muestra los errores del servidor junto a su campo', (
    tester,
  ) async {
    reportes.errores.addAll([
      const ProblemaApi(
        codigo: 'VALIDACION',
        detalle: 'Revisa los datos.',
        estado: 400,
        campos: {'ocurridaAproximadamenteEn': 'Elige una hora que ya pasó.'},
      ),
      const ProblemaApi(
        codigo: 'CAMARA_NO_ENCONTRADA',
        detalle: 'Esa cámara ya no está en la casa.',
        estado: 404,
      ),
    ]);
    await abrir(tester, Rutas.reportar());
    await tocar(tester, find.text('Sala'));
    await enviar(tester);
    expect(find.text('Elige una hora que ya pasó.'), findsOneWidget);
    await enviar(tester);
    expect(find.text('Esa cámara ya no está en la casa.'), findsOneWidget);
    expect(reportes.enviados, isEmpty);
  });

  group('sin internet', () {
    testWidgets('lo guarda y lo envía cuando vuelve la conexión', (
      tester,
    ) async {
      conectividad.hay = false;
      await abrir(tester, Rutas.historial);
      await tocar(tester, find.text('¿Hubo una caída y no avisó?'));
      await tocar(tester, find.text('Sala'));
      await enviar(tester);
      expect(find.text('Lo guardamos para enviarlo'), findsOneWidget);
      expect(find.text('No pudimos enviarlo'), findsOneWidget);
      expect(
        find.text('Lo guardamos y lo enviaremos cuando vuelva la conexión.'),
        findsOneWidget,
      );
      expect(reportes.enviados, isEmpty);
      expect(await cache.leer(ColaReportes.clave), contains('"c1"'));

      conectividad.cambiar(true);
      await tester.pumpAndSettle();
      expect(reportes.enviados.single.camaraId, 'c1');
      expect(await cache.leer(ColaReportes.clave), '[]');
    });

    testWidgets('si el servidor no responde, también lo guarda', (
      tester,
    ) async {
      reportes.errores.add(sinConexion);
      await abrir(tester, Rutas.reportar());
      await tocar(tester, find.text('No sé'));
      await enviar(tester);
      expect(find.text('Lo guardamos para enviarlo'), findsOneWidget);
      expect(reportes.enviados, isEmpty);
      // Back on the tabs, with internet: it goes out.
      await tocar(tester, find.text('Volver al historial'));
      expect(reportes.enviados, hasLength(1));
    });
  });

  group('desde dónde se abre', () {
    testWidgets('la cámara elige su habitación', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ajustes de la cámara'));
      await tocar(tester, find.text('¿Hubo una caída y no avisó?'));
      expect(chip(tester, 'Sala').elegido, isTrue);
      expect(chip(tester, 'Cocina').elegido, isFalse);
    });

    testWidgets('un movimiento inestable atendido pregunta si terminó en '
        'caída, con su habitación y su hora', (tester) async {
      await abrir(
        tester,
        Rutas.detalleAlerta('a-1'),
        alertas: [
          caidaSala(
            tipo: TipoAlerta.movimientoInestable,
            estado: EstadoAlerta.atendida,
            ocurridaEn: DateTime(2026, 9, 22, 18, 26),
          ),
        ],
      );
      expect(find.text('¿Hubo una caída y no avisó?'), findsNothing);
      await tocar(tester, find.text('¿Terminó en caída y no avisamos?'));
      expect(chip(tester, 'Sala').elegido, isTrue);
      expect(find.text('Ayer'), findsOneWidget);
      expect(find.text('18:26'), findsOneWidget);
    });

    testWidgets('una caída o un inestable activo no lo ofrecen', (
      tester,
    ) async {
      await abrir(
        tester,
        Rutas.detalleAlerta('a-1'),
        alertas: [caidaSala(estado: EstadoAlerta.atendida)],
      );
      await verHasta(tester, find.text('Registro del evento'));
      expect(find.text('¿Terminó en caída y no avisamos?'), findsNothing);
    });
  });

  testWidgets('un familiar invitado también puede contarlo', (tester) async {
    await abrir(tester, Rutas.reportar(), sesion: sesionInvitado);
    expect(find.text('Solo ver'), findsNothing);
    await tocar(tester, find.text('Sala'));
    await enviar(tester);
    expect(find.text('Gracias, Luis. Lo revisaremos.'), findsOneWidget);
    expect(reportes.enviados, hasLength(1));
  });

  group('movimientos de ese momento', () {
    testWidgets('sin el permiso no hay movimientos guardados', (tester) async {
      await abrir(tester, Rutas.reportar());
      await verHasta(
        tester,
        find.text('Sin movimientos de ese momento; revisaremos tu relato.'),
      );
    });

    testWidgets('con el permiso y la nube, los revisaremos', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      await abrir(tester, Rutas.reportar());
      await verHasta(
        tester,
        find.text('Revisaremos los movimientos de ese momento.'),
      );
    });
  });

  group('cola de reportes', () {
    test('envía en orden, descarta uno inválido y para sin conexión', () async {
      final cola = ColaReportes(cache, reportes, conectividad);
      conectividad.hay = false;
      for (final h in ['Sala', 'Cocina', 'Pasillo']) {
        expect(
          await cola.enviar(
            ReporteCaida(
              habitacion: h,
              ocurridaAproximadamenteEn: DateTime(2026, 9, 23, 7),
            ),
          ),
          EnvioReporte.guardado,
        );
      }
      reportes.errores.addAll([
        null,
        const ProblemaApi(codigo: 'VALIDACION', detalle: '', estado: 400),
        sinConexion,
      ]);
      expect(await cola.enviarPendientes(), 1);
      expect(
        [for (final r in await cola.pendientes()) r.habitacion],
        ['Pasillo'],
      );
      expect(await cola.enviarPendientes(), 1);
      expect(await cola.pendientes(), isEmpty);
      expect(
        [for (final r in reportes.enviados) r.habitacion],
        ['Sala', 'Pasillo'],
      );
    });

    test('una sesión por renovar no descarta el reporte', () async {
      final cola = ColaReportes(cache, reportes, conectividad);
      conectividad.hay = false;
      await cola.enviar(
        ReporteCaida(ocurridaAproximadamenteEn: DateTime(2026, 9, 23, 7)),
      );
      reportes.errores.add(
        const ProblemaApi(codigo: 'NO_AUTENTICADO', detalle: '', estado: 401),
      );
      expect(await cola.enviarPendientes(), 0);
      expect(await cola.pendientes(), hasLength(1));
    });
  });

  test('POST /api/reportes-de-caida', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'POST',
        '/api/reportes-de-caida',
        const Respuesta(201, {
          'id': 'r-1',
          'recibidoEn': '2026-09-23T15:42:00Z',
          'movimientosDisponibles': true,
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
    final r = await c
        .read(reportesRepositorioProvider)
        .enviar(
          ReporteCaida(
            camaraId: 'c1',
            ocurridaAproximadamenteEn: DateTime.utc(2026, 9, 23, 12, 30),
            nota: 'La encontré sentada en el suelo.',
          ),
        );
    expect(r.id, 'r-1');
    expect(r.movimientosDisponibles, isTrue);
    expect(http.peticiones.single.data, {
      'camaraId': 'c1',
      'habitacion': null,
      'ocurridaAproximadamenteEn': '2026-09-23T12:30:00.000Z',
      'nota': 'La encontré sentada en el suelo.',
    });
  });

  test('la hora se escribe HH:MM', () {
    expect(formatoHora('0730'), '07:30');
    expect(formatoHora('7'), '7');
    expect(formatoHora('07:3'), '07:3');
    expect(formatoHora('12345'), '12:34');
    expect(minutosDeHora('07:30'), 450);
    expect(minutosDeHora('24:00'), isNull);
    expect(minutosDeHora('7:30'), isNull);
  });
}
