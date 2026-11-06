import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../../core/ui/tarjeta.dart';
import '../../../l10n/l10n.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../movimientos/data/movimientos_repositorio.dart';
import '../../movimientos/domain/movimientos.dart';
import '../data/hogar_repositorio.dart';
import '../domain/hogar.dart';
import 'constancia.dart';
import 'revocacion.dart';

/// Privacy and consent (screens 97, 98, 99 and 82): the certificate, how the data is cared for, the
/// access log and the revocation (US-09).
class PantallaPrivacidad extends ConsumerWidget {
  const PantallaPrivacidad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hogar = ref.watch(hogarProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.privacidadTitulo)),
      body: hogar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDePantalla(
          error: e,
          alReintentar: () => ref.refresh(hogarProvider.future),
        ),
        data: (h) => _Privacidad(hogar: h),
      ),
    );
  }
}

class _Privacidad extends ConsumerWidget {
  const _Privacidad({required this.hogar});

  final Hogar hogar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final titular = ref.watch(esTitularProvider);
    final consentimiento = hogar.consentimiento;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        if (hogar.conConsentimiento && consentimiento != null)
          TarjetaConstancia(
            consentimiento: consentimiento,
            enlace: l.privacidadVerDocumento,
          )
        else
          TarjetaBanda.construir(
            banda: Banda.pausa,
            builder: (context) {
              final texto = Theme.of(context).textTheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icono(Ico.lock, tamano: 28, color: context.colores.icono),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.privacidadSinConsentimiento,
                          style: texto.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    consentimiento != null
                        ? l.privacidadRevocadoEliminadas
                        : l.privacidadAunNoRegistra,
                    style: texto.bodyMedium,
                  ),
                  if (titular) ...[
                    const SizedBox(height: 16),
                    Boton(
                      l.consentimientoRegistrar,
                      alPresionar: () => context.push(Rutas.consentimiento),
                    ),
                  ],
                ],
              );
            },
          ),
        // US-35, US-37: the separate consent to store movements and their cloud retention.
        EncabezadoSeccion(l.privacidadMovimientos),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.body),
              titulo: l.privacidadGuardarMovimientos,
              subtitulo: switch (ref.watch(consentimientoMovimientosProvider)) {
                AsyncData(value: final m) =>
                  m.vigente && m.constancia != null
                      ? l.privacidadVigenteDesde(
                          context.formato.fechaConAnio(
                            m.constancia!.otorgadoEn,
                          ),
                        )
                      : l.privacidadNoAutorizado,
                _ => null,
              },
              alTocar: () => context.push(Rutas.movimientos),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.cloud),
              titulo: l.privacidadMovimientosNube,
              subtitulo: switch (ref.watch(movimientosEnLaNubeProvider)) {
                AsyncData(value: final n) =>
                  n.consentimientoVigente
                      ? resumenNube(l, n.retencionDias)
                      : l.privacidadNubeDesactivada,
                _ => null,
              },
              alTocar: () => context.push(Rutas.nube),
            ),
          ],
        ),
        EncabezadoSeccion(l.privacidadSusDatos),
        ListaTarjeta(
          children: [
            // The prototype's fold: video is analysed on the household PC and never stored in the
            // cloud (docs 04-arquitectura/decision-procesamiento-en-pc.md).
            FilaPlegable(
              icono: Ico.shield,
              titulo: l.privacidadComoCuidamos,
              resumen: l.privacidadComoCuidamosResumen,
              child: DatosTarjeta([
                FilaDato(
                  clave: l.privacidadDatoVideo,
                  valor: l.privacidadDatoVideoValor,
                ),
                FilaDato(
                  clave: l.privacidadDatoClips,
                  valor: l.privacidadDatoClipsValor,
                ),
                FilaDato(
                  clave: l.privacidadDatoEnVivo,
                  valor: l.privacidadDatoEnVivoValor,
                ),
                FilaDato(
                  clave: l.privacidadDatoRostros,
                  valor: l.privacidadDatoRostrosValor,
                ),
              ]),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.eye),
              titulo: l.privacidadRegistroAccesos,
              subtitulo: l.privacidadRegistroAccesosSub,
              alTocar: () => context.push(Rutas.accesos),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l.privacidadDerechos),
              const TextSpan(
                text: 'privacidad@tetengo.pe',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: texto.bodyMedium,
        ),
        const SizedBox(height: 16),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.doc),
              titulo: l.legalPoliticaTitulo,
              alTocar: () => context.push(Rutas.politica),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.doc),
              titulo: l.legalTerminosTitulo,
              alTocar: () => context.push(Rutas.terminos),
            ),
          ],
        ),
        if (hogar.conConsentimiento) ...[
          EncabezadoSeccion(l.privacidadRevocar),
          if (titular) ...[
            Text(l.privacidadRevocarTexto, style: texto.bodyMedium),
            const SizedBox(height: 12),
            Boton(
              l.privacidadRevocarBoton,
              estilo: EstiloBoton.peligroContorno,
              alPresionar: () => _revocar(context, ref),
            ),
          ] else
            AvisoSoloLectura(
              titular: ref.watch(nombreTitularProvider) ?? '',
              accion: l.privacidadSoloLecturaRevocar,
            ),
        ],
      ],
    );
  }

  Future<void> _revocar(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final si = await confirmar(
      context,
      icono: Ico.warn,
      peligro: true,
      titulo: l.privacidadRevocarDialogoTitulo,
      texto: l.privacidadRevocarDialogoTexto,
      aceptar: l.privacidadRevocarDialogoAceptar,
      cancelar: l.privacidadRevocarDialogoCancelar,
    );
    if (!context.mounted) return;
    if (!si) {
      // CA-09.2: the consent and the capture stay active.
      mostrarToast(
        context,
        titulo: l.privacidadSigueVigente,
        texto: l.privacidadSigueDetectando,
        icono: Ico.shield,
      );
      return;
    }
    try {
      // An older backend does not say how many recordings it deletes: count them before revoking.
      final contados = _clipsGuardados(ref);
      final clips = await ref
          .read(hogarRepositorioProvider)
          .revocarConsentimiento();
      ref
          .read(revocacionProvider.notifier)
          .iniciar(ref.read(relojProvider)(), clips ?? await contados);
      ref
        ..invalidate(hogarProvider)
        ..invalidate(camarasProvider)
        ..invalidate(alertaActivaProvider);
      if (context.mounted) context.go(Rutas.revocado);
    } on ProblemaApi catch (e) {
      if (e.codigo == 'SIN_CONSENTIMIENTO') {
        // Already revoked (for example from another phone): reloading the household shows the
        // «Sin consentimiento» card instead of the certificate.
        ref
          ..invalidate(hogarProvider)
          ..invalidate(camarasProvider);
        return;
      }
      if (context.mounted) {
        mostrarToast(context, titulo: e.detalle, icono: Ico.warn);
      }
    }
  }

  /// Clips that the revocation deletes, counted on the phone for a backend older than 0.3.4. Null
  /// when they cannot be counted: the screen then shows no count rather than a wrong «0 clips».
  Future<int?> _clipsGuardados(WidgetRef ref) async {
    try {
      return await contarClipsGuardados(ref.read(alertasRepositorioProvider));
    } on Object catch (e) {
      debugPrint('No se pudieron contar los clips guardados: $e');
      return null;
    }
  }
}

