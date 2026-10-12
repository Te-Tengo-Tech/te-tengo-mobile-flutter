import 'package:flutter/material.dart';

import 'colores.dart';

/// The tokens that change with the phone's theme (`.screen.dark` in the prototype) and with
/// «Aumentar el contraste» (`.screen.hc`).
///
/// Light is [Colores]; dark follows the prototype's dark palette; [claraContraste] and
/// [oscuraContraste] are the prototype's high-contrast tokens (darker ink, or white in dark, marked
/// lines and borders, cards outlined instead of shadowed). Colors that do not change (the severity
/// floods, brand, the live view's night) stay in [Colores]: the alerts keep their color. Read them
/// with `context.colores`.
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
    required this.coralSuave,
    required this.coralTinta,
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
    this.contraste = false,
    this.anchoBorde = 1.5,
    this.anchoDivisor = 1,
    this.interruptorApagado,
  });

  final bool oscura;

  /// «Aumentar el contraste» is on (`.screen.hc`).
  final bool contraste;

  /// Width of the borders of chips, choices, fields and outlined cards: 1.5, or 2 with more
  /// contrast.
  final double anchoBorde;

  /// Width of the dividers between rows: 1, or 1.5 with more contrast.
  final double anchoDivisor;

  /// Track of a switch that is off; [linea2] when null. More contrast makes it visible.
  final Color? interruptorApagado;
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

  /// Tinted circle behind a coral icon, and the selected tab (`--coral-soft`).
  final Color coralSuave;

  /// Coral for text and icons on [coralSuave], cream or a card (`--coral-ink`).
  final Color coralTinta;
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
    coralSuave: Colores.coralSuave,
    coralTinta: Colores.coralTinta,
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
    // `--shadow-1`: a 1 px lilac border and a very soft violet shadow.
    sombra: [
      BoxShadow(color: Colores.linea, spreadRadius: 1),
      BoxShadow(color: Color(0x0F4B2E83), blurRadius: 20, offset: Offset(0, 6)),
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
    coralSuave: Color(0xFF3D2329),
    coralTinta: Color(0xFFFFAB9E),
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

  /// High contrast in light (`.screen.hc`): darker ink, marked lines, outlined cards.
  static final claraContraste = clara._conContraste(
    tinta: const Color(0xFF140B2E),
    tinta2: const Color(0xFF2B1D4E),
    tinta3: const Color(0xFF3D3357),
    linea: const Color(0xFF8C82A0),
    linea2: const Color(0xFF4F4566),
    moradoSuave: const Color(0xFFECE4F7),
    moradoTinta: const Color(0xFF36196B),
    coralTinta: const Color(0xFF86291B),
    caidaTinta: const Color(0xFF841C12),
    inestableTinta: const Color(0xFF4F3500),
    calmaTinta: const Color(0xFF0B4529),
    aviso: const Color(0xFF6B3D00),
    pausa: const Color(0xFF353F56),
    inversa: const Color(0xFF140B2E),
    marcador: const Color(0xFF3D3357),
    contorno: const Color(0xFF4F4566),
    interruptorApagado: const Color(0xFF6E6585),
  );

  /// High contrast in dark (`.screen.dark.hc`): white ink on a deeper background.
  static final oscuraContraste = oscuraTeTengo._conContraste(
    fondo: const Color(0xFF0A0810),
    fondo2: const Color(0xFF14101C),
    tarjeta: const Color(0xFF1A1524),
    tinta: const Color(0xFFFFFFFF),
    tinta2: const Color(0xFFEFEAF8),
    tinta3: const Color(0xFFD9D2E6),
    linea: const Color(0xFF8E85A3),
    linea2: const Color(0xFFBDB5CE),
    moradoSuave: const Color(0xFF2E2448),
    moradoTinta: const Color(0xFFE4D9FF),
    coralTinta: const Color(0xFFFFC6BD),
    caidaTinta: const Color(0xFFFFB6AA),
    inestableTinta: const Color(0xFFFFD98A),
    calmaTinta: const Color(0xFFA9EDC8),
    aviso: const Color(0xFFFFCD80),
    pausa: const Color(0xFFCAD2E1),
    inversa: const Color(0xFFFFFFFF),
    sobreInversa: const Color(0xFF0A0810),
    hoja: const Color(0xFF1E1829),
    barra: const Color(0xFA1A1524),
    marcador: const Color(0xFFD9D2E6),
    contorno: const Color(0xFFBDB5CE),
    interruptorApagado: const Color(0xFF8E85A3),
  );

  /// The palette for a theme: light or dark, with or without more contrast.
  static Paleta de({bool oscuro = false, bool contraste = false}) =>
      switch ((oscuro, contraste)) {
        (false, false) => clara,
        (true, false) => oscuraTeTengo,
        (false, true) => claraContraste,
        (true, true) => oscuraContraste,
      };

  Paleta _conContraste({
    required Color tinta,
    required Color tinta2,
    required Color tinta3,
    required Color linea,
    required Color linea2,
    required Color moradoSuave,
    required Color moradoTinta,
    required Color coralTinta,
    required Color caidaTinta,
    required Color inestableTinta,
    required Color calmaTinta,
    required Color aviso,
    required Color pausa,
    required Color inversa,
    required Color marcador,
    required Color contorno,
    required Color interruptorApagado,
    Color? fondo,
    Color? fondo2,
    Color? tarjeta,
    Color? sobreInversa,
    Color? hoja,
    Color? barra,
  }) => Paleta(
    oscura: oscura,
    fondo: fondo ?? this.fondo,
    fondo2: fondo2 ?? this.fondo2,
    tarjeta: tarjeta ?? this.tarjeta,
    tinta: tinta,
    tinta2: tinta2,
    tinta3: tinta3,
    linea: linea,
    linea2: linea2,
    moradoSuave: moradoSuave,
    moradoTinta: moradoTinta,
    coralSuave: coralSuave,
    coralTinta: coralTinta,
    caidaSuave: caidaSuave,
    caidaTinta: caidaTinta,
    inestableSuave: inestableSuave,
    inestableTinta: inestableTinta,
    calmaSuave: calmaSuave,
    calmaTinta: calmaTinta,
    aviso: aviso,
    avisoSuave: avisoSuave,
    avisoTinta: avisoTinta,
    pausa: pausa,
    pausaSuave: pausaSuave,
    botonPrimario: botonPrimario,
    inversa: inversa,
    sobreInversa: sobreInversa ?? this.sobreInversa,
    hoja: hoja ?? this.hoja,
    barra: barra ?? this.barra,
    barraClip: barraClip,
    errorTexto: errorTexto,
    marcador: marcador,
    // Cards are outlined instead of shadowed (`--shadow-1: 0 0 0 1.5px`).
    sombra: [BoxShadow(color: contorno, spreadRadius: 1.5)],
    contraste: true,
    anchoBorde: 2,
    anchoDivisor: 1.5,
    interruptorApagado: interruptorApagado,
  );

  /// Track of a switch that is off.
  Color get pistaApagada => interruptorApagado ?? linea2;

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
