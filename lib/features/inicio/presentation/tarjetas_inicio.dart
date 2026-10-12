import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/estado_camara.dart';
import '../../familia/domain/familiar.dart';
import '../../pcs/domain/camaras_en_casa.dart';
import '../../pcs/presentation/pantalla_camaras.dart';

/// The two tiles of Inicio (`homeTiles`): «Cámaras», how many work and a dot per room, and
/// «Familia», who else is watching. One column with large text.
class TarjetasInicio extends StatelessWidget {
  const TarjetasInicio({
    super.key,
    required this.camaras,
    required this.conConsentimiento,
    required this.familia,
    required this.alTocarCamaras,
    required this.alTocarFamilia,
  });

  final List<CamaraEnCasa> camaras;
  final bool conConsentimiento;

  /// Null while it loads.
  final List<Familiar>? familia;
  final VoidCallback alTocarCamaras;
  final VoidCallback alTocarFamilia;

  @override
  Widget build(BuildContext context) {
    final camarasTile = _Tile(
      icono: Ico.cam,
      coral: true,
      titulo: 'Cámaras',
      linea: lineaTarjetaCamaras(camaras, conConsentimiento: conConsentimiento),
      pie: camaras.length < 2 ? null : PuntosHabitaciones(camaras),
      alTocar: alTocarCamaras,
    );
    final n = familia?.length;
    final familiaTile = _Tile(
      icono: Ico.users,
      titulo: 'Familia',
      linea: n == null ? '' : contar(n, 'persona', 'personas'),
      cabeza: familia == null || familia!.isEmpty
          ? null
          : _Fotos([for (final f in familia!.take(3)) f.nombre]),
      alTocar: alTocarFamilia,
    );
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    if (grande) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [camarasTile, const SizedBox(height: 12), familiaTile],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: camarasTile),
          const SizedBox(width: 12),
          Expanded(child: familiaTile),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icono,
    required this.titulo,
    required this.linea,
    required this.alTocar,
    this.coral = false,
    this.pie,
    this.cabeza,
  });

  final Ico icono;
  final bool coral;
  final String titulo;
  final String linea;
  final Widget? pie;
  final Widget? cabeza;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      button: true,
      child: Material(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: coral ? c.coralSuave : c.moradoSuave,
                      shape: BoxShape.circle,
                    ),
                    child: Icono(
                      icono,
                      tamano: 22,
                      color: coral ? c.coralTinta : c.moradoTinta,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(titulo, style: estiloTexto(17, 700, color: c.tinta)),
                  if (cabeza != null) ...[const SizedBox(height: 6), cabeza!],
                  if (linea.isNotEmpty)
                    Text(linea, style: estiloTexto(15, 400, color: c.tinta3)),
                  if (pie != null) ...[const SizedBox(height: 8), pie!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to three people's initials, stacked.
class _Fotos extends StatelessWidget {
  const _Fotos(this.nombres);

  final List<String> nombres;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 32,
      width: 32.0 + 22 * (nombres.length - 1),
      child: Stack(
        children: [
          for (var i = 0; i < nombres.length; i++)
            Positioned(
              left: 22.0 * i,
              child: Avatar(
                Avatar.inicialesDe(nombres[i]),
                tono: TonoAvatar.values[i % TonoAvatar.values.length],
                tamano: 32,
              ),
            ),
        ],
      ),
    ),
  );
}

/// A 12 px dot per room (`roomDots`), with shape as well as color: filled green works, an amber ring
/// is unplugged or unreliable, dotted gray is a PC offline, striped is paused; problems first, up to
/// five, then «+N».
class PuntosHabitaciones extends StatelessWidget {
  const PuntosHabitaciones(this.camaras, {super.key});

  final List<CamaraEnCasa> camaras;

