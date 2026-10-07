import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_vivo.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'vivo_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;
  late VistaEnVivoRepositorioFalso vivo;
  late TransmisionFalsa transmision;
  late List<String?> llamadas;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    AlertasRepositorioFalso? alertas,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            alertas ?? AlertasRepositorioFalso(),
          ),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          transmisionProvider.overrideWithValue(transmision.abrir),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
          llamarProvider.overrideWithValue((t) async => llamadas.add(t)),
          fabricaClipProvider.overrideWithValue(ClipFalso.new),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> esperar(WidgetTester tester, int segundos) async {
    for (var i = 0; i < segundos; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Camara sala({
    EstadoConexion estado = EstadoConexion.enLinea,
    DateTime? pausadaHasta,
  }) => Camara(
    id: 'c1',
    nombreHabitacion: 'Sala',
    estado: estado,
    ultimaSenal: DateTime(2026, 9, 23, 10, 31),
    pausadaHasta: pausadaHasta,
  );

  setUp(() {
    camaras = CamarasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
    transmision = TransmisionFalsa();
    llamadas = [];
  });

  testWidgets('CA-23.1 y CA-24.1: ve en vivo desde el inicio y al cerrar queda '
      'registrado', (tester) async {
    await abrir(tester, Rutas.inicio);
    await tocar(tester, find.text('Ver en vivo'));
    expect(find.byType(PantallaVivo), findsOneWidget);
    expect(vivo.abiertas, [('c1', null)]);
    expect(transmision.urls.single.toString(), 'wss://api.tetengo.pe/vivo/v-1');
    expect(find.text('En vivo · Sala'), findsOneWidget);
    await verHasta(tester, find.text('Cerrar la vista en vivo'));
    final ya = int.parse(
      RegExp(r'00:(\d\d)')
          .firstMatch(
            tester
                .widget<RichText>(
                  find.textContaining('EN VIVO', findRichText: true).last,
                )
                .text
                .toPlainText(),
          )!
          .group(1)!,
    );
    await esperar(tester, 37 - ya);
    expect(
      find.textContaining('EN VIVO · 00:37', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text(
        'Ves la Sala y la postura de Rosa en este momento. La transmisión no '
        'se graba.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Tu acceso queda en el registro que ve toda la familia: Carmen Huamán, '
        'desde las 10:42.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Llamar a Rosa'));
    await tester.pump();
    expect(llamadas, hasLength(1));
    await tester.tap(find.text('Cerrar la vista en vivo'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaVivo), findsNothing);
    expect(vivo.cerradas, ['v-1']);
    expect(find.text('Acceso registrado'), findsOneWidget);
    expect(
      find.text('Viste la Sala en vivo durante 37\u00a0s.'),
      findsOneWidget,
    );
  });

  testWidgets('cerrar con el botón del sistema también cierra la sesión', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('Disponible ahora'));
    await tocar(tester, find.text('Ver en vivo'));
    await esperar(tester, 2);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(vivo.cerradas, ['v-1']);
    expect(
      find.textContaining('Viste la Sala en vivo durante'),
      findsOneWidget,
    );
  });

  testWidgets('CA-23.2: desde una alerta muestra la habitación de la alerta', (
    tester,
  ) async {
    await abrir(
      tester,
      Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tocar(tester, find.text('Ver en vivo · Sala'));
    expect(vivo.abiertas, [('c1', 'a-1')]);
    expect(
      find.text(
        'Ves la habitación y la postura detectada. La transmisión no se graba.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Volver a la alerta'));
    expect(find.byType(PantallaAlerta), findsOneWidget);
    expect(vivo.cerradas, ['v-1']);
  });

  testWidgets('CA-23.3: con la cámara desconectada no está disponible', (
    tester,
  ) async {
    camaras.camaras = [sala(estado: EstadoConexion.desconectada)];
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('No disponible ahora'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.abiertas, isEmpty);
    expect(
      find.text('La cámara de la Sala no está disponible'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Perdió la conexión a las 10:31, así que no podemos mostrarte la '
        'habitación. Revisa el cable de la cámara, que la PC esté encendida y '
        'el internet de la casa.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Llamar a Rosa'), findsNothing);
    await tocar(tester, find.text('Cerrar la vista en vivo'));
    expect(vivo.cerradas, isEmpty);
    expect(find.text('Acceso registrado'), findsNothing);
  });

  testWidgets('CA-23.3: si el servidor responde CAMARA_DESCONECTADA', (
    tester,
  ) async {
    vivo.errorAbrir = const ProblemaApi(
      codigo: 'CAMARA_DESCONECTADA',
      detalle: 'La cámara está desconectada.',
      estado: 409,
    );
    await abrir(
      tester,
      Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tocar(tester, find.text('Ver en vivo · Sala'));
    expect(
      find.text('La cámara de la Sala no está disponible'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Llama a Rosa o pide a alguien cercano que vaya a verla.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Llamar a Rosa'), findsWidgets);
  });

  testWidgets(
    'CA-05.2: si el servidor responde SIN_CONSENTIMIENTO, la cámara está detenida',
    (tester) async {
      vivo.errorAbrir = const ProblemaApi(
        codigo: 'SIN_CONSENTIMIENTO',
        detalle: 'No hay un consentimiento vigente.',
        estado: 409,
      );
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      expect(vivo.abiertas, hasLength(1));
      expect(find.text('La cámara está detenida'), findsOneWidget);
      expect(
        find.text(
          'Sin el consentimiento de Rosa la cámara no envía video, así que no '
          'se puede ver en vivo.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('No hay un consentimiento vigente.'), findsNothing);
      expect(transmision.urls, isEmpty);
      expect(find.text('Llamar a Rosa'), findsNothing);
    },
  );

  testWidgets('CA-23.4: en pausa indica hasta qué hora y permite reanudar', (
    tester,
  ) async {
    camaras.camaras = [sala(pausadaHasta: DateTime(2026, 9, 23, 11, 42))];
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('No disponible hasta las 11:42'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.abiertas, isEmpty);
    expect(find.text('La vista en vivo no está disponible'), findsOneWidget);
    expect(
      find.textContaining(
        'La cámara de la Sala está en pausa hasta las 11:42. Podrás verla de '
        'nuevo a esa hora, o antes si reanudas la cámara.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Reanudar la cámara ahora'));
    expect(camaras.reanudaciones, 1);
    expect(vivo.abiertas, [('c1', null)]);
    expect(
      find.textContaining('EN VIVO · 00:00', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('CA-23.4: si el servidor responde CAMARA_EN_PAUSA', (
    tester,
  ) async {
    vivo.errorAbrir = const ProblemaApi(
      codigo: 'CAMARA_EN_PAUSA',
      detalle: 'La cámara está en pausa.',
      estado: 409,
      extras: {'pausadaHasta': '2026-09-23T16:42:00Z'},
    );
    await abrir(tester, Rutas.inicio);
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.textContaining(
        'en pausa hasta las ${DateTime.utc(2026, 9, 23, 16, 42).toLocal().hour}',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('un familiar invitado también puede verla en vivo', (
    tester,
  ) async {
    await abrir(tester, Rutas.inicio, sesion: sesionInvitado);
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.textContaining('Luis Huamán, desde las 10:42.', findRichText: true),
      findsOneWidget,
    );
  });

  test('marcos [8 bytes de marca de tiempo][JPEG]', () {
    expect(jpegDeFotograma([0, 0, 0, 0, 0, 0, 0, 1, 0xFF, 0xD8]), [0xFF, 0xD8]);
    expect(jpegDeFotograma([1, 2, 3]), isNull);
    expect(minutosSegundos(125), '02:05');
  });

  test(
    'POST /api/camaras/{id}/vista-en-vivo y DELETE /api/vista-en-vivo/{id}',
    () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/camaras/c1/vista-en-vivo',
          const Respuesta(201, {
            'sesionId': 'v-9',
            'urlTransmision': 'wss://api.tetengo.pe/vivo/v-9',
            'expiraEn': '2026-09-23T15:52:00Z',
          }),
        )
        ..cuando(
          'DELETE',
          '/api/vista-en-vivo/v-9',
          const Respuesta(204, null),
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
      final repo = c.read(vistaEnVivoRepositorioProvider);
      final s = await repo.abrir('c1', alertaId: 'a-1');
      expect(s.sesionId, 'v-9');
      expect(s.urlTransmision.scheme, 'wss');
      expect(http.peticiones.first.data, {'alertaId': 'a-1'});
      await repo.cerrar('v-9');
      expect(http.peticiones.last.method, 'DELETE');
    },
  );
}
