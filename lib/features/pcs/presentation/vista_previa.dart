import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../vivo/data/vista_en_vivo_repositorio.dart';
import '../../vivo/domain/vista_en_vivo.dart';
import '../../vivo/presentation/conexion_vivo.dart';
import '../../vivo/presentation/reproductor_vivo.dart';
import '../../vivo/presentation/reproductor_webrtc.dart';
import '../data/pcs_repositorio.dart';
import '../domain/camara_detectada.dart';
import '../domain/pc.dart';
import 'piezas_pc.dart';

/// How long the preview stays open (CA-29.7: «unos segundos»; the prototype closes it at 15 s). The
/// API ends a preview session after 2 minutes at the latest.
const duracionVistaPrevia = Duration(seconds: 15);

/// Why a webcam cannot be previewed now (`previewWhy`, CA-29.7).
class MotivoSinVistaPrevia {
  const MotivoSinVistaPrevia(this.icono, this.titulo, this.texto);

  final Ico icono;
  final String titulo;
  final InlineSpan? texto;
}

/// The same rules as the live view: the PC online, the webcam plugged in and not paused, and the
/// consent in force. Null when it can be previewed.
MotivoSinVistaPrevia? motivoSinVistaPrevia({
  required CamaraDetectada camara,
  required Pc? pc,
  required bool conConsentimiento,
  required String nombre,
}) {
  if (pc != null && EstadoPc.de(pc) == EstadoPc.sinConexion) {
    final senal = pc.ultimaSenal;
    return MotivoSinVistaPrevia(
      Ico.wifiOff,
      'La PC ${pc.nombre} no responde',
      senal == null
          ? null
          : TextSpan(
              children: [
                const TextSpan(text: 'Sin conexión desde las '),
                TextSpan(
                  text: hora(senal),
                  style: estiloMono(tamano: 16, peso: 400),
                ),
                const TextSpan(text: '.'),
              ],
            ),
    );
  }
  if (!camara.conectada) return _desconectada;
  if (!conConsentimiento) return _sinConsentimiento(nombre);
  if (camara.pausadaHasta case final hasta?) return _enPausa(hasta);
  return null;
}

const _desconectada = MotivoSinVistaPrevia(
  Ico.wifiOff,
  'La cámara está desconectada',
  TextSpan(text: 'Que revisen el cable USB.'),
);

MotivoSinVistaPrevia _sinConsentimiento(String nombre) => MotivoSinVistaPrevia(
  Ico.lock,
  'Falta el consentimiento de $nombre',
  const TextSpan(text: 'Sin él no hay video.'),
);

MotivoSinVistaPrevia _enPausa(DateTime? hasta) => MotivoSinVistaPrevia(
  Ico.pause,
  'La cámara está en pausa',
  hasta == null
      ? null
      : TextSpan(
          children: [
            const TextSpan(text: 'Hasta las '),
            TextSpan(
              text: hora(hasta),
              style: estiloMono(tamano: 16, peso: 400),
            ),
            const TextSpan(text: '.'),
          ],
        ),
);

