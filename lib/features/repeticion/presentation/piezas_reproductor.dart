import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/iconos.dart';
import '../../alertas/presentation/etiquetas.dart';
import '../../movimientos/presentation/esqueleto.dart';
import '../domain/repeticion.dart';
import 'reproductor_camara.dart';

String _dos(int n) => n.toString().padLeft(2, '0');

/// `10:41:52`.
String horaConSegundos(DateTime t) =>
    '${_dos(t.hour)}:${_dos(t.minute)}:${_dos(t.second)}';

/// «Hoy», «Ayer» or «lun 21 sep» (`dayChip`).
String etiquetaDiaCamara(DateTime dia, DateTime hoy) {
  final d = DateTime(dia.year, dia.month, dia.day);
  final h = DateTime(hoy.year, hoy.month, hoy.day);
  if (d == h) return 'Hoy';
  if (d == h.subtract(const Duration(days: 1))) return 'Ayer';
  return fechaCorta(d);
}

/// The mark of an event on the timeline and in the list (`rpMark`): a red triangle for a fall, an
/// amber diamond for an unstable movement, a green circle when the person got up.
class MarcaEvento extends StatelessWidget {
  const MarcaEvento(this.tipo, {super.key, this.tamano = 20});

  final TipoEvento tipo;
  final double tamano;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: tamano,
      child: CustomPaint(painter: _PintorMarca(tipo)),
    ),
  );
}

class _PintorMarca extends CustomPainter {
  const _PintorMarca(this.tipo);

  final TipoEvento tipo;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 20);
    switch (tipo) {
      case TipoEvento.caida:
        final p = Path()
          ..moveTo(10, 2.5)
          ..lineTo(18.5, 17)
          ..lineTo(1.5, 17)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFFD63B2F));
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeJoin = StrokeJoin.round,
        );
      case TipoEvento.inestable:
        final p = Path()
          ..moveTo(10, 1.8)
          ..lineTo(18.2, 10)
          ..lineTo(10, 18.2)
          ..lineTo(1.8, 10)
          ..close();
        canvas.drawPath(p, Paint()..color = Colores.inestable);
        canvas.drawPath(
          p,
          Paint()
            ..color = const Color(0xFF8A5E00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      case TipoEvento.levanto:
        canvas.drawCircle(
          const Offset(10, 10),
          7.5,
          Paint()..color = Colores.calma,
        );
        canvas.drawCircle(
          const Offset(10, 10),
          7.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
    }
  }

  @override
  bool shouldRepaint(_PintorMarca old) => old.tipo != tipo;
}

/// «● En vivo» over the stage: opens the live view.
class BotonEnVivo extends StatelessWidget {
  const BotonEnVivo({
    super.key,
    required this.habitacion,
    required this.alTocar,
  });

  final String habitacion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Ver $habitacion en vivo',
    excludeSemantics: true,
    child: Material(
      color: const Color(0xE6221A38),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: alTocar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5A4A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'En vivo',
                  style: estiloTexto(16, 700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The stage when the movements cannot be shown (screens 201 to 203): an icon, one line and an
/// optional action, over the room.
class EscenarioApagado extends StatelessWidget {
  const EscenarioApagado({
    super.key,
    required this.icono,
    required this.texto,
    required this.enVivo,
    this.accion,
  });

  final Ico icono;
  final String texto;
  final Widget enVivo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        color: c.fondo2,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icono(icono, tamano: 30, color: c.icono),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: estiloTexto(16, 700, color: c.tinta),
                      ),
                    ),
                    if (accion != null) ...[
                      const SizedBox(height: 10),
                      accion!,
                    ],
                  ],
                ),
              ),
            ),
            Positioned(top: 12, right: 12, child: enVivo),
          ],
        ),
      ),
    );
  }
}

/// The stage with the stored movements (`rpCanvas`): a grid and the floor, the skeleton of the
/// frame at the playhead (never video), the phase tag, the moment and «En vivo». Without a frame
/// it says so instead of guessing a posture.
class EscenarioMovimientos extends StatelessWidget {
  const EscenarioMovimientos({
    super.key,
    required this.reproductor,
    required this.hoy,
    required this.enVivo,
    this.nombreAdultoMayor = '',
  });

  final ReproductorCamara reproductor;
  final DateTime hoy;
  final Widget enVivo;
  final String nombreAdultoMayor;

