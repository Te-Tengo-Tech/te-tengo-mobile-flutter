import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';

/// «✓ Activadas» (`.perm-ok`): the permission is already granted.
class PermisoActivado extends StatelessWidget {
  const PermisoActivado({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icono(Ico.check, tamano: 18, color: context.colores.calmaTinta),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          'Activadas',
          style: estiloTexto(15, 700, color: context.colores.calmaTinta),
        ),
      ),
    ],
  );
}

/// «Sonar en silencio»: lets the falls ring with the phone in silent mode.
///
/// Only the system settings can let the alerts through silent mode (the «Alertas» channel on
/// Android); iOS critical alerts need an Apple entitlement and a critical push. So «Permitir» opens
/// the app's settings in the system and the row never claims it is on: the app cannot read that
/// choice back.
class FilaSonarEnSilencio extends ConsumerWidget {
  const FilaSonarEnSilencio({
    super.key,
    required this.subtitulo,
    this.icono = false,
  });

  final String subtitulo;

  /// With the warning icon of the setup step.
  final bool icono;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FilaLista(
    inicio: icono ? const IconoFila(Ico.warn) : null,
    titulo: 'Sonar en silencio',
    subtitulo: subtitulo,
    fin: Boton(
      'Permitir',
      estilo: EstiloBoton.secundario,
      pequeno: true,
      alPresionar: () =>
          ref.read(permisoNotificacionesProvider).abrirAjustesDeSonido(),
    ),
  );
}
