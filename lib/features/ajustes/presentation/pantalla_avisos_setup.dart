import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../inicio/presentation/pantalla_inicio.dart';

/// Setup step 5 of 5 (screen 27, «Avisos»): explains why before the phone asks for the
/// notification permission, so a fall is not missed.
class PantallaAvisosSetup extends ConsumerWidget {
  const PantallaAvisosSetup({super.key, this.invitado});

  /// Email invited in step 4, passed on to «Todo listo».
  final String? invitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final activas = ref.watch(notificacionesActivasProvider).value ?? false;
    final permiso = ref.watch(permisoNotificacionesProvider);
    return Scaffold(
      appBar: CabeceraConfiguracion(
        paso: 5,
        titulo: 'Avisos',
        escala: MediaQuery.textScalerOf(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Que no se te pase ninguna caída',
              style: texto.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te llegará la alerta aunque tengas la app cerrada o el celular en '
            'silencio.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
          ListaTarjeta(
            children: [
              FilaLista(
                inicio: const IconoFila(Ico.bell),
                titulo: 'Notificaciones',
                subtitulo: 'Para recibir las alertas',
                fin: activas
                    ? const PermisoActivado()
                    : Boton(
                        'Permitir',
                        estilo: EstiloBoton.secundario,
                        pequeno: true,
                        alPresionar: () => activarNotificaciones(context, ref),
                      ),
              ),
              if (permiso.ajustesDeSonido)
                const FilaSonarEnSilencio(
                  icono: true,
                  subtitulo: 'Las caídas suenan igual',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Puedes cambiarlo después en Ajustes › Notificaciones.',
            style: texto.bodySmall,
          ),
          const SizedBox(height: 20),
          Boton(
            activas ? 'Continuar' : 'Continuar sin activar todo',
            alPresionar: () => context.go(
              Uri(
                path: Rutas.configListo,
                queryParameters: {'invitado': ?invitado},
              ).toString(),
            ),
          ),
        ],
      ),
    );
  }
}

/// «✓ Activadas» (`.perm-ok`): the permission is already granted.
class PermisoActivado extends StatelessWidget {
  const PermisoActivado({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icono(Ico.check, tamano: 18, color: Colores.calmaTinta),
      const SizedBox(width: 6),
      Text('Activadas', style: estiloTexto(15, 700, color: Colores.calmaTinta)),
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
