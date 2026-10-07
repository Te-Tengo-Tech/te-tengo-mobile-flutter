import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../hogar/data/hogar_repositorio.dart';

/// Screen 13: asks before signing out; then the splash plays and the sign-in screen opens with the
/// email filled in (CA-02.4).
Future<void> cerrarSesion(BuildContext context, WidgetRef ref) async {
  final nombre = ref.read(nombreAdultoMayorProvider);
  final si = await confirmar(
    context,
    icono: Ico.logout,
    titulo: '¿Cerrar sesión?',
    texto: nombre == null
        ? 'Dejarás de recibir las alertas en este celular hasta que vuelvas a '
              'iniciar sesión.'
        : 'Dejarás de recibir las alertas de $nombre en este celular hasta que '
              'vuelvas a iniciar sesión.',
    aceptar: 'Cerrar sesión',
    cancelar: 'Cancelar',
  );
  if (!si || !context.mounted) return;
  final correo = ref.read(sesionControllerProvider)?.usuario.correo ?? '';
  final siguiente = Uri(
    path: Rutas.iniciarSesion,
    queryParameters: {'correo': correo, 'cerrada': '1'},
  ).toString();
  context.go(
    Uri(
      path: Rutas.arranque,
      queryParameters: {'siguiente': siguiente},
    ).toString(),
  );
  await ref.read(sesionControllerProvider.notifier).cerrar();
}
