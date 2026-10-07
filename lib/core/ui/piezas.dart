import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';
import 'aviso.dart';
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
      const Icono(Ico.lock, tamano: 15, color: Colores.tinta3),
      const SizedBox(width: 4),
      Text('Solo ver', style: estiloTexto(13, 700, color: Colores.tinta3)),
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
                      style: estiloTexto(17, pasos[i].$2 == null ? 400 : 700),
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
      color: hecho ? Colores.calma : Colores.tinta,
      shape: BoxShape.circle,
    ),
    child:
        hijo ??
        (hecho
            ? const Icono(Ico.check, tamano: 18, color: Colors.white)
            : Text(
                '$numero',
                style: estiloTexto(16, 800, color: Colors.white),
              )),
  );
}

/// Non-blocking notice (`.toast`): dark, with an icon, a title and an optional text.
void mostrarToast(
  BuildContext context, {
  required String titulo,
  String? texto,
  Ico icono = Ico.check,
  TonoAviso tono = TonoAviso.ok,
}) {
  final colorIcono = switch (tono) {
    TonoAviso.ok => const Color(0xFF7FD9A8),
    TonoAviso.advertencia => const Color(0xFFFFC76B),
    _ => Colors.white,
  };
  final mensajero = ScaffoldMessenger.maybeOf(context);
  if (mensajero == null) return;
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 3400),
        content: Row(
          children: [
            Icono(icono, tamano: 22, color: colorIcono),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: estiloTexto(16, 700, color: Colors.white),
                  ),
                  if (texto != null && texto.isNotEmpty)
                    Text(
                      texto,
                      style: estiloTexto(15, 400, color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

/// Setup header (`setupHead`): back button, title, «Paso N de 4» and the progress bar.
class CabeceraConfiguracion extends StatelessWidget
    implements PreferredSizeWidget {
  const CabeceraConfiguracion({
    super.key,
    required this.paso,
    required this.titulo,
  });

  final int paso;
  final String titulo;

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(titulo),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          child: Text(
            'Paso $paso de 4',
            style: estiloTexto(15, 400, color: Colores.tinta3),
          ),
        ),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
        child: ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 1; i <= 4; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= paso ? Colores.morado : Colores.linea,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