  @override
  Widget build(BuildContext context) {
    final r = reproductor;
    final c = context.colores;
    final fase = r.fase;
    final fotograma = r.fotograma;
    // A state that stops the player covers the stage; otherwise, without a frame, say why
    // there is no skeleton (never a guessed posture).
    final (Ico, String)? bloqueo = switch (r.estado) {
      EstadoReproductor.cargando => (Ico.clock, 'Cargando…'),
      EstadoReproductor.sinInternet => (Ico.wifiOff, 'Sin internet'),
      EstadoReproductor.revocado => (
        Ico.lock,
        '$nombreAdultoMayor retiró el permiso. Se borraron sus movimientos.',
      ),
      EstadoReproductor.listo => null,
    };
    final (Ico, String)? mensaje =
        bloqueo ??
        (fotograma != null || fase?.tipo == null && fase != null
            ? null
            : r.registrada && fase == null
            ? (Ico.eyeOff, 'Sin persona en la imagen')
            : null);
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        color: c.oscura ? const Color(0xFF2A2340) : const Color(0xFFEFEAF7),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _Rejilla(c.oscura ? c.linea : const Color(0xFFDCD5EA)),
                foregroundPainter: fotograma == null
                    ? null
                    : PintorEsqueleto(fotograma, color: c.tinta),
              ),
            ),
            if (mensaje != null && (bloqueo != null || fase == null))
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Semantics(
                      liveRegion: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icono(mensaje.$1, tamano: 26, color: c.icono),
                          const SizedBox(height: 6),
                          Text(
                            mensaje.$2,
                            textAlign: TextAlign.center,
                            style: estiloTexto(15, 700, color: c.tinta2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (fase != null && bloqueo == null)
              Positioned(top: 12, left: 12, child: _EtiquetaFase(fase)),
            Positioned(top: 12, right: 12, child: enVivo),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xD9221A38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${etiquetaDiaCamara(r.dia, hoy)} '
                  '${horaConSegundos(r.posicion)}',
                  style: estiloTexto(15, 700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaFase extends StatelessWidget {
  const _EtiquetaFase(this.fase);

  final ({String texto, TipoEvento? tipo}) fase;

  @override
  Widget build(BuildContext context) {
    final (fondo, color, icono) = switch (fase.tipo) {
      TipoEvento.caida => (const Color(0xFFD63B2F), Colors.white, Ico.fall),
      TipoEvento.inestable => (Colores.inestable, Colores.tinta, Ico.unsteady),
      TipoEvento.levanto => (Colores.calma, Colors.white, Ico.stand),
      null => (const Color(0xD9221A38), Colors.white, Ico.eyeOff),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icono(icono, tamano: 18, color: color),
            const SizedBox(width: 6),
            Text(fase.texto, style: estiloTexto(15, 700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _Rejilla extends CustomPainter {
  const _Rejilla(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    final piso = size.height * 0.85;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (var i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, piso), p);
    }
    canvas.drawLine(
      Offset(0, piso),
      Offset(size.width, piso),
      p
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: 1),
    );
  }

  @override
  bool shouldRepaint(_Rejilla old) => old.color != color;
}

/// The draggable timeline (`rpTimeline`): the events above, the stretches without data hatched,
/// the playhead, and three ticks. A slider for screen readers (±10 s).
class LineaDeTiempoReproductor extends StatelessWidget {
  const LineaDeTiempoReproductor({
    super.key,
    required this.reproductor,
    required this.habilitada,
  });

  final ReproductorCamara reproductor;
  final bool habilitada;

  @override
  Widget build(BuildContext context) {
    final r = reproductor;
    final c = context.colores;
    final total = r.largo.inMilliseconds;
    double fr(DateTime t) =>
        (t.difference(r.inicio).inMilliseconds / total).clamp(0.0, 1.0);
    final eventos = r.eventosEnVentana;
    // Close marks stack up to three rows.
    final niveles = <int>[];
    var previo = -1.0;
    var nivel = 0;
    for (final e in eventos) {
      final q = fr(e.en);
      nivel = q - previo < 0.04 ? math.min(2, nivel + 1) : 0;
      niveles.add(nivel);
      previo = q;
    }
    final altoMarcas =
        24.0 + 22 * (niveles.isEmpty ? 0 : niveles.reduce(math.max));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: LayoutBuilder(
        builder: (context, limites) {
          final ancho = limites.maxWidth;
          void ir(double x) => r.irA(
            r.inicio.add(
              Duration(
                milliseconds: (total * (x / ancho).clamp(0.0, 1.0)).round(),
              ),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: altoMarcas,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < eventos.length; i++)
                      Positioned(
                        left: fr(eventos[i].en) * ancho - 12,
                        bottom: 2.0 + niveles[i] * 22,
                        child: Semantics(
                          button: true,
                          label:
                              '${horaConSegundos(eventos[i].en)}, '
                              '${eventos[i].tipo.texto}. Ir a este momento',
                          excludeSemantics: true,
                          child: InkResponse(
                            radius: 22,
                            onTap: habilitada
                                ? () => r.irA(eventos[i].en, evento: true)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: MarcaEvento(eventos[i].tipo),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Semantics(
                slider: true,
                enabled: habilitada,
                label: 'Momento de la repetición',
                value: horaConSegundos(r.posicion),
                increasedValue: horaConSegundos(
                  r.posicion.add(const Duration(seconds: 10)),
                ),
                decreasedValue: horaConSegundos(
                  r.posicion.subtract(const Duration(seconds: 10)),
                ),
                onIncrease: habilitada ? () => r.saltar(1) : null,
                onDecrease: habilitada ? () => r.saltar(-1) : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: habilitada ? (d) => ir(d.localPosition.dx) : null,
                  onHorizontalDragUpdate: habilitada
                      ? (d) => ir(d.localPosition.dx)
                      : null,
                  child: SizedBox(
                    height: 44,
                    child: CustomPaint(
                      painter: _Pista(
                        avance: fr(r.posicion),
                        huecos: [
                          for (final h in r.huecos) (fr(h.desde), fr(h.hasta)),
                        ],
                        fondo: c.linea,
                        relleno: c.oscura
                            ? const Color(0xFF9C86D6)
                            : Colores.morado,
                        cabeza: c.oscura ? Colors.white : Colores.moradoTinta,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ExcludeSemantics(
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final k in [0, 1, 2])
                          Text(
                            hora(r.inicio.add(r.largo * (k / 2))),
                            style: estiloMono(
                              tamano: 14,
                              peso: 400,
                              color: c.tinta3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pista extends CustomPainter {
  const _Pista({
    required this.avance,
    required this.huecos,
    required this.fondo,
    required this.relleno,
    required this.cabeza,
  });

  final double avance;
  final List<(double, double)> huecos;
  final Color fondo;
  final Color relleno;
  final Color cabeza;

  @override
  void paint(Canvas canvas, Size size) {
    const alto = 14.0;
    final y = (size.height - alto) / 2;
    final pista = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, y, size.width, alto),
      const Radius.circular(7),
    );
    canvas.save();
    canvas.clipRRect(pista);
    canvas.drawRRect(pista, Paint()..color = fondo);
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width * avance, alto),
      Paint()..color = relleno,
    );
    final raya = Paint()
      ..color = relleno.withValues(alpha: 0.45)
      ..strokeWidth = 3;
    for (final (a, b) in huecos) {
      final x0 = size.width * a, x1 = size.width * b;
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(x0, y, x1, y + alto));
      canvas.drawRect(
        Rect.fromLTRB(x0, y, x1, y + alto),
        Paint()..color = fondo,
      );
      for (var x = x0 - alto; x < x1 + alto; x += 7) {
        canvas.drawLine(Offset(x, y + alto), Offset(x + alto, y), raya);
      }
      canvas.restore();
    }
    canvas.restore();
    final x = size.width * avance;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.height / 2),
          width: 8,
          height: size.height,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = cabeza,
    );
  }

  @override
  bool shouldRepaint(_Pista old) =>
      old.avance != avance || old.huecos != huecos || old.fondo != fondo;
}

String textoVelocidad(double v) =>
    v == 0.5 ? '0,5×' : '${v.toStringAsFixed(0)}×';

/// Speed, −10 s (or the previous event), play and +10 s (or the next event) (`camControls`).
class ControlesReproductor extends StatelessWidget {
  const ControlesReproductor({
    super.key,
    required this.reproductor,
    required this.habilitados,
  });

  final ReproductorCamara reproductor;
  final bool habilitados;

  @override
  Widget build(BuildContext context) {
    final r = reproductor;
    final c = context.colores;
    final solo = r.soloEventos;
    Widget redondo({
      required String etiqueta,
      required Widget hijo,
      required VoidCallback accion,
      double tamano = 52,
      bool principal = false,
    }) => Semantics(
      button: true,
      enabled: habilitados,
      label: etiqueta,
      excludeSemantics: true,
      child: Material(
        color: principal
            ? (habilitados ? c.botonPrimario : c.linea2)
            : c.moradoSuave,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: habilitados ? accion : null,
          child: SizedBox.square(
            dimension: tamano,
            child: Center(child: hijo),
          ),
        ),
      ),
    );
    Widget salto(int sentido) {
      if (solo) {
        return Icono(
          sentido < 0 ? Ico.prev : Ico.next,
          tamano: 22,
          color: c.icono,
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          Icono(
            sentido < 0 ? Ico.atras10 : Ico.adelante10,
            tamano: 26,
            color: c.icono,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('10', style: estiloTexto(9, 800, color: c.icono)),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          redondo(
            etiqueta:
                'Velocidad ${textoVelocidad(r.velocidad)}. Cambiar la velocidad',
            hijo: Text(
              textoVelocidad(r.velocidad),
              style: estiloTexto(15, 800, color: c.moradoTinta),
            ),
            accion: r.cambiarVelocidad,
          ),
          const SizedBox(width: 14),
          redondo(
            etiqueta: solo ? 'Evento anterior' : 'Retroceder 10 segundos',
            hijo: salto(-1),
            accion: () => r.saltar(-1),
          ),
          const SizedBox(width: 14),
          redondo(
            etiqueta: r.reproduciendo ? 'Pausar' : 'Reproducir',
            principal: true,
            tamano: 64,
            hijo: Icono(
              r.reproduciendo ? Ico.pause : Ico.play,
              tamano: 28,
              color: Colors.white,
            ),
            accion: r.alternar,
          ),
          const SizedBox(width: 14),
          redondo(
            etiqueta: solo ? 'Evento siguiente' : 'Adelantar 10 segundos',
            hijo: salto(1),
            accion: () => r.saltar(1),
          ),
        ],
      ),
    );
  }
}

/// A row of «Eventos · Hoy» (`camEvList`): the mark, the time, what happened and the alert's
/// stamp; the current one is highlighted. Tapping it moves the player there.
class FilaEvento extends StatelessWidget {
  const FilaEvento({
    super.key,
    required this.evento,
    required this.actual,
    required this.alTocar,
  });

  final EventoCamara evento;
  final bool actual;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final e = evento;
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    return Semantics(
      selected: actual,
      child: Material(
        color: actual ? c.moradoSuave : Colors.transparent,
        child: InkWell(
          onTap: alTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  MarcaEvento(e.tipo),
                  const SizedBox(width: 14),
                  Text(
                    hora(e.en),
                    style: estiloMono(tamano: 16, color: c.tinta2),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.tipo.texto,
                          style: estiloTexto(17, 700, color: c.tinta),
                        ),
                        if (grande && e.tipo != TipoEvento.levanto) ...[
                          const SizedBox(height: 4),
                          SelloEstado(e.alerta),
                        ],
                      ],
                    ),
                  ),
                  if (!grande && e.tipo != TipoEvento.levanto)
                    SelloEstado(e.alerta),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// «Elegir día» (`O.elegirDia`, screens 199, 200): the last 14 days, the ones before the stored
/// movements disabled, a dot on the days with events.
class HojaElegirDia extends StatelessWidget {
  const HojaElegirDia({
    super.key,
    required this.hoy,
    required this.elegido,
    required this.conEventos,
    required this.alElegir,
    this.datosDesde,
  });

  final DateTime hoy;
  final DateTime elegido;
  final DateTime? datosDesde;
  final Set<DateTime> conEventos;
  final ValueChanged<DateTime> alElegir;

  static const _dias = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final h = DateTime(hoy.year, hoy.month, hoy.day);
    final desde = datosDesde == null
        ? null
        : DateTime(datosDesde!.year, datosDesde!.month, datosDesde!.day);
    final dias = [for (var i = 13; i >= 0; i--) h.subtract(Duration(days: i))];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Elegir día',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (desde != null) ...[
            const SizedBox(height: 8),
            Text(
              'Hay movimientos desde el ${fechaNumerica(desde)}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 6,
            childAspectRatio: 0.72,
            children: [
              for (final d in dias)
                _Dia(
                  dia: d,
                  semana: _dias[d.weekday - 1],
                  elegido: d == elegido,
                  deshabilitado: desde != null && d.isBefore(desde),
                  conEventos: conEventos.contains(d),
                  alTocar: () => alElegir(d),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colores.coral,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Con eventos', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Divider(color: c.linea, height: 1, thickness: 0),
        ],
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.dia,
    required this.semana,
    required this.elegido,
    required this.deshabilitado,
    required this.conEventos,
    required this.alTocar,
  });

  final DateTime dia;
  final String semana;
  final bool elegido;
  final bool deshabilitado;
  final bool conEventos;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = elegido
        ? c.sobreInversa
        : deshabilitado
        ? c.tinta3
        : c.tinta;
    return Semantics(
      button: true,
      enabled: !deshabilitado,
      selected: elegido,
      label:
          '${fechaLarga(dia)}'
          '${deshabilitado
              ? ', sin movimientos'
              : conEventos
              ? ', con eventos'
              : ''}',
      excludeSemantics: true,
      child: Material(
        color: elegido
            ? c.inversa
            : deshabilitado
            ? c.fondo
            : c.tarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: elegido ? c.inversa : c.linea2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: deshabilitado ? null : alTocar,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(semana, style: estiloTexto(12, 600, color: color)),
              Text('${dia.day}', style: estiloMono(tamano: 17, color: color)),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: conEventos && !deshabilitado
                      ? Colores.coral
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
