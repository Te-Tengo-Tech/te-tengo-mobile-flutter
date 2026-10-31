import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';

/// Screen 05: the account is ready and the two setup steps follow (CA-01.1, docs/ONBOARDING.md).
/// The PC, the family and the notifications are not steps: «Todo listo» and Inicio offer them.
class PantallaCuentaCreada extends ConsumerWidget {
  const PantallaCuentaCreada({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nombre =
        ref.watch(sesionControllerProvider)?.usuario.nombrePila ?? '';
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconoGrande(
                          icono: Ico.check,
                          fondo: context.colores.calmaSuave,
                          color: context.colores.calmaTinta,
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          header: true,
                          child: Text(
                            'Tu cuenta está lista, $nombre.',
                            style: texto.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '2 pasos más:',
                          style: texto.bodyLarge?.copyWith(
                            color: context.colores.tinta2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const PasosNumerados([
                          ('Datos de la persona', null),
                          ('Consentimiento informado', null),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
              Boton(
                'Empezar',
                alPresionar: () => context.go(Rutas.configPersona),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
