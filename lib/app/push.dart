import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/cache/cache_local.dart';
import '../core/dispositivo/permiso_notificaciones.dart';
import '../core/notificaciones/dispositivos_repositorio.dart';
import '../core/notificaciones/mensaje_push.dart';
import '../core/notificaciones/notificaciones_push.dart';
import '../core/formato.dart';
import '../core/reloj.dart';
import '../core/sesion/sesion.dart';
import '../core/sesion/sesion_controller.dart';
import '../core/ui/avisos_flotantes.dart';
import '../core/web/entorno.dart';
import '../features/ajustes/data/preferencias.dart';
import '../features/alertas/data/alertas_repositorio.dart';
import '../features/alertas/domain/alerta.dart';
import '../features/camaras/data/camaras_repositorio.dart';
import '../features/camaras/domain/camara.dart';
import '../features/familia/data/familia_repositorio.dart';
import '../features/familia/domain/familiar.dart';
import '../features/camaras/presentation/avisos_camara.dart';
import '../features/historial/data/historial_provider.dart';
import '../features/historial/data/resumen_repositorio.dart';
import '../features/hogar/data/hogar_repositorio.dart';
import '../features/hogar/presentation/revocacion.dart';
import 'router.dart';
import 'rutas.dart';

/// Screen that a push opens (contract §7 `tipo`).
String rutaDePush(MensajePush m) {
  final alerta = m.alertaId;
  final camara = m.camaraId;
  return switch (m.tipo) {
    TipoPush.alertaAtendida when alerta != null => Rutas.detalleAlerta(alerta),
    final t when t.deAlerta && alerta != null => Rutas.alerta(alerta),
    final t when t.deCamara && camara != null => Rutas.camara(camara),
    TipoPush.datosEliminados => Rutas.privacidad,
    _ => Rutas.inicio,
  };
}

/// Whether this phone receives the alerts, as the backend sees it (contract §7), not only whether
/// the system allows notifications.
enum RecepcionPush {
  /// Not registered yet in this run (no session, or the registration is under way).
  desconocida,

  /// The backend has this phone's token and sends to it.
  activa,

  /// No token: push unavailable (no Firebase), permission not granted yet, or iOS still waiting
  /// for APNs.
  sinToken,

  /// The push service no longer accepts this phone's token and a new one could not be registered.
  rechazada,

  /// The registration failed (network, backend or Firebase error); retried on the next start or
  /// return to the foreground.
  error,
}

class RecepcionPushController extends Notifier<RecepcionPush> {
  @override
  RecepcionPush build() => RecepcionPush.desconocida;

  void cambiar(RecepcionPush nueva) => state = nueva;
}

final recepcionPushProvider =
    NotifierProvider<RecepcionPushController, RecepcionPush>(
      RecepcionPushController.new,
    );

/// This phone could be receiving alerts but is not: the backend dropped its token or the
/// registration failed.
final celularSinAlertasProvider = Provider<bool>(
  (ref) => switch (ref.watch(recepcionPushProvider)) {
    RecepcionPush.rechazada || RecepcionPush.error => true,
    _ => false,
  },
);

/// Nobody in the family can receive alerts on a phone (`GET /api/hogar` `dispositivosActivos == 0`).
/// False while unknown or with a backend older than 0.3.1.
final familiaSinAlertasProvider = Provider<bool>(
  (ref) => ref.watch(hogarProvider).value?.dispositivosActivos == 0,
);

/// Registers this phone for push while there is a session with a household, and turns pushes into
/// screens (tapped) or in-app notices (received with the app open).
class GestorPush {
  GestorPush(this._ref);

  final Ref _ref;
  final _suscripciones = <StreamSubscription<Object?>>[];
  bool _iniciado = false;
  bool _permisoPedido = false;

  /// The registration under way (single flight).
  Future<RecepcionPush>? _enCurso;

  /// The one registration that runs after [_enCurso], shared by every caller that asked while it
  /// was under way: what they asked for (a new household, a permission just granted) may have come
  /// too late for it.
  Future<RecepcionPush>? _siguiente;
  bool _forzarSiguiente = false;

