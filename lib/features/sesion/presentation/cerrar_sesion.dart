import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'pantalla_iniciar_sesion.dart';

/// Screen 13: asks before signing out; then the splash plays and the sign-in screen opens with the
/// email filled in (CA-02.4).
Future<void> cerrarSesion(BuildContext context, WidgetRef ref) async {
  final nombre = ref.read(nombreAdultoMayorProvider);
  final l = context.l10n;
  final si = await confirmar(
    context,
    icono: Ico.logout,
    titulo: l.sesionCerrarTitulo,
    texto: nombre == null ? l.sesionCerrarTexto : l.sesionCerrarTextoSus,
    aceptar: l.sesionCerrar,
    cancelar: l.sesionCancelar,
  );
  if (!si || !context.mounted) return;
  final correo = ref.read(sesionControllerProvider)?.usuario.correo ?? '';
  final siguiente = Uri(
    path: Rutas.iniciarSesion,
    queryParameters: {
      'correo': correo,
      'aviso': AvisoInicioSesion.sesionCerrada.codigo,
    },
  ).toString();
  context.go(
    Uri(
      path: Rutas.arranque,
      queryParameters: {'siguiente': siguiente},
    ).toString(),
  );
  await ref.read(sesionControllerProvider.notifier).cerrar();
}
