import 'package:flutter/material.dart';

import 'colores.dart';
import 'paleta.dart';

/// Poppins, the typeface of the brand kit, for the whole interface (DESIGN.md, Typography): Bold
/// in headings, SemiBold in buttons and row titles, Regular in the body.
const fuente = 'Poppins';

/// Poppins text at [tamano] and weight [peso] (400, 500, 600 or 700; heavier asks are drawn
/// Bold, the heaviest weight bundled). Pass the ink of the current theme (`context.colores.tinta`)
/// or a color for a fixed surface (an alert flood).
TextStyle estiloTexto(
  double tamano,
  double peso, {
  Color color = Colores.tinta,
}) => TextStyle(
  fontFamily: fuente,
  fontSize: tamano,
  color: color,
  fontWeight: _pesoFijo(peso),
);

FontWeight _pesoFijo(double peso) => switch (peso) {
  >= 700 => FontWeight.w700,
  >= 600 => FontWeight.w600,
  >= 500 => FontWeight.w500,
  _ => FontWeight.w400,
};

/// Times and data (`.mono`): Poppins with tabular figures, so «10:42» does not jump; no second
/// family (DESIGN.md).
TextStyle estiloMono({double tamano = 16, double peso = 600, Color? color}) =>
    TextStyle(
      fontFamily: fuente,
      fontSize: tamano,
      color: color,
      fontWeight: _pesoFijo(peso),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Tabular figures for a time inside other text (`.mono`), with the font of the surrounding text.
const estiloCifras = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

/// App theme: calm neutral base; semantic color appears only when something needs attention.
/// [oscuro] gives the dark theme of the prototype (`.screen.dark`); the app follows the phone's
/// unless this device chose «Claro» or «Oscuro» in Ajustes › «Preferencias» (`aparienciaProvider`).
/// [contraste] is «Aumentar el contraste» (`.screen.hc`): darker ink, thicker borders and dividers,
/// outlined cards and a visible off switch; the severity colors do not change.
///
/// Text scale (prototype classes): `headlineMedium` = `.t-title`, `titleLarge` = `.t-h2`,
/// `titleMedium` = `.t-h3`, `bodyLarge` = `.t-body`, `bodyMedium` = `.t-small`,
/// `bodySmall` = `.t-meta`. Body text is never below 16 (DESIGN.md accessibility).
ThemeData temaTeTengo({bool oscuro = false, bool contraste = false}) {
  final p = Paleta.de(oscuro: oscuro, contraste: contraste);
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
      border: borde(p.linea2, p.anchoBorde),
      enabledBorder: borde(p.linea2, p.anchoBorde),
      focusedBorder: borde(oscuro ? p.moradoTinta : Colores.morado, 2),
      errorBorder: borde(Colores.caida, 2),
      focusedErrorBorder: borde(Colores.caida, 2.5),
      disabledBorder: borde(p.linea2, p.anchoBorde),
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
        side: BorderSide(color: p.linea2, width: p.anchoBorde),
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
    dividerTheme: DividerThemeData(
      color: p.linea,
      space: p.anchoDivisor,
      thickness: p.anchoDivisor,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: oscuro ? p.moradoTinta : Colores.morado,
    ),
  );
}

/// The light theme, for surfaces that look the same in dark mode (the alert flood).
final temaClaroTeTengo = temaTeTengo();
