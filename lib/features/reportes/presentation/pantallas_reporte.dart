import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/conectividad.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../movimientos/data/movimientos_repositorio.dart';
import '../../movimientos/domain/movimientos.dart';
import '../../pcs/presentation/piezas_pc.dart';
import '../data/reportes_repositorio.dart';
import '../domain/reporte_caida.dart';

/// The room chip for «No sé»: its value (never sent); it shows as [AppLocalizations.reportesNoSe].
const noSe = 'No sé';

/// The `.foot-link` that opens the report: «¿Hubo una caída y no avisó?» at the foot of Historial
/// and of a camera, «¿Terminó en caída y no avisamos?» under an unstable movement (screens 221,
/// 229). Any member can report, an invited one too.
class EnlaceReporte extends StatelessWidget {
  const EnlaceReporte({super.key, this.texto, this.habitacion, this.cuando});

  /// «¿Hubo una caída y no avisó?» when null.
  final String? texto;
  final String? habitacion;
  final DateTime? cuando;

  @override
  Widget build(BuildContext context) {
    final color = context.colores.tinta2;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: TextButton.icon(
          onPressed: () => context.push(
            Rutas.reportar(habitacion: habitacion, cuando: cuando),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: color,
            textStyle: estiloTexto(15.5, 700, color: color).copyWith(
              decoration: TextDecoration.underline,
              decorationThickness: 1.5,
            ),
          ),
          icon: Icono(Ico.report, tamano: 18, color: color),
          label: Text(
            texto ?? context.l10n.reportesEnlace,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// «Contarnos qué pasó» (screens 222–226, 230): the room (or «No sé»), the approximate day and
/// time, and an optional note. It creates no alert and notifies nobody (CA-40.4).
class PantallaReporteCaida extends ConsumerStatefulWidget {
  const PantallaReporteCaida({super.key, this.habitacion, this.cuando});

  /// Preselected room: the camera's, or the unstable movement's.
  final String? habitacion;

  /// The unstable movement's time.
  final DateTime? cuando;

  @override
  ConsumerState<PantallaReporteCaida> createState() =>
      _PantallaReporteCaidaState();
}

class _PantallaReporteCaidaState extends ConsumerState<PantallaReporteCaida> {
  late final DateTime _hoy;
  late DateTime _dia;
  late final TextEditingController _hora;
  final _nota = TextEditingController();
  String? _habitacion;
  bool _faltaHabitacion = false;
  String? _errorHora;
  String? _errorNota;
  Object? _error;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final ahora = ref.read(relojProvider)();
    _hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final cuando = widget.cuando;
    final dia = cuando == null
        ? _hoy
        : DateTime(cuando.year, cuando.month, cuando.day);
    _dia = dia.isBefore(_hoy.subtract(const Duration(days: 6))) ? _hoy : dia;
    final redondeada = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      ahora.hour,
      ahora.minute - ahora.minute % 5,
    );
    // The field takes a 24-hour HH:MM time in every language.
    _hora = TextEditingController(
      text: Formato.es.hora(
        cuando != null && _dia == dia ? cuando : redondeada,
      ),
    );
    _habitacion = widget.habitacion;
  }

  @override
  void dispose() {
    _hora.dispose();
    _nota.dispose();
    super.dispose();
  }

  DateTime? get _cuando {
    final m = minutosDeHora(_hora.text);
    return m == null ? null : _dia.add(Duration(minutes: m));
  }

  Future<void> _enviar(List<(String, String?)> habitaciones) async {
    final cuando = _cuando;
    final ahora = ref.read(relojProvider)();
    setState(() {
      _error = null;
      _errorNota = null;
      _faltaHabitacion = _habitacion == null;
      _errorHora = cuando == null
          ? context.l10n.reportesHoraFormato
          : cuando.isAfter(ahora)
          ? context.l10n.reportesHoraFutura
          : null;
    });
    if (_faltaHabitacion || _errorHora != null) return;
    final elegida = _habitacion!;
    final camaraId = habitaciones.where((h) => h.$1 == elegida).firstOrNull?.$2;
    final nota = _nota.text.trim();
    setState(() => _enviando = true);
    try {
      final envio = await ref
          .read(colaReportesProvider)
          .enviar(
            ReporteCaida(
              camaraId: camaraId,
              habitacion: camaraId == null && elegida != noSe ? elegida : null,
              ocurridaAproximadamenteEn: cuando!,
              nota: nota.isEmpty ? null : nota,
            ),
          );
      if (!mounted) return;
      context.pushReplacement(
        Rutas.reporteEnviado(guardado: envio == EnvioReporte.guardado),
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        final hora = e.campos['ocurridaAproximadamenteEn'];
        _errorHora = hora;
        _errorNota = e.campos['nota'];
        _error = hora == null && _errorNota == null ? e : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final nombre = ref.watch(nombreAdultoMayorProvider);
    final camaras = ref.watch(camarasProvider).value ?? const [];
    // The rooms with a camera, a preselected room no camera has any more, and «No sé».
    final habitaciones = <(String, String?)>[
      for (final c in camaras) (c.nombreHabitacion, c.id),
    ];
    final h = widget.habitacion;
    if (h != null && h != noSe && !habitaciones.any((x) => x.$1 == h)) {
      habitaciones.add((h, null));
    }
    habitaciones.add((noSe, null));
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    final dias = [for (var i = 0; i < 7; i++) _hoy.subtract(Duration(days: i))];
    final fecha = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EtiquetaCampo(l.reportesFecha),
          DropdownButtonFormField<DateTime>(
            initialValue: _dia,
            isExpanded: true,
            icon: Icono(Ico.chevD, color: context.colores.icono),
            borderRadius: BorderRadius.circular(16),
            style: estiloTexto(17, 400, color: context.colores.tinta),
            items: [
              for (final d in dias)
                DropdownMenuItem(
                  value: d,
                  child: Text(
                    d == _hoy
                        ? l.reportesHoy
                        : d == dias[1]
                        ? l.reportesAyer
                        : context.formato.fechaCorta(d),
                  ),
                ),
            ],
            onChanged: (d) => setState(() {
              _dia = d ?? _dia;
              _errorHora = null;
            }),
          ),
        ],
      ),
    );
    final campoHora = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EtiquetaCampo(l.reportesHoraAproximada),
          TextField(
            controller: _hora,
            keyboardType: TextInputType.number,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [_FormatoHora()],
            style: estiloMono(
              tamano: 17,
              peso: 400,
              color: context.colores.tinta,
            ),
            onChanged: (_) => setState(() => _errorHora = null),
            decoration: InputDecoration(
              hintText: 'HH:MM',
              semanticCounterText: '',
              error: _errorHora == null ? null : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
    final cuando = _cuando;
    final nube = ref.watch(movimientosEnLaNubeProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.reportesTitulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Aviso(
            tono: TonoAviso.error,
            icono: Ico.phone,
            titulo: nombre == null
                ? l.reportesSamu
                : l.reportesSamuConNombre(nombre),
            accion: Boton(
              l.reportesLlamarSamu,
              icono: Ico.phone,
              estilo: EstiloBoton.peligro,
              pequeno: true,
              alPresionar: () => ref.read(llamarProvider)('106'),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(l.reportesPregunta, style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text(l.reportesRevisaremos, style: texto.bodyMedium),
          const SizedBox(height: 16),
          EtiquetaCampo(l.reportesHabitacion),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (nombre, _) in habitaciones)
                ChipOpcion(
                  texto: nombre == noSe ? l.reportesNoSe : nombre,
                  elegido: _habitacion == nombre,
                  alTocar: () => setState(() {
                    _habitacion = nombre;
                    _faltaHabitacion = false;
                  }),
                ),
            ],
          ),
          if (_faltaHabitacion)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: MensajeCampo(l.reportesEligeHabitacion),
            ),
          const SizedBox(height: 16),
          if (grande) ...[
            Row(children: [fecha]),
            const SizedBox(height: 12),
            Row(children: [campoHora]),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [fecha, const SizedBox(width: 12), campoHora],
            ),
          if (_errorHora case final e?)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: MensajeCampo(e),
            ),
          const SizedBox(height: 16),
          EtiquetaCampo(l.reportesQuePaso),
          TextField(
            controller: _nota,
            minLines: 3,
            maxLines: 6,
            maxLength: notaMaxima,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() => _errorNota = null),
            decoration: InputDecoration(
              hintText: l.reportesNotaEjemplo,
              error: _errorNota == null ? null : const SizedBox.shrink(),
            ),
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => Text(
                  '$currentLength/$notaMaxima',
                  style: estiloMono(
                    tamano: 13,
                    peso: 400,
                    color: context.colores.tinta3,
                  ),
                ),
          ),
          if (_errorNota case final e?) MensajeCampo(e),
          if (nube != null) ...[
            const SizedBox(height: 12),
            _NotaMovimientos(nube: nube, cuando: cuando),
          ],
          if (_error case final e?) ...[
            const SizedBox(height: 16),
            MensajeProblema(e),
          ],
          const SizedBox(height: 20),
          Boton(
            l.reportesEnviar,
            icono: Ico.send,
            cargando: _enviando,
            textoCargando: l.reportesEnviando,
            alPresionar: () => _enviar(habitaciones),
          ),
        ],
      ),
    );
  }
}

