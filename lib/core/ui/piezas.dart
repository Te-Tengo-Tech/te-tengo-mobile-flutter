import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/paleta.dart';
import '../../app/tema/tema.dart';
import 'aviso.dart';
import 'avisos_flotantes.dart';
import 'ilustraciones.dart';
import 'iconos.dart';

/// Empty state (`.empty`): illustration, title and text.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.ilustracion,
    required this.titulo,
    required this.texto,
    this.accion,
  });

  final IlustracionVacio ilustracion;
  final String titulo;
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 36, 14, 10),
    child: Column(
      children: [
        IlustracionEstadoVacio(ilustracion),
        const SizedBox(height: 18),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (accion != null) ...[const SizedBox(height: 16), accion!],
      ],
    ),
  );
}

/// Read-only notice for an invited member: «Solo Carmen (titular) puede …».
class AvisoSoloLectura extends StatelessWidget {
  const AvisoSoloLectura({
    super.key,
    required this.titular,
    required this.accion,
  });

  /// First name of the owner.
  final String titular;

  /// What only the owner can do, e.g. «cambiar el nombre de la habitación».
  final String accion;

  @override
  Widget build(BuildContext context) => Aviso(
    tono: TonoAviso.neutral,
    icono: Ico.lock,
    texto: 'Solo $titular (titular) puede $accion.',
  );
}

/// «Solo ver» tag with a lock (`.ro-tag`).
class EtiquetaSoloVer extends StatelessWidget {
  const EtiquetaSoloVer({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icono(Ico.lock, tamano: 15, color: context.colores.tinta3),
      const SizedBox(width: 4),
      Text(
        'Solo ver',
        style: estiloTexto(13, 700, color: context.colores.tinta3),
      ),
    ],
  );
}

/// Large rounded icon of result screens (account created, consent recorded...).
class IconoGrande extends StatelessWidget {
  const IconoGrande({
    super.key,
    required this.icono,
    required this.fondo,
    required this.color,
    this.tamano = 72,
  });

  final Ico icono;
  final Color fondo;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(tamano * 0.3),
    ),
    child: Icono(icono, tamano: tamano * 0.55, color: color),
  );
}

/// Numbered steps (`.steps`).
class PasosNumerados extends StatelessWidget {
  const PasosNumerados(this.pasos, {super.key});

  /// Title and optional detail of each step.
  final List<(String, String?)> pasos;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < pasos.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CirculoPaso(numero: i + 1),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pasos[i].$1,
                      style: estiloTexto(
                        17,
                        pasos[i].$2 == null ? 400 : 700,
                        color: context.colores.tinta,
                      ),
                    ),
                    if (pasos[i].$2 != null)
                      Text(
                        pasos[i].$2!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// Round step number; green with a check when [hecho].
class CirculoPaso extends StatelessWidget {
  const CirculoPaso({super.key, this.numero, this.hecho = false, this.hijo});

  final int? numero;
  final bool hecho;
  final Widget? hijo;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: hecho ? Colores.calma : context.colores.inversa,
      shape: BoxShape.circle,
    ),
    child:
        hijo ??
        (hecho
            ? const Icono(Ico.check, tamano: 18, color: Colors.white)
            : Text(
                '$numero',
                style: estiloTexto(
                  16,
                  800,
                  color: context.colores.sobreInversa,
                ),
              )),
  );
}

/// Non-blocking notice (`.toast`): dark, at the top, with an icon, a title and an optional text.
void mostrarToast(
  BuildContext context, {
  required String titulo,
  String? texto,
  Ico icono = Ico.check,
  TonoAviso tono = TonoAviso.ok,
}) => mostrarAvisoFlotante(
  context,
  AvisoFlotante(titulo: titulo, texto: texto, icono: icono, tono: tono),
);

/// Setup header (`setupHead`): back button and title, then «Paso N de 5» above the progress bar.
///
/// Pass the screen's [escala] (`MediaQuery.textScalerOf`) so the header grows with large text
/// instead of clipping the step line.
class CabeceraConfiguracion extends StatelessWidget
    implements PreferredSizeWidget {
  const CabeceraConfiguracion({
    super.key,
    required this.paso,
    required this.titulo,
    this.escala = TextScaler.noScaling,
  });

  /// Steps of the setup: person, consent, camera, family and notifications.
  static const pasos = 5;

  final int paso;
  final String titulo;
  final TextScaler escala;

  double get _altoPaso => escala.scale(15) * 1.35;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 4 + _altoPaso + 6 + 6 + 14);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(titulo),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(4 + _altoPaso + 6 + 6 + 14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso $paso de $pasos',
              style: estiloTexto(15, 400, color: context.colores.tinta3),
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 1; i <= pasos; i++) ...[
                    if (i > 1) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= paso
                              ? Colores.morado
                              : context.colores.linea,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Text with a time in the mono font: `«antes»10:42«después»`.
TextSpan conHora(String antes, String horaTexto, [String despues = '']) =>
    TextSpan(
      children: [
        TextSpan(text: antes),
        TextSpan(text: horaTexto, style: estiloMono(tamano: 16)),
        if (despues.isNotEmpty) TextSpan(text: despues),
      ],
    );
