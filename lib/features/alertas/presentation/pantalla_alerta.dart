import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/plegable.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/domain/camara.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../hogar/domain/hogar.dart';
import '../../../l10n/l10n.dart';
import '../../vivo/data/vista_en_vivo_repositorio.dart';
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'clip_evento.dart';
import 'linea_de_tiempo.dart';
import 'marcar_alerta.dart';
import 'textos_alerta.dart';

/// Alert ids already opened in this run, so an active alert opens by itself only once (CA-16.4).
class AlertasVistas extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void marcar(String id) {
    if (!state.contains(id)) state = {...state, id};
  }
}

final alertasVistasProvider = NotifierProvider<AlertasVistas, Set<String>>(
  AlertasVistas.new,
);

/// Full-screen alert (screens 45–48, 50–52): kind and severity, headline, room, time and elapsed
/// time, call and live view, what to do now, the clip and the record (US-16, US-17).
class PantallaAlerta extends ConsumerStatefulWidget {
  const PantallaAlerta({super.key, required this.alertaId});

  final String alertaId;

  /// While active, the alert is refreshed to follow confirmation, recovery and escalation.
  static const refresco = Duration(seconds: 10);

  @override
  ConsumerState<PantallaAlerta> createState() => _PantallaAlertaState();
}

class _PantallaAlertaState extends ConsumerState<PantallaAlerta> {
  Timer? _reloj;
  bool _preparada = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(alertasVistasProvider.notifier).marcar(widget.alertaId),
    );
    // Whoever opens an alert is likely to watch the room: the camera gets ready, once.
    ref.listenManual(alertaProvider(widget.alertaId), (_, a) {
      if (a.value case final a? when a.activa && !_preparada) {
        _preparada = true;
        prepararVivo(ref, a.camaraId);
      }
    }, fireImmediately: true);
    _reloj = Timer.periodic(PantallaAlerta.refresco, (_) {
      if (ref.read(alertaProvider(widget.alertaId)).value?.activa ?? false) {
        ref.invalidate(alertaProvider(widget.alertaId));
      }
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerta = ref.watch(alertaProvider(widget.alertaId));
    final hogar = ref.watch(hogarProvider);
    ref.listen(alertaProvider(widget.alertaId), (_, a) {
      // Marked by someone: the detail shows who attended it and when.
      if (a.value case final a? when !a.activa) {
        context.pushReplacement(Rutas.detalleAlerta(a.id));
      }
    });
    return switch ((alerta, hogar)) {
      (AsyncData(value: final a), AsyncData(value: final h)) => _Alerta(
        alerta: a,
        hogar: h,
      ),
      (AsyncError(:final error), _) ||
      (_, AsyncError(:final error)) => Scaffold(
        appBar: AppBar(),
        body: ErrorDePantalla(
          error: error,
          alReintentar: () =>
              ref.refresh(alertaProvider(widget.alertaId).future),
        ),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _Alerta extends ConsumerWidget {
  const _Alerta({required this.alerta, required this.hogar});

  final Alerta alerta;
  final Hogar hogar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caida = alerta.esCaida;
    final fondo = caida ? Colores.caida : Colores.inestable;
    // The flood keeps its severity color in dark mode too, with the light ink on yellow.
    final tinta = caida ? Colors.white : Colores.tinta;
    final adulto = hogar.adultoMayor;
    final nombre = adulto.nombrePila;
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final espera = esperaDe(ref);
    final escalamiento = _Escalamiento.de(
      alerta,
      miembros: miembros,
      espera: espera,
      yo: ref.watch(sesionControllerProvider)?.usuario.id,
    );
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: caida ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: fondo,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: fondo,
              foregroundColor: tinta,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                tooltip: l.alertaCerrarTooltip,
                icon: Icono(Ico.x, color: tinta),
                onPressed: () => context.go(Rutas.inicio),
              ),
            ),
            SliverToBoxAdapter(
              // The flood keeps its severity color in dark mode: its buttons and notices stay light.
              child: Theme(
                data: temaClaroTeTengo,
                child: _Heroe(alerta: alerta, adulto: adulto, color: tinta),
              ),
            ),
            // The sheet takes its own height (folds open and close inside it); the ground below
            // fills the rest of the screen.
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: context.colores.fondo,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Only what asks for an action stays in view (`help`, `escBlock`).
                    if (caida) ...[
                      TarjetaBanda(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l.alertaNoContesta(nombre),
                              style: texto.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Boton(
                              l.alertaLlamarSamu,
                              icono: Ico.phone,
                              estilo: EstiloBoton.secundario,
                              alPresionar: () =>
                                  ref.read(llamarProvider)('106'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (escalamiento.pideAccion) ...[
                      escalamiento.aviso(
                        context,
                        titular: ref.watch(esTitularProvider),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ListaTarjeta(
                      children: [
                        FilaPlegable(
                          icono: Ico.video,
                          titulo: l.alertaClipTitulo,
                          resumen: alerta.clip == EstadoClip.disponible
                              ? l.alertaClipResumen
                              : l.alertaClipNoGuardado,
                          // An unstable movement is understood by watching it.
                          abierta: !caida,
                          aRas: true,
                          child: ClipEvento(alerta: alerta, aRas: true),
                        ),
                        FilaPlegable(
                          icono: Ico.info,
                          titulo: l.alertaMasDetalles,
                          resumen: l.alertaMasDetallesResumen,
                          child: _MasDetalles(
                            alerta: alerta,
                            adulto: adulto,
                            escalamiento: escalamiento.pideAccion
                                ? null
                                : escalamiento.aviso(
                                    context,
                                    titular: ref.watch(esTitularProvider),
                                  ),
                            linea: itemsDeAlerta(
                              l,
                              alerta,
                              nombreAdultoMayor: nombre,
                              avisados: avisadosDe(l, miembros),
                              secundario: secundarioDe(miembros),
                              esperaMinutos: espera,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: ColoredBox(color: context.colores.fondo),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: context.colores.fondo.withValues(alpha: .97),
            border: Border(top: BorderSide(color: context.colores.linea)),
          ),
          child: SafeArea(
            top: false,
            child: Boton(
              l.alertaMarcar,
              icono: Ico.check,
              alPresionar: () => marcarAlerta(context, alerta),
            ),
          ),
        ),
      ),
    );
  }
}

/// «Más detalles» of the alert: address, phone, firefighters (falls), what the detection does next,
/// who is told next and the record.
class _MasDetalles extends StatelessWidget {
  const _MasDetalles({
    required this.alerta,
    required this.adulto,
    required this.escalamiento,
    required this.linea,
  });

  final Alerta alerta;
  final AdultoMayor adulto;

  /// Who is told next, when it asks for nothing now.
  final Widget? escalamiento;
  final List<ItemLinea> linea;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final telefono = adulto.telefono;
    final porque = !alerta.esCaida
        ? l.alertaPorqueInestable
        : alerta.recuperadaEn != null
        ? l.alertaPorqueSeLevanto
        : alerta.confirmada
        ? l.alertaPorqueConfirmada
        : l.alertaPorqueComprobando;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DatosTarjeta([
          FilaDato(clave: l.alertaDireccion, valor: adulto.direccion),
          if (telefono != null)
            FilaDato(clave: l.alertaTelefono, valor: telefono, mono: true),
          if (alerta.esCaida)
            FilaDato(clave: l.alertaBomberos, valor: '116', mono: true),
        ]),
        const SizedBox(height: 8),
        Text(porque, style: texto.bodyMedium),
        if (alerta.esCaida && alerta.origenInestable) ...[
          const SizedBox(height: 12),
          Aviso(
            tono: TonoAviso.neutral,
            icono: Ico.unsteady,
            titulo: l.alertaEmpezoInestableTitulo,
            contenido: textoConHora(
              l.alertaEmpezoInestableTexto(
                context.formato.hora(alerta.ocurridaEn),
                conArticulo(alerta.habitacion),
                alerta.habitacion,
              ),
              context.formato.hora(alerta.ocurridaEn),
            ),
          ),
        ],
        if (escalamiento case final e?) ...[const SizedBox(height: 8), e],
        const SizedBox(height: 12),
        LineaDeTiempo(linea),
      ],
    );
  }
}

/// Who is told next and when (US-20, `escBlock`). A notice that asks to act (the alert was escalated,
/// or there is no secondary contact) stays in view; the plain «if nobody marks it…» line goes inside
/// «Más detalles».
class _Escalamiento {
  const _Escalamiento._(
    this.alerta, {
    required this.espera,
    required this.principal,
    required this.secundario,
    required this.soySecundario,
    required this.soyPrincipal,
    required this.hayMiembros,
  });

  factory _Escalamiento.de(
    Alerta alerta, {
    required List<MiembroFamilia> miembros,
    required int espera,
    required String? yo,
  }) {
    MiembroFamilia? con(PapelAviso p) =>
        miembros.where((m) => m.papel == p).firstOrNull;
    final principal = con(PapelAviso.principal)?.familiar;
    final secundario = con(PapelAviso.secundario)?.familiar;
    return _Escalamiento._(
      alerta,
      espera: espera,
      principal: principal,
      secundario: secundario,
      soySecundario: secundario != null && secundario.usuarioId == yo,
      soyPrincipal: principal != null && principal.usuarioId == yo,
      hayMiembros: miembros.isNotEmpty,
    );
  }

  final Alerta alerta;
  final int espera;
  final Familiar? principal;
  final Familiar? secundario;
  final bool soySecundario;
  final bool soyPrincipal;
  final bool hayMiembros;

  /// Escalated, or nobody else to tell: the family has to do something.
  bool get pideAccion =>
      hayMiembros && (alerta.escaladaEn != null || secundario == null);

  Widget aviso(BuildContext context, {required bool titular}) {
    final escalada = alerta.escaladaEn;
    final secundario = this.secundario;
    final l = context.l10n;
    final formato = context.formato;
    final agregar = titular
        ? (String texto) => Boton(
            texto,
            estilo: EstiloBoton.tinta,
            pequeno: true,
            alPresionar: () => context.push(Rutas.invitar),
          )
        : null;
    if (escalada != null && secundario != null) {
      return soySecundario
          ? Aviso(
              tono: TonoAviso.info,
              icono: Ico.users,
              titulo: l.alertaTeTocaTitulo,
              contenido: textoConHora(
                l.alertaTeTocaTexto(espera, formato.hora(escalada)),
                formato.hora(escalada),
              ),
            )
          : Aviso(
              tono: TonoAviso.info,
              icono: Ico.users,
              titulo: l.alertaAvisamosA(secundario.nombre),
              contenido: textoConHora(
                l.alertaAvisamosTexto(formato.hora(escalada)),
                formato.hora(escalada),
              ),
            );
    }
    if (escalada != null) {
      return Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.warn,
        titulo: l.alertaNoHayAQuienTitulo,
        texto: soyPrincipal
            ? l.alertaSinRespuestaTuya(espera)
            : l.alertaSinRespuestaDe(espera, principal?.nombrePila ?? ''),
        accion: agregar?.call(l.alertaAgregarSecundario),
      );
    }
    if (secundario == null) {
      return Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.warn,
        titulo: l.alertaSinSecundarioTitulo,
        texto: l.alertaSinSecundarioTexto,
        accion: agregar?.call(l.alertaAgregarContacto),
      );
    }
    final limite = formato.hora(
      alerta.ocurridaEn.add(Duration(minutes: espera)),
    );
    return _LineaRica(
      Ico.clock,
      textoConHora(
        soySecundario
            ? l.alertaLimiteSoySecundario(principal?.nombrePila ?? '', limite)
            : l.alertaLimiteSecundario(limite, secundario.nombre),
        limite,
        estilo: _limite,
      ),
    );
  }
}

final _limite = estiloMono(tamano: 16, peso: 700);

class _LineaRica extends StatelessWidget {
  const _LineaRica(this.icono, this.texto);

  final Ico icono;
  final InlineSpan texto;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icono(icono, tamano: 20, color: context.colores.icono),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text.rich(texto, style: Theme.of(context).textTheme.bodyMedium),
      ),
    ],
  );
}