/// Alerts whose clip is still stored (`clip == DISPONIBLE`), read page by page: `GET /api/alertas`
/// answers at most [FiltroAlertas.tamanoMaximo] per page (`400 VALIDACION` above it).
Future<int> contarClipsGuardados(AlertasRepositorio alertas) async {
  var clips = 0;
  var leidas = 0;
  for (var pagina = 0; ; pagina++) {
    final r = await alertas.listar(
      FiltroAlertas(pagina: pagina, tamano: FiltroAlertas.tamanoMaximo),
    );
    clips += r.elementos.where((a) => a.clip == EstadoClip.disponible).length;
    leidas += r.elementos.length;
    if (r.elementos.length < FiltroAlertas.tamanoMaximo || leidas >= r.total) {
      return clips;
    }
  }
}

/// Screens 100 and 101: capture stopped, recordings being deleted, then deleted (CA-09.1, CA-09.3).
///
/// The push `DATOS_ELIMINADOS` completes it, but a push only reaches the app's code while the app is
/// in the foreground (and a PWA's window is visible). So, while visible, the screen also asks
/// `GET /api/hogar` for `eliminacion` every [intervalo], and once more each time the app comes back;
/// whichever arrives first completes it. Opened without a revocation in memory (the app restarted,
/// the PWA was reloaded), it rebuilds it from the backend. A backend older than 0.3.4 does not send
/// `eliminacion`: the screen then waits for the push only.
class PantallaRevocado extends ConsumerStatefulWidget {
  const PantallaRevocado({
    super.key,
    this.intervalo = const Duration(seconds: 3),
  });

  /// How often the deletion is asked while the screen is visible **[implementation choice]**.
  final Duration intervalo;

  @override
  ConsumerState<PantallaRevocado> createState() => _PantallaRevocadoState();
}

class _PantallaRevocadoState extends ConsumerState<PantallaRevocado> {
  late final AppLifecycleListener _ciclo;
  Timer? _temporizador;
  bool _consultando = false;

