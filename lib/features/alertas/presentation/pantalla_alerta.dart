import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../hogar/domain/hogar.dart';
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'clip_evento.dart';
import 'linea_de_tiempo.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(alertasVistasProvider.notifier).marcar(widget.alertaId),
    );
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
    final tinta = caida ? Colors.white : Colores.tinta;
    final adulto = hogar.adultoMayor;
    final nombre = adulto.nombrePila;
    final familia = ref.watch(familiaresProvider).value ?? const [];
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
                tooltip: 'Cerrar la alerta y volver al inicio',
                icon: Icono(Ico.x, color: tinta),
                onPressed: () => context.go(Rutas.inicio),
              ),
            ),
            SliverToBoxAdapter(
              child: _Heroe(alerta: alerta, adulto: adulto, color: tinta),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colores.fondo,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._avisos(nombre),
                    const SizedBox(height: 4),
                    Semantics(
                      header: true,
                      child: Text(
                        'Qué hacer ahora',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PasosNumerados(_pasos(adulto)),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        'Clip del evento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipEvento(alerta: alerta),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        'Registro',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TarjetaBanda(
                      child: LineaDeTiempo(
                        itemsDeAlerta(
                          alerta,
                          nombreAdultoMayor: nombre,
                          avisados: [for (final f in familia) f.nombrePila],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: const BoxDecoration(
            color: Color(0xF7EEF0F4),
            border: Border(top: BorderSide(color: Colores.linea)),
          ),
          child: SafeArea(
            top: false,
            child: Boton('Marcar alerta', icono: Ico.check, alPresionar: () {}),
          ),
        ),
      ),
    );
  }

  /// Notices above «Qué hacer ahora».
  List<Widget> _avisos(String nombre) {
    final hab = enHabitacion(alerta.habitacion);
    final recuperada = alerta.recuperadaEn;
    final avisos = <Widget>[
      if (recuperada != null)
        Aviso(
          tono: TonoAviso.ok,
          icono: Ico.stand,
          titulo: '$nombre se levantó a las ${hora(recuperada)}',
          texto:
              'Detectamos que se puso de pie $hab. Aun así, confirma cómo está '
              'antes de cerrar la alerta.',
        )
      else if (alerta.esCaida && alerta.confirmada)
        Aviso(
          tono: TonoAviso.error,
          icono: Ico.fall,
          titulo: 'Sigue en el suelo: caída confirmada',
          texto:
              'Pasaron 30 segundos y $nombre no se ha levantado. La alerta sigue '
              'activa hasta que alguien la marque. Si se pone de pie, te '
              'avisaremos.',
        )
      else if (alerta.esCaida)
        _Linea(
          Ico.stand,
          'Estamos comprobando si $nombre se levanta. Si sigue en el suelo 30 '
          'segundos, confirmaremos la caída. Si se pone de pie, te avisaremos.',
        ),
      if (alerta.esCaida && alerta.origenInestable)
        Aviso(
          tono: TonoAviso.neutral,
          icono: Ico.unsteady,
          titulo: 'Empezó como movimiento inestable',
          contenido: conHora(
            'A las ',
            hora(alerta.ocurridaEn),
            ' $hab. La situación terminó en una caída.',
          ),
        ),
      if (!alerta.esCaida)
        const _Linea(
          null,
          'No se detectó una caída. Si la situación termina en una caída, te '
          'avisaremos de inmediato con una alerta urgente.',
        ),
    ];
    return [
      for (final a in avisos) ...[a, const SizedBox(height: 16)],
    ];
  }

  List<(String, String?)> _pasos(AdultoMayor adulto) {
    final nombre = adulto.nombrePila;
    if (!alerta.esCaida) {
      return [
        ('Llama a $nombre', 'Pregúntale cómo se siente y si necesita ayuda.'),
        ('Revisa el clip', 'Mira qué pasó antes y después del movimiento.'),
        (
          'Marca la alerta',
          'Indica si la atendiste o si fue una falsa alarma.',
        ),
      ];
    }
    final partes = adulto.direccion.split(',');
    final cerca = partes.length > 1 ? partes[1].trim() : 'la casa';
    return [
      ('Llama a $nombre', 'Si contesta, pregúntale si puede levantarse sola.'),
      (
        'Si no contesta, pide ayuda cerca',
        'A un vecino o a quien esté más cerca de $cerca. Emergencias: SAMU 106 '
            'o Bomberos 116.',
      ),
      ('Marca la alerta', 'Cuando esté atendida, para que la familia lo sepa.'),
    ];
  }
}

class _Linea extends StatelessWidget {
  const _Linea(this.icono, this.texto);

  final Ico? icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icono != null) ...[
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icono(icono!, tamano: 20, color: Colores.tinta2),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: Text(texto, style: Theme.of(context).textTheme.bodyMedium),
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
    final etiqueta = caida
        ? 'Alerta de caída · Urgente'
        : 'Movimiento inestable · Severidad media';
    final telefono = adulto.telefono;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (alerta.notificadaEn == null) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icono(Ico.bellOff, tamano: 22, color: Colores.tinta),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Esta alerta no te llegó como notificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colores.tinta,
                          ),
                        ),
                        Text(
                          'El servicio de avisos falló. Seguimos reintentando '
                          'el envío; por eso la ves al abrir la app.',
                          style: TextStyle(
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
          Container(
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
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              !caida
                  ? '$nombre tuvo un movimiento inestable'
                  : alerta.sigueEnElSuelo
                  ? '$nombre se cayó y sigue en el suelo'
                  : '$nombre pudo haberse caído',
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
            hace: minutos < 1 ? 'instantes' : '$minutos min',
          ),
          const SizedBox(height: 12),
          Text(
            adulto.direccion,
            style: estiloTexto(15, 400, color: color.withValues(alpha: .95)),
          ),
          const SizedBox(height: 16),
          Boton(
            telefono == null
                ? 'Llamar a $nombre'
                : 'Llamar a $nombre · $telefono',
            icono: Ico.phone,
            estilo: caida ? EstiloBoton.blanco : EstiloBoton.tinta,
            alPresionar: () => ref.read(llamarProvider)(telefono),
          ),
          const SizedBox(height: 12),
          Boton(
            'Ver en vivo · ${alerta.habitacion}',
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
    final (icono, texto) = recuperada != null
        ? (Ico.stand, null)
        : confirmada
        ? (Ico.warn, 'Sigue en el suelo · confirmada')
        : (Ico.clock, 'Comprobando si sigue en el suelo');
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
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Se levantó a las '),
                          TextSpan(
                            text: hora(recuperada),
                            style: estiloMono(tamano: 15, color: color),
                          ),
                        ],
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
                  'Habitación',
                  Text(alerta.habitacion, style: estiloValor),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: separador),
              Expanded(
                flex: 100,
                child: dato(
                  'Hora',
                  Text(
                    hora(alerta.ocurridaEn),
                    style: estiloMono(tamano: 21, color: color),
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: separador),
              Expanded(
                flex: 95,
                child: dato('Hace', Text(hace, style: estiloValor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