  @override
  Widget build(BuildContext context) {
    final ordenadas = [
      ...camaras.where((c) => c.necesitaAtencion),
      ...camaras.where((c) => !c.necesitaAtencion),
    ];
    final vistas = ordenadas.length > 5
        ? ordenadas.take(4).toList()
        : ordenadas;
    final resto = ordenadas.length - vistas.length;
    return ExcludeSemantics(
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final c in vistas)
            CustomPaint(
              size: const Size.square(12),
              painter: _Punto(c.estado, context.colores),
            ),
          if (resto > 0)
            Text(
              '+$resto',
              style: estiloTexto(13, 700, color: context.colores.tinta3),
            ),
        ],
      ),
    );
  }
}

class _Punto extends CustomPainter {
  const _Punto(this.estado, this.paleta);

  final EstadoVisible estado;
  final Paleta paleta;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final r = size.width / 2;
    switch (estado) {
      case EstadoVisible.enLinea:
        canvas.drawCircle(centro, r, Paint()..color = paleta.calmaTinta);
      case EstadoVisible.desconectada || EstadoVisible.noConfiable:
        canvas.drawCircle(
          centro,
          r - 1.25,
          Paint()
            ..color = paleta.aviso
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      case EstadoVisible.sinConexion:
        final p = Paint()
          ..color = paleta.tinta3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        final ruta = Path()
          ..addOval(Rect.fromCircle(center: centro, radius: r - 1));
        for (final m in ruta.computeMetrics()) {
          for (var d = 0.0; d < m.length; d += 4) {
            canvas.drawPath(m.extractPath(d, d + 2), p);
          }
        }
      case EstadoVisible.enPausa:
        canvas.save();
        canvas.clipPath(
          Path()..addOval(Rect.fromCircle(center: centro, radius: r)),
        );
        canvas.drawCircle(centro, r, Paint()..color = paleta.pausaSuave);
        final raya = Paint()
          ..color = paleta.pausa
          ..strokeWidth = 2;
        for (var x = -size.width; x < size.width * 2; x += 4) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            raya,
          );
        }
        canvas.restore();
      case EstadoVisible.detenida:
        canvas.drawCircle(centro, r, Paint()..color = paleta.linea2);
    }
  }

  @override
  bool shouldRepaint(_Punto old) => old.estado != estado;
}

/// The one compact row under the tiles (`homeExtra`): a problem the older adult's card does not
/// mention, e.g. «Pasillo en pausa» while the card talks about the Cocina offline, or «2 cámaras
/// necesitan atención». Null when there is nothing else to say.
Widget? filaAtencionInicio(
  BuildContext context,
  List<CamaraEnCasa> camaras, {
  required bool conConsentimiento,
  required bool hayAlerta,
  required VoidCallback alTocar,
}) {
  if (camaras.length < 2 || !conConsentimiento) return null;
  final atencion = camaras.where((c) => c.necesitaAtencion).toList();
  if (atencion.isEmpty) return null;
  final caidas = atencion.where((c) => c.noResponde).toList();
  final dichas = hayAlerta
      ? const <CamaraEnCasa>[]
      : caidas.isNotEmpty
      ? caidas
      : [
          atencion
                  .where((c) => c.estado == EstadoVisible.noConfiable)
                  .firstOrNull ??
              atencion.firstWhere((c) => c.estado == EstadoVisible.enPausa),
        ];
  final resto = atencion.where((c) => !dichas.contains(c)).toList();
  if (resto.isEmpty) return null;
  if (resto.length == 1) {
    final c = resto.single;
    final info = infoAtencion(c);
    return FilaLista(
      inicio: IconoEstadoCamara(estado: c.estado),
      titulo: info.titulo,
      subtituloRico: info.detalle,
      alTocar: alTocar,
    );
  }
  return FilaLista(
    inicio: const IconoEstadoCamara(
      estado: EstadoVisible.desconectada,
      icono: Ico.warn,
    ),
    titulo: '${resto.length} cámaras necesitan atención',
    subtitulo: enumerar([for (final c in resto) c.habitacion]),
    alTocar: alTocar,
  );
}
