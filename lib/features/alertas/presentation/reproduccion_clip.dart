import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'reproductor.dart';

/// Playback of one alert's clip, shared by the inline player and the full-screen view.
///
/// The clip URL is pre-signed and short-lived (`expiraEn`, 5 minutes; contract §5). A new URL is
/// asked with `GET /api/alertas/{id}/clip`:
/// - when the player fails (an expired URL answers `403`), and
/// - before a command (play, seek) once `expiraEn` is near, so a clip opened later or left paused
///   still plays; and, while it plays, just before `expiraEn`.
///
/// A player that does not open within [esperaInicio], or that plays without moving for
/// [esperaSinAvance], counts as failed too. The new player resumes at the same position and, if it
/// was playing, keeps playing. The old one stays on screen until the new one is ready, so nothing
/// visible happens. Only a clip that is really
/// gone (`404 CLIP_NO_DISPONIBLE`, `410 CLIP_ELIMINADO`) or that fails [maxFallos] times in a row
/// without playing on is reported, with the existing «no disponible» states ([perdido]).
class ReproduccionClip extends ChangeNotifier {
  ReproduccionClip({
    required this.alertaId,
    required this._enlace,
    required this.repositorio,
    required this.fabrica,
    required this.reloj,
  });

  final String alertaId;
  final AlertasRepositorio repositorio;
  final FabricaClip fabrica;
  final Reloj reloj;

  /// A URL this close to `expiraEn` is renewed before it is used.
  static const margen = Duration(seconds: 30);

  /// Failed players or URL requests in a row before the clip is reported as not available.
  static const maxFallos = 3;

  /// Wait between two attempts after a failure.
  static const espera = Duration(seconds: 1);

  /// A player that has not opened by then is replaced. On the web an expired URL can leave
  /// `video_player_web_hls` waiting forever: the browser reports the `403` as an unsupported source
  /// (`MediaError` 4), the plugin then retries the MP4 with hls.js, whose fatal error it swallows.
  static const esperaInicio = Duration(seconds: 10);

  /// Playing without moving for this long counts as a failure (the same silent case, mid-clip).
  static const esperaSinAvance = Duration(seconds: 8);

  /// Length of every clip: 6 s before and 6 s after the event (CA-18.1). Shown until the player
  /// knows the real one.
  static const duracionNominal = Duration(seconds: 12);

  /// Seek step of the -5 s and +5 s buttons.
  static const salto = Duration(seconds: 5);

  EnlaceClip _enlace;
  ControladorClip? _clip;
  Timer? _temporizador;
  Timer? _vigia;
  Duration _ultimaVista = Duration.zero;
  Duration _quieto = Duration.zero;
  bool _cargando = false;
  bool _cerrado = false;
  int _fallos = 0;
  Duration? _reanudadoEn;
  Duration _posicion = Duration.zero;
  bool _quiereReproducir = false;
  EstadoClip? _perdido;
  bool _enPantallaCompleta = false;

  /// Set when the clip cannot be shown: [EstadoClip.noDisponible] or [EstadoClip.eliminado].
  EstadoClip? get perdido => _perdido;

  bool get listo => _clip?.listo ?? false;

  bool get reproduciendo => listo && _clip!.reproduciendo;

  /// A real duration from the player. A clip whose duration is not known yet cannot be sought.
  bool get duracionConocida {
    final d = _clip?.duracion ?? Duration.zero;
    // An endless media reports a huge or negative value.
    return listo && d > Duration.zero && d < const Duration(hours: 1);
  }

  Duration get duracion => duracionConocida ? _clip!.duracion : duracionNominal;

  Duration get posicion => _limitar(_posicion);

  /// Stopped at the end: the play button offers to watch it again.
  bool get terminado =>
      duracionConocida &&
      !reproduciendo &&
      _posicion >= duracion - const Duration(milliseconds: 250);

  /// The full-screen view shows the video; the inline player shows the poster meanwhile, because
  /// the web player is one `<video>` element that cannot be in two places.
  bool get enPantallaCompleta => _enPantallaCompleta;
  set enPantallaCompleta(bool valor) {
    if (_enPantallaCompleta == valor) return;
    _enPantallaCompleta = valor;
    if (!_cerrado) notifyListeners();
  }

