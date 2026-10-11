import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/push.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/presentation/piezas_pc.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/camaras_en_casa.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_webrtc.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../vivo/vivo_falso.dart';
import 'pcs_falso.dart';

final _senal = DateTime(2026, 9, 23, 10, 42);
final _caida = DateTime(2026, 9, 23, 9, 58);

Camara camara(
  String id,
  String habitacion,
  String pcId, {
  EstadoConexion estado = EstadoConexion.enLinea,
  DateTime? pausadaHasta,
  bool confiable = true,
}) => Camara(
  id: id,
  nombreHabitacion: habitacion,
  estado: estado,
  ultimaSenal: estado == EstadoConexion.enLinea
      ? _senal
      : DateTime(2026, 9, 23, 10, 31),
  pausadaHasta: pausadaHasta,
  deteccionConfiable: confiable,
  pcId: pcId,
  nombreDispositivo: 'Webcam de $habitacion',
);

Pc pc(
  String id,
  String nombre,
  List<Camara> camaras, {
  bool sinConexion = false,
  int sinUsar = 0,
}) => Pc(
  id: id,
  nombre: nombre,
  sistemaOperativo: 'Windows 11 Home',
  versionAgente: '0.5.0',
  estado: sinConexion ? EstadoConexion.desconectada : EstadoConexion.enLinea,
  ultimaSenal: sinConexion ? _caida : _senal,
  vinculadaEn: DateTime(2026, 8, 3),
  vinculadaPor: (id: 'u-carmen', nombre: 'Carmen Huamán'),
  camaras: camaras,
  camarasSinUsar: sinUsar,
);

/// The prototype's household: Sala-Rosa with the Sala, Dormitorio and Pasillo, Cocina-Rosa with the
/// Cocina (screen 144).
({List<Pc> pcs, List<Camara> camaras}) casaDeRosa({
  bool cocinaSinConexion = false,
  DateTime? pasilloHasta,
  int sinUsar = 0,
}) {
  final sala = [
    camara('c1', 'Sala', 'pc-sala'),
    camara('c2', 'Dormitorio', 'pc-sala'),
    camara('c3', 'Pasillo', 'pc-sala', pausadaHasta: pasilloHasta),
  ];
  final cocina = [
    camara(
      'c4',
      'Cocina',
      'pc-cocina',
      estado: cocinaSinConexion
          ? EstadoConexion.desconectada
          : EstadoConexion.enLinea,
    ),
  ];
  return (
    pcs: [
      pc('pc-sala', 'Sala-Rosa', sala, sinUsar: sinUsar),
      pc('pc-cocina', 'Cocina-Rosa', cocina, sinConexion: cocinaSinConexion),
    ],
    camaras: [...sala, ...cocina],
  );
}

