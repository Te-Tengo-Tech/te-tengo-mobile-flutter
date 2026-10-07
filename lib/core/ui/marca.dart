import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';

/// «La T que sostiene»: the bar of the T curves like two open arms, the dot is the person and the
/// stem holds them (DESIGN.md, Brand).
String svgSimbolo({required bool oscuro}) {
  final trazo = oscuro ? '#FFFFFF' : '#4A2A85';
  final punto = oscuro ? '#FFB59C' : '#E8765A';
  return '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">'
      '<g fill="none" stroke="$trazo" stroke-width="13" stroke-linecap="round">'
      '<path d="M60 60 V96"/><path d="M22 38 Q60 80 98 38"/></g>'
      '<circle cx="60" cy="38" r="11" fill="$punto"/></svg>';
}

class SimboloTeTengo extends StatelessWidget {
  const SimboloTeTengo({super.key, this.tamano = 40, this.oscuro = false});

  final double tamano;
  final bool oscuro;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(
      svgSimbolo(oscuro: oscuro),
      width: tamano,
      height: tamano,
    ),
  );
}

/// «Te Tengo» in Atkinson Hyperlegible Next 800: «Te» in morado (white on dark) and «Tengo» in
/// coral (peach on dark).
class PalabraTeTengo extends StatelessWidget {
  const PalabraTeTengo({super.key, this.tamano = 34, this.oscuro = false});

  final double tamano;
  final bool oscuro;

  @override
  Widget build(BuildContext context) {
    final estilo = estiloTexto(tamano, 800).copyWith(letterSpacing: -0.5);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Te ',
            style: estilo.copyWith(
              color: oscuro ? Colors.white : Colores.morado,
            ),
          ),
          TextSpan(
            text: 'Tengo',
            style: estilo.copyWith(
              color: oscuro ? Colores.durazno : Colores.coral,
            ),
          ),
        ],
      ),
      semanticsLabel: 'Te Tengo',
    );
  }
}

/// Horizontal logo: symbol + «Te Tengo» (welcome, sign-in, invitation, «Todo listo»).
class Logotipo extends StatelessWidget {
  const Logotipo({super.key, this.oscuro = false});

  final bool oscuro;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SimboloTeTengo(tamano: 40, oscuro: oscuro),
      const SizedBox(width: 6),
      PalabraTeTengo(tamano: 26, oscuro: oscuro),
    ],
  );
}