/// «Ver vista previa» (screens 252, 253, 257, 259 and 269): a few seconds of what a webcam sees, to
/// recognise it before assigning it a room (CA-29.7). It is a live view session: not recorded, and
/// logged in the access log when it closes (CA-24.1).
Future<void> abrirVistaPrevia(
  BuildContext context, {
  required CamaraDetectada camara,
  required Pc? pc,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => HojaVistaPrevia(camara: camara, pc: pc),
);

class HojaVistaPrevia extends ConsumerStatefulWidget {
  const HojaVistaPrevia({super.key, required this.camara, required this.pc});

  final CamaraDetectada camara;
  final Pc? pc;

  @override
  ConsumerState<HojaVistaPrevia> createState() => _HojaVistaPreviaState();
}

class _HojaVistaPreviaState extends ConsumerState<HojaVistaPrevia> {
  MotivoSinVistaPrevia? _motivo;
  ProblemaApi? _problema;
  SesionVivo? _sesion;
  late final ConexionVivo _conexion;
  late final VistaEnVivoRepositorio _vivo;
  late final ProviderContainer _contenedor;
  late final AppLifecycleListener _ciclo;
  late final AvisosFlotantes _avisos;
  Timer? _cuenta;
  int _restantes = duracionVistaPrevia.inSeconds;
  int _vistos = 0;
  bool _cerrada = false;

  @override
  void initState() {
    super.initState();
    _vivo = ref.read(vistaEnVivoRepositorioProvider);
    _contenedor = ProviderScope.containerOf(context, listen: false);
    _avisos = ref.read(avisoFlotanteProvider.notifier);
    _conexion = ConexionVivo(
      fabricaHls: ref.read(fabricaReproductorVivoProvider),
      fabricaWebrtc: ref.read(fabricaReproductorWebrtcProvider),
      alPerder: _perder,
    )..addListener(_redibujar);
    _ciclo = AppLifecycleListener(onHide: _cerrar);
    unawaited(_abrir());
  }

  void _redibujar() {
    if (mounted) setState(() {});
  }

  Future<void> _abrir() async {
    final nombre = ref.read(nombreAdultoMayorProvider) ?? '';
    final hogar = ref.read(hogarProvider).value;
    final motivo = motivoSinVistaPrevia(
      camara: widget.camara,
      pc: widget.pc,
      conConsentimiento: hogar?.conConsentimiento ?? true,
      nombre: nombre,
    );
    if (motivo != null) return setState(() => _motivo = motivo);
    try {
      final sesion = await ref
          .read(pcsRepositorioProvider)
          .vistaPrevia(widget.camara.id);
      if (!mounted || _cerrada) return _cerrarSesion(sesion);
      final ahora = ref.read(relojProvider)();
      // Never longer than the session the API opened.
      final fin = sesion.expiraEn;
      final segundos = fin == null
          ? duracionVistaPrevia.inSeconds
          : fin
                .difference(ahora)
                .inSeconds
                .clamp(1, duracionVistaPrevia.inSeconds);
      setState(() {
        _sesion = sesion;
        _restantes = segundos;
      });
      _conexion.conectar(sesion);
      _cuenta = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _vistos++;
          _restantes--;
        });
        if (_restantes <= 0) Navigator.of(context).maybePop();
      });
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'CAMARA_DESCONECTADA':
            _motivo = _desconectada;
          case 'CAMARA_EN_PAUSA':
            _motivo = _enPausa(fechaDesdeJson(e.extras['pausadaHasta']));
          case 'SIN_CONSENTIMIENTO':
            _motivo = _sinConsentimiento(nombre);
            ref.invalidate(hogarProvider);
          default:
            _problema = e;
        }
      });
    }
  }

  /// The stream was lost: the session ends and the sheet says why.
  void _perder() {
    _terminar();
    if (mounted) setState(() => _motivo = _desconectada);
  }

  /// Ends the session, which records the access, and tells it once (screen 253).
  void _terminar() {
    _cuenta?.cancel();
    _cuenta = null;
    _conexion.detener();
    final sesion = _sesion;
    _sesion = null;
    if (sesion == null) return;
    _cerrarSesion(sesion);
    final aviso = AvisoFlotante(
      titulo: 'Acceso registrado',
      texto:
          'Viste la vista previa de ${widget.camara.nombreDispositivo} '
          'durante ${duracion(Duration(seconds: _vistos))}.',
      icono: Ico.eye,
    );
    // It may close while the tree is finalized (the sheet's dispose): tell it right after.
    scheduleMicrotask(() => _avisos.mostrar(aviso));
  }

  void _cerrarSesion(SesionVivo sesion) => unawaited(
    _vivo
        .cerrar(sesion.sesionId)
        .then((_) => _contenedor.invalidate(accesosVivoProvider))
        .catchError((Object _) {}),
  );

  /// The app went to the background: nobody watches it.
  void _cerrar() {
    if (_cerrada) return;
    _terminar();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _cerrada = true;
    _ciclo.dispose();
    _terminar();
    _conexion
      ..removeListener(_redibujar)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final motivo = _motivo;
    // Closing (the button, the countdown, a tap outside or back) ends the session at once.
    return PopScope(
      onPopInvokedWithResult: (_, _) => _terminar(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Vista previa · ${widget.camara.nombreDispositivo}',
                        style: texto.titleLarge,
                      ),
                    ),
                  ),
                  AyudaInfo(
                    texto:
                        'No se graba y queda en el registro de accesos. Se '
                        'cierra sola a los ${duracionVistaPrevia.inSeconds} s.',
                    tema: 'vista previa',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (motivo != null)
                _NoDisponible(motivo)
              else ...[
                _Imagen(
                  reproductor: _conexion.reproductorEnVivo,
                  restantes: _sesion == null ? null : _restantes,
                  nombre: widget.camara.nombreDispositivo,
                ),
                if (_problema != null) ...[
                  const SizedBox(height: 12),
                  MensajeProblema(_problema!),
                ],
              ],
              const SizedBox(height: 16),
              Boton(
                'Cerrar',
                alPresionar: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The webcam's image at 4:3, whole, with the «● VISTA PREVIA · 0:12» countdown.
class _Imagen extends StatelessWidget {
  const _Imagen({
    required this.reproductor,
    required this.restantes,
    required this.nombre,
  });

  final ReproductorVivo? reproductor;
  final int? restantes;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final r = reproductor;
    final s = restantes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colores.nocheRaya,
              child: r == null
                  ? const Center(
                      child: SizedBox.square(
                        dimension: 32,
                        child: CircularProgressIndicator(
                          color: Colores.nocheTexto,
                        ),
                      ),
                    )
                  : Semantics(
                      image: true,
                      label: 'Vista previa · $nombre',
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: r.relacionAspecto > 0
                              ? r.relacionAspecto
                              : 4 / 3,
                          child: r.vista(),
                        ),
                      ),
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
                            const TextSpan(text: 'VISTA PREVIA · '),
                            TextSpan(
                              text:
                                  '0:${s.clamp(0, 59).toString().padLeft(2, '0')}',
                              style: estiloCifras,
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

/// The gray «no disponible» block with the reason (`.clip.missing`).
class _NoDisponible extends StatelessWidget {
  const _NoDisponible(this.motivo);

  final MotivoSinVistaPrevia motivo;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
    decoration: BoxDecoration(
      color: context.colores.fondo2,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icono(motivo.icono, tamano: 36, color: context.colores.tinta2),
        const SizedBox(height: 10),
        Text(
          motivo.titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (motivo.texto case final t?) ...[
          const SizedBox(height: 8),
          Text.rich(
            t,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    ),
  );
}
