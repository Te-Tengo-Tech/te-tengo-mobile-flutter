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
  Future<String?> token() async => tokenActual;

  @override
  Stream<String> get tokenRenovado => _renovado.stream;

  @override
  Stream<MensajePush> get recibidas => _recibidas.stream;

  @override
  Stream<MensajePush> get abiertas => _abiertas.stream;

  @override
  Future<MensajePush?> inicial() async => mensajeInicial;
}

class DispositivosFalsos implements DispositivosRepositorio {
  final registrados = <String>[];
  final eliminados = <String>[];

  @override
  Future<void> registrar({
    required String tokenPush,
    required String plataforma,
  }) async => registrados.add('$tokenPush|$plataforma');

  @override
  Future<void> eliminar(String tokenPush, {String? tokenAcceso}) async =>
      eliminados.add('$tokenPush|$tokenAcceso');
}
