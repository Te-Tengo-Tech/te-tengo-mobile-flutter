import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/push.dart';
import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/web/entorno.dart';
import '../../../l10n/l10n.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../inicio/presentation/pantalla_inicio.dart';
import '../../instalar/presentation/instalar_app.dart';
import '../data/preferencias.dart';
import 'permiso_avisos.dart';

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
    final espera =
        ref.watch(avisoProvider).value?.esperaMinutos ??
        ConfiguracionAviso.esperaPredeterminada;
    final titular = ref.watch(esTitularProvider);
    final control = ref.read(preferenciasProvider.notifier);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.notificacionesTitulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (ref.watch(entornoNavegadorProvider).debeInstalar)
            const AvisoInstalarApp(separacion: 0)
          else if (activas == false)
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.bellOff,
              titulo: l.notificacionesDesactivadasTitulo,
              texto: l.notificacionesDesactivadasTexto,
              accion: Boton(
                l.notificacionesActivar,
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
                  ? l.notificacionesFamiliaSinAlertas
                  : l.notificacionesCelularSinAlertas,
              texto: l.notificacionesSinAlertasTexto,
              accion: Boton(
                l.notificacionesActivar,
                estilo: EstiloBoton.tinta,
                pequeno: true,
                alPresionar: () => activarNotificaciones(context, ref),
              ),
            )
          else if (activas == true && recepcion == RecepcionPush.activa)
            Aviso(
              tono: TonoAviso.ok,
              icono: Ico.bell,
              titulo: l.notificacionesActivadas,
            ),
          EncabezadoSeccion(l.notificacionesAvisosEnCelular),
          ListaTarjeta(
            children: [
              _FilaInterruptor(
                titulo: l.notificacionesCaidas,
                subtitulo: l.notificacionesSiempreActivas,
                valor: true,
              ),
              if (ref.watch(permisoNotificacionesProvider).ajustesDeSonido)
                FilaSonarEnSilencio(subtitulo: l.notificacionesSonarSubtitulo),
              _FilaInterruptor(
                titulo: l.notificacionesInestables,
                subtitulo: l.notificacionesSeveridadMedia,
                valor: preferencias.inestables,
                alCambiar: (v) =>
                    control.cambiar(preferencias.con(inestables: v)),
              ),
              _FilaInterruptor(
                titulo: l.notificacionesEstadoCamara,
                subtitulo: l.notificacionesEstadoCamaraTexto,
                valor: true,
              ),
              _FilaInterruptor(
                titulo: l.notificacionesFinPausa,
                subtitulo: l.notificacionesFinPausaTexto,
                valor: preferencias.finPausa,
                alCambiar: (v) =>
                    control.cambiar(preferencias.con(finPausa: v)),
              ),
            ],
          ),
          EncabezadoSeccion(l.notificacionesSiNadieAtiende),
          ListaTarjeta(
            children: [
              FilaLista(
                inicio: const IconoFila(Ico.clock),
                titulo: l.notificacionesAvisarSecundario(espera),
                fin: titular
                    ? null
                    : Icono(Ico.lock, tamano: 22, color: context.colores.icono),
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
        inactiveTrackColor: context.colores.pistaApagada,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
  );
}