  /// The backend does not send `eliminacion` (older than 0.3.4), or the deletion is done.
  bool _sinConsultar = false;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onShow: _alVolver,
      onResume: _alVolver,
      onHide: _detener,
    );
    unawaited(_consultar());
    _programar();
  }

  @override
  void dispose() {
    _detener();
    _ciclo.dispose();
    super.dispose();
  }

  void _programar() {
    _temporizador?.cancel();
    if (_sinConsultar || (ref.read(revocacionProvider)?.terminada ?? false)) {
      return;
    }
    _temporizador = Timer.periodic(
      widget.intervalo,
      (_) => unawaited(_consultar()),
    );
  }

  void _detener() {
    _temporizador?.cancel();
    _temporizador = null;
  }

  void _alVolver() {
    unawaited(_consultar());
    _programar();
  }

  Future<void> _consultar() async {
    if (_consultando || _sinConsultar || !mounted) return;
    if (ref.read(revocacionProvider)?.terminada ?? false) return _detener();
    _consultando = true;
    try {
      final hogar = await ref.read(hogarRepositorioProvider).obtener();
      if (!mounted) return;
      if (!hogar.informaEliminacion) {
        // An older backend: only the push can tell it.
        _sinConsultar = true;
        return _detener();
      }
      final eliminacion = hogar.eliminacion;
      if (eliminacion == null) return;
      final antes = ref.read(revocacionProvider)?.terminada ?? false;
      ref.read(revocacionProvider.notifier).sincronizar(eliminacion);
      if (!antes && (ref.read(revocacionProvider)?.terminada ?? false)) {
        _detener();
        // As the push does: the household and the camera show the revocation.
        ref
          ..invalidate(hogarProvider)
          ..invalidate(camarasProvider);
      }
    } on Object catch (e) {
      // Network or backend error: asked again on the next tick or return to the app.
      debugPrint('No se pudo consultar la eliminación de las grabaciones: $e');
    } finally {
      _consultando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(revocacionProvider);
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final formato = context.formato;
    final correo = ref.watch(sesionControllerProvider)?.usuario.correo ?? '';
    final terminada = r?.terminada ?? false;
    final detenida = r?.capturaDetenida ?? ref.watch(relojProvider)();
    final clips = r?.clips;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconoGrande(
                        icono: terminada ? Ico.check : Ico.lock,
                        fondo: terminada
                            ? context.colores.calmaSuave
                            : context.colores.pausaSuave,
                        color: terminada
                            ? context.colores.calmaTinta
                            : context.colores.pausa,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        terminada
                            ? l.privacidadRevocadoTitulo
                            : l.privacidadRevocandoTitulo,
                        style: texto.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      terminada
                          ? l.privacidadConstanciaEnviada(correo)
                          : l.privacidadNoCierres,
                      style: texto.bodyLarge?.copyWith(
                        color: context.colores.tinta2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TarjetaBanda(
                      child: Column(
                        children: [
                          _Paso(
                            hecho: true,
                            titulo: l.privacidadCapturaDetenida,
                            detalle: _conHora(
                              l.privacidadALasHora(formato.hora(detenida)),
                              formato.hora(detenida),
                            ),
                          ),
                          _Paso(
                            hecho: terminada,
                            enCurso: !terminada,
                            titulo: terminada
                                ? l.privacidadGrabacionesEliminadas
                                : l.privacidadEliminandoGrabaciones,
                            // Without a known count, no line rather than a wrong «0 clips».
                            detalle: clips == null
                                ? null
                                : terminada
                                ? _conHora(
                                    l.privacidadClipsHora(
                                      l.privacidadClips(clips),
                                      formato.hora(r!.eliminadasEn!),
                                    ),
                                    formato.hora(r.eliminadasEn!),
                                  )
                                : TextSpan(text: l.privacidadClips(clips)),
                          ),
                          _Paso(
                            hecho: terminada,
                            numero: 3,
                            titulo: l.privacidadConstanciaCorreo,
                            detalle: TextSpan(
                              text: terminada
                                  ? l.privacidadEnviada
                                  : l.privacidadPendiente,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Boton(
                l.consentimientoVolverInicio,
                alPresionar: terminada
                    ? () {
                        ref.read(revocacionProvider.notifier).olvidar();
                        context.go(Rutas.inicio);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [mensaje] with its time [horaTexto] in the mono font (`conHora`), wherever the language puts it.
TextSpan _conHora(String mensaje, String horaTexto) {
  final i = mensaje.indexOf(horaTexto);
  if (i < 0) return TextSpan(text: mensaje);
  return conHora(
    mensaje.substring(0, i),
    horaTexto,
    mensaje.substring(i + horaTexto.length),
  );
}

class _Paso extends StatelessWidget {
  const _Paso({
    required this.hecho,
    required this.titulo,
    required this.detalle,
    this.enCurso = false,
    this.numero,
  });

  final bool hecho;
  final bool enCurso;
  final int? numero;
  final String titulo;
  final InlineSpan? detalle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CirculoPaso(
          hecho: hecho,
          numero: numero,
          hijo: enCurso
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: context.colores.sobreInversa,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Theme.of(context).textTheme.titleMedium),
              if (detalle case final detalle?)
                Text.rich(
                  detalle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
