import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../data/pcs_repositorio.dart';

/// Refreshes everything that shows the household's cameras, PCs and rooms after a change.
void refrescarCamaras(WidgetRef ref, {String? pcId}) {
  ref
    ..invalidate(camarasProvider)
    ..invalidate(pcsProvider)
    ..invalidate(ambientesProvider);
  if (pcId != null) ref.invalidate(camarasDetectadasProvider(pcId));
}

/// «Dejar de usar» (screens 274 to 276): asks first, then the camera stops detecting and its room
/// is free; it stays «sin usar» among the PC's webcams (CA-29.2). Returns true when it was done.
Future<bool> dejarDeUsarCamara(
  BuildContext context,
  WidgetRef ref, {
  required String camaraId,
  required String dispositivo,
  required String habitacion,
  String? pcId,
}) async {
  final l = context.l10n;
  final si = await confirmar(
    context,
    icono: Ico.cam,
    titulo: l.pcsDejarDeUsarTitulo(dispositivo),
    texto: l.pcsDejarDeUsarTexto(enHabitacion(habitacion, l)),
    aceptar: l.pcsDejarDeUsar,
    cancelar: l.pcsCancelar,
    peligro: true,
  );
  if (!si || !context.mounted) return false;
  try {
    await ref.read(pcsRepositorioProvider).dejarDeUsar(camaraId);
    refrescarCamaras(ref, pcId: pcId);
    if (context.mounted) {
      mostrarToast(
        context,
        titulo: l.pcsDejamosDeUsar(dispositivo),
        texto: l.pcsYaNoDetectamos(enHabitacion(habitacion, l)),
        icono: Ico.cam,
      );
    }
    return true;
  } on ProblemaApi catch (e) {
    if (context.mounted) {
      mostrarToast(
        context,
        titulo: e.codigo == ProblemaApi.sinConexion
            ? l.pcsSinInternet
            : e.detalle,
        texto: e.codigo == ProblemaApi.sinConexion ? l.pcsRevisaConexion : null,
        icono: Ico.warn,
        tono: TonoAviso.advertencia,
      );
    }
    return false;
  }
}