/// Whether there are movements of that moment to review (`movimientosDisponibles`): «Revisaremos
/// los movimientos de ese momento.» or «No tenemos movimientos guardados de ese momento;
/// revisaremos lo que nos cuentes.» (screen 225).
class _NotaMovimientos extends StatelessWidget {
  const _NotaMovimientos({required this.nube, required this.cuando});

  final MovimientosEnLaNube nube;
  final DateTime? cuando;

  @override
  Widget build(BuildContext context) {
    final desde = nube.datosDesde;
    final hay =
        nube.consentimientoVigente &&
        nube.retencionDias != null &&
        (desde == null || cuando == null || !cuando!.isBefore(desde));
    return Aviso(
      tono: TonoAviso.neutral,
      icono: hay ? Ico.body : Ico.info,
      texto: hay
          ? context.l10n.reportesMovimientosHay
          : context.l10n.reportesMovimientosNo,
    );
  }
}

/// «07:30» while typing: digits only, the colon after the hour.
class _FormatoHora extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final f = formatoHora(nuevo.text);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

/// «Gracias, Carmen. Lo revisaremos.» or, without internet, «Lo guardamos para enviarlo»
/// (screens 227, 228).
class PantallaReporteEnviado extends ConsumerWidget {
  const PantallaReporteEnviado({super.key, this.guardado = false});

