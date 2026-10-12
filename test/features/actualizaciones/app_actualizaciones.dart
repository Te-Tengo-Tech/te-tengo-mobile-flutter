import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/actividad/data/actividad_repositorio.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../actividad/actividad_falso.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/pcs_falso.dart';

/// The whole app at [ubicacion] with the update's [actualizacion] overrides and every other
/// repository faked.
Future<void> abrirApp(
  WidgetTester tester,
  String ubicacion, {
  required List<Override> actualizacion,
  Sesion? sesion = sesionTitular,
  List<Alerta> alertas = const [],
  AlertasRepositorioFalso? repoAlertas,
  ConectividadFalsa? conectividad,
  List<Pc>? pcs,
  List<Override> mas = const [],
  List<String?>? llamadas,
  DateTime Function()? reloj,
}) async {
  usarTelefono(tester);
  await tester.pumpWidget(
    appDePrueba(
      ubicacion: ubicacion,
      sesion: sesion,
      conectividad: conectividad,
      overrides: [
        ...actualizacion,
        hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
        pcsRepositorioProvider.overrideWithValue(PcsRepositorioFalso(pcs: pcs)),
        actividadRepositorioProvider.overrideWithValue(
          ActividadRepositorioFalso(),
        ),
        camarasRepositorioProvider.overrideWithValue(CamarasRepositorioFalso()),
        familiaRepositorioProvider.overrideWithValue(FamiliaRepositorioFalso()),
        alertasRepositorioProvider.overrideWithValue(
          repoAlertas ?? AlertasRepositorioFalso([...alertas]),
        ),
        llamarProvider.overrideWithValue((t) async => llamadas?.add(t)),
        relojProvider.overrideWithValue(
          reloj ?? () => DateTime(2026, 10, 11, 10, 42),
        ),
        ...mas,
      ],
    ),
  );
  await tester.pumpAndSettle();
}

/// The text of a [Text] or rich text anywhere on screen.
Finder texto(String t) => find.text(t, findRichText: true);

/// The app's provider container.
ProviderContainer contenedorDe(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Navigator).first));
