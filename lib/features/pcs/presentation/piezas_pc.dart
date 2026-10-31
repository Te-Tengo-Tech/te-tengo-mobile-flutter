import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../actualizaciones/data/actualizacion_controller.dart';
import '../../actualizaciones/presentation/version_pc.dart';
import '../../camaras/presentation/cabecera_camara.dart';
import '../domain/pc.dart';

/// State of a PC as the family sees it (`pcState`): never by color alone.
enum EstadoPc {
  enLinea,

  /// No heartbeat in the last 90 s (CA-30.3).
  sinConexion,

  /// Linked, but no webcam is in use yet.
  faltanCamaras;

  /// A PC that never sent a heartbeat was just linked: it is getting its tokens, not offline.
  static EstadoPc de(Pc pc) => pc.sinConexion
      ? sinConexion
      : pc.camaras.isEmpty
      ? faltanCamaras
      : enLinea;
}

/// The PC's state line: «En línea · última señal hace 6 s», «Sin conexión desde las 09:58» or
/// «Falta elegir las cámaras».
InlineSpan textoEstadoPc(Pc pc, DateTime ahora) {
  final senal = pc.ultimaSenal;
  return switch (EstadoPc.de(pc)) {
    EstadoPc.sinConexion => TextSpan(
      children: [
        const TextSpan(text: 'Sin conexión'),
        if (senal != null) ...[
          const TextSpan(text: ' desde las '),
          TextSpan(text: hora(senal), style: estiloMono(tamano: 15)),
        ],
      ],
    ),
    EstadoPc.faltanCamaras => const TextSpan(text: 'Falta elegir las cámaras'),
    EstadoPc.enLinea => TextSpan(
      text: senal == null
          ? 'En línea'
          : 'En línea · última señal ${haceTiempo(senal, ahora)}',
    ),
  };
}

/// Round PC icon with the state's color (`.pcline`): green online, amber dashed offline, purple
/// dashed while its cameras are not chosen.
class IconoPc extends StatelessWidget {
  const IconoPc({super.key, required this.estado, this.tamano = 44});

  final EstadoPc estado;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final (fondo, color, icono, punteado) = switch (estado) {
      EstadoPc.enLinea => (c.calmaSuave, c.calmaTinta, Ico.pc, false),
      EstadoPc.sinConexion => (c.avisoSuave, c.aviso, Ico.wifiOff, true),
      EstadoPc.faltanCamaras => (c.moradoSuave, c.icono, Ico.pc, true),
    };
    return ExcludeSemantics(
      child: CustomPaint(
        foregroundPainter: punteado ? _CirculoPunteado(color) : null,
        child: Container(
          width: tamano,
          height: tamano,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
          child: Icono(icono, tamano: tamano * 0.5, color: color),
        ),
      ),
    );
  }
}

class _CirculoPunteado extends CustomPainter {
  const _CirculoPunteado(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final ruta = Path()..addOval((Offset.zero & size).deflate(1));
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in ruta.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(_CirculoPunteado old) => old.color != color;
}

/// Header row of a PC (`pcHead`): icon, name, state and the version of Te Tengo Captura. Opens the
/// PC's detail when [alTocar] is set.
class CabeceraPc extends ConsumerWidget {
  const CabeceraPc({
    super.key,
    required this.pc,
    required this.ahora,
    this.alTocar,
  });

  final Pc pc;
  final DateTime ahora;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = EstadoPc.de(pc);
    final programa = programaConVersion(
      context,
      pc,
      ref.watch(versionesPublicadasProvider),
    );
    final colorEstado = switch (estado) {
      EstadoPc.enLinea => context.colores.calmaTinta,
      EstadoPc.sinConexion => context.colores.aviso,
      EstadoPc.faltanCamaras => context.colores.moradoTinta,
    };
    return FilaLista(
      inicio: IconoPc(estado: estado),
      titulo: pc.nombre,
      subtituloRico: TextSpan(
        children: [
          TextSpan(
            style: estiloTexto(15, 700, color: colorEstado),
            children: [textoEstadoPc(pc, ahora)],
          ),
          if (programa != null) ...[const TextSpan(text: '\n'), programa],
        ],
      ),
      alTocar: alTocar,
    );
  }
}

/// What to check at home when a PC does not answer (`pcChecks`, CA-30.3).
class QueRevisarPc extends StatelessWidget {
  const QueRevisarPc({super.key});

  @override
  Widget build(BuildContext context) => const ListaTarjeta(
    children: [
      FilaLista(
        inicio: IconoFila(Ico.pc),
        titulo: 'Que la PC esté encendida',
        subtitulo: 'Sin suspender',
      ),
      FilaLista(
        inicio: IconoFila(Ico.wifi),
        titulo: 'Que tenga internet',
        subtitulo: 'Con la luz del módem encendida',
      ),
      FilaLista(
        inicio: IconoFila(Ico.cam),
        titulo: 'Que Te Tengo Captura esté abierto',
        subtitulo: 'Junto al reloj de Windows',
      ),
    ],
  );
}

/// Big round icon at the top of the pairing screens (`.pc-hero`).
class HeroePc extends StatelessWidget {
  const HeroePc({super.key, this.icono = Ico.pc, this.fondo, this.color});

  final Ico icono;
  final Color? fondo;
  final Color? color;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo ?? context.colores.moradoSuave,
        shape: BoxShape.circle,
      ),
      child: Icono(icono, tamano: 32, color: color ?? context.colores.icono),
    ),
  );
}

/// A room chip; one that already has a camera is readable and disabled, and the screen explains it
/// under the chips (CA-29.3).
class ChipHabitacion extends StatelessWidget {
  const ChipHabitacion({
    required this.texto,
    required this.elegido,
    required this.ocupada,
    required this.alTocar,
    super.key,
  });

  final String texto;
  final bool elegido;
  final bool ocupada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    if (!ocupada) {
      return Semantics(
        button: true,
        selected: elegido,
        child: Material(
          color: elegido ? c.inversa : c.tarjeta,
          shape: StadiumBorder(
            side: BorderSide(color: elegido ? c.inversa : c.linea2, width: 1.5),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: alTocar,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  texto,
                  style: estiloTexto(
                    16,
                    600,
                    color: elegido ? c.sobreInversa : c.tinta,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      enabled: false,
      label: '$texto, ya tiene cámara',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: c.fondo2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.linea2, width: 1.5),
        ),
        child: Text(texto, style: estiloTexto(16, 600, color: c.tinta2)),
      ),
    );
  }
}
