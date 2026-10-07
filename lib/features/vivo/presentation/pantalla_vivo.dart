import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/vista_en_vivo_repositorio.dart';
import '../domain/vista_en_vivo.dart';

/// Why the live view cannot open (`liveState`): CA-23.3 and CA-23.4.
enum _NoDisponible { desconectada, enPausa, detenida }

/// Live view (screens 38–40, 54 and 74): the room in real time, how long it has been open, and the
/// reminder that the access is recorded. From an alert it shows that alert's room (CA-23.2).
class PantallaVivo extends ConsumerStatefulWidget {
  const PantallaVivo({super.key, this.camaraId, this.alertaId});

  final String? camaraId;
  final String? alertaId;

  @override
  ConsumerState<PantallaVivo> createState() => _PantallaVivoState();
}

class _PantallaVivoState extends ConsumerState<PantallaVivo> {
  Camara? _camara;
  SesionVivo? _sesion;
  DateTime? _inicio;
  _NoDisponible? _noDisponible;
  DateTime? _pausadaHasta;
  ProblemaApi? _problema;
  Uint8List? _fotograma;
  int _segundos = 0;
  Timer? _reloj;
  StreamSubscription<Uint8List>? _transmision;
  late final VistaEnVivoRepositorio _repositorio;

  bool get _desdeAlerta => widget.alertaId != null;

  @override
  void initState() {
    super.initState();
    _repositorio = ref.read(vistaEnVivoRepositorioProvider);
    unawaited(_abrir());
  }

