import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Internet connection of the phone.
abstract interface class Conectividad {
  Future<bool> conectado();

  Stream<bool> get cambios;
}

class ConectividadSistema implements Conectividad {
  ConectividadSistema([Connectivity? conectividad])
    : _conectividad = conectividad ?? Connectivity();

  final Connectivity _conectividad;

  static bool _hay(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  @override
  Future<bool> conectado() async =>
      _hay(await _conectividad.checkConnectivity());

  @override
  Stream<bool> get cambios => _conectividad.onConnectivityChanged.map(_hay);
}

final conectividadProvider = Provider<Conectividad>(
  (ref) => ConectividadSistema(),
);

/// True while the phone has no internet («Tu celular no tiene internet»).
final sinInternetProvider = StreamProvider<bool>((ref) async* {
  final c = ref.watch(conectividadProvider);
  yield !await c.conectado();
  yield* c.cambios.map((hay) => !hay);
});
