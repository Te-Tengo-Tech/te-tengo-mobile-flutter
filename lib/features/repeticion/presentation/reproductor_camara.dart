import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../../movimientos/data/fuente_fotogramas.dart';
import '../../movimientos/domain/fotogramas.dart';
import '../data/repeticiones_repositorio.dart';
import '../domain/repeticion.dart';

/// Why the player cannot move now.
enum EstadoReproductor { listo, cargando, sinInternet, revocado }

/// Where today's movements stop: the camera unplugged or paused, or its PC offline.
typedef CorteDeDatos = ({DateTime desde, String motivo});

/// The camera's player (screens 35, 204 to 211, 303 to 306): the stored movements of a day, a
/// 10-minute or 1-hour window, the playhead, speed, «Solo eventos» and the events of the day from
/// the alerts (contract §11). It never shows video: the skeleton comes from the light movement
/// files ([FuenteFotogramas]) and, before any replay, from the clip's landmarks of the event it
/// opens at (the still frame, not logged: CA-39.3).
class ReproductorCamara extends ChangeNotifier {
  ReproductorCamara({
    required this.camaraId,
    required this.habitacion,
    required this.repeticiones,
    required this.alertas,
    required this.reloj,
    this.fuente,
    this.momento,
    this.datosDesde,
    this.corte,
    this.avisar,
  });

  final String camaraId;
  final String habitacion;
  final RepeticionesRepositorio repeticiones;
  final AlertasRepositorio alertas;
  final Reloj reloj;

  /// Null: this build cannot draw the movements.
  final FuenteFotogramas? fuente;

  /// Open at this moment (an alert's «Ver qué pasó», the access log's «Abrir de nuevo»).
  final DateTime? momento;

  /// Since when the cloud has movements (`datosDesde`).
  DateTime? datosDesde;

  /// Today's data ends here.
  CorteDeDatos? corte;

  /// A short notice for the screen («No hay más eventos»).
  final void Function(String)? avisar;

  static const velocidades = [0.5, 1.0, 2.0, 4.0];
  static const diezMinutos = Duration(minutes: 10);
  static const unaHora = Duration(hours: 1);

  late DateTime dia;
  late DateTime inicio;
  Duration largo = diezMinutos;
  late DateTime posicion;
  bool reproduciendo = false;
  double velocidad = 1;
  bool soloEventos = false;
  DateTime? seleccionado;
  bool iniciado = false;
  EstadoReproductor estado = EstadoReproductor.listo;

  /// The camera's latest alerts (newest first), for «Últimos eventos» without stored movements.
  List<Alerta> recientes = const [];
  List<EventoCamara> eventos = const [];
  Repeticion? sesion;
  DateTime? _registradaEn;
  bool _registrando = false;
  final _fotogramas = <String, List<Fotograma>>{};
  Timer? _tic;
  bool _cerrado = false;

  DateTime get fin => inicio.add(largo);

  DateTime get _hoy {
    final a = reloj();
    return DateTime(a.year, a.month, a.day);
  }

  bool get esHoy => dia == _hoy;

  /// The day has no stored movements any more (CA-39.4).
  bool get fueraDePlazo {
    final d = datosDesde;
    return d != null && dia.isBefore(_diaDe(d));
  }

  /// The last moment with data: now (or the cut) today, the day's end before.
  DateTime get finDeDatos {
    if (!esHoy) return dia.add(const Duration(days: 1));
    final ahora = reloj();
    final c = corte?.desde;
    return c != null && c.isBefore(ahora) ? c : ahora;
  }

  /// The stretches without movements inside the window: before a replay exists only the end of
  /// today's data is known; with it, the time no file covers (CA-39.5).
  List<Tramo> get huecos {
    final finVisible = finDeDatos.isBefore(fin) ? finDeDatos : fin;
    final tramos = <Tramo>[
      if (sesion != null && finVisible.isAfter(inicio))
        // A file without its light file cannot be drawn: a stretch without data.
        ...huecosDe(
          [
            for (final a in sesion!.archivos)
              if (a.ligero != null) a,
          ],
          inicio,
          finVisible,
        ),
    ];
    if (finDeDatos.isBefore(fin)) {
      final desde = finDeDatos.isAfter(inicio) ? finDeDatos : inicio;
      tramos.add(
        Tramo(desde, fin, esHoy ? corte?.motivo ?? 'Sin datos' : 'Sin datos'),
      );
    }
    return tramos;
  }

  List<EventoCamara> get eventosEnVentana => [
    for (final e in eventos)
      if (!e.en.isBefore(inicio) && !e.en.isAfter(fin)) e,
  ];

  /// The frame at the playhead; null without frames (or a decoder).
  Fotograma? get fotograma {
    final todos = [for (final l in _fotogramas.values) ...l]
      ..sort((a, b) => a.en.compareTo(b.en));
    return fotogramaEn(todos, posicion);
  }