  final bool guardado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final nombre = ref.watch(sesionControllerProvider)?.usuario.nombrePila;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HeroePc(
                      icono: guardado ? Ico.clock : Ico.check,
                      fondo: guardado ? null : context.colores.calmaSuave,
                      color: guardado ? null : context.colores.calmaTinta,
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        guardado
                            ? l.reportesGuardado
                            : nombre == null
                            ? l.reportesGracias
                            : l.reportesGraciasNombre(nombre),
                        style: texto.headlineMedium,
                      ),
                    ),
                    if (guardado) ...[
                      const SizedBox(height: 16),
                      Aviso(
                        tono: TonoAviso.advertencia,
                        icono: Ico.wifiOff,
                        titulo: l.reportesNoPudimosTitulo,
                        texto: l.reportesNoPudimosTexto,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      l.reportesNoGeneraAlerta,
                      style: texto.bodyLarge?.copyWith(
                        color: context.colores.tinta2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    Boton(
                      l.reportesVolverHistorial,
                      alPresionar: () => context.go(Rutas.historial),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sends the reports kept without internet when the app opens with a connection and each time
/// the connection returns. Draws nothing.
class EnvioReportesPendientes extends ConsumerStatefulWidget {
  const EnvioReportesPendientes({super.key});

  @override
  ConsumerState<EnvioReportesPendientes> createState() =>
      _EnvioReportesPendientesState();
}

class _EnvioReportesPendientesState
    extends ConsumerState<EnvioReportesPendientes> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(sinInternetProvider, (_, sin) {
      if (sin.value == false) {
        ref.read(colaReportesProvider).enviarPendientes().ignore();
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