  Widget vista() => _clip!.vista();

  bool get _porVencer {
    final expira = _enlace.expiraEn;
    return expira != null && !reloj().isBefore(expira.subtract(margen));
  }

  /// Opens the first player, after a new URL if the one given is already about to expire (a clip
  /// opened minutes after its URL was obtained).
  Future<void> iniciar() => _cargar(nuevoEnlace: _porVencer);

  Future<void> alternar() => reproduciendo ? pausar() : reproducir();

  Future<void> reproducir() async {
    _quiereReproducir = true;
    _vigilar();
    final clip = _clip;
    if (terminado) _posicion = Duration.zero;
    if (clip == null || clip.fallo || !clip.listo || _porVencer) {
      return _cargar(nuevoEnlace: clip != null);
    }
    if (terminado || clip.posicion != _posicion) await clip.buscar(_posicion);
    await clip.reproducir();
  }

  Future<void> pausar() async {
    _quiereReproducir = false;
    final clip = _clip;
    if (clip != null && clip.listo) await clip.pausar();
  }

  /// Moves to [destino], clamped to the clip. Does nothing while the duration is not known.
  Future<void> buscar(Duration destino) async {
    if (!duracionConocida) return;
    _posicion = _limitar(destino);
    notifyListeners();
    final clip = _clip!;
    if (clip.fallo || _porVencer) return _cargar(nuevoEnlace: true);
    await clip.buscar(_posicion);
  }

  Future<void> retroceder() => buscar(posicion - salto);

  Future<void> adelantar() => buscar(posicion + salto);

  /// See [ControladorClip.pantallaCompletaNativa].
  bool pantallaCompletaNativa() => _clip?.pantallaCompletaNativa() ?? false;

  Duration _limitar(Duration d) => d < Duration.zero
      ? Duration.zero
      : d > duracion
      ? duracion
      : d;

  void _alCambiar() {
    final clip = _clip;
    if (clip == null || _cerrado) return;
    if (clip.fallo) {
      // Keep the position and intent it had before failing; the new player resumes from them.
      notifyListeners();
      _cargar(nuevoEnlace: true, porFallo: true);
      return;
    }
    if (clip.listo) {
      _posicion = clip.posicion;
      final desde = _reanudadoEn;
      if (desde != null && _posicion - desde >= const Duration(seconds: 1)) {
        // It plays on after a failure: the next failure starts a new count.
        _fallos = 0;
        _reanudadoEn = null;
      }
      if (terminado) _quiereReproducir = false;
    }
    notifyListeners();
  }

  /// Asks for a new URL (with [nuevoEnlace]) and replaces the player, resuming at [_posicion].
  Future<void> _cargar({
    bool nuevoEnlace = false,
    bool porFallo = false,
  }) async {
    if (_cargando || _cerrado || _perdido != null) return;
    _cargando = true;
    _temporizador?.cancel();
    try {
      var reintento = porFallo;
      while (true) {
        if (reintento) {
          final viejo = _clip;
          if (!porFallo && viejo != null && viejo.listo && !viejo.fallo) {
            // A refresh ahead of time failed (no connection?): the player still works, so keep it
            // and try again on the next command.
            await _aplicar(viejo);
            return;
          }
          if (!await _otroIntento()) return;
        }
        reintento = true;
        if (nuevoEnlace) {
          try {
            _usarEnlace(await repositorio.clip(alertaId));
          } on ProblemaApi catch (e) {
            if (e.codigo == 'CLIP_NO_DISPONIBLE') {
              return _perder(EstadoClip.noDisponible);
            }
            if (e.codigo == 'CLIP_ELIMINADO') {
              return _perder(EstadoClip.eliminado);
            }
            continue;
          } on Object {
            continue;
          }
          if (_cerrado) return;
        }
        nuevoEnlace = true;
        final nuevo = fabrica(_enlace.url);
        try {
          await nuevo.iniciar().timeout(esperaInicio);
          if (_cerrado) {
            nuevo.dispose();
            return;
          }
          final viejo = _clip;
          // A player that was still playing moved on meanwhile.
          if (viejo != null && viejo.listo && !viejo.fallo) {
            _posicion = viejo.posicion;
          }
          if (_posicion > Duration.zero) await nuevo.buscar(_posicion);
          if (_cerrado) {
            nuevo.dispose();
            return;
          }
          _cambiar(nuevo);
          if (porFallo) {
            _reanudadoEn = _posicion;
          } else {
            _fallos = 0;
          }
          if (_quiereReproducir) {
            // Play once it is on screen: Chrome pauses a muted video started outside a tap while
            // it is not visible, and the web player's element is only added when it is shown.
            notifyListeners();
            await WidgetsBinding.instance.endOfFrame;
            if (!_cerrado && identical(_clip, nuevo)) await nuevo.reproducir();
          }
          return;
        } on Object {
          nuevo.dispose();
          porFallo = true;
        }
      }
    } finally {
      _cargando = false;
      if (!_cerrado) {
        _programar();
        notifyListeners();
      }
    }
  }

