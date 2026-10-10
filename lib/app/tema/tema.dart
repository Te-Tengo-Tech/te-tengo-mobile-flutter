import 'package:flutter/material.dart';

import 'colores.dart';
import 'paleta.dart';

const fuente = 'AtkinsonHyperlegibleNext';

/// Monospaced font for times and tabular data (10:42).
const fuenteMono = 'AtkinsonHyperlegibleMono';

/// Atkinson text at [tamano] and weight [peso]. Pass the ink of the current theme
/// (`context.colores.tinta`) or a color for a fixed surface (an alert flood).
TextStyle estiloTexto(
  double tamano,
  double peso, {
  Color color = Colores.tinta,
}) => TextStyle(
  fontFamily: fuente,
  fontSize: tamano,
  color: color,
  fontWeight: _pesoFijo(peso),
  fontVariations: [FontVariation('wght', peso)],
);

FontWeight _pesoFijo(double peso) => switch (peso) {
  >= 800 => FontWeight.w800,
  >= 700 => FontWeight.w700,
  >= 600 => FontWeight.w600,
  _ => FontWeight.w400,
};

/// Times and data (`.mono`).
TextStyle estiloMono({double tamano = 16, double peso = 600, Color? color}) =>
    TextStyle(
      fontFamily: fuenteMono,
      fontSize: tamano,
      color: color,
      fontWeight: _pesoFijo(peso),
      fontVariations: [FontVariation('wght', peso)],
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// App theme: calm neutral base; semantic color appears only when something needs attention.
/// [oscuro] gives the dark theme of the prototype (`.screen.dark`); the app follows the phone's.
///
/// Text scale (prototype classes): `headlineMedium` = `.t-title`, `titleLarge` = `.t-h2`,
/// `titleMedium` = `.t-h3`, `bodyLarge` = `.t-body`, `bodyMedium` = `.t-small`,
/// `bodySmall` = `.t-meta`. Body text is never below 16 (DESIGN.md accessibility).
ThemeData temaTeTengo({bool oscuro = false}) {
  final p = oscuro ? Paleta.oscuraTeTengo : Paleta.clara;
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.morado,
    brightness: oscuro ? Brightness.dark : Brightness.light,
    primary: p.botonPrimario,
    onPrimary: Colors.white,
    error: oscuro ? p.caidaTinta : Colores.caida,
    surface: p.tarjeta,
    onSurface: p.tinta,
    onSurfaceVariant: p.tinta2,
    outline: p.linea2,
    outlineVariant: p.linea,
  );
  final botonTexto = estiloTexto(18, 700, color: p.tinta);
  final radioControl = const BorderRadius.all(Radius.circular(16));
  OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
    borderRadius: radioControl,
    borderSide: BorderSide(color: color, width: ancho),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: oscuro ? Brightness.dark : Brightness.light,
    colorScheme: esquema,
    extensions: [p],
    scaffoldBackgroundColor: p.fondo,
    canvasColor: p.fondo,
    fontFamily: fuente,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    iconTheme: IconThemeData(color: p.tinta),
    textTheme: TextTheme(
      headlineLarge: estiloTexto(34, 800, color: p.tinta),
      headlineMedium: estiloTexto(28, 800, color: p.tinta),
      titleLarge: estiloTexto(22, 800, color: p.tinta),
      titleMedium: estiloTexto(18, 700, color: p.tinta),
      bodyLarge: estiloTexto(17, 400, color: p.tinta),
      bodyMedium: estiloTexto(16, 400, color: p.tinta2),
      bodySmall: estiloTexto(15, 400, color: p.tinta3),
      labelLarge: estiloTexto(16, 700, color: p.tinta),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.fondo,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.tinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: estiloTexto(19, 800, color: p.tinta),
    ),
    cardTheme: CardThemeData(
      color: p.tarjeta,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.tarjeta,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      hintStyle: estiloTexto(17, 400, color: p.marcador),
      helperStyle: estiloTexto(15, 400, color: p.tinta3),
      helperMaxLines: 3,
      errorMaxLines: 3,
      errorStyle: estiloTexto(15, 700, color: p.caidaTinta),
      border: borde(p.linea2, 1.5),
      enabledBorder: borde(p.linea2, 1.5),
      focusedBorder: borde(oscuro ? p.moradoTinta : Colores.morado, 2),
      errorBorder: borde(Colores.caida, 2),
      focusedErrorBorder: borde(Colores.caida, 2.5),
      disabledBorder: borde(p.linea2, 1.5),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.botonPrimario,
        foregroundColor: Colors.white,
        disabledBackgroundColor: p.linea,
        disabledForegroundColor: p.tinta3,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        textStyle: botonTexto,
        shape: RoundedRectangleBorder(borderRadius: radioControl),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: p.tarjeta,
        foregroundColor: p.moradoTinta,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        textStyle: botonTexto,
        side: BorderSide(color: p.linea2, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: radioControl),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.moradoTinta,
        minimumSize: const Size(48, 48),
        textStyle: botonTexto,
        shape: RoundedRectangleBorder(borderRadius: radioControl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.inversa,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: estiloTexto(15, 400, color: p.sobreInversa),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.hoja,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: p.linea2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.hoja,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(26)),
      ),
      titleTextStyle: estiloTexto(22, 800, color: p.tinta),
      contentTextStyle: estiloTexto(16, 400, color: p.tinta2),
    ),
    dividerTheme: DividerThemeData(color: p.linea, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: oscuro ? p.moradoTinta : Colores.morado,
    ),
  );
}

/// The light theme, for surfaces that look the same in dark mode (the alert flood).
final temaClaroTeTengo = temaTeTengo();