  /// `hogarId|token` of the last successful registration, and when it happened.
  String? _registrado;
  DateTime? _registradoEn;

  /// Registrations closer than this to the last successful one, for the same household and token,
  /// are skipped unless forced: the app starts and resumes from several places at once.
  static const _intervaloMinimo = Duration(seconds: 30);

  /// Where the backend's id of this phone is kept, with the token it belongs to.
  static const _claveDispositivo = '${deDispositivo}push';

  NotificacionesPush get _push => _ref.read(notificacionesPushProvider);

  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;
    // Loaded now so a push can be filtered by them as soon as it arrives.
    unawaited(
      _ref.read(preferenciasProvider.future).then((_) {}, onError: (_) {}),
    );
    _suscripciones
      ..add(_push.abiertas.listen(abrir))
      ..add(_push.recibidas.listen(enPrimerPlano))
      ..add(
        _push.tokenRenovado.listen((_) => unawaited(registrar(forzar: true))),
      );
    await registrar(forzar: true);
    final inicial = await _push.inicial();
    if (inicial != null) abrir(inicial, desdeCerrada: true);
  }

  /// `POST /api/dispositivos` on every start, return to the foreground, session change, token
  /// refresh and «Activar notificaciones», so the backend knows this phone is still there. Only one
  /// registration runs at a time (two at once got two FCM tokens): callers during one wait for a
  /// single one that runs right after it. The first time there is a household, it asks for the
  /// notification permission (CA-16.2), except on the web. Before registering, it asks the backend
  /// whether it still sends to this phone; if not, it gets a new token. Returns how it went, also
  /// in [recepcionPushProvider]; it never throws.
  Future<RecepcionPush> registrar({bool forzar = false}) {
    final enCurso = _enCurso;
    if (enCurso == null && _siguiente == null) return _empezar(forzar);
    _forzarSiguiente = _forzarSiguiente || forzar;
    return _siguiente ??= enCurso!.then((_) {
      final forzarla = _forzarSiguiente;
      _siguiente = null;
      _forzarSiguiente = false;
      return _empezar(forzarla);
    });
  }

  Future<RecepcionPush> _empezar(bool forzar) {
    final nuevo = _registrar(forzar: forzar);
    _enCurso = nuevo;
    nuevo.whenComplete(() {
      if (identical(_enCurso, nuevo)) _enCurso = null;
    }).ignore();
    return nuevo;
  }

  Future<RecepcionPush> _registrar({required bool forzar}) async {
    // Callers may be building widgets (initState): the state changes after that.
    await Future<void>.value();
    final sesion = _ref.read(sesionControllerProvider);
    if (sesion == null || !sesion.tieneHogar) {
      _registrado = null;
      return _estado(RecepcionPush.desconocida);
    }
    try {
      // On the web the browser only asks from a tap: «Activar notificaciones» in Inicio asks, and
      // then calls this again.
      if (!_permisoPedido && !_ref.read(entornoNavegadorProvider).esWeb) {
        _permisoPedido = true;
        await _push.pedirPermiso();
        _ref.invalidate(notificacionesActivasProvider);
      }
      var token = await _push.token();
      if (token == null) return _estado(RecepcionPush.sinToken);
      final clave = '${sesion.hogarId}|$token';
      final ultimo = _registradoEn;
      if (!forzar &&
          _registrado == clave &&
          ultimo != null &&
          DateTime.now().difference(ultimo) < _intervaloMinimo) {
        return _ref.read(recepcionPushProvider);
      }
      final guardado = await _leerGuardado();
      // A token this phone registered before and no longer uses (FCM issued a new one).
      final sobrante = guardado != null && guardado.token != token
          ? guardado.token
          : null;
      if (guardado != null && guardado.token == token) {
        final dispositivo = await _ref
            .read(dispositivosRepositorioProvider)
            .consultar(guardado.id);
        if (dispositivo != null && !dispositivo.activo) {
          // The push service dropped this token: registering it again would not help.
          debugPrint(
            'El backend ya no envía a este celular: se pide otro token.',
          );
          final nuevo = await _renovarToken(token);
          if (nuevo == null) return _estado(RecepcionPush.rechazada);
          token = nuevo;
        }
      }
      final dispositivo = await _ref
          .read(dispositivosRepositorioProvider)
          .registrar(tokenPush: token, plataforma: _push.plataforma);
      if (!dispositivo.activo) return _estado(RecepcionPush.rechazada);
      if (dispositivo.id case final id?) await _guardar(token, id);
      if (sobrante != null) await _eliminarDelBackend(sobrante);
      final anterior = _ref.read(recepcionPushProvider);
      _registrado = '${sesion.hogarId}|$token';
      _registradoEn = DateTime.now();
      // To send a test message from the Firebase console (docs/FIREBASE.md).
      if (kDebugMode) debugPrint('Token de push: $token');
      // The family's count of active phones may have changed (`dispositivosActivos`).
      if (anterior != RecepcionPush.activa) _ref.invalidate(hogarProvider);
      return _estado(RecepcionPush.activa);
    } on Object catch (e) {
      // Shown in Inicio and Notificaciones; retried on the next start or return to the foreground.
      debugPrint('No se pudo registrar el celular para las alertas: $e');
      return _estado(RecepcionPush.error);
    }
  }

  /// Deletes the rejected token, gets a new one and drops the old one from the backend.
  Future<String?> _renovarToken(String anterior) async {
    await _push.borrarToken();
    final nuevo = await _push.token();
    if (nuevo != null && nuevo != anterior) await _eliminarDelBackend(anterior);
    return nuevo == anterior ? null : nuevo;
  }

  /// `DELETE /api/dispositivos/{tokenPush}` of a token this phone no longer uses, so the backend
  /// stops counting and sending to it. Best effort: the push service rejects it anyway.
  Future<void> _eliminarDelBackend(String token) async {
    try {
      await _ref.read(dispositivosRepositorioProvider).eliminar(token);
    } on Object catch (e) {
      debugPrint('No se pudo quitar un token anterior: $e');
    }
  }

  RecepcionPush _estado(RecepcionPush estado) {
    if (_ref.read(recepcionPushProvider) != estado) {
      _ref.read(recepcionPushProvider.notifier).cambiar(estado);
    }
    return estado;
  }

  Future<({String token, String id})?> _leerGuardado() async {
    try {
      final texto = await _ref.read(cacheLocalProvider).leer(_claveDispositivo);
      if (texto == null) return null;
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return (token: json['token'] as String, id: json['id'] as String);
    } on Object {
      return null;
    }
  }

  Future<void> _guardar(String token, String id) async {
    try {
      await _ref
          .read(cacheLocalProvider)
          .guardar(_claveDispositivo, jsonEncode({'token': token, 'id': id}));
    } on Object {
      // Without it the next start registers without asking first.
    }
  }

  /// A tapped push opens its screen; alerts never wait for the splash.
  void abrir(MensajePush m, {bool desdeCerrada = false}) {
    _refrescar(m);
    final router = _ref.read(routerProvider);
    final ruta = rutaDePush(m);
    if (desdeCerrada || ruta == Rutas.inicio) router.go(Rutas.inicio);
    if (ruta != Rutas.inicio) router.push(ruta);
  }

  /// A push received with the app open.
  void enPrimerPlano(MensajePush m) {
    _refrescar(m);
    final router = _ref.read(routerProvider);
    final habitacion = m.habitacion ?? '';
    switch (m.tipo) {
      case TipoPush.alertaCaida ||
          TipoPush.alertaMovimientoInestable ||
          TipoPush.alertaActualizadaACaida:
        // A new alert takes the whole screen; an alert already open is refreshed in place
        // (unstable movement that became a fall, CA-17.3).
        final id = m.alertaId;
        // Unstable movement can be muted on this phone (screen 96); falls never.
        final silenciada =
            m.tipo == TipoPush.alertaMovimientoInestable &&
            !(_ref.read(preferenciasProvider).value?.inestables ?? true);
        if (id != null &&
            !silenciada &&
            !_enPantalla(router, Rutas.alerta(id))) {
          router.push(Rutas.alerta(id));
        }
      case TipoPush.caidaConfirmada:
        // On the alert itself the chip changes; elsewhere an in-app notice tells it (CA-13.1).
        final id = m.alertaId;
        if (id == null || _enPantalla(router, Rutas.alerta(id))) break;
        final nombre = _ref.read(nombreAdultoMayorProvider) ?? '';
        _ref
            .read(avisoFlotanteProvider.notifier)
            .mostrar(
              AvisoFlotante(
                tipo: TipoFlotante.enApp,
                titulo: '$nombre sigue en el suelo',
                texto:
                    'Caída confirmada a las '
                    '${hora(_ref.read(relojProvider)())}. La alerta sigue activa.',
                alTocar: () => router.push(Rutas.alerta(id)),
              ),
            );
      case TipoPush.seLevanto:
        // CA-21.1: the follow-up notice, also on the alert itself (screen 57).
        final id = m.alertaId;
        final nombre = _ref.read(nombreAdultoMayorProvider) ?? '';
        _ref
            .read(avisoFlotanteProvider.notifier)
            .mostrar(
              AvisoFlotante(
                tipo: TipoFlotante.enApp,
                titulo: '$nombre se levantó',
                texto:
                    '${hora(m.ocurridaEn ?? _ref.read(relojProvider)())} · Se '
                    'puso de pie${habitacion.isEmpty ? '' : ' ${enHabitacion(habitacion)}'}. '
                    'Confirma cómo está.',
                alTocar: id == null || _enPantalla(router, Rutas.alerta(id))
                    ? null
                    : () => router.push(Rutas.alerta(id)),
              ),
            );
      case TipoPush.alertaAtendida:
        // CA-19.3: the others see who attended it and when.
        final id = m.alertaId;
        if (id == null || _enPantalla(router, Rutas.alerta(id))) break;
        unawaited(_avisarAtendida(router, id));
      case TipoPush.alertaEscalada || TipoPush.sinContactoSecundario:
        final id = m.alertaId;
        if (id == null || _enPantalla(router, Rutas.alerta(id))) break;
        unawaited(
          _avisarEscalamiento(
            router,
            id,
            conSecundario: m.tipo == TipoPush.alertaEscalada,
          ),
        );
      case TipoPush.datosEliminados:
        // CA-09.3: the revocation screen shows the recordings as deleted.
        _ref
            .read(revocacionProvider.notifier)
            .terminar(m.ocurridaEn ?? _ref.read(relojProvider)());
      case TipoPush.camaraDesconectada:
        _ref
            .read(avisosCamaraProvider)
            .desconectada(
              habitacion: habitacion,
              abrir: m.camaraId == null
                  ? null
                  : () => router.push(Rutas.camara(m.camaraId!)),
            );
      case TipoPush.camaraReconectada:
        _ref
            .read(avisosCamaraProvider)
            .reconectada(
              habitacion: habitacion,
              cuando: m.ocurridaEn ?? _ref.read(relojProvider)(),
            );
      case TipoPush.deteccionNoConfiable:
        _ref
            .read(avisosCamaraProvider)
            .noConfiable(
              habitacion: habitacion,
              nombre: _ref.read(nombreAdultoMayorProvider) ?? '',
              abrir: m.camaraId == null
                  ? null
                  : () => router.push(Rutas.camara(m.camaraId!)),
            );
      case TipoPush.pausaFinalizada:
        if (!(_ref.read(preferenciasProvider).value?.finPausa ?? true)) {
          _ref.invalidate(camarasProvider);
          break;
        }
        _ref
            .read(avisosCamaraProvider)
            .reactivada(
              habitacion: habitacion,
              cuando: m.ocurridaEn ?? _ref.read(relojProvider)(),
            );
    }
  }

  /// Escalation notices (CA-20.1, CA-20.3).
  Future<void> _avisarEscalamiento(
    GoRouter router,
    String id, {
    required bool conSecundario,
  }) async {
    List<MiembroFamilia> miembros;
    int? esperaGuardada;
    try {
      final aviso = await _ref.read(avisoProvider.future);
      miembros = ordenarFamilia(
        await _ref.read(familiaresProvider.future),
        aviso,
      );
      esperaGuardada = aviso.esperaMinutos;
    } catch (_) {
      miembros = const [];
    }
    final secundario = miembros
        .where((x) => x.papel == PapelAviso.secundario)
        .firstOrNull
        ?.familiar;
    final yo = _ref.read(sesionControllerProvider)?.usuario.id;
    final espera = esperaGuardada ?? ConfiguracionAviso.esperaPredeterminada;
    final mia = conSecundario && secundario?.usuarioId == yo;
    final (titulo, texto) = mia
        ? (
            'Nadie atendió la alerta: te toca',
            'Pasaron $espera min sin respuesta. Eres el contacto secundario.',
          )
        : conSecundario
        ? (
            'Alerta escalada a ${secundario?.nombre ?? 'tu contacto secundario'}',
            'Nadie la marcó en $espera min. Tú todavía puedes atenderla.',
          )
        : (
            'No hay contacto secundario',
            'Pasaron $espera min sin respuesta. La alerta sigue siendo tuya.',
          );
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            tipo: TipoFlotante.enApp,
            titulo: titulo,
            texto: texto,
            alTocar: () => router.push(Rutas.alerta(id)),
          ),
        );
  }

  Future<void> _avisarAtendida(GoRouter router, String id) async {
    try {
      final a = await _ref.read(alertaProvider(id).future);
      final quien = (a.atendidaPor ?? '').split(' ').first;
      final cuando = a.atendidaEn ?? _ref.read(relojProvider)();
      _ref
          .read(avisoFlotanteProvider.notifier)
          .mostrar(
            AvisoFlotante(
              tipo: TipoFlotante.enApp,
              titulo: a.estado == EstadoAlerta.falsaAlarma
                  ? '$quien la marcó como falsa alarma'
                  : '$quien atendió la alerta',
              texto:
                  '${hora(cuando)} · ${a.tipo.nombre} '
                  '${enHabitacion(a.habitacion)}.',
              alTocar: () => router.push(Rutas.detalleAlerta(id)),
            ),
          );
    } on Object {
      // The alert list and the strip are refreshed anyway.
    }
  }

  static bool _enPantalla(GoRouter router, String ruta) =>
      router.routerDelegate.currentConfiguration.uri.path == ruta;

  void _refrescar(MensajePush m) {
    if (m.tipo.deCamara) _ref.invalidate(camarasProvider);
    if (m.tipo == TipoPush.datosEliminados) {
      _ref
        ..invalidate(hogarProvider)
        ..invalidate(camarasProvider);
    }
    if (m.tipo.deAlerta || m.tipo == TipoPush.alertaAtendida) {
      _ref
        ..invalidate(alertaActivaProvider)
        ..invalidate(historialProvider)
        ..invalidate(resumenSemanalProvider)
        ..invalidate(alertasDeSemanaProvider)
        ..invalidate(ultimoEventoProvider);
      if (m.alertaId case final id?) _ref.invalidate(alertaProvider(id));
    }
  }

  void cerrar() {
    for (final s in _suscripciones) {
      unawaited(s.cancel());
    }
    _suscripciones.clear();
  }
}

final gestorPushProvider = Provider<GestorPush>((ref) {
  final gestor = GestorPush(ref);
  ref.listen<Sesion?>(
    sesionControllerProvider,
    (antes, ahora) =>
        unawaited(gestor.registrar(forzar: antes?.hogarId != ahora?.hogarId)),
  );
  ref.onDispose(gestor.cerrar);
  return gestor;
});
