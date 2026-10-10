import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'iconos.dart';

/// Kind of text field.
enum TipoCampo { texto, correo, contrasena, numero }

/// Labelled text field (`.field`): label above, hint or error (with a warning icon) below.
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.tipo = TipoCampo.texto,
    this.error,
    this.ayuda,
    this.marcador,
    this.habilitado = true,
    this.autocompletar,
    this.alCambiar,
    this.alEnviar,
    this.longitudMaxima,
    this.accionTeclado,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final TipoCampo tipo;
  final String? error;
  final String? ayuda;
  final String? marcador;
  final bool habilitado;
  final Iterable<String>? autocompletar;
  final ValueChanged<String>? alCambiar;
  final ValueChanged<String>? alEnviar;
  final int? longitudMaxima;
  final TextInputAction? accionTeclado;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    final esClave = widget.tipo == TipoCampo.contrasena;
    final error = widget.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.etiqueta,
                style: estiloTexto(15, 700, color: context.colores.tinta),
              ),
            ),
            TextField(
              controller: widget.controlador,
              enabled: widget.habilitado,
              obscureText: esClave && _oculta,
              autocorrect: !esClave && widget.tipo != TipoCampo.correo,
              enableSuggestions: !esClave,
              keyboardType: switch (widget.tipo) {
                TipoCampo.correo => TextInputType.emailAddress,
                TipoCampo.numero => TextInputType.number,
                _ => TextInputType.text,
              },
              inputFormatters: [
                if (widget.tipo == TipoCampo.numero)
                  FilteringTextInputFormatter.digitsOnly,
                if (widget.longitudMaxima != null)
                  LengthLimitingTextInputFormatter(widget.longitudMaxima),
              ],
              textInputAction: widget.accionTeclado,
              autofillHints: widget.autocompletar,
              onChanged: widget.alCambiar,
              onSubmitted: widget.alEnviar,
              style: estiloTexto(
                17,
                400,
                color: widget.habilitado
                    ? context.colores.tinta
                    : context.colores.tinta2,
              ),
              decoration: InputDecoration(
                hintText: widget.marcador,
                semanticCounterText: '',
                fillColor: widget.habilitado
                    ? context.colores.tarjeta
                    : context.colores.fondo,
                disabledBorder: widget.habilitado
                    ? null
                    : _BordePunteado(context.colores.linea2),
                error: error == null ? null : _MensajeError(error),
                helperText: error == null ? widget.ayuda : null,
                suffixIcon: esClave
                    ? IconButton(
                        tooltip: _oculta
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () => setState(() => _oculta = !_oculta),
                        icon: Icono(
                          _oculta ? Ico.eye : Ico.eyeOff,
                          color: context.colores.tinta,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icono(Ico.warn, tamano: 18, color: context.colores.caidaTinta),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          texto,
          style: estiloTexto(15, 700, color: context.colores.caidaTinta),
        ),
      ),
    ],
  );
}

/// Dashed border of read-only fields (`.input:disabled`).
class _BordePunteado extends InputBorder {
  _BordePunteado(this.color)
    : super(borderSide: BorderSide(color: color, width: 1.5));

  final Color color;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(1.5);

  @override
  bool get isOutline => true;

  @override
  InputBorder copyWith({BorderSide? borderSide}) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(BorderRadius.circular(16).toRRect(rect).deflate(1.5));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(BorderRadius.circular(16).toRRect(rect));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final path = getOuterPath(rect.deflate(0.75));
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metrica in path.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += 9) {
        canvas.drawPath(metrica.extractPath(d, d + 5), pincel);
      }
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}

/// Field label used above groups of choices (`.label`).
class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      texto,
      style: estiloTexto(15, 700, color: context.colores.tinta),
    ),
  );
}

/// Radio choice (`.choice`): a bordered row with a dot, title and optional subtitle.
class OpcionRadio<T> extends StatelessWidget {
  const OpcionRadio({
    super.key,
    required this.valor,
    required this.seleccion,
    required this.titulo,
    this.subtitulo,
    this.alElegir,
    this.error = false,
  });

  final T valor;
  final T? seleccion;
  final String titulo;
  final String? subtitulo;
  final ValueChanged<T>? alElegir;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final elegida = valor == seleccion;
    final habilitada = alElegir != null;
    final borde = elegida
        ? Colores.morado
        : error
        ? Colores.caida
        : context.colores.linea2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: elegida,
        enabled: habilitada,
        button: true,
        excludeSemantics: true,
        label: subtitulo == null ? titulo : '$titulo. $subtitulo',
        onTap: habilitada ? () => alElegir!(valor) : null,
        child: Material(
          color: elegida
              ? context.colores.moradoSuave
              : context.colores.tarjeta,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borde, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: habilitada ? () => alElegir!(valor) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _Punto(elegida: elegida),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            titulo,
                            style: estiloTexto(
                              17,
                              600,
                              color: habilitada
                                  ? context.colores.tinta
                                  : context.colores.tinta2,
                            ),
                          ),
                          if (subtitulo != null)
                            Text(
                              subtitulo!,
                              style: estiloTexto(
                                15,
                                400,
                                color: context.colores.tinta3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.elegida});

  final bool elegida;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: elegida ? Colores.morado : context.colores.tinta3,
        width: 2,
      ),
    ),
    child: elegida
        ? Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colores.morado,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}

/// Checkbox row (`.check`): a 26 px box and its text.
class Casilla extends StatelessWidget {
  const Casilla({
    super.key,
    required this.marcada,
    required this.texto,
    required this.alCambiar,
    this.error = false,
  });

  final bool marcada;
  final String texto;
  final ValueChanged<bool> alCambiar;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: marcada,
    label: texto,
    excludeSemantics: true,
    onTap: () => alCambiar(!marcada),
    child: InkWell(
      onTap: () => alCambiar(!marcada),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: marcada ? Colores.morado : context.colores.tarjeta,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: marcada
                      ? Colores.morado
                      : error
                      ? Colores.caida
                      : context.colores.tinta3,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: marcada
                  ? const Icono(Ico.check, tamano: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                texto,
                style: estiloTexto(16, 400, color: context.colores.tinta),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Validation message under a group (`.field-msg` in error).
class MensajeCampo extends StatelessWidget {
  const MensajeCampo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 12),
    child: Semantics(liveRegion: true, child: _MensajeError(texto)),
  );
}
