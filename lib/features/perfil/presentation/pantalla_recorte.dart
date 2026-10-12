import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/botones.dart';

/// Side of the picture the app uploads: the backend keeps 512 × 512 at most (contract §13).
const ladoFoto = 512;

/// Crops a picture to the square the avatars show; null when the person goes back.
typedef RecortadorFoto =
    Future<Uint8List?> Function(BuildContext context, Uint8List original);

final recortadorFotoProvider = Provider<RecortadorFoto>(
  (ref) =>
      (context, original) => Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PantallaRecorte(original: original),
        ),
      ),
);

/// The part of the picture inside a square viewport of [lado] px, in the picture's pixels: the
/// picture is drawn at [escalaBase] (covering the square) and then moved and zoomed by [vista].
Rect areaVisible({
  required Matrix4 vista,
  required double lado,
  required double escalaBase,
  required Size imagen,
}) {
  final inversa = Matrix4.inverted(vista);
  final a = MatrixUtils.transformPoint(inversa, Offset.zero) / escalaBase;
  final b =
      MatrixUtils.transformPoint(inversa, Offset(lado, lado)) / escalaBase;
  final area = Rect.fromPoints(a, b);
  // Always a square inside the picture.
  final s = math.min(
    math.min(area.width, area.height),
    math.min(imagen.width, imagen.height),
  );
  final x = area.left.clamp(0.0, imagen.width - s);
  final y = area.top.clamp(0.0, imagen.height - s);
  return Rect.fromLTWH(x, y, s, s);
}

/// Draws [area] of [imagen] as a [ladoFoto] PNG (dart:ui encodes PNG on every platform; the
/// backend turns it into a JPEG without metadata).
Future<Uint8List> recortarImagen(ui.Image imagen, Rect area) async {
  final grabador = ui.PictureRecorder();
  final lado = math.min(ladoFoto.toDouble(), area.width).roundToDouble();
  Canvas(grabador).drawImageRect(
    imagen,
    area,
    Rect.fromLTWH(0, 0, lado, lado),
    Paint()..filterQuality = FilterQuality.high,
  );
  final salida = await grabador.endRecording().toImage(
    lado.toInt(),
    lado.toInt(),
  );
  try {
    final datos = await salida.toByteData(format: ui.ImageByteFormat.png);
    return datos!.buffer.asUint8List();
  } finally {
    salida.dispose();
  }
}

/// Move and zoom the picture inside the circle the family will see, then use it. Full screen, on a
/// dark ground like the camera.
class PantallaRecorte extends StatefulWidget {
  const PantallaRecorte({super.key, required this.original});

  final Uint8List original;

  @override
  State<PantallaRecorte> createState() => _PantallaRecorteState();
}

class _PantallaRecorteState extends State<PantallaRecorte> {
  final _vista = TransformationController();
  ui.Image? _imagen;
  bool _error = false;
  bool _recortando = false;

  @override
  void initState() {
    super.initState();
    _decodificar();
  }

  Future<void> _decodificar() async {
    try {
      final imagen = await decodeImageFromList(widget.original);
      if (!mounted) return imagen.dispose();
      setState(() => _imagen = imagen);
    } on Object {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _vista.dispose();
    _imagen?.dispose();
    super.dispose();
  }

  Future<void> _usar(double lado, double escalaBase) async {
    final imagen = _imagen!;
    setState(() => _recortando = true);
    final area = areaVisible(
      vista: _vista.value,
      lado: lado,
      escalaBase: escalaBase,
      imagen: Size(imagen.width.toDouble(), imagen.height.toDouble()),
    );
    final bytes = await recortarImagen(imagen, area);
    if (mounted) Navigator.of(context).pop(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final imagen = _imagen;
    return Scaffold(
      backgroundColor: Colores.noche,
      appBar: AppBar(
        backgroundColor: Colores.noche,
        foregroundColor: Colors.white,
        title: Text(
          'Ajusta la foto',
          style: estiloTexto(20, 700, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: LayoutBuilder(
            builder: (context, c) {
              final lado = math.min(c.maxWidth, c.maxHeight - 140);
              if (_error) {
                return Center(
                  child: Text(
                    'No pudimos abrir esa foto. Elige otra.',
                    textAlign: TextAlign.center,
                    style: estiloTexto(17, 600, color: Colors.white),
                  ),
                );
              }
              if (imagen == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              final ancho = imagen.width.toDouble();
              final alto = imagen.height.toDouble();
              final escalaBase = lado / math.min(ancho, alto);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mueve y acerca la foto para centrar la cara.',
                    textAlign: TextAlign.center,
                    style: estiloTexto(16, 400, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox.square(
                      dimension: lado,
                      child: Stack(
                        children: [
                          ClipRect(
                            child: InteractiveViewer(
                              transformationController: _vista,
                              constrained: false,
                              minScale: 1,
                              maxScale: 4,
                              child: SizedBox(
                                width: ancho * escalaBase,
                                height: alto * escalaBase,
                                child: RawImage(
                                  image: imagen,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: CustomPaint(
                              size: Size.square(lado),
                              painter: _Mascara(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Boton(
                    'Usar esta foto',
                    cargando: _recortando,
                    alPresionar: () => _usar(lado, escalaBase),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Darkens what falls outside the circle of the avatar.
class _Mascara extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final todo = Path()..addRect(Offset.zero & size);
    final circulo = Path()..addOval(Offset.zero & size);
    canvas.drawPath(
      Path.combine(PathOperation.difference, todo, circulo),
      Paint()..color = Colores.noche.withValues(alpha: .62),
    );
    canvas.drawOval(
      (Offset.zero & size).deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: .9),
    );
  }

  @override
  bool shouldRepaint(_Mascara oldDelegate) => false;
}
