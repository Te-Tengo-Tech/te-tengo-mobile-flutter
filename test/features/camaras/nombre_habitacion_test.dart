import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:flutter/material.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'repositorio_falso.dart';

class _CamarasQueFallan extends CamarasRepositorioFalso {
  _CamarasQueFallan(this.error);

  final ProblemaApi error;

  @override
  Future<Camara> renombrar(String camaraId, String nombreHabitacion) async =>
      throw error;
}

Finder get campoNombre => find.descendant(
  of: find.widgetWithText(CampoTexto, 'Nombre de la habitación'),
  matching: find.byType(TextField),
);

void main() {
  late CamarasRepositorioFalso camaras;

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
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
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

  setUp(() => camaras = CamarasRepositorioFalso());

  testWidgets(
    'CA-06.1: la cámara instalada aparece con el nombre de la instalación',
    (tester) async {
      await abrir(tester, Rutas.configCamara);
      expect(find.text('Tu cámara ya está lista'), findsOneWidget);
      expect(find.text('Sala'), findsOneWidget);
      expect(find.text('En línea'), findsOneWidget);
      expect(find.text('22 sep 2026'), findsOneWidget);
      expect(find.text('Equipo del proyecto'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);
    },
  );

  testWidgets(
    'CA-06.2: la titular cambia el nombre y se usa en las próximas alertas',
    (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      expect(find.text('Cámara · Sala'), findsOneWidget);
      await tocar(
        tester,
        find.text('Cambiar el nombre que aparece en las alertas'),
      );
      expect(find.text('¿Cómo se llama esta habitación?'), findsOneWidget);
      await tocar(tester, find.text('Sala comedor'));
      expect(find.text('Posible caída en la Sala comedor'), findsOneWidget);
      camaras.camaras = [
        const Camara(
          id: 'c1',
          nombreHabitacion: 'Sala comedor',
          estado: EstadoConexion.enLinea,
        ),
      ];
      await tocar(tester, find.text('Guardar nombre'));
      expect(camaras.renombradas, {'c1': 'Sala comedor'});
      expect(find.text('Nombre guardado: Sala comedor'), findsOneWidget);
      expect(
        find.text('Las próximas alertas dirán «en la Sala comedor».'),
        findsOneWidget,
      );
      expect(find.text('Cámara · Sala comedor'), findsOneWidget);
    },
  );

  testWidgets('CA-06.3: no permite guardar el nombre vacío', (tester) async {
    await abrir(tester, Rutas.camara('c1'));
    await tocar(
      tester,
      find.text('Cambiar el nombre que aparece en las alertas'),
    );
    await tester.enterText(campoNombre, '   ');
    await tester.pump();
    expect(find.text('Posible caída …'), findsOneWidget);
    await tocar(tester, find.text('Guardar nombre'));
    expect(find.text('Escribe el nombre de la habitación.'), findsOneWidget);
    expect(camaras.renombradas, isEmpty);
  });

  testWidgets('en la configuración vuelve al paso de la cámara', (
    tester,
  ) async {
    await abrir(tester, Rutas.configCamara);
    await tocar(tester, find.text('Cambiar el nombre'));
    expect(find.text('Paso 3 de 4'), findsOneWidget);
    await tester.enterText(campoNombre, 'cocina');
    await tocar(tester, find.text('Guardar nombre'));
    expect(camaras.renombradas, {'c1': 'Cocina'});
    expect(find.text('¿Cómo se llama esta habitación?'), findsNothing);
    expect(find.text('Cambiar el nombre'), findsOneWidget);
  });

  testWidgets('un familiar invitado no puede cambiar el nombre', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'), sesion: sesionInvitado);
    expect(find.text('Nombre que aparece en las alertas'), findsOneWidget);
    expect(find.text('Solo ver'), findsOneWidget);
    expect(
      find.text(
        'Solo Carmen (titular) puede cambiar el nombre de la habitación.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Cambiar el nombre que aparece en las alertas'),
      findsNothing,
    );
  });

  testWidgets('403 SOLO_TITULAR muestra el mensaje del backend', (
    tester,
  ) async {
    camaras = _CamarasQueFallan(
      const ProblemaApi(
        codigo: 'SOLO_TITULAR',
        detalle: 'Solo la titular puede hacer esto.',
        estado: 403,
      ),
    );
    await abrir(tester, Rutas.camara('c1'));
    await tocar(
      tester,
      find.text('Cambiar el nombre que aparece en las alertas'),
    );
    await tocar(tester, find.text('Guardar nombre'));
    expect(find.text('Solo la titular puede hacer esto.'), findsOneWidget);
  });

  group('CamarasRepositorioApi', () {
    ProviderContainer contenedor(AdaptadorFalso http) {
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('GET /api/camaras lee el contrato completo', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'GET',
          '/api/camaras',
          const Respuesta(200, [
            {
              'id': 'c1',
              'nombreHabitacion': 'Sala',
              'estadoConexion': 'EN_LINEA',
              'ultimaSenal': '2026-10-07T15:04:31Z',
              'pausadaHasta': '2026-10-07T16:04:31Z',
              'deteccionConfiable': false,
            },
          ]),
        );
      final c = (await contenedor(
        http,
      ).read(camarasRepositorioProvider).listar()).single;
      expect(c.enPausa, isTrue);
      expect(c.deteccionConfiable, isFalse);
      expect(c.estadoVisible(conConsentimiento: true), EstadoVisible.enPausa);
      expect(c.estadoVisible(conConsentimiento: false), EstadoVisible.detenida);
    });

    test('PATCH /api/camaras/{id} con nombreHabitacion', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'PATCH',
          '/api/camaras/c1',
          const Respuesta(200, {
            'id': 'c1',
            'nombreHabitacion': 'Cocina',
            'estadoConexion': 'EN_LINEA',
            'ultimaSenal': null,
            'pausadaHasta': null,
            'deteccionConfiable': true,
          }),
        );
      final c = await contenedor(
        http,
      ).read(camarasRepositorioProvider).renombrar('c1', 'Cocina');
      expect(c.nombreHabitacion, 'Cocina');
      expect(http.peticiones.single.data, {'nombreHabitacion': 'Cocina'});
    });

    test('422 CAMARA_NOMBRE_VACIO', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'PATCH',
          '/api/camaras/c1',
          Respuesta.problema(422, 'CAMARA_NOMBRE_VACIO'),
        );
      await expectLater(
        contenedor(http).read(camarasRepositorioProvider).renombrar('c1', ''),
        throwsA(
          isA<ProblemaApi>().having(
            (p) => p.codigo,
            'codigo',
            'CAMARA_NOMBRE_VACIO',
          ),
        ),
      );
    });
  });
}
