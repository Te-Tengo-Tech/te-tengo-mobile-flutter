import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import '../domain/camara.dart';

extension PresentacionEstado on EstadoVisible {
  Ico get icono => switch (this) {
    EstadoVisible.enLinea => Ico.cam,
    EstadoVisible.desconectada => Ico.wifiOff,
    EstadoVisible.enPausa => Ico.pause,
    EstadoVisible.noConfiable => Ico.eyeOff,
    EstadoVisible.detenida => Ico.lock,
  };

  /// Text color of the state (`.state-txt`).
  Color get color => switch (this) {
    EstadoVisible.enLinea => Colores.calmaTinta,
    EstadoVisible.desconectada || EstadoVisible.noConfiable => Colores.aviso,
    EstadoVisible.enPausa => Colores.pausa,
    EstadoVisible.detenida => Colores.tinta3,
  };
}

/// Camera status with icon, text and color: status never depends on color alone.
class EstadoCamara extends StatelessWidget {
  const EstadoCamara({super.key, required this.estado, this.tamano = 15});

  final EstadoVisible estado;
  final double tamano;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icono(estado.icono, tamano: 18, color: estado.color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          estado.texto,
          style: estiloTexto(tamano, 700, color: estado.color),
        ),
      ),
    ],
  );
}

/// Square state icon of a camera (`.camline`): online green, offline amber dashed, paused striped,
/// stopped gray, unreliable amber dashed.
class IconoEstadoCamara extends StatelessWidget {
  const IconoEstadoCamara({super.key, required this.estado, this.tamano = 36});

  final EstadoVisible estado;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(tamano * 0.33);
    final (fondo, color) = switch (estado) {
      EstadoVisible.enLinea => (Colores.calmaSuave, Colores.calmaTinta),
      EstadoVisible.desconectada ||
      EstadoVisible.noConfiable => (Colores.avisoSuave, Colores.aviso),
      EstadoVisible.enPausa => (Colores.pausaSuave, Colores.pausa),
      EstadoVisible.detenida => (Colores.fondo2, Colores.tinta3),
    };
    return ExcludeSemantics(
      child: CustomPaint(
        foregroundPainter: switch (estado) {
          EstadoVisible.desconectada ||
          EstadoVisible.noConfiable => _Punteado(radio),
          _ => null,
        },
        painter: estado == EstadoVisible.enPausa ? _Rayado(radio) : null,
        child: Container(
          width: tamano,
          height: tamano,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: estado == EstadoVisible.enPausa ? null : fondo,
            borderRadius: radio,
          ),
          child: Icono(estado.icono, tamano: tamano * 0.6, color: color),
        ),
      ),
    );
  }
}

class _Punteado extends CustomPainter {
  const _Punteado(this.radio);

  final BorderRadius radio;

  @override
  void paint(Canvas canvas, Size size) {
    final ruta = Path()..addRRect(radio.toRRect(Offset.zero & size).deflate(1));
    final p = Paint()
      ..color = Colores.aviso
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in ruta.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(_Punteado old) => false;
}

class _Rayado extends CustomPainter {
  const _Rayado(this.radio);

  final BorderRadius radio;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRRect(radio.toRRect(rect));
    canvas.drawRect(rect, Paint()..color = Colores.pausaSuave);
    final p = Paint()..color = const Color(0xFFD4D9E4);
    for (var x = -size.height; x < size.width + size.height; x += 10) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 5, 0)
          ..lineTo(x + 5 + size.height, size.height)
          ..lineTo(x + size.height, size.height)
          ..close(),
        p,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Rayado old) => false;
}
