import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../l10n/l10n.dart';

/// How to add the widget (`widgetSteps`, Ajustes › «Agregar el widget»): three numbered steps and
/// the privacy line.
class PasosWidget extends StatelessWidget {
  const PasosWidget({super.key});

  static List<String> pasos(AppLocalizations l) => [
    l.widgetPaso1,
    l.widgetPaso2,
    l.widgetPaso3,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estilo = estiloTexto(16, 400, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, paso) in pasos(context.l10n).indexed)
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
          context.l10n.widgetPrivacidad,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