  Future<void> _abrir() async {
    setState(() {
      _problema = null;
      _noDisponible = null;
    });
    try {
      final hogar = await ref.read(hogarProvider.future);
      final camaras = await ref.read(camarasProvider.future);
      var camaraId = widget.camaraId;
      if (camaraId == null && widget.alertaId != null) {
        camaraId = (await ref.read(
          alertaProvider(widget.alertaId!).future,
        )).camaraId;
      }
      final camara =
          camaras.where((c) => c.id == camaraId).firstOrNull ??
          camaras.firstOrNull;
      if (!mounted || camara == null) return;
      setState(() {
        _camara = camara;
        _pausadaHasta = camara.pausadaHasta;
      });
      final noDisponible = switch (camara.estadoVisible(
        conConsentimiento: hogar.conConsentimiento,
      )) {
        EstadoVisible.detenida => _NoDisponible.detenida,
        EstadoVisible.desconectada => _NoDisponible.desconectada,
        EstadoVisible.enPausa => _NoDisponible.enPausa,
        _ => null,
      };
      if (noDisponible != null) {
        return setState(() => _noDisponible = noDisponible);
      }
      final sesion = await _repositorio.abrir(
        camara.id,
        alertaId: widget.alertaId,
      );
      if (!mounted) {
        unawaited(_repositorio.cerrar(sesion.sesionId).catchError((_) {}));
        return;
      }
      setState(() {
        _sesion = sesion;
        _inicio = ref.read(relojProvider)();
      });
      _reloj = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _segundos++),
      );
      _transmision = ref
          .read(transmisionProvider)(sesion.urlTransmision)
          .listen(
            (f) => setState(() => _fotograma = f),
            onError: (Object _) {},
          );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'CAMARA_DESCONECTADA':
            _noDisponible = _NoDisponible.desconectada;
          case 'CAMARA_EN_PAUSA':
            _noDisponible = _NoDisponible.enPausa;
            _pausadaHasta =
                fechaDesdeJson(e.extras['pausadaHasta']) ?? _pausadaHasta;
          default:
            _problema = e;
        }
      });
    }
  }

  /// Stops the stream and closes the session, which records the access (CA-24.1).
  void _terminar() {
    _reloj?.cancel();
    unawaited(_transmision?.cancel());
    final sesion = _sesion;
    _sesion = null;
    if (sesion == null) return;
    // The widget is gone when the DELETE finishes: refresh the log through the container.
    final contenedor = ProviderScope.containerOf(context, listen: false);
    unawaited(
      _repositorio
          .cerrar(sesion.sesionId)
          .then((_) => contenedor.invalidate(accesosVivoProvider))
          .catchError((_) {}),
    );
    final habitacion = _camara?.nombreHabitacion ?? '';
    ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            titulo: 'Acceso registrado',
            texto:
                'Viste ${conArticulo(habitacion)} en vivo durante '
                '${duracion(Duration(seconds: _segundos))}.',
            icono: Ico.eye,
          ),
        );
  }

  Future<void> _reanudar() async {
    final camara = _camara;
    if (camara == null) return;
    try {
      await ref.read(camarasRepositorioProvider).reanudar(camara.id);
      ref.invalidate(camarasProvider);
      await _abrir();
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _problema = e);
    }
  }

  @override
  void dispose() {
    _reloj?.cancel();
    unawaited(_transmision?.cancel());
    // Left without popping (e.g. replaced): still close the session.
    if (_sesion case final s?) {
      unawaited(_repositorio.cerrar(s.sesionId).catchError((_) {}));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitacion = _camara?.nombreHabitacion ?? '';
    final adulto = ref.watch(hogarProvider).value?.adultoMayor;
    final nombre = adulto?.nombrePila ?? '';
    final cerrar = _desdeAlerta
        ? 'Volver a la alerta'
        : 'Cerrar la vista en vivo';
    final viendo = _sesion != null;
    return PopScope(
      onPopInvokedWithResult: (_, _) => _terminar(),
      child: Scaffold(
        backgroundColor: Colores.noche,
        appBar: AppBar(
          backgroundColor: Colores.noche,
          foregroundColor: Colors.white,
          leading: IconButton(
            tooltip: cerrar,
            icon: Icono(_desdeAlerta ? Ico.back : Ico.x, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            habitacion.isEmpty ? 'En vivo' : 'En vivo · $habitacion',
            style: estiloTexto(20, 700, color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            if (_noDisponible case final motivo?)
              _NoDisponibleVista(
                motivo: motivo,
                habitacion: habitacion,
                nombre: nombre,
                desdeAlerta: _desdeAlerta,
                ultimaSenal: _camara?.ultimaSenal,
                pausadaHasta: _pausadaHasta,
                ahora: ref.watch(relojProvider)(),
              )
            else
              _Imagen(
                fotograma: _fotograma,
                segundos: viendo ? _segundos : null,
                habitacion: habitacion,
              ),
            if (_problema != null) ...[
              const SizedBox(height: 16),
              Text(
                _problema!.detalle,
                style: estiloTexto(16, 400, color: Colores.nocheTexto),
              ),
            ],
            if (viendo) ...[
              const SizedBox(height: 16),
              Text(
                _desdeAlerta
                    ? 'Ves la habitación y la postura detectada. La '
                          'transmisión no se graba.'
                    : 'Ves ${conArticulo(habitacion)} y la postura de $nombre '
                          'en este momento. La transmisión no se graba.',
                style: estiloTexto(16, 400, color: Colores.nocheTexto),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icono(Ico.eye, tamano: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Tu acceso queda en el registro que ve toda la '
                                'familia: '
                                '${ref.watch(sesionControllerProvider)?.usuario.nombre ?? ''}'
                                ', desde las ',
                          ),
                          TextSpan(
                            text: hora(_inicio!),
                            style: const TextStyle(fontFamily: fuenteMono),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      style: estiloTexto(16, 400, color: Colores.nocheTexto),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (viendo || _desdeAlerta) ...[
              Boton(
                'Llamar a $nombre',
                icono: Ico.phone,
                estilo: EstiloBoton.blanco,
                colorTexto: Colores.tinta,
                alPresionar: () => ref.read(llamarProvider)(adulto?.telefono),
              ),
              const SizedBox(height: 12),
            ],
            if (_noDisponible == _NoDisponible.enPausa) ...[
              Boton(
                'Reanudar la cámara ahora',
                icono: Ico.refresh,
                estilo: EstiloBoton.blanco,
                colorTexto: Colores.tinta,
                alPresionar: _reanudar,
              ),
              const SizedBox(height: 12),
            ],
            Boton(
              cerrar,
              estilo: EstiloBoton.sobreRojo,
              alPresionar: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The frame with the «EN VIVO · mm:ss» tag.
class _Imagen extends StatelessWidget {
  const _Imagen({
    required this.fotograma,
    required this.segundos,
    required this.habitacion,
  });

  final Uint8List? fotograma;
  final int? segundos;
  final String habitacion;

  @override
  Widget build(BuildContext context) {
    final f = fotograma;
    final s = segundos;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colores.nocheRaya,
              child: f == null
                  ? const Center(
                      child: Icono(
                        Ico.video,
                        tamano: 40,
                        color: Colores.nocheTexto,
                      ),
                    )
                  : Image.memory(
                      f,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      semanticLabel: 'En vivo · $habitacion',
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
            ),
            if (s != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.nocheEtiqueta,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Colores.grabando,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'EN VIVO · '),
                            TextSpan(
                              text: minutosSegundos(s),
                              style: const TextStyle(fontFamily: fuenteMono),
                            ),
                          ],
                        ),
                        style: estiloTexto(13, 700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// «00:37».
String minutosSegundos(int segundos) =>
    '${(segundos ~/ 60).toString().padLeft(2, '0')}:'
    '${(segundos % 60).toString().padLeft(2, '0')}';

/// Striped box of an unavailable live view (screens 39 and 40).
class _NoDisponibleVista extends StatelessWidget {
  const _NoDisponibleVista({
    required this.motivo,
    required this.habitacion,
    required this.nombre,
    required this.desdeAlerta,
    required this.ultimaSenal,
    required this.pausadaHasta,
    required this.ahora,
  });

  final _NoDisponible motivo;
  final String habitacion;
  final String nombre;
  final bool desdeAlerta;
  final DateTime? ultimaSenal;
  final DateTime? pausadaHasta;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: fuenteMono);
    final (icono, color, titulo, texto) = switch (motivo) {
      _NoDisponible.desconectada => (
        Ico.wifiOff,
        Colores.nocheAviso,
        'La cámara ${deHabitacion(habitacion)} no está disponible',
        TextSpan(
          children: [
            if (ultimaSenal case final s?) ...[
              const TextSpan(text: 'Perdió la conexión a las '),
              TextSpan(text: hora(s), style: mono),
              const TextSpan(text: ', así que '),
            ] else
              const TextSpan(text: 'Perdió la conexión, así que '),
            TextSpan(
              text: desdeAlerta
                  ? 'no podemos mostrarte la habitación. Llama a $nombre o '
                        'pide a alguien cercano que vaya a verla.'
                  : 'no podemos mostrarte la habitación. Revisa el cable de la '
                        'cámara, que la PC esté encendida y el internet de la '
                        'casa.',
            ),
          ],
        ),
      ),
      _NoDisponible.enPausa => (
        Ico.pause,
        Colores.nochePausa,
        'La vista en vivo no está disponible',
        TextSpan(
          children: [
            TextSpan(
              text:
                  'La cámara ${deHabitacion(habitacion)} está en pausa'
                  '${pausadaHasta == null ? '' : ' hasta las '}',
            ),
            if (pausadaHasta case final p?)
              TextSpan(text: finDePausa(p, ahora), style: mono),
            const TextSpan(
              text:
                  '. Podrás verla de nuevo a esa hora, o antes si reanudas la '
                  'cámara.',
            ),
          ],
        ),
      ),
      _NoDisponible.detenida => (
        Ico.lock,
        Colores.nochePausa,
        'La cámara está detenida',
        TextSpan(
          text:
              'Sin el consentimiento de $nombre la cámara no envía video, así '
              'que no se puede ver en vivo.',
        ),
      ),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colores.linea2, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: CustomPaint(
            painter: const _Rayas(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icono(icono, tamano: 40, color: color),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: estiloTexto(22, 700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    texto,
                    textAlign: TextAlign.center,
                    style: estiloTexto(16, 400, color: Colores.nocheTexto),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Rayas extends CustomPainter {
  const _Rayas();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colores.nocheRaya);
    final raya = Paint()
      ..color = Colores.nocheRaya2
      ..strokeWidth = 10;
    for (var x = -size.height; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), raya);
    }
  }

  @override
  bool shouldRepaint(_Rayas oldDelegate) => false;
}
