import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import 'lista.dart';

/// Colors of the fill of a card (`.band`).
enum Banda { calma, caida, inestable, morado, pausa, aviso }

/// The color of a [Banda] and the one of what is written on it: white on all but amber, which
/// takes ink. All pairs reach 4.5:1.
extension ColoresDeBanda on Banda {
  Color get fondo => switch (this) {
    Banda.calma => Colores.calma,
    Banda.caida => Colores.caida,
    Banda.inestable => Colores.inestable,
    Banda.pausa => Colores.pausa,
    Banda.aviso => Colores.aviso,
    Banda.morado => Colores.morado,
  };

  Color get texto => this == Banda.inestable ? Colores.tinta : Colors.white;
}

/// Tells what sits inside a [TarjetaBanda] that it is on a filled card, for the pieces that draw
/// their own colors (severity tags, buttons).
class SobreBanda extends InheritedWidget {
  const SobreBanda({super.key, required this.banda, required super.child});

  final Banda banda;

  static Banda? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SobreBanda>()?.banda;

  @override
  bool updateShouldNotify(SobreBanda old) => old.banda != banda;
}

/// Card (`.card`) filled with the color of the state when it has a [banda]: the whole card is red
/// for a fall, green when calm, amber when unstable. What is inside reads on that fill: ink,
/// lines, icons, tags and buttons take the foreground color through the theme.
class TarjetaBanda extends StatelessWidget {
  const TarjetaBanda({
    super.key,
    this.banda,
    required this.child,
    this.relleno = const EdgeInsets.all(18),
    this.borde = false,
  }) : builder = null;

  /// A card whose content is built inside its own theme, for content that reads the theme (text
  /// styles, state colors) and so must see the foreground of the fill.
  const TarjetaBanda.construir({
    super.key,
    this.banda,
    required WidgetBuilder this.builder,
    this.relleno = const EdgeInsets.all(18),
    this.borde = false,
  }) : child = null;

  final Banda? banda;
  final Widget? child;
  final WidgetBuilder? builder;
  final EdgeInsets relleno;
  final bool borde;

  @override
  Widget build(BuildContext context) {
    final b = banda;
    final contenido = Padding(
      padding: relleno,
      child: builder == null ? child : Builder(builder: builder!),
    );
    return Container(
      decoration: BoxDecoration(
        color: b?.fondo ?? context.colores.tarjeta,
        borderRadius: BorderRadius.circular(22),
        border: borde
            ? Border.all(
                color: b == null ? context.colores.linea : b.fondo,
                width: context.colores.anchoBorde,
              )
            : null,
        boxShadow: borde ? null : sombraDe(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: b == null
          ? contenido
          : SobreBanda(
              banda: b,
              child: Theme(data: _temaSobre(context, b), child: contenido),
            ),
    );
  }

  static ThemeData _temaSobre(BuildContext context, Banda b) {
    final base = Theme.of(context);
    final paleta = context.colores.sobreColor(b.fondo, b.texto);
    final texto = b.texto;
    return base.copyWith(
      extensions: [
        ...base.extensions.values.where((e) => e is! Paleta),
        paleta,
      ],
      iconTheme: IconThemeData(color: texto),
      textTheme: base.textTheme.apply(bodyColor: texto, displayColor: texto),
      colorScheme: base.colorScheme.copyWith(
        onSurface: texto,
        onSurfaceVariant: texto,
        outline: paleta.linea2,
        outlineVariant: paleta.linea,
      ),
      dividerTheme: base.dividerTheme.copyWith(color: paleta.linea),
      textButtonTheme: TextButtonThemeData(
        style: base.textButtonTheme.style?.copyWith(
          foregroundColor: WidgetStatePropertyAll(texto),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: base.filledButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(texto),
          foregroundColor: WidgetStatePropertyAll(b.fondo),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: base.outlinedButtonTheme.style?.copyWith(
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStatePropertyAll(texto),
          side: WidgetStatePropertyAll(
            BorderSide(color: texto, width: paleta.anchoBorde),
          ),
        ),
      ),
    );
  }
}

/// Key-value row of a card (`.kv`).
class FilaDato extends StatelessWidget {
  const FilaDato({
    super.key,
    required this.clave,
    required this.valor,
    this.mono = false,
    this.valorRico,
  });

  final String clave;
  final String valor;
  final bool mono;
  final InlineSpan? valorRico;

  @override
  Widget build(BuildContext context) {
    final estiloValor = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: context.colores.tinta,
      fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              clave,
              style: TextStyle(fontSize: 16, color: context.colores.tinta3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: valorRico != null
                ? Text.rich(
                    valorRico!,
                    style: estiloValor,
                    textAlign: TextAlign.right,
                  )
                : Text(valor, style: estiloValor, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// Column of [FilaDato] separated by lines.
class DatosTarjeta extends StatelessWidget {
  const DatosTarjeta(this.filas, {super.key});

  final List<Widget> filas;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < filas.length; i++) ...[
        if (i > 0) const Divider(height: 1, thickness: 1),
        filas[i],
      ],
    ],
  );
}
