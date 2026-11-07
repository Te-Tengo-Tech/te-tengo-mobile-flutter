import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../l10n/l10n.dart';
import '../domain/pc.dart';
import 'piezas_pc.dart';

/// What went wrong with a link code, from the `vinculaciones` endpoints (contract §9).
enum TipoErrorCodigo {
  /// `404 CODIGO_INCORRECTO` or `400 VALIDACION`: a wrong attempt.
  incorrecto,

  /// `410 CODIGO_VENCIDO`: expired or already used (CA-28.3).
  vencido,

  /// `423 VINCULACION_BLOQUEADA`: 5 wrong codes in a row (CA-28.6).
  bloqueado,

  /// `409 PC_YA_VINCULADA`: the PC showing the code is already linked, here or to another
  /// household («Esta PC ya está vinculada»).
  yaVinculada,

  /// `403 SOLO_TITULAR`: an invited member (CA-28.5).
  soloTitular,
  sinConexion,
  otro,
}

class ErrorDeCodigo {
  const ErrorDeCodigo(
    this.tipo, {
    this.detalle,
    this.bloqueadaHasta,
    this.porFormato = false,
  });

  final TipoErrorCodigo tipo;

  /// The backend's own words, shown as they arrive (`SOLO_TITULAR`, an unknown code, or the
  /// `codigo` field of a `VALIDACION`).
  final String? detalle;

  /// «Podrás volver a intentarlo a las 10:57».
  final DateTime? bloqueadaHasta;

  /// A `VALIDACION` without the field's message: the code's format is wrong.
  final bool porFormato;

  /// The prototype's line for the field or the notice.
  String texto(AppLocalizations l) =>
      detalle ??
      switch (tipo) {
        TipoErrorCodigo.incorrecto =>
          porFormato ? l.pcsCodigoFormato : l.pcsCodigoNoExiste,
        TipoErrorCodigo.vencido => l.pcsCodigoVencido,
        TipoErrorCodigo.bloqueado => l.pcsDemasiadosIntentos,
        TipoErrorCodigo.yaVinculada => l.pcsYaVinculadaTitulo,
        TipoErrorCodigo.sinConexion => l.pcsSinInternetReintenta,
        TipoErrorCodigo.soloTitular || TipoErrorCodigo.otro => '',
      };

  factory ErrorDeCodigo.desde(ProblemaApi e) => switch (e.codigo) {
    'CODIGO_INCORRECTO' => const ErrorDeCodigo(TipoErrorCodigo.incorrecto),
    'VALIDACION' => ErrorDeCodigo(
      TipoErrorCodigo.incorrecto,
      detalle: e.campos['codigo'],
      porFormato: true,
    ),
    'CODIGO_VENCIDO' => const ErrorDeCodigo(TipoErrorCodigo.vencido),
    'VINCULACION_BLOQUEADA' => ErrorDeCodigo(
      TipoErrorCodigo.bloqueado,
      bloqueadaHasta: fechaDesdeJson(e.extras['bloqueadaHasta']),
    ),
    'PC_YA_VINCULADA' => const ErrorDeCodigo(TipoErrorCodigo.yaVinculada),
    'SOLO_TITULAR' => ErrorDeCodigo(
      TipoErrorCodigo.soloTitular,
      detalle: e.detalle,
    ),
    ProblemaApi.sinConexion => const ErrorDeCodigo(TipoErrorCodigo.sinConexion),
    _ => ErrorDeCodigo(TipoErrorCodigo.otro, detalle: e.detalle),
  };
}

/// «Podrás volver a intentarlo a las 10:57.», with the time in the mono font.
TextSpan textoBloqueo(AppLocalizations l, DateTime? hasta) => hasta == null
    ? TextSpan(children: [TextSpan(text: l.pcsBloqueoQuinceMinutos)])
    : textoConDato(
        l.pcsBloqueoHasta,
        l.formato.hora(hasta),
        estiloMono(tamano: 15.5, peso: 400),
      );

/// Keeps the code's letters and shows them as `KQWT-MXHD`: lower case, a hyphen or none, vowels and
/// digits are accepted and the ones the code never uses are ignored (CA-28.2).
class _FormatoCodigo extends TextInputFormatter {
  _FormatoCodigo(this.alIgnorar);

