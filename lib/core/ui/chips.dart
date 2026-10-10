import 'package:flutter/material.dart';

import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';

/// Chip (`.chip`): white with a border, filled in ink when selected; ≥ 44 px tall.
class ChipOpcion extends StatelessWidget {
  const ChipOpcion({
    super.key,
    required this.texto,
    required this.alTocar,
    this.elegido = false,
    this.icono,
    this.iconoFinal,
    this.etiqueta,
  });

  final String texto;
  final VoidCallback? alTocar;
  final bool elegido;
  final Ico? icono;
  final Ico? iconoFinal;

  /// Accessibility label when the text alone is not enough («Quitar filtro …»).
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final color = elegido
        ? context.colores.sobreInversa
        : context.colores.tinta;
    return Semantics(
      button: true,
      selected: elegido,
      label: etiqueta,
      excludeSemantics: etiqueta != null,
      child: Material(
        color: elegido ? context.colores.inversa : context.colores.tarjeta,
        shape: StadiumBorder(
          side: BorderSide(
            color: elegido ? context.colores.inversa : context.colores.linea2,
            width: 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: alTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icono != null) ...[
                    Icono(icono!, tamano: 18, color: color),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      texto,
                      style: estiloTexto(16, 600, color: color),
                    ),
                  ),
                  if (iconoFinal != null) ...[
                    const SizedBox(width: 6),
                    Icono(iconoFinal!, tamano: 18, color: color),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control (`.seg`).
class Segmentado<T> extends StatelessWidget {
  const Segmentado({
    super.key,
    required this.opciones,
    required this.valor,
    required this.alCambiar,
  });

  final List<(T, String)> opciones;
  final T valor;
  final ValueChanged<T> alCambiar;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colores.fondo2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        for (final (v, texto) in opciones) ...[
          if (v != opciones.first.$1) const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              selected: v == valor,
              button: true,
              child: Material(
                color: v == valor
                    ? context.colores.tarjeta
                    : Colors.transparent,
                elevation: v == valor ? 1 : 0,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => alCambiar(v),
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Text(
                        texto,
                        style: estiloTexto(
                          16,
                          700,
                          color: v == valor
                              ? context.colores.tinta
                              : context.colores.tinta2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
