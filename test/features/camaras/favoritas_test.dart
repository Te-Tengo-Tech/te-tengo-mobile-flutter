import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/data/orden_camaras.dart';
import 'package:te_tengo/features/camaras/presentation/favorita.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/presentation/pantalla_camaras.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/presentation/elegir_habitacion.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/camaras_y_pcs_test.dart' show casaDeRosa, camara, pc;
import '../pcs/pcs_falso.dart';
import '../vivo/vivo_falso.dart';
import 'repositorio_falso.dart';

void main() {
  group('orden de este celular', () {
    const ids = ['c1', 'c2', 'c3', 'c4'];
    List<String> ordenadas(OrdenCamaras o) => o.ordenar(ids, (x) => x);

    test('sin elegir nada sigue el orden del backend', () {
      expect(ordenadas(const OrdenCamaras()), ids);
    });

    test('las favoritas van primero, cada grupo en el orden elegido', () {
      const o = OrdenCamaras(
        orden: ['c3', 'c1', 'c4', 'c2'],
        favoritas: {'c4', 'c2'},
      );
      expect(ordenadas(o), ['c4', 'c2', 'c3', 'c1']);
    });

    test('una cámara nueva va al final de su grupo', () {
      const o = OrdenCamaras(orden: ['c2', 'c1']);
      expect(ordenadas(o), ['c2', 'c1', 'c3', 'c4']);
    });

    test('mover no sale de su grupo', () {
      const o = OrdenCamaras(favoritas: {'c4'});
      // c4 is first; the others start at 1.
      expect(o.mover(ids, 'c1', 0)?.ordenar(ids, (x) => x), isNull);
      expect(o.puedeMover(ids, 'c1', -1), isFalse);
      expect(o.puedeMover(ids, 'c1', 1), isTrue);
      expect(o.puedeMover(ids, 'c4', 1), isFalse);
      expect(o.mover(ids, 'c3', 1)!.ordenar(ids, (x) => x), [
        'c4',
        'c3',
        'c1',
        'c2',
      ]);
    });

    test('se guarda y se lee; un valor dañado empieza de cero', () async {
      final cache = CacheMemoria();
      const o = OrdenCamaras(orden: ['c2', 'c1'], favoritas: {'c2'});
      await AlmacenOrdenCamarasLocal(cache).guardar(o);
      final leido = await AlmacenOrdenCamarasLocal(cache).cargar();
      expect(leido.orden, ['c2', 'c1']);
      expect(leido.favoritas, {'c2'});
      await cache.guardar(AlmacenOrdenCamarasLocal.clave, '{roto');
      expect((await AlmacenOrdenCamarasLocal(cache).cargar()).orden, isEmpty);
      await cache.vaciar();
      expect(cache.datos.containsKey(AlmacenOrdenCamarasLocal.clave), isTrue);
    });
  });

  group('CA-41.4 favoritas y «Ordenar»', () {
    late PcsRepositorioFalso pcs;
    late CamarasRepositorioFalso camaras;
    late CacheMemoria cache;

    setUp(() {
      pcs = PcsRepositorioFalso();
      camaras = CamarasRepositorioFalso();
      cache = CacheMemoria();
      final casa = casaDeRosa();
      pcs.pcs = casa.pcs;
      camaras.camaras = casa.camaras;
    });

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
          cache: cache,
          overrides: [
            pcsRepositorioProvider.overrideWithValue(pcs),
            camarasRepositorioProvider.overrideWithValue(camaras),
            vistaEnVivoRepositorioProvider.overrideWithValue(
              VistaEnVivoRepositorioFalso(),
            ),
            hogarRepositorioProvider.overrideWithValue(
              HogarRepositorioFalso(hogarDeRosa()),
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

    List<String> tarjetas(WidgetTester tester) => [
      for (final t in tester.widgetList<TarjetaHabitacion>(
        find.byType(TarjetaHabitacion),
      ))
        t.camara.habitacion,
    ];

    testWidgets('la estrella pone la habitación primero en «Cámaras» y se '
        'guarda solo en este celular', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, Rutas.pcs);
      expect(find.text('Ordenar'), findsOneWidget);
      expect(tarjetas(tester), ['Sala', 'Dormitorio', 'Pasillo', 'Cocina']);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Favorita: Cocina')),
        isSemantics(
          isButton: true,
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      await tocar(tester, find.bySemanticsLabel('Favorita: Cocina'));
      expect(tarjetas(tester), ['Cocina', 'Sala', 'Dormitorio', 'Pasillo']);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Favorita: Cocina')),
        isSemantics(isToggled: true, hasToggledState: true),
      );
      expect(
        OrdenCamaras.desdeJson(
          cache.datos[AlmacenOrdenCamarasLocal.clave],
        ).favoritas,
        {'c4'},
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantica.dispose();
    });

    testWidgets('«Ordenar» sube y baja dentro de cada grupo y la estrella la '
        'pasa al otro', (tester) async {
      await abrir(tester, Rutas.pcs);
      await tocar(tester, find.text('Ordenar'));
      expect(
        find.text('Favoritas primero. Solo en este celular.'),
        findsOneWidget,
      );
      // No favourites yet: one group.
      expect(find.text('Cámaras'), findsOneWidget);
      expect(find.text('Favoritas'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Subir Sala')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      await tester.tap(find.bySemanticsLabel('Bajar Sala'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Favorita: Cocina'));
      await tester.pumpAndSettle();
      expect(find.text('Favoritas'), findsOneWidget);
      expect(find.text('Las demás'), findsOneWidget);
      // Cocina is alone among the favourites: it cannot move.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bajar Cocina')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(tarjetas(tester), ['Cocina', 'Dormitorio', 'Sala', 'Pasillo']);
    });

    testWidgets('el mismo orden rige la hoja de habitaciones y sobrevive a '
        'reiniciar la app', (tester) async {
      await AlmacenOrdenCamarasLocal(cache).guardar(
        const OrdenCamaras(
          orden: ['c3', 'c4', 'c1', 'c2'],
          favoritas: {'c4', 'c3'},
        ),
      );
      await abrir(tester, Rutas.inicio);
      await tocar(tester, find.text('Ver en vivo'));
      final hoja = tester.widget<HojaElegirHabitacion>(
        find.byType(HojaElegirHabitacion),
      );
      expect(
        [for (final c in hoja.camaras) c.habitacion],
        ['Pasillo', 'Cocina', 'Sala', 'Dormitorio'],
      );
      expect(find.byType(MarcaFavorita), findsNWidgets(2));
    });

    testWidgets('el familiar invitado ordena las suyas', (tester) async {
      await abrir(tester, Rutas.ordenarCamaras, sesion: sesionInvitado);
      await tester.tap(find.bySemanticsLabel('Favorita: Pasillo'));
      await tester.pumpAndSettle();
      expect(find.text('Favoritas'), findsOneWidget);
    });

    testWidgets('con una sola cámara no aparece «Ordenar»', (tester) async {
      final sola = [camara('c1', 'Sala', 'pc-sala')];
      pcs.pcs = [pc('pc-sala', 'Sala-Rosa', sola)];
      camaras.camaras = sola;
      await abrir(tester, Rutas.pcs);
      expect(find.text('Ordenar'), findsNothing);
    });

    testWidgets('con el texto al 200 % no se desborda', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrir(tester, Rutas.ordenarCamaras);
      expect(tester.takeException(), isNull);
    });
  });
}
