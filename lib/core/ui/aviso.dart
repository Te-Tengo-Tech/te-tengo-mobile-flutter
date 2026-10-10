import 'package:flutter/material.dart';

import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import '../red/problema_api.dart';
import 'iconos.dart';

/// Tones of the prototype `.notice`.
enum TonoAviso { error, advertencia, ok, info, neutral }

/// Inline notice (`.notice`): icon + optional title + text + optional action.
class Aviso extends StatelessWidget {
  const Aviso({
    super.key,
    required this.tono,
    required this.icono,
    this.titulo,
    this.texto,
    this.contenido,
    this.accion,
  });

  final TonoAviso tono;
  final Ico icono;
  final String? titulo;
  final String? texto;

  /// Rich body, used instead of [texto] when part of it is a time (mono) or bold.
  final InlineSpan? contenido;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final (fondo, color, cuerpo) = switch (tono) {
      TonoAviso.error => (
        context.colores.caidaSuave,
        context.colores.caidaTinta,
        context.colores.errorTexto,
      ),
      TonoAviso.advertencia => (
        context.colores.avisoSuave,
        context.colores.avisoTinta,
        context.colores.avisoTinta,
      ),
      TonoAviso.ok => (
        context.colores.calmaSuave,
        context.colores.calmaTinta,
        context.colores.calmaTinta,
      ),
      TonoAviso.info => (
        context.colores.moradoSuave,
        context.colores.moradoTinta,
        context.colores.moradoTinta,
      ),
      TonoAviso.neutral => (
        context.colores.fondo2,
        context.colores.tinta2,
        context.colores.tinta2,
      ),
    };
    final estiloCuerpo = estiloTexto(15.5, 400, color: cuerpo);
    final contenido = this.contenido;
    return Semantics(
      container: true,
      liveRegion: tono == TonoAviso.error,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icono(icono, tamano: 22, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (titulo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        titulo!,
                        style: estiloTexto(16, 700, color: color),
                      ),
                    ),
                  if (contenido != null)
                    Text.rich(contenido, style: estiloCuerpo)
                  else if (texto != null)
                    Text(texto!, style: estiloCuerpo),
                  if (accion != null) ...[const SizedBox(height: 10), accion!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text shown for an error: the backend `detalle` for a [ProblemaApi], a generic line otherwise.
String textoDeError(Object error) =>
    error is ProblemaApi ? error.detalle : 'Ocurrió un error.';

/// Shared widget for `ProblemaApi` messages (RFC 9457): shows `detalle`.
class MensajeProblema extends StatelessWidget {
  const MensajeProblema(this.error, {super.key, this.titulo});

  final Object error;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    final sinConexion =
        error is ProblemaApi &&
        (error as ProblemaApi).codigo == ProblemaApi.sinConexion;
    return Aviso(
      tono: TonoAviso.error,
      icono: sinConexion ? Ico.wifiOff : Ico.warn,
      titulo: titulo,
      texto: textoDeError(error),
    );
  }
}

/// Error state of a whole screen: the problem message, retried by pulling down.
class ErrorDePantalla extends StatelessWidget {
  const ErrorDePantalla({super.key, required this.error, this.alReintentar});

  final Object error;
  final Future<void> Function()? alReintentar;

  @override
  Widget build(BuildContext context) {
    final lista = ListView(
      padding: const EdgeInsets.all(20),
      children: [MensajeProblema(error)],
    );
    final reintentar = alReintentar;
    return reintentar == null
        ? lista
        : RefreshIndicator(onRefresh: reintentar, child: lista);
  }
}
