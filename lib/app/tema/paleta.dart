import 'package:flutter/material.dart';

import 'colores.dart';

/// The tokens that change with the phone's theme (`.screen.dark` in the prototype).
///
/// Light is [Colores]; dark follows the prototype's dark palette. Colors that do not change (the
/// severity floods, brand, the live view's night) stay in [Colores]. Read them with
/// `context.colores`.
@immutable
class Paleta extends ThemeExtension<Paleta> {
  const Paleta({
    required this.oscura,
    required this.fondo,
    required this.fondo2,
    required this.tarjeta,
    required this.tinta,
    required this.tinta2,
    required this.tinta3,
    required this.linea,
    required this.linea2,
    required this.moradoSuave,
    required this.moradoTinta,
    required this.caidaSuave,
    required this.caidaTinta,
    required this.inestableSuave,
    required this.inestableTinta,
    required this.calmaSuave,
    required this.calmaTinta,
    required this.aviso,
    required this.avisoSuave,
    required this.avisoTinta,
    required this.pausa,
    required this.pausaSuave,
    required this.botonPrimario,
    required this.inversa,
    required this.sobreInversa,
    required this.hoja,
    required this.barra,
    required this.barraClip,
    required this.errorTexto,
    required this.marcador,
    required this.sombra,
  });

  final bool oscura;
  final Color fondo;
  final Color fondo2;
  final Color tarjeta;
  final Color tinta;
  final Color tinta2;
  final Color tinta3;
  final Color linea;
  final Color linea2;
  final Color moradoSuave;
  final Color moradoTinta;
  final Color caidaSuave;
  final Color caidaTinta;
  final Color inestableSuave;
  final Color inestableTinta;
  final Color calmaSuave;
  final Color calmaTinta;
  final Color aviso;
  final Color avisoSuave;
  final Color avisoTinta;
  final Color pausa;
  final Color pausaSuave;

  /// Background of the primary button (`.btn-primary`).
  final Color botonPrimario;

  /// Ink buttons, the selected chip, step numbers and toasts (`.btn-ink`): ink in light, inverted
  /// (light on dark) in dark.
  final Color inversa;
  final Color sobreInversa;

  /// Sheets and dialogs (`.sheet`, `.dialog`).
  final Color hoja;

  /// The tab bar and the docked button area (`.tabbar`, `.dock`).
  final Color barra;

  /// The clip bar (`.clip-bar`).
  final Color barraClip;

  /// Body text of an error notice (`.notice.err span`).
  final Color errorTexto;

  /// Placeholder of a text field.
  final Color marcador;

  /// `--shadow-1`.
  final List<BoxShadow> sombra;

  static const clara = Paleta(
    oscura: false,
    fondo: Colores.fondo,
    fondo2: Colores.fondo2,
    tarjeta: Colores.tarjeta,
    tinta: Colores.tinta,
    tinta2: Colores.tinta2,
    tinta3: Colores.tinta3,
    linea: Colores.linea,
    linea2: Colores.linea2,
    moradoSuave: Colores.moradoSuave,
    moradoTinta: Colores.moradoTinta,
    caidaSuave: Colores.caidaSuave,
    caidaTinta: Colores.caidaTinta,
    inestableSuave: Colores.inestableSuave,
    inestableTinta: Colores.inestableTinta,
    calmaSuave: Colores.calmaSuave,
    calmaTinta: Colores.calmaTinta,
    aviso: Colores.aviso,
    avisoSuave: Colores.avisoSuave,
    avisoTinta: Colores.avisoTinta,
    pausa: Colores.pausa,
    pausaSuave: Colores.pausaSuave,
    botonPrimario: Colores.morado,
    inversa: Colores.tinta,
    sobreInversa: Color(0xFFFFFFFF),
    hoja: Colores.tarjeta,
    barra: Color(0xF5FFFFFF),
    barraClip: Colores.tinta,
    errorTexto: Color(0xFF6E1A10),
    marcador: Color(0xFF77708A),
    sombra: [
      BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 4)),
    ],
  );

  static const oscuraTeTengo = Paleta(
    oscura: true,
    fondo: Color(0xFF14111B),
    fondo2: Color(0xFF1E1A27),
    tarjeta: Color(0xFF221D2D),
    tinta: Color(0xFFF2EFF8),
    tinta2: Color(0xFFD2CBE0),
    tinta3: Color(0xFFA9A1BA),
    linea: Color(0xFF3A3347),
    linea2: Color(0xFF4C4459),
    moradoSuave: Color(0xFF2F2547),
    moradoTinta: Color(0xFFCDBBF5),
    caidaSuave: Color(0xFF3B1D1A),
    caidaTinta: Color(0xFFFF9E90),
    inestableSuave: Color(0xFF3A2F14),
    inestableTinta: Color(0xFFF5CB66),
    calmaSuave: Color(0xFF173323),
    calmaTinta: Color(0xFF86DDAE),
    aviso: Color(0xFFF2B65E),
    avisoSuave: Color(0xFF3A2B13),
    avisoTinta: Color(0xFFF7D9A6),
    pausa: Color(0xFFAEB8CC),
    pausaSuave: Color(0xFF272C37),
    botonPrimario: Color(0xFF6A47B0),
    inversa: Color(0xFFF2EFF8),
    sobreInversa: Color(0xFF14111B),
    hoja: Color(0xFF262033),
    barra: Color(0xF5221D2D),
    barraClip: Color(0xFF0E0B14),
    errorTexto: Color(0xFFFFC9C0),
    marcador: Color(0xFFA9A1BA),
    sombra: [
      BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  @override
  Paleta copyWith() => this;

  /// Theme changes swap the palette at once: no color is half-way between light and dark.
  @override
  Paleta lerp(Paleta? other, double t) =>
      other == null || t < .5 ? this : other;
}

extension ColoresDelTema on BuildContext {
  /// The palette of the current theme (light or dark).
  Paleta get colores => Theme.of(this).extension<Paleta>() ?? Paleta.clara;
}
