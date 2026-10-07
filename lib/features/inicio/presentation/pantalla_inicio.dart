import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/fila_camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'tarjeta_adulto_mayor.dart';

/// Inicio tab (screens 25–27 and 102): greeting, notifications notice (CA-16.3), the older adult
/// status card, the camera and the live view.
class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    // Signing out: the guards are about to leave this screen.
    if (sesion == null) return const SizedBox.shrink();
    final hogar = ref.watch(hogarProvider);
    final camaras = ref.watch(camarasProvider);
    final camara = camaras.value?.firstOrNull;
    final texto = Theme.of(context).textTheme;
    final hoy = ref.watch(relojProvider)();
    final notificaciones = ref.watch(notificacionesActivasProvider).value;
    final alerta = ref.watch(alertaActivaProvider).value;
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(hogarProvider)
          ..invalidate(camarasProvider)
          ..invalidate(alertaActivaProvider)
          ..invalidate(notificacionesActivasProvider);
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
          if (notificaciones == false) ...[
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.bellOff,
              titulo: 'Activa las notificaciones',
              texto:
                  'Están desactivadas en tu celular. Sin ellas no te enterarás '
                  'de una caída cuando tengas la app cerrada.',
              accion: Boton(
                'Activar notificaciones',
                estilo: EstiloBoton.tinta,
                pequeno: true,
                alPresionar: () => activarNotificaciones(context, ref),
              ),
            ),
            const SizedBox(height: 12),
          ],
          switch (hogar) {
            AsyncData(value: final h) => TarjetaAdultoMayor(
              adulto: h.adultoMayor,
              estado: estadoTarjeta(h, camara, alerta: alerta),
              accion: alerta != null
                  ? Boton(
                      'Ver la alerta',
                      estilo: alerta.esCaida
                          ? EstiloBoton.peligro
                          : EstiloBoton.tinta,
                      alPresionar: () => context.push(Rutas.alerta(alerta.id)),
                    )
                  : _accionTarjeta(
                      context,
                      h.conConsentimiento,
                      camara,
                      titular: sesion.esTitular,
                    ),
            ),
            AsyncError(:final error) => MensajeProblema(error),
            _ => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
          if (camaras case AsyncError(:final error)) ...[
            const SizedBox(height: 16),
            MensajeProblema(error),
          ],
          if (camara != null && hogar.value != null) ...[
            EncabezadoSeccion(
              'Cámara',
              accion: Enlace(
                'Ver detalle',
                alTocar: () => context.push(Rutas.camara(camara.id)),
              ),
            ),
            ListaTarjeta(
              children: [
                FilaCamara(
                  camara: camara,
                  estado: camara.estadoVisible(
                    conConsentimiento: hogar.value!.conConsentimiento,
                  ),
                  alTocar: () => context.push(Rutas.camara(camara.id)),
                ),
                FilaLista(
                  inicio: const IconoFila(Ico.video),
                  titulo: 'Ver en vivo',
                  subtitulo: 'Cuando quieras. Cada acceso queda registrado.',
                  alTocar: () => context.push(
                    Uri(
                      path: Rutas.vivo,
                      queryParameters: {'camara': camara.id},
                    ).toString(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Boton? _accionTarjeta(
    BuildContext context,
    bool conConsentimiento,
    Camara? camara, {
    required bool titular,
  }) {
    if (!conConsentimiento) {
      return titular
          ? Boton(
              'Registrar consentimiento',
              alPresionar: () => context.push(Rutas.consentimiento),
            )
          : null;
    }
    final estado = camara?.estadoVisible(conConsentimiento: true);
    if (estado == EstadoVisible.desconectada ||
        estado == EstadoVisible.noConfiable) {
      return Boton(
        'Ver qué revisar',
        estilo: EstiloBoton.secundario,
        alPresionar: () => context.push(Rutas.camara(camara!.id)),
      );
    }
    return null;
  }
}

/// Asks for the notification permission and confirms it (CA-16.3).
Future<void> activarNotificaciones(BuildContext context, WidgetRef ref) async {
  final activas = await ref.read(permisoNotificacionesProvider).activar();
  ref.invalidate(notificacionesActivasProvider);
  if (activas && context.mounted) {
    mostrarToast(
      context,
      titulo: 'Notificaciones activadas',
      texto: 'Te llegarán las alertas aunque la app esté cerrada.',
      icono: Ico.bell,
    );
  }
}
