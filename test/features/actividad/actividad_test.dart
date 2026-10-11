import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/chips.dart';
import 'package:te_tengo/features/actividad/data/actividad_repositorio.dart';
import 'package:te_tengo/features/actividad/domain/actividad.dart';
import 'package:te_tengo/features/actividad/presentation/pantalla_actividad.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/pcs_falso.dart';
import 'actividad_falso.dart';

final _pcCocina = Pc(
  id: 'pc-cocina',
  nombre: 'Cocina-Rosa',
  sistemaOperativo: 'Windows 10 Home',
  versionAgente: '0.5.0',
  estado: EstadoConexion.enLinea,
  ultimaSenal: DateTime(2026, 9, 23, 10, 42),
  vinculadaEn: DateTime(2026, 9, 22),
  vinculadaPor: (id: 'u-carmen', nombre: 'Carmen'),
  camaras: const [],
  camarasSinUsar: 0,
);

void main() {
  late ActividadRepositorioFalso repo;

  setUp(() => repo = ActividadRepositorioFalso());

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
          actividadRepositorioProvider.overrideWithValue(repo),
          pcsRepositorioProvider.overrideWithValue(
            PcsRepositorioFalso(pcs: [pcSalaRosa(), _pcCocina]),
          ),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  ChipOpcion chip(WidgetTester tester, String texto) => tester.widget(
    find.ancestor(of: find.text(texto), matching: find.byType(ChipOpcion)),
  );

  group('Actividad', () {
    testWidgets('CA-33.1: quién cambió qué y cuándo, agrupado por día', (
      tester,
    ) async {
      await abrir(tester, Rutas.actividad);
      expect(
        find.text('Quién cambió qué y cuándo, en la app o en la PC.'),
        findsNothing,
      );
      expect(find.text('Hoy'), findsOneWidget);
      expect(
        find.text(
          'Desde la PC Sala-Rosa: la cámara Logitech C920 pasó a Dormitorio',
        ),
        findsOneWidget,
      );
      expect(find.text('10:33'), findsOneWidget);
      expect(
        find.text('Desde la PC Sala-Rosa: se activó el modo avanzado'),
        findsOneWidget,
      );
      expect(find.text('Ayer'), findsOneWidget);
      expect(
        find.text('Carmen eligió la cámara HD Pro Webcam para la Cocina'),
        findsOneWidget,
      );
      expect(find.text('Carmen vinculó la PC Cocina-Rosa'), findsOneWidget);
      await verHasta(tester, find.text('21/09/2026'));
      await verHasta(
        tester,
        find.text('Carmen cambió los movimientos en la nube de 7 a 30 días'),
      );
      await verHasta(
        tester,
        find.text('Luis pausó la cámara de la Sala hasta las 09:15'),
      );
      await verHasta(
        tester,
        find.text('Nadie puede borrar ni cambiar este registro.'),
      );
    });

    testWidgets('CA-33.2: filtra por PC', (tester) async {
      await abrir(tester, Rutas.actividad);
      expect(chip(tester, 'Todas').elegido, isTrue);
      await tocar(tester, find.text('Cocina-Rosa'));
      expect(chip(tester, 'Cocina-Rosa').elegido, isTrue);
      expect(repo.consultas.last.$1, 'pc-cocina');
      expect(find.text('Carmen vinculó la PC Cocina-Rosa'), findsOneWidget);
      expect(
        find.text('Desde la PC Sala-Rosa: se activó el modo avanzado'),
        findsNothing,
      );
      await tocar(tester, find.text('Todas'));
      expect(
        find.text('Desde la PC Sala-Rosa: se activó el modo avanzado'),
        findsOneWidget,
      );
    });

    testWidgets('el detalle dice quién, desde dónde, antes y después', (
      tester,
    ) async {
      await abrir(tester, Rutas.actividad);
      await tocar(
        tester,
        find.text(
          'Desde la PC Sala-Rosa: la cámara Logitech C920 pasó a Dormitorio',
        ),
      );
      final hoja = find.byType(HojaActividad);
      Finder en(String t) => find.descendant(of: hoja, matching: find.text(t));
      expect(en('Alguien en la PC'), findsOneWidget);
      expect(en('PC Sala-Rosa'), findsOneWidget);
      expect(en('Sin usar'), findsOneWidget);
      expect(en('Dormitorio'), findsOneWidget);
      expect(
        find.descendant(
          of: hoja,
          matching: find.textContaining(
            '23/09/2026 · 10:33',
            findRichText: true,
          ),
        ),
        findsOneWidget,
      );
      await tocar(tester, en('Cerrar'));
      expect(hoja, findsNothing);

      await tocar(tester, find.text('Carmen vinculó la PC Cocina-Rosa'));
      expect(en('Carmen Huamán'), findsOneWidget);
      expect(en('Celular de Carmen'), findsOneWidget);
      expect(en('Vinculada'), findsOneWidget);
    });

    testWidgets('CA-33.4: sin actividad', (tester) async {
      repo.lista = [];
      await abrir(tester, Rutas.actividad);
      expect(find.text('Aún no hay actividad registrada'), findsOneWidget);
      expect(
        find.text('Aquí verás cada cambio en PCs, cámaras y datos.'),
        findsOneWidget,
      );
      expect(find.byType(ChipOpcion), findsNothing);
      expect(
        find.text('Nadie puede borrar ni cambiar este registro.'),
        findsNothing,
      );
    });

    testWidgets('un error se puede reintentar', (tester) async {
      repo.error = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: 'No hay conexión con Te Tengo. Revisa tu internet.',
      );
      await abrir(tester, Rutas.actividad);
      expect(
        find.text('No hay conexión con Te Tengo. Revisa tu internet.'),
        findsOneWidget,
      );
      repo.error = null;
      await tocar(tester, find.text('Volver a intentarlo'));
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets('carga más al llegar al final', (tester) async {
      repo.lista = [
        for (var i = 0; i < 60; i++)
          actividad(
            'x$i',
            'CAMARA_REANUDADA',
            DateTime(2026, 9, 23, 10, 0).subtract(Duration(hours: i)),
            objeto: 'Sala',
          ),
      ];
      await abrir(tester, Rutas.actividad);
      expect(repo.consultas.single, (null, 0, 50));
      await tester.fling(find.byType(ListView), const Offset(0, -20000), 5000);
      await tester.pumpAndSettle();
      expect(repo.consultas.last, (null, 1, 50));
    });

    testWidgets('el familiar invitado ve lo mismo', (tester) async {
      await abrir(tester, Rutas.actividad, sesion: sesionInvitado);
      expect(find.text('Carmen vinculó la PC Cocina-Rosa'), findsOneWidget);
      expect(find.text('Solo ver'), findsNothing);
    });
  });

  group('Ajustes', () {
    testWidgets('dice el último cambio y abre la actividad', (tester) async {
      await abrir(tester, Rutas.ajustes);
      await verHasta(tester, find.text('Último cambio: hoy 10:33'));
      await tocar(tester, find.text('Actividad'));
      expect(find.byType(PantallaActividad), findsOneWidget);
    });

    testWidgets('sin actividad', (tester) async {
      repo.lista = [];
      await abrir(tester, Rutas.ajustes, sesion: sesionInvitado);
      await verHasta(tester, find.text('Aún no hay actividad'));
    });
  });

  group('frases', () {
    final t = DateTime(2026, 9, 23, 10, 42);
    String frase(
      String tipo, {
      TipoActor actor = TipoActor.familiar,
      String? objeto,
      String? antes,
      String? despues,
      String pc = 'Sala-Rosa',
    }) => actividad(
      'a',
      tipo,
      t,
      actor: actor,
      pc: pc,
      objeto: objeto,
      antes: antes,
      despues: despues,
    ).frase(adultoMayor: 'Rosa');

    test('de un familiar', () {
      expect(
        frase(
          'PC_RENOMBRADA',
          objeto: 'PC',
          antes: 'Cocina-Rosa',
          despues: 'Cocina',
        ),
        'Carmen renombró la PC Cocina-Rosa a Cocina',
      );
      expect(
        frase('PC_DESVINCULADA', objeto: 'Sala-Rosa'),
        'Carmen quitó la PC Sala-Rosa',
      );
      expect(
        frase(
          'CAMARA_ASIGNADA',
          objeto: 'Logitech C920',
          antes: 'Sala',
          despues: 'Dormitorio',
        ),
        'Carmen pasó la cámara Logitech C920 de la Sala al Dormitorio',
      );
      expect(
        frase('CAMARA_RETIRADA', objeto: 'Logitech C920', antes: 'Sala'),
        'Carmen dejó de usar la cámara Logitech C920',
      );
      expect(
        frase(
          'AMBIENTE_RENOMBRADO',
          objeto: 'Ambiente',
          antes: 'Sala',
          despues: 'Sala comedor',
        ),
        'Carmen cambió el nombre de la habitación de la Sala a Sala comedor',
      );
      expect(
        frase('CAMARA_REANUDADA', objeto: 'Sala'),
        'Carmen reanudó la cámara de la Sala',
      );
      expect(
        frase(
          'CAMARA_PAUSADA',
          objeto: 'Dormitorio',
          despues: DateTime(2026, 9, 24, 7).toUtc().toIso8601String(),
        ),
        'Carmen pausó la cámara del Dormitorio hasta el jue 24 sep a las 07:00',
      );
      expect(
        frase('CONSENTIMIENTO_OTORGADO'),
        'Carmen registró el consentimiento de monitoreo',
      );
      expect(
        frase('CONSENTIMIENTO_REVOCADO'),
        'Carmen revocó el consentimiento de monitoreo',
      );
      expect(
        frase('CONSENTIMIENTO_MOVIMIENTOS_OTORGADO'),
        'Carmen registró el permiso de Rosa para guardar movimientos',
      );
      expect(
        frase('CONSENTIMIENTO_MOVIMIENTOS_REVOCADO'),
        'Carmen dejó de guardar los movimientos de Rosa',
      );
      expect(
        frase(
          'RETENCION_MOVIMIENTOS_CAMBIADA',
          antes: '30 días',
          despues: null,
        ),
        'Carmen cambió los movimientos en la nube de 30 días a No guardar',
      );
    });

    test('desde una PC', () {
      expect(
        frase('PC_DESVINCULADA', actor: TipoActor.pc),
        'Desde la PC Sala-Rosa: se desvinculó esta PC',
      );
      expect(
        frase('CAMARA_RETIRADA', actor: TipoActor.pc, objeto: 'C920'),
        'Desde la PC Sala-Rosa: se dejó de usar la cámara C920',
      );
      expect(
        frase('MODO_AVANZADO_DESACTIVADO', actor: TipoActor.pc),
        'Desde la PC Sala-Rosa: se desactivó el modo avanzado',
      );
      expect(
        frase(
          'GUARDADO_LOCAL_CAMBIADO',
          actor: TipoActor.pc,
          objeto: 'Video continuo',
          antes: 'No',
          despues: 'Sí, 7 días',
        ),
        'Desde la PC Sala-Rosa: video continuo pasó de No a Sí, 7 días',
      );
      expect(
        frase('DATOS_LOCALES_ELIMINADOS', actor: TipoActor.pc),
        'Desde la PC Sala-Rosa: se borraron los datos guardados en la PC',
      );
    });

    test('CA-39.3: una repetición vista en la PC', () {
      final momento =
          '${DateTime(2026, 9, 23, 10, 36).toUtc().toIso8601String()}/'
          '${DateTime(2026, 9, 23, 10, 46).toUtc().toIso8601String()}';
      expect(
        frase(
          'REPETICION_VISTA',
          actor: TipoActor.pc,
          objeto: 'Sala',
          antes: momento,
          despues: '180',
        ),
        'Desde la PC Sala-Rosa: se vio qué pasó en la Sala '
        '(23/09 10:36–10:46, 3\u00a0min)',
      );
      final a = actividad(
        'r1',
        'REPETICION_VISTA',
        DateTime(2026, 9, 23, 10, 50),
        actor: TipoActor.pc,
        pc: 'Sala-Rosa',
        objeto: 'Sala',
        antes: momento,
        despues: '180',
      );
      expect(a.momentoYDuracion, ('23/09 10:36–10:46', '3\u00a0min'));
      expect(a.segundosVistos, 180);
      // Without the moment it still reads well.
      expect(
        frase('REPETICION_VISTA', actor: TipoActor.pc),
        'Desde la PC Sala-Rosa: se vio qué pasó',
      );
    });

    test('automáticas', () {
      expect(
        frase('CAMARA_REANUDADA', actor: TipoActor.sistema, objeto: 'Sala'),
        'Terminó la pausa de la Sala',
      );
      expect(
        frase(
          'PC_DESVINCULADA',
          actor: TipoActor.sistema,
          objeto: 'Sala-Rosa',
          despues: 'VENCIDA',
        ),
        'Se desvinculó la PC Sala-Rosa: no se conectó en 90 días',
      );
      expect(
        frase(
          'PC_DESVINCULADA',
          actor: TipoActor.sistema,
          objeto: 'Sala-Rosa',
          despues: 'REUSO_DE_TOKEN',
        ),
        'Se desvinculó la PC Sala-Rosa por seguridad',
      );
      expect(
        frase('CONSENTIMIENTO_MOVIMIENTOS_REVOCADO', actor: TipoActor.sistema),
        'Se dejaron de guardar los movimientos de Rosa al revocar el '
        'consentimiento',
      );
    });

    test('un tipo nuevo tiene una frase genérica', () {
      expect(frase('ALGO_NUEVO'), 'Carmen hizo un cambio en la configuración');
      expect(
        frase('ALGO_NUEVO', actor: TipoActor.pc),
        'Desde la PC Sala-Rosa: hubo un cambio en la configuración',
      );
      expect(
        frase('ALGO_NUEVO', actor: TipoActor.sistema),
        'Hubo un cambio en la configuración',
      );
    });

    test('etiquetas del día y del último cambio', () {
      expect(etiquetaDia(DateTime(2026, 9, 22, 23), t), 'Ayer');
      expect(etiquetaDia(DateTime(2026, 9, 8), t), '08/09/2026');
      expect(resumenUltimoCambio(null, t), 'Aún no hay actividad');
      expect(
        resumenUltimoCambio(registroDePrueba[2], t),
        'Último cambio: ayer 18:44',
      );
      expect(
        resumenUltimoCambio(registroDePrueba[4], t),
        'Último cambio: el 21/09/2026 12:20',
      );
    });
  });

  test('GET /api/actividad', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'GET',
        '/api/actividad',
        const Respuesta(200, {
          'elementos': [
            {
              'id': 'ac1',
              'ocurridaEn': '2026-10-11T14:46:16.479362Z',
              'registradaEn': '2026-10-11T14:46:16.498187Z',
              'tipo': 'CAMARA_ASIGNADA',
              'actor': {
                'tipo': 'FAMILIAR',
                'usuario': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
              },
              'pc': {'id': 'pc-sala', 'nombre': 'Sala-Rosa'},
              'camaraId': 'c1',
              'objeto': 'Logitech C920',
              'valorAnterior': null,
              'valorNuevo': 'Dormitorio',
            },
          ],
          'total': 1,
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
    final p = await c
        .read(actividadRepositorioProvider)
        .listar(pcId: 'pc-sala', pagina: 1, tamano: 20);
    expect(p.total, 1);
    final a = p.elementos.single;
    expect(a.actor, TipoActor.familiar);
    expect(a.usuarioId, 'u-carmen');
    expect(a.pc, 'Sala-Rosa');
    expect(
      a.ocurridaEn.toUtc(),
      DateTime.utc(2026, 10, 11, 14, 46, 16, 479, 362),
    );
    expect(
      a.frase(adultoMayor: 'Rosa'),
      'Carmen eligió la cámara Logitech C920 para el Dormitorio',
    );
    expect(http.peticiones.single.queryParameters, {
      'pcId': 'pc-sala',
      'pagina': 1,
      'tamano': 20,
    });
  });
}
