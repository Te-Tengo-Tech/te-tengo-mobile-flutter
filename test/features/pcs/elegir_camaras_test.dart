import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/camara_detectada.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_webrtc.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../vivo/vivo_falso.dart';
import 'pcs_falso.dart';

/// Three new webcams of the PC Sala-Rosa, none in use yet (screen 250).
List<CamaraDetectada> tresSinUsar() => [
  webcam('w1', 'Webcam USB HD'),
  webcam('w2', 'Logitech C920'),
  webcam('w3', 'USB2.0 PC Camera'),
];

void main() {
  late PcsRepositorioFalso pcs;
  late CamarasRepositorioFalso camaras;
  late VistaEnVivoRepositorioFalso vivo;
  late FabricaReproductorFalsa reproductores;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    bool consentimiento = true,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          pcsRepositorioProvider.overrideWithValue(pcs),
          camarasRepositorioProvider.overrideWithValue(camaras),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          fabricaReproductorVivoProvider.overrideWithValue(reproductores.crear),
          fabricaReproductorWebrtcProvider.overrideWithValue(
            reproductores.crearWebrtc,
          ),
          hogarRepositorioProvider.overrideWithValue(
            HogarRepositorioFalso(hogarDeRosa(consentimiento: consentimiento)),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder campoOtra() => find.descendant(
    of: find.widgetWithText(CampoTexto, 'Nombre de la habitación'),
    matching: find.byType(TextField),
  );

  setUp(() {
    pcs = PcsRepositorioFalso(
      pcs: [pcSalaRosa(camaras: [], sinUsar: 3)],
      webcams: tresSinUsar(),
      habitaciones: [],
    );
    camaras = CamarasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
    reproductores = FabricaReproductorFalsa();
  });

  testWidgets('CA-29.1: lista cada cámara de la PC con su estado', (
    tester,
  ) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    expect(find.text('Elige las cámaras'), findsOneWidget);
    expect(
      find.text(
        'La PC Sala-Rosa encontró 3 cámaras. Dinos en qué habitación está cada '
        'una; por ahora, cada habitación usa una sola cámara.',
      ),
      findsOneWidget,
    );
    expect(find.text('Webcam USB HD'), findsOneWidget);
    // The first one without a room is open.
    expect(find.text('Ver vista previa'), findsOneWidget);
    expect(find.text('¿En qué habitación está?'), findsOneWidget);
    expect(
      find.text('Por privacidad, Te Tengo no admite cámaras en el baño.'),
      findsOneWidget,
    );
    await verHasta(tester, find.text('USB2.0 PC Camera'));
    expect(find.text('Logitech C920'), findsOneWidget);
    expect(
      find.textContaining('Sin usar', findRichText: true),
      findsNWidgets(3),
    );
  });

  testWidgets('CA-29.2: asigna una habitación y la cámara empieza a cuidarla', (
    tester,
  ) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('Dormitorio'));
    await tocar(tester, find.text('Usar esta cámara'));
    expect(pcs.usos, [('w1', null, 'Dormitorio')]);
    expect(
      find.text('La cámara Webcam USB HD cuida ahora el Dormitorio'),
      findsOneWidget,
    );
    expect(
      find.text('Las próximas alertas dirán «en el Dormitorio».'),
      findsOneWidget,
    );
    // The next webcam without a room opens.
    expect(find.text('Ver vista previa'), findsOneWidget);
    expect(pcs.webcams.first.nombreHabitacion, 'Dormitorio');
  });

  testWidgets(
    'CA-29.2: una habitación que existe sin cámara se usa por su id',
    (tester) async {
      pcs.habitaciones = [ambiente('Cocina')];
      await abrir(tester, Rutas.elegirCamaras('pc-sala'));
      await tocar(tester, find.text('Cocina'));
      await tocar(tester, find.text('Usar esta cámara'));
      expect(pcs.usos, [('w1', 'a-cocina', null)]);
    },
  );

  testWidgets('CA-29.2: «Otra…» pide el nombre y no admite uno vacío', (
    tester,
  ) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('Otra…'));
    await tester.enterText(campoOtra(), '   ');
    await tocar(tester, find.text('Usar esta cámara'));
    expect(find.text('Escribe el nombre de la habitación.'), findsOneWidget);
    expect(pcs.usos, isEmpty);
    await tester.enterText(campoOtra(), 'estudio');
    await tocar(tester, find.text('Usar esta cámara'));
    expect(pcs.usos, [('w1', null, 'Estudio')]);
  });

  testWidgets('no admite cámaras en el baño', (tester) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('Otra…'));
    await tester.enterText(campoOtra(), 'Baño de visitas');
    await tocar(tester, find.text('Usar esta cámara'));
    expect(
      find.text('Por privacidad, Te Tengo no admite cámaras en el baño.'),
      findsNWidgets(2),
    );
    expect(pcs.usos, isEmpty);
    expect(esBano('SS.HH.'), isTrue);
    expect(esBano('Servicios higiénicos'), isTrue);
    expect(esBano('WC'), isTrue);
    expect(esBano('Sala'), isFalse);
    expect(esBano('Bañera'), isFalse);
  });

  testWidgets('el backend también rechaza el baño', (tester) async {
    pcs.errorUso = const ProblemaApi(
      codigo: 'AMBIENTE_NO_PERMITIDO',
      detalle: 'Por privacidad, Te Tengo no admite cámaras en el baño.',
    );
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('Otra…'));
    await tester.enterText(campoOtra(), 'Aseo');
    await tocar(tester, find.text('Usar esta cámara'));
    expect(
      find.text('Por privacidad, Te Tengo no admite cámaras en el baño.'),
      findsNWidgets(2),
    );
  });

  testWidgets('CA-29.3: una habitación con cámara no se puede elegir', (
    tester,
  ) async {
    pcs.habitaciones = [ambiente('Cocina', camara: 'c9', pc: 'Cocina-Rosa')];
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    expect(find.text('Ya tiene cámara'), findsOneWidget);
    await tocar(tester, find.text('Cocina'));
    final usar = find.text('Usar esta cámara');
    await tocar(tester, usar);
    expect(pcs.usos, isEmpty);
    // Typed, it says where the camera is.
    await tocar(tester, find.text('Otra…'));
    await tester.enterText(campoOtra(), 'cocina');
    await tocar(tester, usar);
    expect(
      find.text(
        'Ya hay una cámara en la Cocina (PC Cocina-Rosa). Por ahora, cada '
        'habitación usa una sola cámara.',
      ),
      findsOneWidget,
    );
    expect(pcs.usos, isEmpty);
  });

  testWidgets('CA-29.3: si otra PC la eligió antes, lo dice el backend', (
    tester,
  ) async {
    pcs.errorUso = const ProblemaApi(
      codigo: 'AMBIENTE_OCUPADO',
      detalle: 'Ocupado',
      extras: {
        'ambiente': 'Sala',
        'camara': {
          'id': 'c9',
          'pcId': 'pc-2',
          'pcNombre': 'Cocina-Rosa',
          'nombreDispositivo': 'HD Pro Webcam',
        },
      },
    );
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('Sala'));
    await tocar(tester, find.text('Usar esta cámara'));
    expect(
      find.text(
        'Ya hay una cámara en la Sala (PC Cocina-Rosa). Por ahora, cada '
        'habitación usa una sola cámara.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CA-29.2: «Dejar de usar» pide confirmar y libera la habitación', (
    tester,
  ) async {
    pcs.webcams = [
      webcam('w1', 'Webcam USB HD', habitacion: 'Sala'),
      webcam('w3', 'USB2.0 PC Camera', habitacion: 'Pasillo'),
    ];
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    await tocar(tester, find.text('USB2.0 PC Camera'));
    await tocar(tester, find.text('Dejar de usar'));
    expect(
      find.text('¿Dejar de usar la cámara USB2.0 PC Camera?'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Dejaremos de detectar caídas en el Pasillo. La cámara sigue conectada '
        'a la PC y puedes volver a elegirla.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Cancelar'));
    expect(pcs.dejadas, isEmpty);
    await tocar(tester, find.text('Dejar de usar'));
    await tocar(tester, find.text('Dejar de usar').last);
    expect(pcs.dejadas, ['w3']);
    expect(
      find.text('Dejamos de usar la cámara USB2.0 PC Camera'),
      findsOneWidget,
    );
    expect(find.text('Ya no detectamos caídas en el Pasillo.'), findsOneWidget);
  });

  testWidgets('CA-29.5: una cámara desconectada conserva su habitación', (
    tester,
  ) async {
    pcs.webcams = [
      webcam('w3', 'USB2.0 PC Camera', habitacion: 'Pasillo', conectada: false),
      webcam('w4', 'Logitech C270', conectada: false),
    ];
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    expect(
      find.textContaining('Desconectada · Pasillo', findRichText: true),
      findsOneWidget,
    );
    await tocar(tester, find.text('USB2.0 PC Camera'));
    expect(
      find.text(
        'Revisa el cable USB. Pasillo sigue con esta cámara: no pasa a otra.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Logitech C270'));
    expect(
      find.text('Pide a alguien en la casa que la conecte por USB a la PC.'),
      findsOneWidget,
    );
    expect(find.text('Usar esta cámara'), findsNothing);
  });

  testWidgets('CA-29.6: sin cámaras pide conectar una y buscar de nuevo', (
    tester,
  ) async {
    pcs.webcams = [];
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    expect(
      find.text('No encontramos cámaras en la PC Sala-Rosa'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Pide a alguien en la casa que conecte una webcam por USB a la PC.',
      ),
      findsOneWidget,
    );
    pcs.webcams = tresSinUsar();
    await tester.tap(find.text('Buscar de nuevo'));
    await tester.pump();
    expect(pcs.busquedas, ['pc-sala']);
    expect(find.text('Buscando cámaras en la PC Sala-Rosa…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Webcam USB HD'), findsOneWidget);
  });

  testWidgets('CA-30.3: con la PC sin conexión la lista no está disponible', (
    tester,
  ) async {
    pcs.pcs = [pcSalaRosa(estado: EstadoConexion.desconectada)];
    await abrir(tester, Rutas.elegirCamaras('pc-sala'));
    expect(find.text('La PC Sala-Rosa no responde'), findsOneWidget);
    expect(find.text('Que la PC esté encendida'), findsOneWidget);
    expect(find.text('Webcam USB HD'), findsNothing);
  });

  testWidgets('CA-29.9: el familiar invitado la ve sin poder cambiarla', (
    tester,
  ) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala'), sesion: sesionInvitado);
    expect(
      find.text('Solo Carmen (titular) puede elegir las cámaras.'),
      findsOneWidget,
    );
    expect(find.text('Webcam USB HD'), findsOneWidget);
    expect(find.text('Ver vista previa'), findsNothing);
    expect(find.text('Usar esta cámara'), findsNothing);
    expect(find.text('Buscar de nuevo'), findsNothing);
    await tester.tap(find.text('Webcam USB HD'));
    await tester.pumpAndSettle();
    expect(find.text('¿En qué habitación está?'), findsNothing);
  });

  testWidgets(
    'sin consentimiento se pueden elegir, sin vista previa ni detección',
    (tester) async {
      await abrir(
        tester,
        Rutas.elegirCamaras('pc-sala'),
        consentimiento: false,
      );
      expect(find.text('Falta el consentimiento de Rosa'), findsOneWidget);
      await tocar(tester, find.text('Sala'));
      await tocar(tester, find.text('Usar esta cámara'));
      expect(
        find.text('Detectará caídas cuando registres el consentimiento.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('en la configuración, «Continuar» va al paso 4', (tester) async {
    await abrir(tester, Rutas.elegirCamaras('pc-sala', config: true));
    expect(find.text('Paso 3 de 5'), findsOneWidget);
    await tocar(tester, find.text('Continuar'));
    expect(find.text('Paso 4 de 5'), findsOneWidget);
  });

  group('Vista previa', () {
    testWidgets(
      'CA-29.7: muestra unos segundos, se cierra sola y se registra',
      (tester) async {
        await abrir(tester, Rutas.elegirCamaras('pc-sala'));
        await tocar(tester, find.text('Ver vista previa'));
        expect(pcs.vistasPrevias, ['w1']);
        expect(find.text('Vista previa · Webcam USB HD'), findsOneWidget);
        expect(
          find.text('Así sabes qué habitación ve esta cámara.'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
        expect(
          find.textContaining('VISTA PREVIA · 0:15', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.text(
            'No se graba. Tu acceso queda en el registro de la familia.',
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 3));
        expect(
          find.textContaining('VISTA PREVIA · 0:12', findRichText: true),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 12));
        await tester.pumpAndSettle();
        expect(find.text('Vista previa · Webcam USB HD'), findsNothing);
        expect(vivo.cerradas, ['vp-1']);
        expect(find.text('Acceso registrado'), findsOneWidget);
        expect(
          find.text(
            'Viste la vista previa de Webcam USB HD durante 15\u00a0s.',
          ),
          findsOneWidget,
        );
        expect(reproductores.ultimo.desechado, isTrue);
      },
    );

    testWidgets('«Cerrar» la termina antes y registra lo que duró', (
      tester,
    ) async {
      await abrir(tester, Rutas.elegirCamaras('pc-sala'));
      await tocar(tester, find.text('Ver vista previa'));
      await tester.pump(const Duration(seconds: 4));
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(vivo.cerradas, ['vp-1']);
      expect(
        find.text('Viste la vista previa de Webcam USB HD durante 4\u00a0s.'),
        findsOneWidget,
      );
    });

    testWidgets('dura lo que dura la sesión del backend si vence antes', (
      tester,
    ) async {
      pcs.expiraVistaPrevia = DateTime(2026, 9, 23, 10, 42, 11);
      await abrir(tester, Rutas.elegirCamaras('pc-sala'));
      await tocar(tester, find.text('Ver vista previa'));
      expect(
        find.textContaining('VISTA PREVIA · 0:05', findRichText: true),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Vista previa · Webcam USB HD'), findsNothing);
      expect(vivo.cerradas, ['vp-1']);
    });

    testWidgets('CA-29.7: en pausa dice por qué no se puede ver', (
      tester,
    ) async {
      pcs.webcams = [
        webcam(
          'w1',
          'Webcam USB HD',
          habitacion: 'Sala',
          pausadaHasta: DateTime(2026, 9, 23, 11, 42),
        ),
      ];
      await abrir(tester, Rutas.elegirCamaras('pc-sala'));
      expect(
        find.textContaining('En uso · Sala · en pausa', findRichText: true),
        findsOneWidget,
      );
      await tocar(tester, find.text('Webcam USB HD'));
      await tocar(tester, find.text('Ver vista previa'));
      expect(pcs.vistasPrevias, isEmpty);
      expect(
        find.text('No podemos mostrar lo que ve esta cámara ahora.'),
        findsOneWidget,
      );
      expect(find.text('La cámara está en pausa'), findsOneWidget);
      await tocar(tester, find.text('Cerrar'));
      expect(find.text('Acceso registrado'), findsNothing);
    });

    testWidgets('CA-05.2: sin consentimiento no hay vista previa', (
      tester,
    ) async {
      await abrir(
        tester,
        Rutas.elegirCamaras('pc-sala'),
        consentimiento: false,
      );
      await tocar(tester, find.text('Ver vista previa'));
      expect(pcs.vistasPrevias, isEmpty);
      expect(
        find.text(
          'Sin el consentimiento de Rosa no hay video, tampoco para la vista '
          'previa.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('si el backend dice que se desconectó, lo explica', (
      tester,
    ) async {
      pcs.errorVistaPrevia = const ProblemaApi(
        codigo: 'CAMARA_DESCONECTADA',
        detalle: 'Desconectada',
      );
      await abrir(tester, Rutas.elegirCamaras('pc-sala'));
      await tocar(tester, find.text('Ver vista previa'));
      expect(find.text('La cámara está desconectada'), findsOneWidget);
      expect(vivo.cerradas, isEmpty);
    });
  });

  group('Detalle de la cámara', () {
    setUp(() {
      camaras = CamarasRepositorioFalso([camaraSalaPc]);
      pcs = PcsRepositorioFalso();
    });

    testWidgets('dice en qué PC y qué webcam es', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ajustes de la cámara'));
      expect(find.text('PC Sala-Rosa'), findsOneWidget);
      expect(find.textContaining('Webcam USB HD · desde el'), findsOneWidget);
    });

    testWidgets('CA-29.2: «Dejar de usar esta cámara» pide confirmar', (
      tester,
    ) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ajustes de la cámara'));
      await tocar(tester, find.text('Dejar de usar esta cámara'));
      expect(
        find.text('¿Dejar de usar la cámara Webcam USB HD?'),
        findsOneWidget,
      );
      await tocar(tester, find.text('Dejar de usar'));
      expect(pcs.dejadas, ['c1']);
      expect(
        find.text('Dejamos de usar la cámara Webcam USB HD'),
        findsOneWidget,
      );
    });

    testWidgets('CA-29.9: el familiar invitado no puede dejar de usarla', (
      tester,
    ) async {
      await abrir(tester, Rutas.camara('c1'), sesion: sesionInvitado);
      await tocar(tester, find.text('Ajustes de la cámara'));
      expect(find.text('Solo ver'), findsOneWidget);
      expect(find.text('Dejar de usar esta cámara'), findsNothing);
    });
  });

  group('Nombre de la habitación', () {
    setUp(() {
      camaras = CamarasRepositorioFalso([camaraSalaPc]);
      pcs = PcsRepositorioFalso(
        habitaciones: [
          ambiente('Sala', camara: 'c1'),
          ambiente('Dormitorio', camara: 'c2'),
        ],
      );
    });

    testWidgets('CA-29.3: las habitaciones con otra cámara no se eligen', (
      tester,
    ) async {
      await abrir(tester, Rutas.nombreCamara('c1'));
      expect(find.text('Ya tiene cámara'), findsOneWidget);
      expect(
        find.text('Las habitaciones que ya tienen cámara no se pueden elegir.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'dormitorio');
      await tocar(tester, find.text('Guardar nombre'));
      expect(
        find.text(
          'Ya hay una cámara en el Dormitorio. Por ahora, cada habitación usa '
          'una sola cámara.',
        ),
        findsOneWidget,
      );
      expect(camaras.renombradas, isEmpty);
    });

    testWidgets('el backend también responde que la habitación tiene cámara', (
      tester,
    ) async {
      camaras = _CamarasOcupadas([camaraSalaPc]);
      await abrir(tester, Rutas.nombreCamara('c1'));
      await tester.enterText(find.byType(TextField), 'Comedor');
      await tocar(tester, find.text('Guardar nombre'));
      expect(
        find.text(
          'Ya hay una cámara en el Comedor. Por ahora, cada habitación usa una '
          'sola cámara.',
        ),
        findsOneWidget,
      );
    });
  });
}

class _CamarasOcupadas extends CamarasRepositorioFalso {
  _CamarasOcupadas(super.camaras);

  @override
  Future<Camara> renombrar(String camaraId, String nombreHabitacion) async =>
      throw const ProblemaApi(
        codigo: 'AMBIENTE_OCUPADO',
        detalle: 'Ocupado',
        extras: {'ambiente': 'Comedor'},
      );
}