  /// The phase tag over the stage, from the events: «Posible caída», «En el suelo», «Movimiento
  /// inestable», «Se levantó», or the reason of a stretch without data. Null otherwise: without
  /// frames the posture is not known.
  ({String texto, TipoEvento? tipo})? get fase {
    for (final t in huecos) {
      if (t.contiene(posicion)) return (texto: t.motivo, tipo: null);
    }
    for (final e in eventos.reversed) {
      final d = posicion.difference(e.en);
      switch (e.tipo) {
        case TipoEvento.levanto when d >= Duration.zero && d < _s(4):
          return (texto: 'Se levantó', tipo: TipoEvento.levanto);
        case TipoEvento.inestable when d >= -_s(2) && d < _s(4):
          return (texto: 'Movimiento inestable', tipo: TipoEvento.inestable);
        case TipoEvento.caida when d >= -_s(3) && d < _s(5):
          return (texto: 'Posible caída', tipo: TipoEvento.caida);
        case TipoEvento.caida when d >= _s(5) && d < const Duration(minutes: 2):
          final levanto = eventos.any(
            (x) =>
                x.tipo == TipoEvento.levanto &&
                x.alerta.id == e.alerta.id &&
                !x.en.isAfter(posicion),
          );
          if (!levanto) {
            return (texto: 'En el suelo', tipo: TipoEvento.caida);
          }
        default:
      }
    }
    return null;
  }

  static Duration _s(int s) => Duration(seconds: s);

