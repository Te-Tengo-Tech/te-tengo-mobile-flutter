import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';

/// How to add the widget (`widgetSteps`, Ajustes › «Agregar el widget»): three numbered steps and
/// the privacy line.
class PasosWidget extends StatelessWidget {
  const PasosWidget({super.key});

  static const pasos = [
    'Mantén presionado un espacio libre de la pantalla de inicio.',
    'Toca «Widgets» y busca Te Tengo.',
    'Elige el tamaño y suéltalo.',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estilo = estiloTexto(16, 400, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, paso) in pasos.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 24, child: Text('${i + 1}.', style: estilo)),
                Expanded(child: Text(paso, style: estilo)),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Muestra el estado, nunca imágenes de la casa.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
