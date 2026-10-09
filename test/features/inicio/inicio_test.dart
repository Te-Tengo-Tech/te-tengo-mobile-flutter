import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../../apoyo/push_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;

  Future<void> abrir(
    WidgetTester tester, {
    PermisoFalso? permiso,
    ConectividadFalsa? conectividad,
    NotificacionesPushFalsas? push,
    DispositivosFalsos? dispositivos,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.inicio,
        sesion: sesionTitular,
        permiso: permiso,
        conectividad: conectividad,
        push: push,
        dispositivos: dispositivos,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => camaras = CamarasRepositorioFalso());

  testWidgets('muestra el saludo, la tarjeta de estado y la cámara', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.text('Miércoles 23 de septiembre'), findsOneWidget);
    expect(find.text('Hola, Carmen'), findsOneWidget);
    expect(find.text('Rosa Huamán, 78 años'), findsOneWidget);
    expect(find.text('Jr. Los Pinos 482, San Miguel'), findsOneWidget);
    expect(find.text('Todo tranquilo'), findsOneWidget);
    expect(
      find.text('Sin eventos hoy. La cámara de la Sala está funcionando.'),
      findsOneWidget,
    );
    expect(find.text('Cámara'), findsOneWidget);
    expect(
      find.textContaining('última señal 10:42', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Ver en vivo'), findsOneWidget);
    expect(
      find.text('Cuando quieras. Cada acceso queda registrado.'),
      findsOneWidget,
    );
    expect(find.text('Activa las notificaciones'), findsNothing);
    await tocar(tester, find.text('Ver detalle'));
    expect(find.text('Cámara · Sala'), findsOneWidget);
  });

  testWidgets('CA-16.3: con las notificaciones desactivadas pide activarlas', (
    tester,
  ) async {
    final permiso = PermisoFalso(activas: false);
    await abrir(tester, permiso: permiso);
    expect(find.text('Activa las notificaciones'), findsOneWidget);
    expect(
      find.text(
        'Están desactivadas en tu celular. Sin ellas no te enterarás de una caída cuando tengas la app cerrada.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Activar notificaciones'));
    expect(permiso.pedidos, 1);
    expect(find.text('Notificaciones activadas'), findsOneWidget);
    expect(find.text('Activa las notificaciones'), findsNothing);
  });

  testWidgets(
    'al activar las notificaciones registra el celular si recién hay token',
    (tester) async {
      // On iOS the token only exists after the permission is granted.
      final push = NotificacionesPushFalsas(permiso: false);
      final dispositivos = DispositivosFalsos();
      await abrir(
        tester,
        permiso: PermisoFalso(activas: false),
        push: push,
        dispositivos: dispositivos,
      );
      expect(dispositivos.registrados, isEmpty);
      push.tokenActual = 'fcm-1';
      await tocar(tester, find.text('Activar notificaciones'));
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
    },
  );

  testWidgets('sin internet lo indica en cada sección', (tester) async {
    final red = ConectividadFalsa(hay: false);
    await abrir(tester, conectividad: red);
    expect(find.text('Tu celular no tiene internet'), findsOneWidget);
    await tocar(tester, find.text('Familia'));
    expect(find.text('Tu celular no tiene internet'), findsOneWidget);
    red.cambiar(true);
    await tester.pumpAndSettle();
    expect(find.text('Tu celular no tiene internet'), findsNothing);
  });

  testWidgets('con la cámara desconectada ofrece ver qué revisar', (
    tester,
  ) async {
    camaras.camaras = [
      Camara(
        id: 'c1',
        nombreHabitacion: 'Sala',
        estado: EstadoConexion.desconectada,
        ultimaSenal: DateTime(2026, 9, 23, 10, 31),
      ),
    ];
    await abrir(tester);
    expect(find.text('La cámara está desconectada'), findsOneWidget);
    expect(
      find.textContaining('desde las 10:31', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Ver qué revisar'), findsOneWidget);
  });

  testWidgets('la cámara en pausa dice hasta qué hora', (tester) async {
    camaras.camaras = [
      Camara(
        id: 'c1',
        nombreHabitacion: 'Sala',
        estado: EstadoConexion.enLinea,
        pausadaHasta: DateTime(2026, 9, 23, 11, 42),
      ),
    ];
    await abrir(tester);
    expect(find.text('Todo tranquilo, con una pausa'), findsOneWidget);
    expect(
      find.text('La cámara de la Sala está en pausa hasta las 11:42.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('hasta las 11:42', findRichText: true),
      findsWidgets,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