  static bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _diaDe(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Opens at [momento], or at the camera's latest event with stored movements, or at the last
  /// minutes (PRODUCT.md, «Detalle de la cámara con el reproductor primero»).
  Future<void> iniciar() async {
    final ahora = reloj();
    try {
      final p = await alertas.listar(
        const FiltroAlertas(tamano: FiltroAlertas.tamanoMaximo),
      );
      recientes = [
        for (final a in p.elementos)
          if (a.camaraId == camaraId) a,
      ];
    } on ProblemaApi {
      recientes = const [];
    }
    final desde = datosDesde;
    final ultimo = recientes
        .where((a) => desde == null || !a.ocurridaEn.isBefore(desde))
        .firstOrNull;
    final t = momento ?? ultimo?.ocurridaEn ?? ahora.subtract(_s(90));
    dia = _diaDe(t);
    posicion = t;
    seleccionado = momento == null ? ultimo?.ocurridaEn : null;
    _centrar(t);
    await _cargarDia();
    iniciado = true;
    _notificar();
    unawaited(_fotoFija(t));
  }

  /// The still frame of the event at [t] (decided: opening shows it and is not logged, CA-39.3):
  /// the landmarks of that alert's clip (`GET /api/alertas/{id}/clip` → `puntos.ligero`), the
  /// cheapest source that creates no replay. Without them the stage keeps the phase tag only.
  Future<void> _fotoFija(DateTime t) async {
    final f = fuente;
    if (f == null) return;
    final alerta = [...recientes, for (final e in eventos) e.alerta]
        .where(
          (a) =>
              a.camaraId == camaraId &&
              a.ocurridaEn.difference(t).abs() < _s(6),
        )
        .firstOrNull;
    if (alerta == null || _fotogramas.containsKey('clip:${alerta.id}')) return;
    _fotogramas['clip:${alerta.id}'] = const [];
    try {
      final url = (await alertas.clip(alerta.id)).puntosLigeros;
      if (url == null || _cerrado) return;
      _fotogramas['clip:${alerta.id}'] = await f.cargar(url);
      _notificar();
    } on Object {
      // No clip or no landmarks: the phase tag stays, never a guessed posture.
    }
  }

  Future<void> _cargarDia() async {
    try {
      final p = await alertas.listar(
        FiltroAlertas(
          desde: dia,
          hasta: dia.add(const Duration(days: 1)),
          tamano: FiltroAlertas.tamanoMaximo,
        ),
      );
      eventos = eventosDe(p.elementos, camaraId);
    } on ProblemaApi {
      eventos = eventosDe(
        recientes.where((a) => _mismoDia(a.ocurridaEn, dia)),
        camaraId,
      );
    }
  }

  /// The window around [t]: 10 minutes from 5 before, or the clock hour; inside the day and never
  /// past now.
  void _centrar(DateTime t) {
    final base = largo == unaHora
        ? DateTime(t.year, t.month, t.day, t.hour)
        : DateTime(
            t.year,
            t.month,
            t.day,
            t.hour,
            t.minute,
          ).subtract(const Duration(minutes: 5));
    final limite = esHoy ? reloj() : dia.add(const Duration(days: 1));
    var i = base;
    if (i.add(largo).isAfter(limite)) i = limite.subtract(largo);
    if (i.isBefore(dia)) i = dia;
    inicio = i;
    posicion = _limitar(t);
  }

  DateTime _limitar(DateTime t) {
    var p = t;
    if (p.isBefore(inicio)) p = inicio;
    final tope = finDeDatos.isBefore(fin) ? finDeDatos : fin;
    if (p.isAfter(tope)) p = tope.isBefore(inicio) ? inicio : tope;
    return p;
  }

  bool get _usable =>
      iniciado &&
      !_cerrado &&
      estado != EstadoReproductor.revocado &&
      estado != EstadoReproductor.cargando;

  /// **When a replay is logged** (US-24, CA-39.3, decided): only when the member plays or moves
  /// along the timeline (drag or tap, ±10 s, an event of the list or of the timeline). This is
  /// the single place that creates the replay (`POST /api/camaras/{id}/repeticiones`, which writes
  /// the access log entry); closing it or leaving the camera records its duration. Opening the
  /// camera and seeing the still frame of the last event is not logged.
  Future<void> _registrar() async {
    if (sesion != null || _registrando || _cerrado) return;
    _registrando = true;
    final ahora = reloj();
    final hasta = fin.isAfter(ahora) ? ahora : fin;
    try {
      final pedido = inicio;
      sesion = await repeticiones.crear(camaraId, pedido, hasta);
      _registradaEn = ahora;
      estado = EstadoReproductor.listo;
      if (sesion!.disponiblesDesde case final d?) datosDesde = d;
      // The window moved while it was being created: ask for its files.
      if (inicio != pedido) {
        unawaited(_actualizarArchivos());
      } else {
        unawaited(_cargarFotogramas());
      }
    } on ProblemaApi catch (e) {
      _error(e);
    } finally {
      _registrando = false;
      _notificar();
    }
  }

  void _error(ProblemaApi e) {
    reproduciendo = false;
    _tic?.cancel();
    if (e.codigo == ProblemaApi.sinConexion) {
      estado = EstadoReproductor.sinInternet;
    } else if (e.codigo == 'SIN_CONSENTIMIENTO_DE_MOVIMIENTOS') {
      estado = EstadoReproductor.revocado;
    } else {
      avisar?.call(e.detalle);
    }
  }

  /// The files of the window, after moving it (the same replay, contract §11).
  Future<void> _actualizarArchivos() async {
    final s = sesion;
    if (s == null) return;
    final ahora = reloj();
    final hasta = fin.isAfter(ahora) ? ahora : fin;
    if (!hasta.isAfter(inicio)) return;
    try {
      sesion = await repeticiones.archivos(s.id, inicio, hasta);
      estado = EstadoReproductor.listo;
      unawaited(_cargarFotogramas());
    } on ProblemaApi catch (e) {
      _error(e);
    }
    _notificar();
  }

  Future<void> _cargarFotogramas() async {
    final f = fuente;
    final s = sesion;
    if (f == null || s == null) return;
    for (final a in s.archivos) {
      if (_fotogramas.containsKey(a.id) || _cerrado) continue;
      final ligero = a.ligero;
      if (ligero == null) {
        _fotogramas[a.id] = const [];
        continue;
      }
      try {
        _fotogramas[a.id] = await f.cargar(
          ligero.url,
          sha256Esperado: ligero.sha256,
        );
        _notificar();
      } on Object {
        // A file that does not load or verify draws as a stretch without data.
        _fotogramas[a.id] = const [];
      }
    }
  }

  void _usar() {
    if (sesion == null) unawaited(_registrar());
  }

  /// Play or pause.
  void alternar() {
    if (!_usable) return;
    _usar();
    reproduciendo = !reproduciendo;
    if (reproduciendo) {
      final tope = finDeDatos.isBefore(fin) ? finDeDatos : fin;
      if (!posicion.isBefore(tope.subtract(_s(1)))) posicion = inicio;
      _tic?.cancel();
      _tic = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _avanzar(),
      );
    } else {
      _tic?.cancel();
    }
    _notificar();
  }

  void _avanzar() {
    if (!reproduciendo || _cerrado) return;
    var t = posicion.add(Duration(milliseconds: (100 * velocidad).round()));
    if (soloEventos) {
      final dentro = eventos.any(
        (e) =>
            !t.isBefore(e.en.subtract(_s(6))) && !t.isAfter(e.en.add(_s(12))),
      );
      if (!dentro) {
        final proximo = eventos
            .where((e) => e.en.subtract(_s(6)).isAfter(t))
            .firstOrNull;
        if (proximo == null) {
          _parar();
          avisar?.call('No hay más eventos este día');
          return;
        }
        t = proximo.en.subtract(_s(6));
        seleccionado = proximo.en;
      }
    }
    if (!t.isBefore(finDeDatos)) {
      posicion = finDeDatos;
      _parar();
      return;
    }
    if (t.isAfter(fin)) {
      _centrar(t);
      unawaited(_actualizarArchivos());
    } else {
      posicion = t;
    }
    _notificar();
  }

