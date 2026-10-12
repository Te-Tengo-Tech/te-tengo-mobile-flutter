import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';

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

/// «Esta PC ya está vinculada» (`409 PC_YA_VINCULADA`): the toast, then back to «Agregar PC», or to
/// «Cámaras y PCs» (step 3 in setup) when the pairing was opened from the PC's QR.
void avisarPcYaVinculada(
  BuildContext context, {
  required bool enConfiguracion,
}) {
  mostrarToast(
    context,
    titulo: 'Esta PC ya está vinculada',
    texto: 'La encuentras en Cámaras y PCs.',
    icono: Ico.pc,
    tono: TonoAviso.advertencia,
  );
  salirA(context, enConfiguracion ? Rutas.configCamara : Rutas.pcs);
}
