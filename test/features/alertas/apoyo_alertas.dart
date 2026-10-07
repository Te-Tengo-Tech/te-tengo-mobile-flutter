import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'alertas_falso.dart';

/// Opens the app with the alert fakes; returns the dialed numbers.
Future<List<String?>> abrirConAlertas(
  WidgetTester tester, {
  required String ubicacion,
  required AlertasRepositorioFalso alertas,
  DateTime? ahora,
  Sesion sesion = sesionTitular,
  NotificacionesPushFalsas? push,
  List<Override> overrides = const [],
}) async {
  final llamadas = <String?>[];
  usarTelefono(tester);
  await tester.pumpWidget(
    appDePrueba(
      ubicacion: ubicacion,
      sesion: sesion,
      push: push,
      overrides: [
        alertasRepositorioProvider.overrideWithValue(alertas),
        camarasRepositorioProvider.overrideWithValue(CamarasRepositorioFalso()),
        hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
        familiaRepositorioProvider.overrideWithValue(FamiliaRepositorioFalso()),
        relojProvider.overrideWithValue(
          () => ahora ?? DateTime(2026, 9, 23, 10, 42, 20),
        ),
        llamarProvider.overrideWithValue((t) async => llamadas.add(t)),
        ...overrides,
      ],
    ),
  );
  await tester.pumpAndSettle();
  return llamadas;
}
