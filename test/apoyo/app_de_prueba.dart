import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:te_tengo/app/app.dart';
import 'package:te_tengo/app/router.dart';
import 'package:te_tengo/app/tema/tema.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';

import 'adaptador_falso.dart';

/// A screen alone, inside the theme, with fake repositories in [overrides].
Widget pantallaDePrueba(
  Widget pantalla, {
  List<Override> overrides = const [],
  Sesion? sesion,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    almacenSesionProvider.overrideWithValue(AlmacenSesionMemoria(sesion)),
    adaptadorHttpProvider.overrideWithValue(AdaptadorFalso()),
    ...overrides,
  ],
  child: MaterialApp(theme: temaTeTengo(), home: pantalla),
);

/// The whole app with its router, starting at [ubicacion].
Widget appDePrueba({
  required String ubicacion,
  Sesion? sesion,
  AlmacenSesion? almacen,
  List<Override> overrides = const [],
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    almacenSesionProvider.overrideWithValue(
      almacen ?? AlmacenSesionMemoria(sesion),
    ),
    adaptadorHttpProvider.overrideWithValue(AdaptadorFalso()),
    ubicacionInicialProvider.overrideWithValue(ubicacion),
    ...overrides,
  ],
  child: const TeTengoApp(),
);