  void _parar() {
    reproduciendo = false;
    _tic?.cancel();
    _notificar();
  }

  /// −10 s / +10 s, or the previous / next event with «Solo eventos».
  void saltar(int sentido) {
    if (!_usable) return;
    if (soloEventos) {
      final e = sentido > 0
          ? eventos.where((x) => x.en.isAfter(posicion.add(_s(1)))).firstOrNull
          : eventos
                .where((x) => x.en.isBefore(posicion.subtract(_s(1))))
                .lastOrNull;
      if (e == null) {
        avisar?.call(
          sentido > 0 ? 'No hay más eventos' : 'No hay eventos antes',
        );
        return;
      }
      seleccionado = e.en;
      _ir(e.en);
      _usar();
      return;
    }
    seleccionado = null;
    var t = posicion.add(_s(10 * sentido));
    if (t.isBefore(dia)) t = dia;
    if (t.isAfter(finDeDatos)) t = finDeDatos;
    _ir(t);
    _usar();
  }

  /// Drag or tap on the timeline, or an event of the list.
  void irA(DateTime t, {bool evento = false}) {
    if (!_usable) return;
    seleccionado = evento ? t : null;
    _ir(t);
    _usar();
  }

  void _ir(DateTime t) {
    if (t.isBefore(inicio) || t.isAfter(fin)) {
      _centrar(t);
      unawaited(_actualizarArchivos());
    } else {
      posicion = _limitar(t);
    }
    _notificar();
  }

  /// 0,5× → 1× → 2× → 4×.
  void cambiarVelocidad() {
    final i = velocidades.indexOf(velocidad);
    velocidad = velocidades[(i + 1) % velocidades.length];
    _notificar();
  }

  /// «10 min» or «1 hora».
  void cambiarLargo(Duration nuevo) {
    if (nuevo == largo) return;
    largo = nuevo;
    _centrar(posicion);
    unawaited(_actualizarArchivos());
    _notificar();
  }

  void alternarSoloEventos() {
    soloEventos = !soloEventos;
    if (soloEventos &&
        eventos.isNotEmpty &&
        !eventos.any((e) => posicion.difference(e.en).abs() < _s(12))) {
      final e =
          eventos.where((x) => !x.en.isAfter(posicion)).lastOrNull ??
          eventos.first;
      seleccionado = e.en;
      _ir(e.en);
    }
    _notificar();
  }

  /// «Hoy», «Ayer», a day of «Elegir día…»: its last event, or the last minutes today, or the same
  /// time of day.
  Future<void> elegirDia(DateTime d) async {
    final nuevo = _diaDe(d);
    if (nuevo == dia) return;
    _parar();
    final hora = posicion.difference(dia);
    dia = nuevo;
    seleccionado = null;
    await _cargarDia();
    final ultimo = eventos
        .where((e) => e.tipo != TipoEvento.levanto)
        .lastOrNull;
    final t = ultimo?.en ?? (esHoy ? reloj().subtract(_s(90)) : dia.add(hora));
    seleccionado = ultimo?.en;
    _centrar(t);
    unawaited(_actualizarArchivos());
    _notificar();
    if (ultimo != null) unawaited(_fotoFija(ultimo.en));
  }

  /// «Ver lo último» when the chosen day is out of the retention.
  Future<void> verLoUltimo() async {
    final desde = datosDesde;
    final ultimo = recientes
        .where((a) => desde == null || !a.ocurridaEn.isBefore(desde))
        .firstOrNull;
    final t = ultimo?.ocurridaEn ?? reloj().subtract(_s(90));
    _parar();
    dia = _diaDe(t);
    await _cargarDia();
    seleccionado = ultimo?.ocurridaEn;
    _centrar(t);
    unawaited(_actualizarArchivos());
    _notificar();
    unawaited(_fotoFija(t));
  }

  /// Closes the replay, if one was created; returns how long it lasted.
  Future<Duration?> cerrar() async {
    _cerrado = true;
    _tic?.cancel();
    final s = sesion;
    final desde = _registradaEn;
    if (s == null || desde == null) return null;
    final dura = reloj().difference(desde);
    try {
      await repeticiones.cerrar(s.id);
    } on ProblemaApi {
      // The backend closes it after an hour anyway.
    }
    return dura;
  }

  bool get registrada => sesion != null;

  void _notificar() {
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    _tic?.cancel();
    super.dispose();
  }
}
