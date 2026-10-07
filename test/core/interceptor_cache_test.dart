import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/features/ajustes/data/preferencias.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';

import '../apoyo/adaptador_falso.dart';
import '../apoyo/app_de_prueba.dart';
import '../apoyo/datos.dart';
import '../apoyo/dispositivo_falso.dart';

const _camaras = [
  {
    'id': 'c1',
    'nombreHabitacion': 'Sala',
    'estadoConexion': 'EN_LINEA',
    'ultimaSenal': '2026-09-23T15:42:00Z',
    'pausadaHasta': null,
    'deteccionConfiable': true,
  },
];

const _hogar = {
  'hogarId': 'h-1',
  'rol': 'TITULAR',
  'adultoMayor': {
    'nombre': 'Rosa Huamán',
    'direccion': 'Jr. Los Pinos 482, San Miguel',
    'convivencia': 'SOLO',
  },
  'consentimiento': {
    'otorgadoEn': '2026-08-03T15:00:00Z',
    'otorgadoPor': 'Rosa Huamán',
    'registradoPor': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
    'vistaEnVivoAceptada': true,
    'vigente': true,
  },
};

void main() {
  late AdaptadorFalso http;
  late CacheMemoria cache;
  late AlmacenSesionMemoria almacen;

  ProviderContainer contenedor([Sesion sesion = sesionTitular]) {
    almacen = AlmacenSesionMemoria(sesion);
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(almacen),
        adaptadorHttpProvider.overrideWithValue(http),
        cacheLocalProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    http = AdaptadorFalso()
      ..cuando('GET', '/api/camaras', const Respuesta(200, _camaras))
      ..cuando(
        'GET',
        '/api/alertas',
        const Respuesta(200, {'elementos': [], 'total': 0}),
      );
    cache = CacheMemoria();
  });

  test('sin conexión devuelve la última respuesta guardada', () async {
    final c = contenedor();
    final repo = c.read(camarasRepositorioProvider);
    expect((await repo.listar()).single.nombreHabitacion, 'Sala');
    await Future<void>.delayed(Duration.zero);
    expect(cache.datos.keys, ['h-1|/api/camaras?']);
    http.sinConexion = true;
    expect((await repo.listar()).single.nombreHabitacion, 'Sala');
  });

  test('cada página del historial se guarda con su consulta', () async {
    final c = contenedor();
    await c.read(alertasRepositorioProvider).listar(const FiltroAlertas());
    await Future<void>.delayed(Duration.zero);
    expect(cache.datos.keys.single, 'h-1|/api/alertas?pagina=0&tamano=50');
  });

  test('los datos de un hogar no se muestran en otro', () async {
    await contenedor().read(camarasRepositorioProvider).listar();
    await Future<void>.delayed(Duration.zero);
    http.sinConexion = true;
    final otro = contenedor(
      const Sesion(
        tokenAcceso: 'a',
        tokenRefresco: 'r',
        usuario: usuarioCarmen,
        hogarId: 'h-2',
        rol: Rol.titular,
      ),
    );
    await expectLater(
      otro.read(camarasRepositorioProvider).listar(),
      throwsA(
        isA<ProblemaApi>().having(
          (p) => p.codigo,
          'codigo',
          ProblemaApi.sinConexion,
        ),
      ),
    );
  });

  test('al cerrar sesión se borran los datos del hogar, no las preferencias '
      'del celular', () async {
    final c = contenedor();
    await c.read(camarasRepositorioProvider).listar();
    await c
        .read(almacenPreferenciasProvider)
        .guardar(const PreferenciasNotificaciones(inestables: false));
    await Future<void>.delayed(Duration.zero);
    expect(cache.datos, hasLength(2));
    http
      ..cuando('DELETE', '/api/sesiones/actual', const Respuesta(204))
      ..cuando('DELETE', '/api/sesiones', const Respuesta(204));
    await c.read(sesionControllerProvider.notifier).cerrar();
    expect(cache.datos.keys, ['dispositivo|preferencias']);
    expect(
      (await c.read(almacenPreferenciasProvider).cargar()).inestables,
      isFalse,
    );
  });

  testWidgets('sin conexión la app muestra la cámara guardada', (tester) async {
    cache.datos
      ..['h-1|/api/camaras?'] = jsonEncode(_camaras)
      ..['h-1|/api/hogar?'] = jsonEncode(_hogar);
    http.sinConexion = true;
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.camara('c1'),
        sesion: sesionTitular,
        http: http,
        cache: cache,
        conectividad: ConectividadFalsa(hay: false),
        overrides: [
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cámara · Sala'), findsOneWidget);
    expect(find.text('En línea'), findsOneWidget);
    expect(find.text('Pausar esta cámara'), findsOneWidget);
  });
}
