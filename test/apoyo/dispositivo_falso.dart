import 'dart:async';

import 'package:te_tengo/core/dispositivo/conectividad.dart';
import 'package:te_tengo/core/dispositivo/permiso_notificaciones.dart';

class PermisoFalso implements PermisoNotificaciones {
  PermisoFalso({this.activas = true, this.alActivar = true});

  bool activas;
  bool alActivar;
  int pedidos = 0;

  @override
  Future<bool> activadas() async => activas;

  @override
  Future<bool> activar() async {
    pedidos++;
    activas = alActivar;
    return activas;
  }
}

class ConectividadFalsa implements Conectividad {
  ConectividadFalsa({this.hay = true});

  bool hay;
  final _cambios = StreamController<bool>.broadcast();

  void cambiar(bool conectado) {
    hay = conectado;
    _cambios.add(conectado);
  }

  @override
  Future<bool> conectado() async => hay;

  @override
  Stream<bool> get cambios => _cambios.stream;
}
