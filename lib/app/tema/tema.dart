import 'package:flutter/material.dart';

import 'colores.dart';

const _fuente = 'AtkinsonHyperlegibleNext';

/// Fuente monoespaciada para horas y datos tabulares (10:42).
const fuenteMono = 'AtkinsonHyperlegibleMono';

TextStyle _peso(double tamano, double peso, {Color color = Colores.tinta}) =>
    TextStyle(
      fontFamily: _fuente,
      fontSize: tamano,
      color: color,
      fontVariations: [FontVariation('wght', peso)],
    );

/// Tema de la app: base neutra y serena; el color semántico solo aparece cuando algo pide atención.
ThemeData temaTeTengo() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.morado,
    primary: Colores.morado,
    error: Colores.caida,
    surface: Colores.tarjeta,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondo,
    fontFamily: _fuente,
    textTheme: TextTheme(
      headlineMedium: _peso(28, 800),
      titleLarge: _peso(22, 700),
      titleMedium: _peso(18, 700),
      bodyLarge: _peso(17, 400),
      bodyMedium: _peso(16, 400, color: Colores.tinta2),
      labelLarge: _peso(16, 700),
    ),
    cardTheme: const CardThemeData(
      color: Colores.tarjeta,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colores.tarjeta,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
  );
}
