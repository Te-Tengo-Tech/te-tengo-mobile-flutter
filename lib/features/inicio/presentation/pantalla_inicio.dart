import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/push.dart';
import '../../../app/rutas.dart';
import '../../historial/presentation/pantalla_historial.dart';
import '../../historial/presentation/resumen_semanal.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/web/entorno.dart';
import '../../instalar/presentation/instalar_app.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/fila_camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import 'tarjeta_adulto_mayor.dart';

/// Inicio tab (screens 25–27 and 102): greeting, notifications notice (CA-16.3), the older adult
/// status card, the camera and the live view. While it is on screen it also asks for the active
/// alert every [BuscarAlertaActiva.cada], so an alert whose push never arrived still opens.
class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const BuscarAlertaActiva(child: _ContenidoInicio());
}

class _ContenidoInicio extends ConsumerWidget {
  const _ContenidoInicio();

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
    final celularSinAlertas = ref.watch(celularSinAlertasProvider);
    final familiaSinAlertas = ref.watch(familiaSinAlertasProvider);
    final alerta = ref.watch(alertaActivaProvider).value;
    final debeInstalar = ref.watch(entornoNavegadorProvider).debeInstalar;
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
          // On an iPhone browser tab notifications cannot be turned on: install first.
          if (debeInstalar)
            const AvisoInstalarApp()
          else if (notificaciones == false ||
              celularSinAlertas ||
              familiaSinAlertas) ...[
            // What the backend says, not only the permission: this phone or the whole family may
            // be left without the alerts (contract §2 `dispositivosActivos`, §7).
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.bellOff,
              titulo: familiaSinAlertas
                  ? 'Nadie de la familia recibe las alertas'
                  : notificaciones == false
                  ? 'Activa las notificaciones'
                  : 'Este celular no recibe las alertas',
              texto: notificaciones == false
                  ? 'Están desactivadas en tu celular. Sin ellas no te enterarás '
                        'de una caída cuando tengas la app cerrada.'
                  : 'Sin ellas no te enterarás de una caída cuando tengas la '
                        'app cerrada.',
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
          if (hogar.value?.conConsentimiento ?? false)
            SemanaEnInicio(
              alVerResumen: () {
                ref
                    .read(seccionHistorialProvider.notifier)
                    .elegir(SeccionHistorial.resumen);
                context.go(Rutas.historial);
              },
              alAbrir: (a) => context.push(
                a.activa ? Rutas.alerta(a.id) : Rutas.detalleAlerta(a.id),
              ),
            ),
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

/// Asks for the notification permission, registers this phone and confirms it only once the
/// backend has it (CA-16.3); otherwise the notice in Inicio and Notificaciones stays.
Future<void> activarNotificaciones(BuildContext context, WidgetRef ref) async {
  final activas = await ref.read(permisoNotificacionesProvider).activar();
  ref.invalidate(notificacionesActivasProvider);
  if (!activas) return;
  // On iOS the push token only exists once notifications are allowed.
  final recepcion = await ref.read(gestorPushProvider).registrar(forzar: true);
  ref.invalidate(hogarProvider);
  if (recepcion == RecepcionPush.activa && context.mounted) {
    mostrarToast(
      context,
      titulo: 'Notificaciones activadas',
      texto: 'Te llegarán las alertas aunque la app esté cerrada.',
      icono: Ico.bell,
    );
  }
}

/// While its screen is on top, its tab visible and the app in the foreground, asks for the active
/// alert every [cada]: a push may not arrive (CA-16.4), and the tab shell opens a new active alert
/// by itself.
class BuscarAlertaActiva extends ConsumerStatefulWidget {
  const BuscarAlertaActiva({super.key, required this.child});

  /// [implementation choice]: often enough for an alert that lost its push, cheap for the backend.
  static const cada = Duration(seconds: 20);

  final Widget child;

  @override
  ConsumerState<BuscarAlertaActiva> createState() => _BuscarAlertaActivaState();
}

class _BuscarAlertaActivaState extends ConsumerState<BuscarAlertaActiva> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer.periodic(BuscarAlertaActiva.cada, (_) => _buscar());
  }

  void _buscar() {
    if (!mounted) return;
    final ciclo = WidgetsBinding.instance.lifecycleState;
    final enPrimerPlano = ciclo == null || ciclo == AppLifecycleState.resumed;
    // Tabs that are not shown keep their screens in the tree with tickers off.
    final visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (enPrimerPlano && visible) ref.invalidate(alertaActivaProvider);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
