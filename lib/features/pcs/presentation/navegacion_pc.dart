import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';

/// The location of the screen on top of the stack.
String ubicacionArriba(GoRouter router) =>
    router.routerDelegate.currentConfiguration.lastOrNull?.matchedLocation ??
    '';

/// Closes the pairing screens (`/vincular…`) on top of the stack, back to the screen the pairing
/// started from. Returns false when the pairing is all there is (it was opened from the PC's QR).
bool cerrarVinculacion(BuildContext context) {
  final router = GoRouter.of(context);
  while (ubicacionArriba(router).startsWith(Rutas.vincular)) {
    if (!router.canPop()) return false;
    router.pop();
  }
  return true;
}

/// Leaves a screen that may be the only one (opened from a link or after the pairing): back, or to
/// [destino] when there is nothing to go back to.
void salirA(BuildContext context, String destino) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(destino);
  }
}
