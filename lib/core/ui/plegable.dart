import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';

/// Duration of the disclosure animations; none when the system asks for no animations.
Duration _duracion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 200);

/// Chevron that turns upside down when its section is open.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.abierta, required this.color});

  final bool abierta;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedRotation(
    turns: abierta ? .5 : 0,
    duration: _duracion(context),
    curve: Curves.easeOut,
    child: Icono(Ico.chevD, tamano: 22, color: color),
  );
}

/// Disclosure row of a list (`fold()` in the prototype): icon, title and a one-line summary that
/// gives way to the full text when the row is open. The whole row is the target (≥ 64 px) and
/// screen readers hear it as a button with its expanded state.
///
/// Secondary detail stays folded so a screen shows first what decides the action; nothing is
/// removed. Put it inside a [ListaTarjeta] next to other rows or folds.
class FilaPlegable extends StatefulWidget {
  const FilaPlegable({
    super.key,
    this.icono,
    required this.titulo,
    this.resumen,
    required this.child,
    this.abierta = false,
    this.destacada = false,
    this.aRas = false,
  });

  final Ico? icono;
  final String titulo;

  /// One line under the title, hidden while the row is open.
  final String? resumen;
  final Widget child;

  /// Open when it is first shown.
  final bool abierta;

  /// The key section (`.fold.key`): the icon is filled in purple.
  final bool destacada;

  /// The body spans the card edge to edge (`.fold.media`), for a clip.
  final bool aRas;

  @override
  State<FilaPlegable> createState() => _FilaPlegableState();
}

class _FilaPlegableState extends State<FilaPlegable> {
  late bool _abierta = widget.abierta;

  void _alternar() => setState(() => _abierta = !_abierta);

  @override
  Widget build(BuildContext context) {
    final icono = widget.icono;
    final resumen = widget.resumen;
    final cabecera = Semantics(
      button: true,
      expanded: _abierta,
      child: InkWell(
        onTap: _alternar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (icono != null) ...[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.destacada
                          ? Colores.morado
                          : context.colores.moradoSuave,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icono(
                      icono,
                      tamano: 24,
                      color: widget.destacada
                          ? Colors.white
                          : context.colores.moradoTinta,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.titulo,
                        style: estiloTexto(
                          17,
                          700,
                          color: context.colores.tinta,
                        ),
                      ),
                      if (resumen != null && !_abierta)
                        Text(
                          resumen,
                          style: estiloTexto(
                            15,
                            400,
                            color: context.colores.tinta3,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _Chevron(abierta: _abierta, color: context.colores.tinta3),
              ],
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        cabecera,
        AnimatedSize(
          duration: _duracion(context),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: !_abierta
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: widget.aRas
                      ? EdgeInsets.zero
                      : const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DefaultTextStyle.merge(
                    style: estiloTexto(
                      15,
                      400,
                      color: context.colores.tinta2,
                    ).copyWith(height: 1.45),
                    child: widget.child,
                  ),
                ),
        ),
      ],
    );
  }
}

/// «Ver más» inside a card (`more()` in the prototype): a 48 px row with a line above, the label
/// in purple and a chevron; the detail shows below it when open.
class VerMas extends StatefulWidget {
  const VerMas({
    super.key,
    required this.etiqueta,
    required this.child,
    this.abierto = false,
  });

  final String etiqueta;
  final Widget child;
  final bool abierto;

  @override
  State<VerMas> createState() => _VerMasState();
}

class _VerMasState extends State<VerMas> {
  late bool _abierto = widget.abierto;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 6),
      const Divider(height: 1, thickness: 1),
      Semantics(
        button: true,
        expanded: _abierto,
        child: InkWell(
          onTap: () => setState(() => _abierto = !_abierto),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.etiqueta,
                    style: estiloTexto(
                      16,
                      700,
                      color: context.colores.moradoTinta,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _Chevron(abierta: _abierto, color: context.colores.moradoTinta),
              ],
            ),
          ),
        ),
      ),
      AnimatedSize(
        duration: _duracion(context),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: _abierto
            ? Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: widget.child,
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}
