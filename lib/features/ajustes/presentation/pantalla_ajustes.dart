import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/presentation/cerrar_sesion.dart';

/// Ajustes tab (screen 94).
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    // Loads the household: the sign-out dialog names the older adult.
    ref.watch(nombreAdultoMayorProvider);
    final texto = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Semantics(
            header: true,
            child: Text('Ajustes', style: texto.headlineMedium),
          ),
        ),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.user),
              titulo:
                  'Tu cuenta · ${sesion?.esTitular ?? false ? 'Titular' : 'Familiar invitado'}',
              subtitulo: sesion?.usuario.correo,
            ),
            FilaLista(
              inicio: const IconoFila(Ico.logout, peligro: true),
              titulo: 'Cerrar sesión',
              peligro: true,
              chevron: false,
              alTocar: () => cerrarSesion(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Te Tengo 1.0 · prueba piloto',
          textAlign: TextAlign.center,
          style: texto.bodySmall,
        ),
      ],
    );
  }
}
