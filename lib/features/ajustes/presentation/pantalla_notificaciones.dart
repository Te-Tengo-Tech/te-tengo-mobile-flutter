import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/push.dart';
import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/web/entorno.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../inicio/presentation/pantalla_inicio.dart';
import '../../instalar/presentation/instalar_app.dart';
import '../data/preferencias.dart';

/// Screen 96: whether this phone may show notifications and what it is told about.
class PantallaNotificaciones extends ConsumerWidget {
  const PantallaNotificaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activas = ref.watch(notificacionesActivasProvider).value;
    final recepcion = ref.watch(recepcionPushProvider);
    final celularSinAlertas = ref.watch(celularSinAlertasProvider);
    final familiaSinAlertas = ref.watch(familiaSinAlertasProvider);
    final preferencias =
        ref.watch(preferenciasProvider).value ??
        const PreferenciasNotificaciones();
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final espera =
        ref.watch(avisoProvider).value?.esperaMinutos ??
        ConfiguracionAviso.esperaPredeterminada;
    final titular = ref.watch(esTitularProvider);
    final control = ref.read(preferenciasProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (ref.watch(entornoNavegadorProvider).debeInstalar)
            const AvisoInstalarApp(separacion: 0)
          else if (activas == false)
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.bellOff,
              titulo: 'Desactivadas en tu celular',
              texto:
                  'Sin permiso de notificaciones no te enterarás de una caída '
                  'con la app cerrada.',
              accion: Boton(
                'Activar notificaciones',
                estilo: EstiloBoton.tinta,
                pequeno: true,
                alPresionar: () => activarNotificaciones(context, ref),
              ),
            )
          // The confirmation only once the backend has this phone (contract §7), never from the
          // permission alone.
          else if (activas == true && (celularSinAlertas || familiaSinAlertas))
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.bellOff,
              titulo: familiaSinAlertas
                  ? 'Nadie de la familia recibe las alertas'
                  : 'Este celular no recibe las alertas',
              texto:
                  'Sin ellas no te enterarás de una caída cuando tengas la '
                  'app cerrada.',
              accion: Boton(
                'Activar notificaciones',
                estilo: EstiloBoton.tinta,
                pequeno: true,
                alPresionar: () => activarNotificaciones(context, ref),
              ),
            )
          else if (activas == true && recepcion == RecepcionPush.activa)
            const Aviso(
              tono: TonoAviso.ok,
              icono: Ico.bell,
              titulo: 'Notificaciones activadas',
              texto: 'Recibirás las alertas aunque tengas la app cerrada.',
            ),
          const EncabezadoSeccion('Qué te avisamos en este celular'),
          ListaTarjeta(
            children: [
              const _FilaInterruptor(
                titulo: 'Caídas',
                subtitulo: 'Siempre activas. No se pueden silenciar.',
                valor: true,
              ),
              _FilaInterruptor(
                titulo: 'Movimientos inestables',
                subtitulo: 'Severidad media',
                valor: preferencias.inestables,
                alCambiar: (v) =>
                    control.cambiar(preferencias.con(inestables: v)),
              ),
              _FilaInterruptor(
                titulo: 'Estado de la cámara',
                subtitulo:
                    'Desconectada, reconectada o detección no confiable. '
                    'Siempre activas, para que $nombre no quede sin monitoreo.',
                valor: true,
              ),
              _FilaInterruptor(
                titulo: 'Fin de una pausa',
                subtitulo: 'Cuando la cámara se reactiva sola',
                valor: preferencias.finPausa,
                alCambiar: (v) =>
                    control.cambiar(preferencias.con(finPausa: v)),
              ),
            ],
          ),
          const EncabezadoSeccion('Escalamiento'),
          ListaTarjeta(
            children: [
              FilaLista(
                inicio: const IconoFila(Ico.clock),
                titulo: 'Esperar $espera minutos antes de escalar',
                subtitulo: 'Se define en el orden de aviso de la familia',
                fin: titular
                    ? null
                    : const Icono(Ico.lock, tamano: 22, color: Colores.tinta3),
                alTocar: () => context.push(Rutas.ordenAviso),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Row with a switch (`.switch`); without [alCambiar] the switch is fixed.
class _FilaInterruptor extends StatelessWidget {
  const _FilaInterruptor({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    this.alCambiar,
  });

  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool>? alCambiar;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: FilaLista(
      titulo: titulo,
      subtitulo: subtitulo,
      chevron: false,
      fin: Switch(
        value: valor,
        onChanged: alCambiar,
        activeThumbColor: Colors.white,
        activeTrackColor: Colores.calma,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colores.linea2,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
  );
}