  final VoidCallback alIgnorar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antes,
    TextEditingValue ahora,
  ) {
    final limpio = limpiarCodigo(ahora.text);
    final escrito = ahora.text.replaceAll(RegExp(r'[\s-]'), '');
    if (escrito.length > limpio.length &&
        limpio.length < largoDelCodigo &&
        tieneLetrasAjenas(ahora.text)) {
      alIgnorar();
    }
    final texto = formatoCodigo(limpio);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// The 8 boxes of the link code with a hyphen in the middle (`codeInput`): one real text field
/// over them, so typing, pasting and the keyboard's one-time code all work.
class CampoCodigo extends StatefulWidget {
  const CampoCodigo({
    super.key,
    required this.controlador,
    required this.alCambiar,
    required this.alIgnorarLetras,
    this.alEnviar,
    this.error = false,
    this.habilitado = true,
    this.foco,
  });

  final TextEditingController controlador;

  /// The clean letters (`KQWTMXHD`).
  final ValueChanged<String> alCambiar;

  /// The person typed a vowel or a digit, which the code never has.
  final VoidCallback alIgnorarLetras;
  final VoidCallback? alEnviar;

  /// Every box in red (wrong or expired code).
  final bool error;

  /// Dashed and disabled while code entry is blocked (CA-28.6).
  final bool habilitado;
  final FocusNode? foco;

  @override
  State<CampoCodigo> createState() => _CampoCodigoState();
}

class _CampoCodigoState extends State<CampoCodigo> {
  late final FocusNode _foco = widget.foco ?? FocusNode();
  late final _formato = _FormatoCodigo(widget.alIgnorarLetras);

  @override
  void initState() {
    super.initState();
    _foco.addListener(_redibujar);
    widget.controlador.addListener(_redibujar);
  }

  void _redibujar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _foco.removeListener(_redibujar);
    widget.controlador.removeListener(_redibujar);
    if (widget.foco == null) _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letras = limpiarCodigo(widget.controlador.text);
    return LayoutBuilder(
      builder: (context, limites) {
        const guion = 22.0;
        const espacio = 6.0;
        final ancho = ((limites.maxWidth - guion - espacio * 8) / 8).clamp(
          30.0,
          56.0,
        );
        final alto = (ancho * 1.3).clamp(48.0, 72.0);
        return SizedBox(
          height: alto,
          child: Stack(
            children: [
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < largoDelCodigo; i++) ...[
                      if (i == 4)
                        SizedBox(
                          width: guion + espacio,
                          child: Center(
                            child: Text(
                              '–',
                              style: estiloTexto(
                                22,
                                700,
                                color: context.colores.tinta3,
                              ),
                            ),
                          ),
                        )
                      else if (i > 0)
                        const SizedBox(width: espacio),
                      _Casilla(
                        letra: i < letras.length ? letras[i] : '',
                        actual:
                            widget.habilitado &&
                            _foco.hasFocus &&
                            i == letras.length.clamp(0, largoDelCodigo - 1),
                        error: widget.error,
                        habilitado: widget.habilitado,
                        ancho: ancho,
                        alto: alto,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  // The boxes are drawn below; the field stays for screen readers.
                  alwaysIncludeSemantics: true,
                  child: TextField(
                    controller: widget.controlador,
                    focusNode: _foco,
                    enabled: widget.habilitado,
                    autocorrect: false,
                    enableSuggestions: false,
                    showCursor: false,
                    textCapitalization: TextCapitalization.characters,
                    keyboardType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [_formato],
                    onChanged: (t) => widget.alCambiar(limpiarCodigo(t)),
                    onSubmitted: (_) => widget.alEnviar?.call(),
                    decoration: InputDecoration(
                      labelText: context.l10n.pcsCampoCodigoEtiqueta,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.letra,
    required this.actual,
    required this.error,
    required this.habilitado,
    required this.ancho,
    required this.alto,
  });

  final String letra;
  final bool actual;
  final bool error;
  final bool habilitado;
  final double ancho;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final borde = error
        ? c.caidaTinta
        : actual
        ? c.moradoTinta
        : letra.isEmpty
        ? c.linea2
        : c.tinta2;
    final radio = BorderRadius.circular(12);
    final casilla = Container(
      width: ancho,
      height: alto,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: habilitado ? c.tarjeta : c.fondo2,
        borderRadius: radio,
        border: habilitado
            ? Border.all(color: borde, width: actual || error ? 2.5 : 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            letra,
            style: estiloTexto(26, 700, color: habilitado ? c.tinta : c.tinta3),
          ),
        ),
      ),
    );
    if (habilitado) return casilla;
    return CustomPaint(
      foregroundPainter: _Punteado(radio, c.tinta3),
      child: casilla,
    );
  }
}

class _Punteado extends CustomPainter {
  const _Punteado(this.radio, this.color);

  final BorderRadius radio;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final ruta = Path()..addRRect(radio.toRRect(Offset.zero & size).deflate(1));
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in ruta.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 6) {
        canvas.drawPath(m.extractPath(d, d + 3.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(_Punteado old) => old.color != color;
}
