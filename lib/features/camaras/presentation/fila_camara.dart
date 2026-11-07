import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/lista.dart';
import '../../../l10n/l10n.dart';
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
    final l = context.l10n;
    final f = context.formato;
    final detalle = switch (estado) {
      EstadoVisible.enLinea when senal != null => conHoraMono(
        l.camaraUltimaSenalPrefijo,
        f.hora(senal),
      ),
      EstadoVisible.enLinea => const TextSpan(),
      EstadoVisible.desconectada when senal != null => conHoraMono(
        l.camaraDesdeLasPrefijo,
        f.hora(senal),
      ),
      EstadoVisible.desconectada => const TextSpan(),
      EstadoVisible.enPausa => TextSpan(
        text: pausa == null ? '' : l.camaraHastaLas(f.hora(pausa)),
      ),
      EstadoVisible.noConfiable => TextSpan(text: l.camaraRevisaLuzEncuadre),
      EstadoVisible.detenida => TextSpan(text: l.camaraSinConsentimiento),
      EstadoVisible.sinConexion => TextSpan(text: l.camaraPcNoResponde),
    };
    return FilaLista(
      inicio: IconoEstadoCamara(estado: estado),
      titulo: camara.nombreHabitacion,
      subtituloRico: TextSpan(
        children: [
          TextSpan(
            text: estado.texto(l),
            style: estiloTexto(15, 700, color: estado.colorEn(context.colores)),
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
