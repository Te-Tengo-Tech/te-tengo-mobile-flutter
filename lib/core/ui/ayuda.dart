import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';

/// A «?» icon whose help opens in a small card (`infoTip` of the prototype, docs `5100fc7`): the
/// privacy and help lines that were always visible now wait behind it, so a screen first shows what
/// decides the action. Alerts, errors, legal pages and states stay visible and never use it.
///
/// The button is 48 dp with a 24 px icon and the label «Más información: [tema]»; screen readers hear
/// whether it is open, and the card is a live region, so its text is read when it appears. A tap
/// opens or closes it; a tap outside, Escape or scrolling close it. The card flips above or below
/// and slides sideways to stay on screen.
class AyudaInfo extends StatefulWidget {
  const AyudaInfo({
    super.key,
    required this.texto,
    required this.tema,
    this.sobreOscuro = false,
    this.arriba = false,
  });

  /// The help itself, as the prototype words it.
  final String texto;

  /// What it is about, for the button's label («privacidad», «vista previa», «el clip»…).
  final String tema;

  /// White icon over the live view and «Ver todas».
  final bool sobreOscuro;

  /// Prefers opening above the icon (a bar at the bottom of the screen).
  final bool arriba;

  @override
  State<AyudaInfo> createState() => _AyudaInfoState();
}

class _AyudaInfoState extends State<AyudaInfo> {
  final _controlador = OverlayPortalController();
  final _foco = FocusNode(debugLabel: 'AyudaInfo');
  final _grupo = Object();
  ScrollPosition? _desplazamiento;

  bool get _abierta => _controlador.isShowing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final posicion = Scrollable.maybeOf(context)?.position;
    if (posicion != _desplazamiento) {
      _desplazamiento?.removeListener(_cerrar);
      _desplazamiento = posicion?..addListener(_cerrar);
    }
  }

  void _alternar() {
    setState(() {
      if (_abierta) {
        _controlador.hide();
      } else {
        _controlador.show();
        _foco.requestFocus();
      }
    });
  }

  void _cerrar() {
    if (!_abierta || !mounted) return;
    setState(_controlador.hide);
  }

  @override
  void dispose() {
    _desplazamiento?.removeListener(_cerrar);
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = widget.sobreOscuro ? Colors.white : c.icono;
    return TapRegion(
      groupId: _grupo,
      onTapOutside: (_) => _cerrar(),
      child: OverlayPortal(
        controller: _controlador,
        overlayChildBuilder: (overlayContext) => _Globo(
          ancla: context,
          texto: widget.texto,
          arriba: widget.arriba,
          grupo: _grupo,
        ),
        child: Focus(
          focusNode: _foco,
          onKeyEvent: (_, evento) {
            if (evento is KeyDownEvent &&
                evento.logicalKey == LogicalKeyboardKey.escape &&
                _abierta) {
              _cerrar();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Semantics(
            button: true,
            expanded: _abierta,
            label: 'Más información: ${widget.tema}',
            excludeSemantics: true,
            onTap: _alternar,
            child: SizedBox.square(
              dimension: 48,
              child: InkResponse(
                onTap: _alternar,
                radius: 24,
                canRequestFocus: false,
                child: Center(child: Icono(Ico.help, color: color)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The help card, placed by the icon it belongs to.
class _Globo extends StatelessWidget {
  const _Globo({
    required this.ancla,
    required this.texto,
    required this.arriba,
    required this.grupo,
  });

  final BuildContext ancla;
  final String texto;
  final bool arriba;
  final Object grupo;

  static const _margen = 8.0;
  static const _anchoMaximo = 280.0;

  @override
  Widget build(BuildContext context) {
    final caja = ancla.findRenderObject();
    if (caja is! RenderBox || !caja.attached) return const SizedBox.shrink();
    final pantalla = MediaQuery.sizeOf(context);
    final relleno = MediaQuery.paddingOf(context);
    final origen = caja.localToGlobal(Offset.zero);
    final icono = origen & caja.size;
    final ancho = math.min(_anchoMaximo, pantalla.width - 2 * _margen);
    final izquierda = (icono.center.dx - ancho / 2)
        .clamp(_margen, pantalla.width - _margen - ancho)
        .toDouble();
    final espacioArriba = icono.top - relleno.top;
    final espacioAbajo = pantalla.height - relleno.bottom - icono.bottom;
    // Opens on the preferred side unless the other one has clearly more room (`flip`).
    final haciaArriba = arriba
        ? espacioArriba >= 120 || espacioArriba > espacioAbajo
        : espacioAbajo < 120 && espacioArriba > espacioAbajo;
    final c = context.colores;
    final tarjeta = TapRegion(
      groupId: grupo,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ancho),
          child: Material(
            color: c.oscura ? c.moradoSuave : c.tarjeta,
            elevation: 6,
            shadowColor: const Color(0x33000000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: c.contraste ? c.tinta : c.moradoTinta.withAlpha(0x66),
                width: c.contraste ? 2 : 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(texto, style: estiloTexto(16, 400, color: c.tinta)),
            ),
          ),
        ),
      ),
    );
    return Stack(
      children: [
        Positioned(
          left: izquierda,
          top: haciaArriba ? null : icono.bottom + 4,
          bottom: haciaArriba ? pantalla.height - icono.top + 4 : null,
          child: tarjeta,
        ),
      ],
    );
  }
}