void main() {
  late PcsRepositorioFalso pcs;
  late CamarasRepositorioFalso camaras;
  late VistaEnVivoRepositorioFalso vivo;
  late NotificacionesPushFalsas push;

  void usarCasa(({List<Pc> pcs, List<Camara> camaras}) casa) {
    pcs.pcs = casa.pcs;
    camaras.camaras = casa.camaras;
  }

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    bool consentimiento = true,
  }) async {
    usarTelefono(tester);
    final reproductores = FabricaReproductorFalsa();
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        push: push,
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

  setUp(() {
    pcs = PcsRepositorioFalso();
    camaras = CamarasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
    push = NotificacionesPushFalsas(tokenActual: 'fcm-prueba');
    usarCasa(casaDeRosa());
  });

  group('resumen de las cámaras', () {
    List<CamaraEnCasa> enCasa(
      ({List<Pc> pcs, List<Camara> camaras}) casa, {
      bool consentimiento = true,
    }) => camarasEnCasa(
      casa.camaras,
      casa.pcs,
      conConsentimiento: consentimiento,
    );

    test('la tarjeta dice cuántas funcionan', () {
      expect(
        lineaTarjetaCamaras(enCasa(casaDeRosa()), conConsentimiento: true),
        '4 de 4 funcionan',
      );
      expect(
        lineaTarjetaCamaras(
          enCasa(casaDeRosa(cocinaSinConexion: true)),
          conConsentimiento: true,
        ),
        '3 de 4 funcionan',
      );
      expect(
        lineaTarjetaCamaras(const [], conConsentimiento: true),
        'Sin cámaras',
      );
      expect(
        lineaTarjetaCamaras(enCasa(casaDeRosa()), conConsentimiento: false),
        'Detenidas',
      );
      final una = enCasa((
        pcs: const [],
        camaras: [camara('c1', 'Sala', 'pc-sala')],
      ));
      expect(
        lineaTarjetaCamaras(una, conConsentimiento: true),
        'Funciona · Sala',
      );
    });

    test('la página resume el estado de todas', () {
      final todas = resumenCamaras(
        enCasa(casaDeRosa()),
        conConsentimiento: true,
      );
      expect(
        (todas.ok, todas.cuantas, todas.estado),
        (true, '4 cámaras', 'todas funcionan bien'),
      );
      final dos = resumenCamaras(
        enCasa(
          casaDeRosa(
            cocinaSinConexion: true,
            pasilloHasta: DateTime(2026, 9, 23, 11, 42),
          ),
        ),
        conConsentimiento: true,
      );
      expect((dos.ok, dos.estado), (false, '2 funcionan bien'));
    });

    test('CA-30.3: las cámaras de una PC sin conexión la nombran', () {
      final cocina = enCasa(casaDeRosa(cocinaSinConexion: true)).last;
      expect(cocina.estado, EstadoVisible.sinConexion);
      expect(cocina.necesitaAtencion, isTrue);
      expect(cocina.vivoDisponible, isFalse);
    });
  });

  group('Cámaras', () {
    testWidgets('CA-30.2: por habitación, con las PCs de la casa', (
      tester,
    ) async {
      await abrir(tester, Rutas.pcs);
      expect(find.text('Cámaras'), findsOneWidget);
      expect(
        find.textContaining('todas funcionan bien', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Necesitan atención'), findsNothing);
      expect(find.text('Funcionando'), findsOneWidget);
      for (final h in ['Sala', 'Dormitorio', 'Pasillo', 'Cocina']) {
        expect(find.bySemanticsLabel('$h, En línea'), findsOneWidget);
      }
      await verHasta(tester, find.text('PCs de la casa'));
      expect(find.text('Sala-Rosa'), findsWidgets);
      expect(
        find.textContaining('3 cámaras · En línea', findRichText: true),
        findsOneWidget,
      );
      await verHasta(tester, find.text('Agregar PC'));
      expect(find.text('Una cámara por habitación.'), findsOneWidget);
      await tocar(tester, find.text('Agregar PC'));
      expect(find.text('Vincula la PC de la casa'), findsOneWidget);
    });

    testWidgets('con varias PCs filtra por PC', (tester) async {
      await abrir(tester, Rutas.pcs);
      // The chips slide sideways when they do not fit.
      await tocar(tester, find.text('Cocina-Rosa').first);
      expect(find.bySemanticsLabel('Cocina, En línea'), findsOneWidget);
      expect(find.bySemanticsLabel('Sala, En línea'), findsNothing);
      await tocar(tester, find.text('Todas'));
      expect(find.bySemanticsLabel('Sala, En línea'), findsOneWidget);
    });

    testWidgets(
      'CA-30.3: una PC sin conexión y una cámara en pausa van primero',
      (tester) async {
        usarCasa(
          casaDeRosa(
            cocinaSinConexion: true,
            pasilloHasta: DateTime(2026, 9, 23, 11, 42),
          ),
        );
        await abrir(tester, Rutas.pcs);
        expect(
          find.textContaining('2 funcionan bien', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('Necesitan atención'), findsOneWidget);
        expect(find.text('Pasillo en pausa'), findsOneWidget);
        expect(
          find.textContaining(
            'Hasta las 11:42 · se reactiva sola',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(find.text('Cocina sin conexión'), findsOneWidget);
        expect(
          find.textContaining(
            'La PC Cocina-Rosa no responde desde las 09:58',
            findRichText: true,
          ),
          findsOneWidget,
        );
        await tocar(tester, find.text('Reanudar ahora'));
        expect(camaras.reanudaciones, 1);
        // The toast goes away on its own.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        await tocar(tester, find.text('Qué revisar'));
        expect(find.text('Que la PC esté encendida'), findsOneWidget);
        await verHasta(tester, find.text('Cámaras de esta PC'));
      },
    );

    testWidgets('CA-29.2: una webcam sin usar pide elegir su habitación', (
      tester,
    ) async {
      usarCasa(casaDeRosa(sinUsar: 1));
      await abrir(tester, Rutas.pcs);
      expect(find.text('1 cámara sin usar'), findsOneWidget);
      expect(
        find.textContaining('elige en qué habitación está', findRichText: true),
        findsOneWidget,
      );
      await tocar(tester, find.text('Elegir las cámaras'));
      expect(find.text('Elige las cámaras'), findsOneWidget);
    });

    testWidgets('una PC sin cámaras elegidas lo dice', (tester) async {
      pcs.pcs = [
        ...casaDeRosa().pcs.take(1),
        pc('pc-cocina', 'Cocina-Rosa', const []),
      ];
      camaras.camaras = casaDeRosa().camaras.take(3).toList();
      await abrir(tester, Rutas.pcs);
      expect(find.text('PC Cocina-Rosa'), findsOneWidget);
      expect(find.text('Elegir las cámaras'), findsOneWidget);
    });

    testWidgets('sin consentimiento, las cámaras están detenidas', (
      tester,
    ) async {
      await abrir(tester, Rutas.pcs, consentimiento: false);
      expect(find.text('Falta el consentimiento'), findsOneWidget);
      expect(find.text('Detenidas'), findsOneWidget);
      expect(
        find.textContaining('detenidas', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('sin PCs, invita a agregar la primera', (tester) async {
      usarCasa((pcs: const [], camaras: const []));
      await abrir(tester, Rutas.pcs);
      expect(find.text('Aún no hay una PC vinculada'), findsOneWidget);
      expect(find.text('Agregar PC'), findsOneWidget);
    });

    testWidgets('CA-30.2: el familiar invitado la ve sin poder cambiarla', (
      tester,
    ) async {
      usarCasa(casaDeRosa(sinUsar: 1));
      await abrir(tester, Rutas.pcs, sesion: sesionInvitado);
      expect(find.text('Solo ver'), findsOneWidget);
      expect(find.text('1 cámara sin usar'), findsOneWidget);
      expect(find.text('Elegir las cámaras'), findsNothing);
      await verHasta(
        tester,
        find.text('Solo Carmen (titular) puede agregar o quitar PCs.'),
      );
      expect(find.text('Agregar PC'), findsNothing);
    });

    for (final (nombre, escala, oscuro) in [
      ('normal', 1.0, false),
      ('con la letra al 200 % y en modo oscuro', 2.0, true),
    ]) {
      testWidgets('con 8 habitaciones en 2 PCs entra todo ($nombre)', (
        tester,
      ) async {
        tester.platformDispatcher
          ..textScaleFactorTestValue = escala
          ..platformBrightnessTestValue = oscuro
              ? Brightness.dark
              : Brightness.light;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        final sala = [
          for (final h in ['Sala', 'Comedor', 'Dormitorio', 'Pasillo'])
            camara('s-$h', h, 'pc-sala'),
        ];
        final cocina = [
          for (final h in ['Cocina', 'Patio', 'Estudio', 'Dormitorio 2'])
            camara('k-$h', h, 'pc-cocina'),
        ];
        usarCasa((
          pcs: [
            pc('pc-sala', 'Sala-Rosa', sala),
            pc('pc-cocina', 'Cocina-Rosa', cocina),
          ],
          camaras: [...sala, ...cocina],
        ));
        await abrir(tester, Rutas.pcs);
        expect(
          find.textContaining('8 cámaras', findRichText: true),
          findsOneWidget,
        );
        await verHasta(tester, find.bySemanticsLabel('Dormitorio 2, En línea'));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await abrir(tester, Rutas.inicio);
        await verHasta(tester, find.text('+4'));
        expect(find.text('8 de 8 funcionan'), findsOneWidget);
        await tocar(tester, find.text('Ver en vivo'));
        expect(find.text('Disponible ahora'), findsNWidgets(8));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Detalle de la PC', () {
    testWidgets('CA-30.2: su versión, sus datos y sus cámaras', (tester) async {
      await abrir(tester, Rutas.pc('pc-sala'));
      expect(find.text('Windows 11 Home'), findsOneWidget);
      expect(find.text('Te Tengo Captura 0.5.0'), findsWidgets);
      expect(find.text('03/08/2026 por Carmen'), findsOneWidget);
      expect(find.text('Cámaras de esta PC'), findsOneWidget);
      await verHasta(tester, find.text('Usa otra cámara o deja de usar una'));
    });

    testWidgets('CA-31.4: quitarla pide confirmar con sus habitaciones', (
      tester,
    ) async {
      await abrir(tester, Rutas.pcs);
      await verHasta(tester, find.text('PCs de la casa'));
      await tocar(tester, find.text('Sala-Rosa').last);
      await tocar(tester, find.text('Quitar esta PC'));
      expect(find.text('¿Quitar la PC Sala-Rosa?'), findsOneWidget);
      expect(
        find.text(
          'Dejaremos de detectar caídas en Sala, Dormitorio y Pasillo. La PC '
          'volverá a mostrar su QR.',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.text('Cancelar'));
      expect(pcs.quitadas, isEmpty);
    });

    testWidgets('CA-31.1: quitada, deja de verse con sus cámaras', (
      tester,
    ) async {
      await abrir(tester, Rutas.pcs);
      await verHasta(tester, find.text('PCs de la casa'));
      await tocar(tester, find.text('Cocina-Rosa').last);
      await tocar(tester, find.text('Quitar esta PC'));
      camaras.camaras = casaDeRosa().camaras.take(3).toList();
      await tocar(tester, find.text('Quitar la PC'));
      expect(pcs.quitadas, ['pc-cocina']);
      expect(find.text('Quitamos la PC Cocina-Rosa'), findsOneWidget);
      expect(find.text('Cocina-Rosa'), findsNothing);
      expect(find.bySemanticsLabel('Cocina, En línea'), findsNothing);
    });

    testWidgets(
      'CA-31.2: quitada sin conexión, dejará de capturar al conectarse',
      (tester) async {
        usarCasa(casaDeRosa(cocinaSinConexion: true));
        await abrir(tester, Rutas.pc('pc-cocina'));
        expect(find.text('Qué revisar'), findsOneWidget);
        await tocar(tester, find.text('Quitar esta PC'));
        await tocar(tester, find.text('Quitar la PC'));
        expect(
          find.text('Dejará de capturar en cuanto se conecte.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('CA-31.5: el familiar invitado no puede quitarla', (
      tester,
    ) async {
      await abrir(tester, Rutas.pc('pc-sala'), sesion: sesionInvitado);
      await verHasta(
        tester,
        find.text(
          'Solo Carmen (titular) puede elegir las cámaras o quitar esta PC.',
        ),
      );
      expect(find.text('Quitar esta PC'), findsNothing);
      expect(find.text('Elegir las cámaras'), findsNothing);
    });

    testWidgets('CA-30.3: la cámara de una PC sin conexión dice qué revisar', (
      tester,
    ) async {
      usarCasa(casaDeRosa(cocinaSinConexion: true));
      await abrir(tester, Rutas.camara('c4'));
      expect(find.text('Sin conexión desde las 09:58'), findsOneWidget);
      await tocar(tester, find.text('Qué revisar'));
      expect(find.byType(QueRevisarPc), findsOneWidget);
      await tocar(tester, find.text('Ajustes de la cámara'));
      expect(find.text('PC Cocina-Rosa'), findsOneWidget);
    });
  });

  group('Inicio', () {
    testWidgets('la tarjeta «Cámaras» dice cuántas funcionan', (tester) async {
      await abrir(tester, Rutas.inicio);
      expect(find.text('4 cámaras cuidando. Sin eventos hoy.'), findsOneWidget);
      expect(find.text('4 de 4 funcionan'), findsOneWidget);
      // No list of cameras in Inicio.
      expect(find.text('Dormitorio'), findsNothing);
      await tocar(tester, find.text('Cámaras'));
      expect(find.text('Funcionando'), findsOneWidget);
    });

    testWidgets('CA-30.3: una PC sin conexión la dice la tarjeta de Rosa', (
      tester,
    ) async {
      usarCasa(casaDeRosa(cocinaSinConexion: true));
      await abrir(tester, Rutas.inicio);
      expect(find.text('1 cámara no responde · Cocina'), findsOneWidget);
      expect(
        find.text('No detectamos caídas en la Cocina. Las demás siguen.'),
        findsOneWidget,
      );
      expect(find.text('3 de 4 funcionan'), findsOneWidget);
      await tocar(tester, find.text('Ver qué revisar'));
      expect(find.text('Que la PC esté encendida'), findsOneWidget);
    });

    testWidgets('lo que la tarjeta no dice va en una sola fila', (
      tester,
    ) async {
      usarCasa(
        casaDeRosa(
          cocinaSinConexion: true,
          pasilloHasta: DateTime(2026, 9, 23, 11, 42),
        ),
      );
      await abrir(tester, Rutas.inicio);
      expect(find.text('2 de 4 funcionan'), findsOneWidget);
      await verHasta(tester, find.text('Pasillo en pausa'));
      expect(find.text('Pasillo en pausa'), findsOneWidget);
    });

    testWidgets(
      'CA-23.1: con varias cámaras, «Ver en vivo» pide la habitación',
      (tester) async {
        usarCasa(
          casaDeRosa(
            cocinaSinConexion: true,
            pasilloHasta: DateTime(2026, 9, 23, 11, 42),
          ),
        );
        await abrir(tester, Rutas.inicio);
        await tocar(tester, find.text('Ver en vivo'));
        expect(find.text('¿Qué habitación quieres ver?'), findsOneWidget);
        expect(find.text('Disponible ahora'), findsNWidgets(2));
        expect(
          find.textContaining('En pausa hasta las 11:42', findRichText: true),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Sin conexión · la PC Cocina-Rosa no responde',
            findRichText: true,
          ),
          findsOneWidget,
        );
        // Disabled rooms do nothing.
        await tester.tap(find.text('Cocina').last);
        await tester.pumpAndSettle();
        expect(vivo.abiertas, isEmpty);
        await tester.tap(find.text('Dormitorio').last);
        await tester.pumpAndSettle();
        expect(find.text('En vivo · Dormitorio'), findsOneWidget);
      },
    );

    testWidgets('sin PCs, la titular agrega la primera', (tester) async {
      usarCasa((pcs: const [], camaras: const []));
      await abrir(tester, Rutas.inicio);
      expect(find.text('Sin cámaras'), findsWidgets);
      expect(
        find.text('Vincula la PC de la casa para detectar caídas.'),
        findsOneWidget,
      );
      expect(find.text('Ver en vivo'), findsNothing);
      await tocar(tester, find.text('Agregar PC'));
      expect(find.text('Vincula la PC de la casa'), findsOneWidget);
    });

    testWidgets('con la PC sin cámaras, pide elegirlas', (tester) async {
      pcs.pcs = [pc('pc-sala', 'Sala-Rosa', const [], sinUsar: 3)];
      camaras.camaras = [];
      await abrir(tester, Rutas.inicio);
      expect(find.text('Falta elegir las cámaras.'), findsOneWidget);
      expect(find.text('Elegir las cámaras'), findsOneWidget);
    });

    testWidgets('el invitado sin PCs no ve «Agregar PC»', (tester) async {
      usarCasa((pcs: const [], camaras: const []));
      await abrir(tester, Rutas.inicio, sesion: sesionInvitado);
      expect(find.text('Agregar PC'), findsNothing);
    });
  });

  group('Ajustes', () {
    testWidgets('«Cámaras y PCs» resume las cámaras', (tester) async {
      await abrir(tester, Rutas.ajustes);
      expect(find.text('Cámaras y PCs'), findsOneWidget);
      expect(find.text('4 cámaras · 2 PCs'), findsOneWidget);
    });

    testWidgets('dice qué PC no responde', (tester) async {
      usarCasa(casaDeRosa(cocinaSinConexion: true));
      await abrir(tester, Rutas.ajustes);
      expect(find.text('Cocina-Rosa sin conexión'), findsOneWidget);
    });
  });

  group('PC_DESVINCULADA', () {
    test('tocar el aviso abre «Cámaras»', () {
      expect(
        rutaDePush(const MensajePush(tipo: TipoPush.pcDesvinculada)),
        Rutas.pcs,
      );
    });

    testWidgets('CA-31.3: con la app abierta, dice qué PC se desvinculó', (
      tester,
    ) async {
      await abrir(tester, Rutas.inicio);
      final casa = casaDeRosa();
      pcs.pcs = casa.pcs.take(1).toList();
      camaras.camaras = casa.camaras.take(3).toList();
      push.recibir(
        MensajePush(
          tipo: TipoPush.pcDesvinculada,
          ocurridaEn: DateTime.utc(2026, 9, 23, 15, 42),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('La PC Cocina-Rosa se desvinculó'), findsOneWidget);
      expect(find.text('Ya no detecta caídas en Cocina.'), findsOneWidget);
      expect(find.text('3 de 3 funcionan'), findsOneWidget);
      await tester.tap(find.text('La PC Cocina-Rosa se desvinculó'));
      await tester.pumpAndSettle();
      expect(find.text('PCs de la casa'), findsOneWidget);
    });
  });
}
