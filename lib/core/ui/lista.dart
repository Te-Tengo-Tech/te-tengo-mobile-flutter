import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';

/// White rounded list (`.list`) with a divider between rows.
class ListaTarjeta extends StatelessWidget {
  const ListaTarjeta({super.key, required this.children, this.borde = false});

  final List<Widget> children;

  /// Inset border instead of a shadow (lists inside sheets).
  final bool borde;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colores.tarjeta,
        borderRadius: BorderRadius.circular(22),
        border: borde
            ? Border.all(color: context.colores.linea, width: 1.5)
            : null,
        boxShadow: borde ? null : sombraTarjeta,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// `--shadow-1`.
const sombraTarjeta = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 4)),
];

/// Row of a list (`.row`): leading, title, subtitle, trailing; ≥ 64 px tall.
class FilaLista extends StatelessWidget {
  const FilaLista({
    super.key,
    this.inicio,
    required this.titulo,
    this.subtitulo,
    this.subtituloRico,
    this.debajo,
    this.fin,
    this.alTocar,
    this.peligro = false,
    this.chevron,
  });

  final Widget? inicio;
  final String titulo;
  final String? subtitulo;
  final InlineSpan? subtituloRico;

  /// Extra content below the subtitle (a tag, for example).
  final Widget? debajo;
  final Widget? fin;
  final VoidCallback? alTocar;
  final bool peligro;

  /// Shows the chevron; defaults to true when the row is tappable and has no [fin].
  final bool? chevron;

  @override
  Widget build(BuildContext context) {
    final mostrarChevron = chevron ?? (alTocar != null && fin == null);
    // With large text the trailing tag goes under the texts so nothing overflows.
    final finDebajo =
        fin != null && MediaQuery.textScalerOf(context).scale(16) > 24;
    final subtituloEstilo = estiloTexto(15, 400, color: context.colores.tinta3);
    final contenido = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (inicio != null) ...[inicio!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: estiloTexto(
                      17,
                      700,
                      color: peligro
                          ? context.colores.caidaTinta
                          : context.colores.tinta,
                    ),
                  ),
                  if (subtituloRico != null)
                    Text.rich(subtituloRico!, style: subtituloEstilo)
                  else if (subtitulo != null)
                    Text(subtitulo!, style: subtituloEstilo),
                  ?debajo,
                  if (finDebajo) ...[const SizedBox(height: 6), fin!],
                ],
              ),
            ),
            if (fin != null && !finDebajo) ...[const SizedBox(width: 8), fin!],
            if (mostrarChevron) ...[
              const SizedBox(width: 8),
              Icono(Ico.chevR, tamano: 22, color: context.colores.tinta3),
            ],
          ],
        ),
      ),
    );
    if (alTocar == null) return contenido;
    return InkWell(onTap: alTocar, child: contenido);
  }
}

/// Square icon of a row (`.row .ico`): 44 px, soft purple, or soft red in danger rows.
class IconoFila extends StatelessWidget {
  const IconoFila(this.icono, {super.key, this.peligro = false});

  final Ico icono;
  final bool peligro;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: peligro ? context.colores.caidaSuave : context.colores.moradoSuave,
      borderRadius: BorderRadius.circular(14),
    ),
    alignment: Alignment.center,
    child: Icono(
      icono,
      tamano: 24,
      color: peligro ? context.colores.caidaTinta : context.colores.moradoTinta,
    ),
  );
}

/// Section heading (`.sec-h`) with an optional link on the right.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion(
    this.titulo, {
    super.key,
    this.accion,
    this.arriba = 28,
  });

  final String titulo;
  final Widget? accion;
  final double arriba;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: arriba, bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              titulo,
              style: estiloTexto(18, 800, color: context.colores.tinta),
            ),
          ),
        ),
        ?accion,
      ],
    ),
  );
}

/// Underlined text link (`.link`), with a 48 px touch target.
class Enlace extends StatelessWidget {
  const Enlace(
    this.texto, {
    super.key,
    required this.alTocar,
    this.tamano = 16,
  });

  final String texto;
  final VoidCallback? alTocar;
  final double tamano;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: alTocar,
    style: TextButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: estiloTexto(tamano, 700, color: context.colores.tinta)
          .copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 1.5,
          ),
    ),
    child: Text(texto),
  );
}

/// Avatar tones of the prototype.
enum TonoAvatar { morado, azul, arena, rosa }

/// Round avatar with initials (`.avatar`).
class Avatar extends StatelessWidget {
  const Avatar(
    this.iniciales, {
    super.key,
    this.tono = TonoAvatar.morado,
    this.tamano = 44,
  });

  final String iniciales;
  final TonoAvatar tono;
  final double tamano;

  static String inicialesDe(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final (fondo, tinta) = switch (tono) {
      TonoAvatar.morado => (
        context.colores.moradoSuave,
        context.colores.moradoTinta,
      ),
      TonoAvatar.azul => (Colores.avatarAzulFondo, Colores.avatarAzulTinta),
      TonoAvatar.arena => (Colores.avatarArenaFondo, Colores.avatarArenaTinta),
      TonoAvatar.rosa => (Colores.avatarRosaFondo, Colores.avatarRosaTinta),
    };
    return ExcludeSemantics(
      child: Container(
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
        child: Text(iniciales, style: estiloTexto(16, 800, color: tinta)),
      ),
    );
  }
}

/// Day heading of grouped lists (`.day-h`).
class EncabezadoDia extends StatelessWidget {
  const EncabezadoDia(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
    child: Semantics(
      header: true,
      child: Text(
        texto,
        style: estiloTexto(15, 800, color: context.colores.tinta2),
      ),
    ),
  );
}
