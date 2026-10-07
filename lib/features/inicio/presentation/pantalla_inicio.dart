import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'tarjeta_adulto_mayor.dart';

/// Inicio tab (screens 25–27 and 102).
class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionActualProvider);
    final hogar = ref.watch(hogarProvider);
    final camara = ref.watch(camarasProvider).value?.firstOrNull;
    final texto = Theme.of(context).textTheme;
    final hoy = ref.watch(relojProvider)();
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(hogarProvider)
          ..invalidate(camarasProvider);
        await ref.read(hogarProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          Text(mayusculaInicial(fechaLarga(hoy)), style: texto.bodySmall),
          Semantics(
            header: true,
            child: Text(
              'Hola, ${sesion.usuario.nombrePila}',
              style: texto.headlineMedium,
            ),
          ),
          const SizedBox(height: 14),
          switch (hogar) {
            AsyncData(value: final h) => TarjetaAdultoMayor(
              adulto: h.adultoMayor,
              estado: estadoTarjeta(h, camara),
              accion: !h.conConsentimiento && sesion.esTitular
                  ? Boton(
                      'Registrar consentimiento',
                      alPresionar: () => context.push(Rutas.consentimiento),
                    )
                  : null,
            ),
            AsyncError(:final error) => MensajeProblema(error),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}