/// Top of the alert, on the color of the event.
class _Heroe extends ConsumerWidget {
  const _Heroe({
    required this.alerta,
    required this.adulto,
    required this.color,
  });

  final Alerta alerta;
  final AdultoMayor adulto;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caida = alerta.esCaida;
    final nombre = adulto.nombrePila;
    final ahora = ref.watch(relojProvider)();
    final minutos = ahora.difference(alerta.ocurridaEn).inMinutes;
    final l = context.l10n;
    final etiqueta = caida
        ? l.alertaEtiquetaCaidaUrgente
        : l.alertaEtiquetaInestableMedia;
    final telefono = adulto.telefono;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only what the backend says (`estadoAviso`): «Seguimos reintentando» only while it does.
          if (alerta.notificadaEn == null &&
              (alerta.avisoReintentando || alerta.avisoNoEntregado)) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icono(Ico.bellOff, tamano: 22, color: Colores.tinta),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.alertaNoTeLlego,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colores.tinta,
                          ),
                        ),
                        if (alerta.avisoReintentando)
                          Text(
                            l.alertaFalloEnvio,
                            style: const TextStyle(
                              fontSize: 15.5,
                              color: Colores.tinta,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          // `alert-who`: who it is about, then what happened.
          Row(
            children: [
              Avatar(
                Avatar.inicialesDe(adulto.nombre),
                tono: TonoAvatar.rosa,
                foto: adulto.foto,
                anillo: Colors.white.withValues(alpha: .85),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                  decoration: BoxDecoration(
                    color: caida
                        ? Colors.black.withValues(alpha: .18)
                        : Colores.tinta.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icono(
                        caida ? Ico.fall : Ico.unsteady,
                        tamano: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          etiqueta.toUpperCase(),
                          semanticsLabel: etiqueta,
                          style: estiloTexto(
                            15,
                            800,
                            color: color,
                          ).copyWith(letterSpacing: .6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              !caida
                  ? l.alertaTituloInestable(nombre)
                  : alerta.sigueEnElSuelo
                  ? l.alertaTituloEnElSuelo(nombre)
                  : l.alertaTituloPudoCaerse(nombre),
              style: estiloTexto(
                34,
                800,
                color: color,
              ).copyWith(height: 1.08, letterSpacing: -.6),
            ),
          ),
          const SizedBox(height: 18),
          if (caida) ...[
            ChipPermanencia(alerta: alerta),
            const SizedBox(height: 16),
          ],
          _Datos(
            alerta: alerta,
            color: color,
            hace: minutos < 1
                ? l.alertaHaceAhora
                : l.alertaHaceMinutos(minutos),
          ),
          const SizedBox(height: 16),
          Boton(
            l.alertaLlamarA(nombre),
            icono: Ico.phone,
            estilo: caida ? EstiloBoton.blanco : EstiloBoton.tinta,
            alPresionar: () => ref.read(llamarProvider)(telefono),
          ),
          const SizedBox(height: 12),
          Boton(
            l.alertaVerEnVivo,
            icono: Ico.video,
            estilo: caida ? EstiloBoton.sobreRojo : EstiloBoton.secundario,
            alPresionar: () => context.push(
              Uri(
                path: Rutas.vivo,
                queryParameters: {
                  'camara': alerta.camaraId,
                  'alerta': alerta.id,
                },
              ).toString(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permanence chip (`.alert-conf`): checking, confirmed on the floor, or got up (US-13, US-21).
class ChipPermanencia extends StatelessWidget {
  const ChipPermanencia({super.key, required this.alerta});

  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    final recuperada = alerta.recuperadaEn;
    final confirmada = alerta.confirmada && recuperada == null;
    final l = context.l10n;
    final (icono, texto) = recuperada != null
        ? (Ico.stand, null)
        : confirmada
        ? (Ico.warn, l.alertaSigueEnSueloConfirmada)
        : (Ico.clock, l.alertaComprobando);
    final color = confirmada ? Colores.caidaTinta : Colors.white;
    final estilo = estiloTexto(15, 800, color: color);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
        decoration: BoxDecoration(
          color: confirmada ? Colors.white : Colors.black.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icono(icono, tamano: 19, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: recuperada != null
                  ? Text.rich(
                      textoConHora(
                        l.alertaSeLevantoALas(context.formato.hora(recuperada)),
                        context.formato.hora(recuperada),
                        estilo: estiloMono(tamano: 15, color: color),
                      ),
                      style: estilo,
                    )
                  : Text(texto!, style: estilo),
            ),
          ],
        ),
      ),
    );
  }
}

/// Room, time and elapsed time (`.slots`).
class _Datos extends StatelessWidget {
  const _Datos({required this.alerta, required this.color, required this.hace});

  final Alerta alerta;
  final Color color;
  final String hace;

  @override
  Widget build(BuildContext context) {
    final caida = alerta.esCaida;
    final separador = caida
        ? Colors.white.withValues(alpha: .28)
        : Colores.tinta.withValues(alpha: .18);
    Widget dato(String clave, Widget valor) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(clave, style: estiloTexto(13, 700, color: color)),
          valor,
        ],
      ),
    );
    final estiloValor = estiloTexto(21, 800, color: color);
    final l = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: caida
            ? Colors.black.withValues(alpha: .16)
            : Colores.tinta.withValues(alpha: .09),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 125,
                child: dato(
                  l.alertaDatoHabitacion,
                  Text(alerta.habitacion, style: estiloValor),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: separador),
              Expanded(
                flex: 100,
                child: dato(
                  l.alertaDatoHora,
                  // «10:42 AM» in English: shrink it instead of breaking it.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.formato.hora(alerta.ocurridaEn),
                      style: estiloMono(tamano: 21, color: color),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: separador),
              Expanded(
                flex: 95,
                child: dato(
                  l.alertaDatoHace,
                  // «instantes» is one word: shrink it instead of breaking it.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(hace, style: estiloValor, maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
