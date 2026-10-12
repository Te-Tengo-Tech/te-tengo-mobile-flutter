import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import '../domain/vista_en_vivo.dart';

/// «Video» is on in this mode.
bool conVideo(ModoVista m) => m != ModoVista.soloPostura;

/// «Esqueleto» is on in this mode.
bool conEsqueleto(ModoVista m) => m != ModoVista.video;

/// The mode after switching «Video» ([video]) or «Esqueleto»: at least one stays on, so turning off
/// the only one turns on the other (`liveMode`).
ModoVista alternarModo(ModoVista actual, {required bool video}) {
  var v = conVideo(actual);
  var e = conEsqueleto(actual);
  if (video) {
    v = !v;
    if (!v) e = true;
  } else {
    e = !e;
    if (!e) v = true;
  }
  return v && e
      ? ModoVista.videoConPostura
      : v
      ? ModoVista.video
      : ModoVista.soloPostura;
}

/// «Video» and «Esqueleto» as two pill switches over the dark live view (`modeBar`, `mlModes`):
/// on, white with a check; off, outlined. [soloIconos] keeps the name for screen readers only (the
/// landscape bar with large text).
class ModosVista extends StatelessWidget {
  const ModosVista({
    super.key,
    required this.modo,
    required this.alCambiar,
    this.expandir = true,
    this.soloIconos = false,
  });

  final ModoVista modo;

  /// Null while a change is on its way.
  final ValueChanged<ModoVista>? alCambiar;

  /// Each switch takes half the width (the portrait live view and «Ver todas»).
  final bool expandir;
  final bool soloIconos;

  @override
  Widget build(BuildContext context) {
    Widget interruptor(String texto, Ico icono, bool video) {
      final encendido = video ? conVideo(modo) : conEsqueleto(modo);
      final boton = InterruptorPildora(
        texto: texto,
        icono: icono,
        encendido: encendido,
        soloIcono: soloIconos,
        alTocar: alCambiar == null
            ? null
            : () => alCambiar!(alternarModo(modo, video: video)),
      );
      return expandir ? Expanded(child: boton) : boton;
    }

    return Semantics(
      container: true,
      label: 'Qué se ve',
      child: Row(
        mainAxisSize: expandir ? MainAxisSize.max : MainAxisSize.min,
        children: [
          interruptor('Video', Ico.video, true),
          const SizedBox(width: 10),
          interruptor('Esqueleto', Ico.body, false),
        ],
      ),
    );
  }
}

/// A pill switch over a dark surface (`.mode-t`): white with a check when on, outlined when off.
class InterruptorPildora extends StatelessWidget {
  const InterruptorPildora({
    super.key,
    required this.texto,
    required this.icono,
    required this.encendido,
    required this.alTocar,
    this.soloIcono = false,
  });

  final String texto;
  final Ico icono;
  final bool encendido;
  final VoidCallback? alTocar;
  final bool soloIcono;

  @override
  Widget build(BuildContext context) {
    const tinta = Color(0xFF221A38);
    final color = encendido ? tinta : Colors.white;
    final contraste = context.colores.contraste;
    return Semantics(
      button: true,
      toggled: encendido,
      enabled: alTocar != null,
      label: texto,
      excludeSemantics: true,
      onTap: alTocar,
      child: Material(
        color: encendido ? Colors.white : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: encendido ? Colors.white : const Color(0xB3FFFFFF),
            width: contraste ? 2 : 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: alTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: soloIcono ? 12 : 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icono(
                    encendido ? Ico.check : icono,
                    tamano: 20,
                    color: color,
                  ),
                  if (!soloIcono) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        texto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: estiloTexto(17, 700, color: color),
                      ),
                    ),
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
