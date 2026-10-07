import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/notificaciones/dispositivos_repositorio.dart';
import '../core/notificaciones/mensaje_push.dart';
import '../core/notificaciones/notificaciones_push.dart';
import '../core/formato.dart';
import '../core/reloj.dart';
import '../core/sesion/sesion.dart';
import '../core/sesion/sesion_controller.dart';
import '../core/ui/avisos_flotantes.dart';
import '../features/alertas/data/alertas_repositorio.dart';
import '../features/camaras/data/camaras_repositorio.dart';
import '../features/camaras/presentation/avisos_camara.dart';
import '../features/hogar/data/hogar_repositorio.dart';
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

/// Registers this phone for push while there is a session with a household, and turns pushes into
/// screens (tapped) or in-app notices (received with the app open).
class GestorPush {
  GestorPush(this._ref);

  final Ref _ref;
  final _suscripciones = <StreamSubscription<Object?>>[];
  String? _token;
  String? _registrado;
  bool _iniciado = false;

  NotificacionesPush get _push => _ref.read(notificacionesPushProvider);

  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;
    _suscripciones
      ..add(_push.abiertas.listen(abrir))
      ..add(_push.recibidas.listen(enPrimerPlano))
      ..add(
        _push.tokenRenovado.listen((t) {
          _token = t;
          _registrado = null;
          unawaited(registrar());
        }),
      );
    await registrar();
    final inicial = await _push.inicial();
    if (inicial != null) abrir(inicial, desdeCerrada: true);
  }

  /// `POST /api/dispositivos` once per household and token.
  Future<void> registrar() async {
    final sesion = _ref.read(sesionControllerProvider);
    if (sesion == null || !sesion.tieneHogar) {
      _registrado = null;
      return;
    }
    final token = _token ??= await _push.token();
    if (token == null) return;
    final clave = '${sesion.hogarId}|$token';
    if (_registrado == clave) return;
    try {
      await _ref
          .read(dispositivosRepositorioProvider)
          .registrar(tokenPush: token, plataforma: _push.plataforma);
      _registrado = clave;
    } on Object {
      // Retried on the next session change or token refresh.
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
        if (id != null && !_enPantalla(router, Rutas.alerta(id))) {
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
      default:
        break;
    }
  }

  static bool _enPantalla(GoRouter router, String ruta) =>
      router.routerDelegate.currentConfiguration.uri.path == ruta;

  void _refrescar(MensajePush m) {
    if (m.tipo.deCamara) _ref.invalidate(camarasProvider);
    if (m.tipo.deAlerta || m.tipo == TipoPush.alertaAtendida) {
      _ref.invalidate(alertaActivaProvider);
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
    (_, _) => unawaited(gestor.registrar()),
  );
  ref.onDispose(gestor.cerrar);
  return gestor;
});
