import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/pc.dart';
import '../data/actualizacion_controller.dart';
import '../data/interrupcion.dart';
import '../domain/estado_actualizacion.dart';
import '../domain/versiones.dart';
import '../../../core/ui/ayuda.dart';
import 'barra_actualizacion.dart';
import 'situacion.dart';
import '../../../core/ui/marca.dart';

/// How each platform updates, behind the «?» of «Actualizaciones».
String comoSeActualiza(Canal canal) => switch (canal) {
  Canal.pwa => 'Se actualiza con internet. Te avisamos para recargarla.',
  Canal.apk =>
    'Te avisamos cuando hay una versión nueva. Android te pide confirmar.',
  Canal.play => 'Google Play la actualiza sola.',
  Canal.ios => 'Se actualiza desde App Store o TestFlight.',
};

/// Ajustes › «Acerca de Te Tengo» (screens 379 to 385): the version and the platform,
/// «Actualizaciones» (look for one, the new version with «Qué cambió» and its action, or the
/// download and its errors) and «PCs de la casa» with each PC's Te Tengo Captura (CA-43.4 to
/// CA-43.7).
class PantallaAcercaDe extends ConsumerWidget {
  const PantallaAcercaDe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionProvider);
    final info = estado.info;
    final c = context.colores;
    final conHogar = ref.watch(sesionControllerProvider)?.tieneHogar ?? false;
    final pcs = conHogar
        ? ref.watch(pcsProvider).value ?? const <Pc>[]
        : const <Pc>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Semantics(
            container: true,
            child: Row(
              children: [
                const IconoApp(tamano: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Te Tengo',
                        style: estiloTexto(22, 800, color: c.tinta),
                      ),
                      if (info != null) ...[
                        Text(
                          'Versión ${info.version}',
                          style: estiloTexto(16, 400, color: c.tinta2),
                        ),
                        Text(
                          info.plataforma,
                          style: estiloTexto(15, 400, color: c.tinta3),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (info != null) ...[
            EncabezadoSeccion(
              'Actualizaciones',
              accion: AyudaInfo(
                texto: comoSeActualiza(info.canal),
                tema: 'actualizaciones',
              ),
            ),
            const _PanelActualizaciones(),
          ],
          if (pcs.isNotEmpty) ...[
            const EncabezadoSeccion(
              'PCs de la casa',
              accion: AyudaInfo(
                texto: 'Cada PC actualiza Te Tengo Captura por su cuenta.',
                tema: 'las PCs',
              ),
            ),
            _PcsDeLaCasa(pcs: pcs, versiones: estado.versiones),
          ],
        ],
      ),
    );
  }
}

class _PanelActualizaciones extends ConsumerWidget {
  const _PanelActualizaciones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionProvider);
    final controller = ref.read(actualizacionProvider.notifier);
    final c = context.colores;
    if (estado.fase == FaseActualizacion.buscando) {
      return TarjetaActualizacion(
        child: Semantics(
          liveRegion: true,
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: c.moradoTinta,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Buscando actualizaciones…',
                  style: estiloTexto(17, 700, color: c.tinta),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final situacion = situacionDe(estado);
    if (situacion != null && situacion.nueva) {
      return _VersionNueva(estado: estado);
    }
    if (situacion != null) return TarjetaSituacion(situacion);
    final error = estado.error == ErrorActualizacion.sinInternetAlBuscar;
    final revisado = estado.revisadoEn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error)
          const Aviso(
            tono: TonoAviso.advertencia,
            icono: Ico.wifiOff,
            titulo: 'Sin internet',
            texto: 'No pudimos buscar.',
          )
        else if (revisado != null && estado.publicada != null)
          Aviso(
            tono: TonoAviso.ok,
            icono: Ico.check,
            titulo: 'Tienes la última versión',
            contenido: TextSpan(
              children: [
                const TextSpan(text: 'Revisado hoy a las '),
                TextSpan(text: hora(revisado), style: estiloCifras),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        if (error || (revisado != null && estado.publicada != null))
          const SizedBox(height: 12),
        Boton(
          'Buscar actualizaciones',
          icono: Ico.refresh,
          estilo: EstiloBoton.secundario,
          alPresionar: () => controller.buscar(MotivoBusqueda.manual),
        ),
      ],
    );
  }
}

/// The new version (screen 382): its number and size, «Qué cambió» and the action, disabled with
/// «Al cerrar la alerta.» while an alert is active (CA-43.9).
class _VersionNueva extends ConsumerWidget {
  const _VersionNueva({required this.estado});

  final EstadoActualizacion estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = estado.info!;
    final nueva = estado.nueva ?? estado.publicada!;
    final c = context.colores;
    final espera = ref.watch(interrupcionActivaProvider);
    final conTamano =
        (info.canal == Canal.apk || info.canal == Canal.play) &&
        nueva.tamanoBytes != null;
    return TarjetaActualizacion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icono(Ico.refresh, tamano: 22, color: c.moradoTinta),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Versión ${nueva.version}',
                      style: estiloTexto(17, 700, color: c.tinta),
                    ),
                    if (conTamano)
                      Text(
                        tamanoLegible(nueva.tamanoBytes!),
                        style: estiloTexto(15, 400, color: c.tinta3),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (nueva.notas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Qué cambió', style: estiloTexto(16, 700, color: c.tinta)),
            const SizedBox(height: 6),
            NotasVersion(nueva.notas),
          ],
          if (espera) ...[
            const SizedBox(height: 8),
            Text(
              'Al cerrar la alerta.',
              style: estiloTexto(15, 400, color: c.tinta3),
            ),
          ],
          const SizedBox(height: 12),
          Boton(
            textoActualizar(info, largo: true),
            icono: info.canal == Canal.ios ? Ico.download : Ico.refresh,
            alPresionar: espera
                ? null
                : ref.read(actualizacionProvider.notifier).actualizar,
          ),
        ],
      ),
    );
  }
}

