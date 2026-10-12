import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/barras_estado.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/actualizacion_controller.dart';
import '../domain/estado_actualizacion.dart';
import '../domain/versiones.dart';
import '../../../core/ui/ayuda.dart';
import 'pantalla_acerca_de.dart';
import 'situacion.dart';

/// «Actualiza Te Tengo para seguir recibiendo alertas» (screens 375, 377, 378, 394 and 398): the
/// installed version is below `versionMinima` (CA-43.8). It blocks politely: the platform's path
/// to update and «Llamar a Rosa» stay at hand, and an active alert is still one tap away (the
/// alert and live view screens are never covered).
class PantallaVersionObligatoria extends ConsumerWidget {
  const PantallaVersionObligatoria({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionProvider);
    final info = estado.info;
    if (info == null) return const SizedBox.shrink();
    final c = context.colores;
    final texto = Theme.of(context).textTheme;
    final conHogar = ref.watch(sesionControllerProvider)?.tieneHogar ?? false;
    final adulto = conHogar
        ? ref.watch(hogarProvider).value?.adultoMayor
        : null;
    final nombre = adulto?.nombrePila;
    final tienda = info.tienda;
    final situacion = situacionDe(estado);
    final enCurso = situacion != null && !situacion.nueva;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            if (conHogar) const FranjaAlertaActiva(),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: IconoApp(tamano: 64),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                'Actualiza Te Tengo para seguir recibiendo alertas',
                style: texto.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Tienes la ${info.version}. Toma un minuto.',
                    style: estiloTexto(16, 400, color: c.tinta2),
                  ),
                ),
                const AyudaInfo(
                  texto:
                      'Esta versión ya no recibe las alertas de forma segura. '
                      'Quienes ya actualizaron las siguen recibiendo.',
                  tema: 'por qué actualizar',
                ),
              ],
            ),
            // The APK's download and its errors, as in «Acerca de».
            if (enCurso) ...[
              const SizedBox(height: 16),
              TarjetaSituacion(situacion),
            ],
            const SizedBox(height: 24),
            if (!enCurso)
              Boton(
                tienda == null ? textoActualizar(info) : 'Abrir la tienda',
                icono: Ico.download,
                alPresionar: ref
                    .read(actualizacionProvider.notifier)
                    .actualizar,
              ),
            if (nombre != null) ...[
              const SizedBox(height: 12),
              Boton(
                'Llamar a $nombre',
                icono: Ico.phone,
                estilo: EstiloBoton.secundario,
                alPresionar: () => ref.read(llamarProvider)(adulto?.telefono),
              ),
            ],
            if (tienda != null) ...[
              const SizedBox(height: 12),
              Text(
                'Se abre $tienda.',
                style: estiloTexto(15, 400, color: c.tinta3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// «Actualizando…» (screen 356): the web app reloads with the new version.
class PantallaActualizando extends StatelessWidget {
  const PantallaActualizando({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Material(
      color: c.fondo,
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconoApp(tamano: 72),
              const SizedBox(height: 20),
              Text(
                'Actualizando…',
                style: estiloTexto(18, 800, color: c.tinta),
              ),
              const SizedBox(height: 14),
              const SizedBox(width: 120, child: _Pista()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pista extends StatelessWidget {
  const _Pista();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final quieta = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: quieta ? 1 : null,
        minHeight: 6,
        backgroundColor: c.linea,
        color: c.moradoTinta,
      ),
    );
  }
}

/// The screen the guard shows over the app now, if any.
enum Cubierta { ninguna, obligatoria, actualizando }

Cubierta cubiertaPara(EstadoActualizacion e, {required bool rutaLibre}) {
  if (e.info?.canal == Canal.pwa && e.fase == FaseActualizacion.recargando) {
    return Cubierta.actualizando;
  }
  if (e.obligatoria && !rutaLibre) return Cubierta.obligatoria;
  return Cubierta.ninguna;
}