  /// A fresh URL that already looks expired means the phone's clock is ahead of the server's: its
  /// `expiraEn` is then ignored and only a failure of the player renews it.
  void _usarEnlace(EnlaceClip enlace) {
    final expira = enlace.expiraEn;
    _enlace = expira != null && !reloj().isBefore(expira.subtract(margen))
        ? EnlaceClip(url: enlace.url)
        : enlace;
  }

  /// Applies the position and the play or pause asked for to [clip].
  Future<void> _aplicar(ControladorClip clip) async {
    final diferencia = (clip.posicion - _posicion).abs();
    if (diferencia > const Duration(milliseconds: 200)) {
      await clip.buscar(_posicion);
    }
    if (_quiereReproducir && !clip.reproduciendo) {
      await clip.reproducir();
    } else if (!_quiereReproducir && clip.reproduciendo) {
      await clip.pausar();
    }
  }

  Future<bool> _otroIntento() async {
    _fallos++;
    if (_fallos >= maxFallos) {
      _perder(EstadoClip.noDisponible);
      return false;
    }
    await Future<void>.delayed(espera);
    return !_cerrado;
  }

  void _perder(EstadoClip estado) {
    _perdido = estado;
    _quiereReproducir = false;
    _vigia?.cancel();
    _soltar();
  }

  /// While playing is wanted, checks every second that the position moves.
  void _vigilar() {
    _quieto = Duration.zero;
    _vigia ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final clip = _clip;
      if (!_quiereReproducir || _cerrado || _perdido != null) {
        _vigia?.cancel();
        _vigia = null;
        return;
      }
      if (_cargando || clip == null || terminado) {
        _quieto = Duration.zero;
        return;
      }
      final ahora = clip.listo ? clip.posicion : _posicion;
      if (ahora != _ultimaVista) {
        _ultimaVista = ahora;
        _quieto = Duration.zero;
        return;
      }
      _quieto += const Duration(seconds: 1);
      if (_quieto * 2 == esperaSinAvance) {
        // Halfway: the browser may just have paused it; ask once more on the same player.
        clip.reproducir();
      } else if (_quieto >= esperaSinAvance) {
        _quieto = Duration.zero;
        _cargar(nuevoEnlace: true, porFallo: true);
      }
    });
  }

  void _cambiar(ControladorClip nuevo) {
    _soltar();
    _clip = nuevo..addListener(_alCambiar);
  }

  void _soltar() {
    final viejo = _clip;
    _clip = null;
    if (viejo == null) return;
    viejo.removeListener(_alCambiar);
    viejo.dispose();
  }

  /// While it plays, renews the URL just before `expiraEn`; a paused clip renews it on the next
  /// command instead, so an idle screen does not keep asking for URLs.
  void _programar() {
    _temporizador?.cancel();
    final expira = _enlace.expiraEn;
    if (expira == null || _perdido != null) return;
    var falta = expira.subtract(margen).difference(reloj());
    if (falta.isNegative) falta = Duration.zero;
    _temporizador = Timer(falta, () {
      if (reproduciendo) _cargar(nuevoEnlace: true);
    });
  }

  @override
  void dispose() {
    _cerrado = true;
    _temporizador?.cancel();
    _vigia?.cancel();
    _soltar();
    super.dispose();
  }
}