/// The white card of «Acerca de» (`upd-card`), soft amber or purple for the errors.
class TarjetaActualizacion extends StatelessWidget {
  const TarjetaActualizacion({super.key, required this.child, this.tono});

  final Widget child;
  final TonoAviso? tono;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: switch (tono) {
          TonoAviso.advertencia => c.avisoSuave,
          TonoAviso.info => c.moradoSuave,
          _ => c.tarjeta,
        },
        borderRadius: BorderRadius.circular(20),
        border: tono == null ? Border.all(color: c.linea) : null,
      ),
      child: child,
    );
  }
}

/// The download, its check or an error as a card (screens 383 and 396): the same words as the
/// bar, with a full-size action.
class TarjetaSituacion extends ConsumerWidget {
  const TarjetaSituacion(this.situacion, {super.key});

  final Situacion situacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = situacion;
    final c = context.colores;
    final controller = ref.read(actualizacionProvider.notifier);
    final accion = s.accion;
    return Semantics(
      liveRegion: true,
      container: true,
      child: TarjetaActualizacion(
        tono: s.tono,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icono(
                    s.icono,
                    tamano: 22,
                    color: s.tono == TonoAviso.advertencia
                        ? c.aviso
                        : c.moradoTinta,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.titulo,
                        style: estiloTexto(17, 700, color: c.tinta),
                      ),
                      if (s.texto case final t?)
                        Text(
                          t,
                          style: s.textoMono
                              ? estiloMono(
                                  tamano: 15,
                                  peso: 400,
                                  color: c.tinta2,
                                )
                              : estiloTexto(15, 400, color: c.tinta2),
                        ),
                    ],
                  ),
                ),
                if (s.ayuda case final a?)
                  AyudaInfo(texto: a, tema: 'la descarga'),
              ],
            ),
            if (s.conPista) ...[
              const SizedBox(height: 10),
              PistaDescarga(progreso: s.indeterminado ? null : s.progreso),
            ],
            if (accion != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Boton(
                  s.textoAccion ?? '',
                  pequeno: true,
                  estilo: s.accionPrincipal
                      ? EstiloBoton.primario
                      : EstiloBoton.secundario,
                  alPresionar: switch (accion) {
                    AccionActualizacion.actualizar => controller.actualizar,
                    AccionActualizacion.cancelar => controller.cancelarDescarga,
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// «PCs de la casa» (screens 379 and 382): «Todas al día · Te Tengo Captura 0.5.0» or «1 PC con
/// versión anterior», and each PC with its Te Tengo Captura.
class _PcsDeLaCasa extends StatelessWidget {
  const _PcsDeLaCasa({required this.pcs, required this.versiones});

  final List<Pc> pcs;
  final Versiones? versiones;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    EstadoVersionPc estado(Pc pc) => estadoVersionPc(
      versiones,
      versionAgente: pc.versionAgente,
      sistemaOperativo: pc.sistemaOperativo,
    );
    final anteriores = pcs
        .where((p) => estado(p) == EstadoVersionPc.anterior)
        .length;
    final alDia = pcs.every((p) => estado(p) == EstadoVersionPc.alDia);
    final ultima = versiones?.captura(pcs.first.sistemaOperativo)?.version;
    final resumen = anteriores > 0
        ? '${contar(anteriores, 'PC', 'PCs')} con versión anterior'
        : alDia && ultima != null
        ? 'Todas al día · Te Tengo Captura $ultima'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (resumen != null) ...[
          Text(resumen, style: estiloTexto(16, 400, color: c.tinta2)),
          const SizedBox(height: 12),
        ],
        ListaTarjeta(
          children: [
            for (final pc in pcs)
              FilaLista(
                inicio: const IconoFila(Ico.pc),
                titulo: pc.nombre,
                subtituloRico: pc.versionAgente == null
                    ? null
                    : TextSpan(
                        children: [
                          TextSpan(text: 'Captura ${pc.versionAgente}'),
                          ...switch (estado(pc)) {
                            EstadoVersionPc.anterior => [
                              const TextSpan(text: ' · '),
                              TextSpan(
                                text: 'versión anterior',
                                style: estiloTexto(
                                  15,
                                  700,
                                  color: c.avisoTinta,
                                ),
                              ),
                            ],
                            EstadoVersionPc.alDia => [
                              const TextSpan(text: ' · '),
                              TextSpan(
                                text: 'al día',
                                style: estiloTexto(
                                  15,
                                  700,
                                  color: c.calmaTinta,
                                ),
                              ),
                            ],
                            EstadoVersionPc.desconocido => const <TextSpan>[],
                          },
                        ],
                      ),
                alTocar: () => context.push(Rutas.pc(pc.id)),
              ),
          ],
        ),
      ],
    );
  }
}
