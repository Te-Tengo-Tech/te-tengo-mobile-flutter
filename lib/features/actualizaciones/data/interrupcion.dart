import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../alertas/data/alertas_repositorio.dart';

/// The screen on top (the router's path), kept by `GuardiaActualizaciones`.
class RutaActual extends Notifier<String> {
  @override
  String build() => '';

  void cambiar(String ruta) {
    if (ruta != state) state = ruta;
  }
}

final rutaActualProvider = NotifierProvider<RutaActual, String>(RutaActual.new);

/// An alert (`/alerta/…`, `/alertas/…`) or a live view (`/vivo`, and any view under it, such as
/// «Ver todas»): no update notice, installer or reload interrupts them (CA-43.9), and the
/// minimum-version screen never covers them, so the alerts already received stay visible (CA-43.8).
bool esRutaProtegida(String ruta) =>
    ruta.startsWith('/alerta/') ||
    ruta.startsWith('/alertas/') ||
    ruta == '/vivo' ||
    ruta.startsWith('/vivo/') ||
    ruta.startsWith('/vivo?');

/// An active alert or an open alert or live view: the update waits until they close (CA-43.9).
final interrupcionActivaProvider = Provider<bool>((ref) {
  if (esRutaProtegida(ref.watch(rutaActualProvider))) return true;
  return ref.watch(alertaActivaProvider).value != null;
});
