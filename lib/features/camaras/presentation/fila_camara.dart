import 'package:flutter/material.dart';

import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/lista.dart';
import '../domain/camara.dart';
import 'estado_camara.dart';

/// Camera row of the home screen (`camRow`): state icon, room, state text and a detail.
class FilaCamara extends StatelessWidget {
  const FilaCamara({
    super.key,
    required this.camara,
    required this.estado,
    required this.alTocar,
  });

  final Camara camara;
  final EstadoVisible estado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final senal = camara.ultimaSenal;
    final pausa = camara.pausadaHasta;
    final detalle = switch (estado) {
      EstadoVisible.enLinea when senal != null => conHoraMono(
        'última señal ',
        hora(senal),
      ),
      EstadoVisible.enLinea => const TextSpan(),
      EstadoVisible.desconectada when senal != null => conHoraMono(
        'desde las ',
        hora(senal),
      ),
      EstadoVisible.desconectada => const TextSpan(),
      EstadoVisible.enPausa => TextSpan(
        text: pausa == null ? '' : 'hasta las ${hora(pausa)}',
      ),
      EstadoVisible.noConfiable => const TextSpan(
        text: 'revisa la luz y el encuadre',
      ),
      EstadoVisible.detenida => const TextSpan(text: 'sin consentimiento'),
    };
    return FilaLista(
      inicio: IconoEstadoCamara(estado: estado),
      titulo: camara.nombreHabitacion,
      subtituloRico: TextSpan(
        children: [
          TextSpan(
            text: estado.texto,
            style: estiloTexto(15, 700, color: estado.color),
          ),
          if (detalle.text != '' || detalle.children != null) ...[
            const TextSpan(text: ' · '),
            detalle,
          ],
        ],
      ),
      alTocar: alTocar,
    );
  }
}

/// `prefix` + time in the mono font.
TextSpan conHoraMono(String prefijo, String horaTexto) => TextSpan(
  children: [
    TextSpan(text: prefijo),
    TextSpan(text: horaTexto, style: estiloMono(tamano: 15, peso: 400)),
  ],
);
