import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';
import 'tarjeta.dart';

/// Button styles of the prototype (`.btn-*`).
enum EstiloBoton {
  primario,
  secundario,
  fantasma,
  peligro,
  peligroContorno,
  tinta,
  blanco,
  sobreRojo,
}

/// Full-width button, ≥ 56 px tall (48 for the ghost and small variants).
class Boton extends StatelessWidget {
  const Boton(
    this.texto, {
    super.key,
    required this.alPresionar,
    this.estilo = EstiloBoton.primario,
    this.icono,
    this.cargando = false,
    this.pequeno = false,
    this.colorTexto,
    this.textoCargando = 'Un momento…',
  });

  final String texto;
  final VoidCallback? alPresionar;
  final EstiloBoton estilo;
  final Ico? icono;
  final bool cargando;

  /// `.btn-sm`: inside notices.
  final bool pequeno;
  final Color? colorTexto;

  /// Shown instead of [texto] while [cargando] («Vinculando…»).
  final String textoCargando;

  @override
  Widget build(BuildContext context) {
    final sobre = SobreBanda.of(context);
    final (fondo, texto, borde) = switch (estilo) {
      // On a card filled with a state color the buttons are the color of its text, with the fill
      // as ink; the ghost one is outlined.
      EstiloBoton.primario ||
      EstiloBoton.tinta when sobre != null => (sobre.texto, sobre.fondo, null),
      EstiloBoton.secundario when sobre != null => (
        Colors.transparent,
        sobre.texto,
        sobre.texto,
      ),
      EstiloBoton.fantasma when sobre != null => (
        Colors.transparent,
        sobre.texto,
        null,
      ),
      EstiloBoton.primario => (
        context.colores.botonPrimario,
        Colors.white,
        null,
      ),
      // More contrast outlines it in its own purple (`.screen.hc .btn-secondary`).
      EstiloBoton.secundario => (
        context.colores.tarjeta,
        context.colores.moradoTinta,
        context.colores.contraste
            ? context.colores.moradoTinta
            : context.colores.linea2,
      ),
      EstiloBoton.fantasma => (
        Colors.transparent,
        context.colores.moradoTinta,
        null,
      ),
      EstiloBoton.peligro => (Colores.caida, Colors.white, null),
      EstiloBoton.peligroContorno => (
        Colors.transparent,
        context.colores.caidaTinta,
        const Color(0xFFE7B9B3),
      ),
      EstiloBoton.tinta => (
        context.colores.inversa,
        context.colores.sobreInversa,
        null,
      ),
      // Over the red flood: always white with the light red ink.
      EstiloBoton.blanco => (Colors.white, Colores.caidaTinta, null),
      EstiloBoton.sobreRojo => (
        const Color(0x24FFFFFF),
        Colors.white,
        const Color(0x8CFFFFFF),
      ),
    };
    final color = colorTexto ?? texto;
    final alto = pequeno || estilo == EstiloBoton.fantasma ? 48.0 : 56.0;
    final habilitado = alPresionar != null && !cargando;
    final hijo = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cargando) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
          ),
          const SizedBox(width: 10),
        ] else if (icono != null) ...[
          Icono(icono!, tamano: 22, color: color),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            cargando ? textoCargando : this.texto,
            textAlign: TextAlign.center,
            style: estiloTexto(pequeno ? 16 : 18, 700, color: color),
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: habilitado,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: alto,
          minWidth: pequeno ? 0 : double.infinity,
        ),
        child: Material(
          color: habilitado || estilo == EstiloBoton.fantasma
              ? fondo
              : (fondo == Colors.transparent ? fondo : context.colores.linea),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borde == null
                ? BorderSide.none
                : BorderSide(color: borde, width: context.colores.anchoBorde),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: habilitado ? alPresionar : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pequeno ? 16 : 22,
                vertical: 10,
              ),
              child: Opacity(
                opacity: habilitado || cargando ? 1 : 0.6,
                child: Center(
                  widthFactor: pequeno ? 1 : null,
                  heightFactor: 1,
                  child: hijo,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
