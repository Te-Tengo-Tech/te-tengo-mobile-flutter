import 'dart:async';

import 'package:te_tengo/core/notificaciones/dispositivos_repositorio.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/notificaciones/notificaciones_push.dart';

class NotificacionesPushFalsas implements NotificacionesPush {
  NotificacionesPushFalsas({
    this.tokenActual,
    this.mensajeInicial,
    this.permiso = true,
  });

  String? tokenActual;
  MensajePush? mensajeInicial;

  /// The token FCM issues after [borrarToken].
  String? tokenTrasBorrar;
  int tokensBorrados = 0;

  /// Thrown by [token], as Firebase does when it cannot issue one.
  Object? errorToken;

  /// While set, [token] waits for it, as Firebase does while it subscribes to the push service.
  Future<void>? esperaToken;
  int _tokensEnCurso = 0;

  /// The most [token] calls that were under way at the same time.
  int maxTokensALaVez = 0;

  /// Answer of the system permission prompt.
  bool permiso;
  int permisosPedidos = 0;
  final _renovado = StreamController<String>.broadcast();
  final _recibidas = StreamController<MensajePush>.broadcast();
  final _abiertas = StreamController<MensajePush>.broadcast();

  void renovar(String token) {
    tokenActual = token;
    _renovado.add(token);
  }

  void recibir(MensajePush m) => _recibidas.add(m);

  void tocar(MensajePush m) => _abiertas.add(m);

  @override
  Future<bool> pedirPermiso() async {
    permisosPedidos++;
    return permiso;
  }

  @override
  String get plataforma => 'ANDROID';

  @override
  Future<String?> token() async {
    _tokensEnCurso++;
    if (_tokensEnCurso > maxTokensALaVez) maxTokensALaVez = _tokensEnCurso;
    try {
      // What Firebase answers is decided when it is asked.
      final token = tokenActual;
      if (esperaToken case final espera?) await espera;
      if (errorToken case final e?) throw e;
      return token;
    } finally {
      _tokensEnCurso--;
    }
  }

  @override
  Future<void> borrarToken() async {
    tokensBorrados++;
    tokenActual = tokenTrasBorrar;
  }

  @override
  Stream<String> get tokenRenovado => _renovado.stream;

  @override
  Stream<MensajePush> get recibidas => _recibidas.stream;

  @override
  Stream<MensajePush> get abiertas => _abiertas.stream;

  @override
  Future<MensajePush?> inicial() async => mensajeInicial;
}

/// The backend's devices: `d-<token>` is the id of each registered token.
class DispositivosFalsos implements DispositivosRepositorio {
  final registrados = <String>[];
  final eliminados = <String>[];
  final consultados = <String>[];

  /// Ids the backend deactivated (the push service dropped their token).
  final inactivos = <String>{};

  /// Thrown by [registrar], as a failing backend or network does.
  Object? errorRegistrar;

  @override
  Future<DispositivoPush> registrar({
    required String tokenPush,
    required String plataforma,
  }) async {
    if (errorRegistrar case final e?) throw e;
    registrados.add('$tokenPush|$plataforma');
    inactivos.remove('d-$tokenPush');
    return DispositivoPush(id: 'd-$tokenPush', activo: true);
  }

  @override
  Future<DispositivoPush?> consultar(String id) async {
    consultados.add(id);
    final token = id.substring(2);
    if (!registrados.any((r) => r.startsWith('$token|'))) return null;
    return DispositivoPush(id: id, activo: !inactivos.contains(id));
  }

  @override
  Future<void> eliminar(String tokenPush, {String? tokenAcceso}) async =>
      eliminados.add('$tokenPush|$tokenAcceso');
}

/// The PWA's pushes: Firebase hands them to a visible window ([firebase]); the service worker posts
/// their data to every window ([trabajador], `tt-push-recibida`).
class NotificacionesPushWebFalsas extends NotificacionesPushFalsas {
  NotificacionesPushWebFalsas({super.tokenActual});

  final firebase = StreamController<MensajePush>.broadcast();
  final trabajador = StreamController<Map<String, Object?>>.broadcast();

  @override
  String get plataforma => 'WEB';

  @override
  Stream<MensajePush> get recibidas =>
      recibidasEnLaWeb(firebase.stream, trabajador.stream);
}
