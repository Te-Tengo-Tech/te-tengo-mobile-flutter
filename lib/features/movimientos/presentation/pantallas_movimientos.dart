import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../hogar/domain/hogar.dart';
import '../../legal/presentation/pantallas_legales.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../data/movimientos_repositorio.dart';
import '../domain/movimientos.dart';
import '../../../app/tema/tema.dart';
import '../../../l10n/l10n.dart';

/// Version of the movements consent text this app shows and records (CA-35.2). It must match the
/// API's `versionTextoVigente` (`TT_MOVIMIENTOS_VERSION_TEXTO`); a consent keeps the version it was
/// given with, and its document shows that version's text.
///
/// - `1`: the prototype's text.
/// - `2`: «Dónde» names the cloud store (Cloudflare R2) and the cross-border flow of the change
///   request (2.6); pending legal review (docs/BLOCKERS.md).
/// - `3`: «Dónde» names the new cloud store, Microsoft Azure (Azure Blob Storage, region Chile
///   Central), after the move from Cloudflare R2; the rest of the text is version 2's.
const versionTextoMovimientos = '3';

/// The sections of the movements consent (`movSec`): icon, title, summary and the full text, shared
/// by the screen and its document (CA-35.1), in the text [version] (the current one by default).
///
/// Only the display is localized: the version recorded with the consent is [version], whatever the
/// language the text was read in.
List<(Ico, String, String, String)> seccionesMovimientos(
  AppLocalizations l,
  String nombre, {
  String version = versionTextoMovimientos,
}) => [
  (
    Ico.eye,
    l.movimientosSecParaQueTitulo,
    l.movimientosSecParaQueResumen,
    l.movimientosSecParaQueTexto,
  ),
  (
    Ico.body,
    l.movimientosSecQueTitulo,
    l.movimientosSecQueResumen,
    l.movimientosSecQueTexto,
  ),
  (
    Ico.cloud,
    l.movimientosSecDondeTitulo,
    l.movimientosSecDondeResumen,
    switch (version) {
      '1' => l.movimientosSecDondeTextoV1,
      '2' => l.movimientosSecDondeTextoV2,
      _ => l.movimientosSecDondeTextoV3,
    },
  ),
  (
    Ico.clock,
    l.movimientosSecCuantoTitulo,
    l.movimientosSecCuantoResumen,
    l.movimientosSecCuantoTexto,
  ),
  (
    Ico.users,
    l.movimientosSecQuienTitulo,
    l.movimientosSecQuienResumen,
    l.movimientosSecQuienTexto,
  ),
  (
    Ico.shield,
    l.movimientosSecDerechosTitulo,
    l.movimientosSecDerechosResumen,
    l.movimientosSecDerechosTexto(nombre),
  ),
];

/// «Guardar movimientos» (screens 172 to 181): a separate, optional consent to store the older
/// adult's movements (CA-35.1); registered with who gave it, who registered it, when and the text
/// version (CA-35.2); without it nothing is stored and the options that use it are off (CA-35.3);
/// «Dejar de guardar movimientos» (CA-35.4). The invited member reads it.
class PantallaGuardarMovimientos extends ConsumerStatefulWidget {
  const PantallaGuardarMovimientos({super.key});

  @override
  ConsumerState<PantallaGuardarMovimientos> createState() =>
      _PantallaGuardarMovimientosState();
}

class _PantallaGuardarMovimientosState
    extends ConsumerState<PantallaGuardarMovimientos> {
  bool _representante = false;
  bool _acepto = false;
  final _nombreRepresentante = TextEditingController();
  String? _errorRepresentante;
  bool _errorRed = false;
  bool _guardando = false;
  ProblemaApi? _problema;

  @override
  void dispose() {
    _nombreRepresentante.dispose();
    super.dispose();
  }

  Future<void> _registrar(String adulto) async {
    final representante = _nombreRepresentante.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (_representante && representante.isEmpty) {
      setState(
        () => _errorRepresentante = context.l10n.movimientosErrorRepresentante,
      );
      return;
    }
    setState(() {
      _guardando = true;
      _errorRed = false;
      _problema = null;
    });
    try {
      await ref
          .read(movimientosRepositorioProvider)
          .registrar(
            otorgadoPor: _representante ? representante : adulto,
            representante: _representante,
            versionTexto: versionTextoMovimientos,
          );
      ref
        ..invalidate(consentimientoMovimientosProvider)
        ..invalidate(movimientosEnLaNubeProvider);
      if (!mounted) return;
      mostrarToast(
        context,
        titulo: context.l10n.movimientosRegistradoTitulo,
        texto: context.l10n.movimientosRegistradoTexto,
        icono: Ico.shield,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case ProblemaApi.sinConexion:
            _errorRed = true;
          case 'SIN_CONSENTIMIENTO':
            ref.invalidate(hogarProvider);
          default:
            _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _dejarDeGuardar(String nombre) async {
    final l = context.l10n;
    final si = await confirmar(
      context,
      icono: Ico.body,
      titulo: l.movimientosDejarTitulo(nombre),
      texto: l.movimientosDejarTexto,
      aceptar: l.movimientosDejarAceptar,
      cancelar: l.movimientosCancelar,
      peligro: true,
    );
    if (!si || !mounted) return;
    try {
      await ref.read(movimientosRepositorioProvider).revocar();
    } on ProblemaApi catch (e) {
      if (e.codigo != 'SIN_CONSENTIMIENTO_DE_MOVIMIENTOS') {
        if (mounted) {
          mostrarToast(
            context,
            titulo: e.codigo == ProblemaApi.sinConexion
                ? context.l10n.movimientosSinInternetTitulo
                : e.detalle,
            texto: e.codigo == ProblemaApi.sinConexion
                ? context.l10n.movimientosSinInternetTexto
                : null,
            icono: Ico.warn,
            tono: TonoAviso.advertencia,
          );
        }
        return;
      }
    }
    ref
        .read(borradoMovimientosProvider.notifier)
        .iniciar(ref.read(relojProvider)());
    ref
      ..invalidate(consentimientoMovimientosProvider)
      ..invalidate(movimientosEnLaNubeProvider);
    if (mounted) unawaited(context.push(Rutas.movimientosBorrados));
  }

  @override
  Widget build(BuildContext context) {
    final consentimiento = ref.watch(consentimientoMovimientosProvider);
    final hogar = ref.watch(hogarProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.movimientosTitulo)),
      body: switch ((consentimiento, hogar)) {
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => ErrorDePantalla(
          error: error,
          alReintentar: () async => ref
            ..invalidate(consentimientoMovimientosProvider)
            ..invalidate(hogarProvider),
        ),
        (AsyncData(value: final c), AsyncData(value: final h)) =>
          c.vigente && c.constancia != null
              ? _Vigente(
                  constancia: c.constancia!,
                  nombre: h.adultoMayor.nombrePila,
                  alDejar: () => _dejarDeGuardar(h.adultoMayor.nombrePila),
                )
              : _formulario(context, c, h.adultoMayor, h.conConsentimiento),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _formulario(
    BuildContext context,
    ConsentimientoMovimientos c,
    AdultoMayor adulto,
    bool conConsentimiento,
  ) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final titular = ref.watch(esTitularProvider);
    final nombre = adulto.nombrePila;
    final completo = adulto.nombre;
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l.movimientosPregunta(nombre), style: texto.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(l.movimientosOpcional, style: texto.bodyMedium),
        const SizedBox(height: 12),
        IlustracionEsqueleto(color: context.colores.moradoTinta),
        const SizedBox(height: 12),
        ListaTarjeta(
          children: [
            for (final (icono, titulo, resumen, cuerpo) in seccionesMovimientos(
              l,
              nombre,
            ))
              FilaPlegable(
                icono: icono,
                titulo: titulo,
                resumen: resumen,
                child: Text(cuerpo, style: texto.bodyMedium),
              ),
          ],
        ),
        if (titular) ...[
          const SizedBox(height: 20),
          EtiquetaCampo(l.movimientosQuienDa),
          const SizedBox(height: 6),
          OpcionRadio<bool>(
            valor: false,
            seleccion: _representante,
            titulo: l.movimientosEnPersona(nombre),
            alElegir: (v) => setState(() => _representante = v),
          ),
          OpcionRadio<bool>(
            valor: true,
            seleccion: _representante,
            titulo: l.movimientosSuRepresentante,
            alElegir: (v) => setState(() => _representante = v),
          ),
          if (_representante) ...[
            const SizedBox(height: 8),
            CampoTexto(
              etiqueta: l.movimientosNombreRepresentante,
              controlador: _nombreRepresentante,
              marcador: l.movimientosNombreMarcador,
              error: _errorRepresentante,
              longitudMaxima: 120,
              alCambiar: (_) => setState(() => _errorRepresentante = null),
            ),
          ],
          const SizedBox(height: 8),
          Casilla(
            marcada: _acepto,
            texto: l.movimientosAcepto(nombre),
            alCambiar: (v) => setState(() => _acepto = v),
          ),
          if (_errorRed) ...[
            const SizedBox(height: 12),
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              titulo: l.movimientosErrorRedTitulo,
              texto: l.movimientosErrorRedTexto,
            ),
          ],
          if (_problema != null) ...[
            const SizedBox(height: 12),
            MensajeProblema(_problema!),
          ],
          const SizedBox(height: 16),
          Boton(
            l.movimientosRegistrar,
            cargando: _guardando,
            alPresionar: _acepto ? () => _registrar(completo) : null,
          ),
          const SizedBox(height: 8),
          Boton(
            l.movimientosAhoraNo,
            estilo: EstiloBoton.fantasma,
            alPresionar: () => Navigator.of(context).maybePop(),
          ),
        ] else ...[
          const SizedBox(height: 16),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: l.movimientosAccionRegistrar,
          ),
        ],
        const SizedBox(height: 8),
        Boton(
          l.movimientosLeerDocumento,
          estilo: EstiloBoton.fantasma,
          alPresionar: () => context.push(Rutas.documentoMovimientos),
        ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        if (!conConsentimiento) ...[
          // CA-35.1: the monitoring consent comes first.
          Aviso(
            tono: TonoAviso.error,
            icono: Ico.lock,
            titulo: l.movimientosFaltaConsentimientoTitulo,
            texto: l.movimientosFaltaConsentimientoTexto,
            accion: titular
                ? Boton(
                    l.movimientosRegistrarConsentimiento,
                    pequeno: true,
                    alPresionar: () => context.push(Rutas.consentimiento),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          ExcludeSemantics(
            child: IgnorePointer(
              child: Opacity(opacity: 0.5, child: contenido),
            ),
          ),
        ] else
          contenido,
      ],
    );
  }
}

/// The consent in force (screens 179 and 181).
class _Vigente extends ConsumerWidget {
  const _Vigente({
    required this.constancia,
    required this.nombre,
    required this.alDejar,
  });

  final ConstanciaMovimientos constancia;
  final String nombre;
  final VoidCallback alDejar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titular = ref.watch(esTitularProvider);
    final nube = ref.watch(movimientosEnLaNubeProvider).value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        TarjetaConstanciaMovimientos(constancia: constancia),
        const SizedBox(height: 16),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.cloud),
              titulo: context.l10n.movimientosEnLaNube,
              subtitulo: nube == null
                  ? null
                  : resumenNube(context.l10n, nube.retencionDias),
              alTocar: () => context.push(Rutas.nube),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (titular)
          Boton(
            context.l10n.movimientosDejarBoton,
            estilo: EstiloBoton.peligroContorno,
            alPresionar: alDejar,
          )
        else
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: context.l10n.movimientosAccionRetirar,
          ),
      ],
    );
  }
}

/// «Permiso para guardar movimientos» (screen 179, CA-35.2).
class TarjetaConstanciaMovimientos extends StatelessWidget {
  const TarjetaConstanciaMovimientos({super.key, required this.constancia});

  final ConstanciaMovimientos constancia;

  @override
  Widget build(BuildContext context) {
    final c = constancia;
    return TarjetaBanda.construir(
      banda: Banda.calma,
      builder: (context) {
        final texto = Theme.of(context).textTheme;
        final l = context.l10n;
        final formato = context.formato;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icono(
                  Ico.shield,
                  tamano: 26,
                  color: context.colores.calmaTinta,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.movimientosConstanciaTitulo,
                    style: texto.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DatosTarjeta([
              FilaDato(
                clave: l.movimientosConstanciaOtorgadoPor,
                valor: c.representante
                    ? l.movimientosConstanciaRepresentante(c.otorgadoPor)
                    : c.otorgadoPor,
              ),
              FilaDato(
                clave: l.movimientosConstanciaRegistradoPor,
                valor: c.registradoPor,
              ),
              FilaDato(
                clave: l.movimientosConstanciaFecha,
                valor: '',
                valorRico: TextSpan(
                  children: [
                    TextSpan(text: '${formato.fechaNumerica(c.otorgadoEn)} · '),
                    TextSpan(
                      text: formato.hora(c.otorgadoEn),
                      style: estiloCifras,
                    ),
                  ],
                ),
              ),
              FilaDato(
                clave: l.movimientosConstanciaVersion,
                valor: c.versionTexto,
              ),
            ]),
            const SizedBox(height: 8),
            Text(l.movimientosConstanciaLey, style: texto.bodySmall),
            const SizedBox(height: 4),
            Boton(
              l.movimientosLeerAceptado,
              estilo: EstiloBoton.fantasma,
              alPresionar: () => context.push(Rutas.documentoMovimientos),
            ),
          ],
        );
      },
    );
  }
}

/// The full text of the movements consent (screen 180).
class PantallaDocumentoMovimientos extends ConsumerWidget {
  const PantallaDocumentoMovimientos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final nombre =
        ref.watch(nombreAdultoMayorProvider) ?? l.movimientosPersonaCuidada;
    final c = ref.watch(consentimientoMovimientosProvider).value;
    // The document of a consent in force is the text it was given with.
    final version = c != null && c.vigente && c.constancia != null
        ? c.constancia!.versionTexto
        : versionTextoMovimientos;
    return PantallaDocumento(
      titulo: l.movimientosTitulo,
      introduccion: l.movimientosDocIntroduccion(nombre),
      secciones: [
        for (final (_, titulo, _, cuerpo) in seccionesMovimientos(
          l,
          nombre,
          version: version,
        ))
          (titulo, [cuerpo]),
        (l.movimientosDocRegistraTitulo, [l.movimientosDocRegistraTexto]),
        (l.movimientosDocRetirarTitulo, [l.movimientosDocRetirarTexto]),
      ],
      pie: c == null
          ? null
          : Text(
              l.movimientosDocVersion(version),
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}

/// «Borrando los movimientos de la nube…» and «Listo» (screens 182, 183, CA-35.4). The push
/// `MOVIMIENTOS_ELIMINADOS` completes it, and so does asking the API every [intervalo] while the
/// screen is visible: a push does not reach a hidden app.
class PantallaBorrandoMovimientos extends ConsumerStatefulWidget {
  const PantallaBorrandoMovimientos({
    super.key,
    this.intervalo = const Duration(seconds: 3),
  });

  /// How often the deletion is asked [implementation choice], as for the recordings.
  final Duration intervalo;

  @override
  ConsumerState<PantallaBorrandoMovimientos> createState() =>
      _PantallaBorrandoMovimientosState();
}

class _PantallaBorrandoMovimientosState
    extends ConsumerState<PantallaBorrandoMovimientos> {
  Timer? _temporizador;
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(onShow: _consultar, onResume: _consultar);
    _temporizador = Timer.periodic(widget.intervalo, (_) => _consultar());
    WidgetsBinding.instance.addPostFrameCallback((_) => _consultar());
  }

  Future<void> _consultar() async {
    if (!mounted) return;
    final b = ref.read(borradoMovimientosProvider);
    if (b?.terminado ?? false) return _temporizador?.cancel();
    try {
      final c = await ref.read(movimientosRepositorioProvider).consentimiento();
      if (!mounted) return;
      final e = c.eliminacion;
      if (b == null && e != null) {
        // Opened after a restart: rebuilt from the backend.
        ref.read(borradoMovimientosProvider.notifier).iniciar(e.programadaEn);
      }
      if (e != null && e.terminada) {
        ref.read(borradoMovimientosProvider.notifier).terminar();
        _temporizador?.cancel();
      }
    } on Object catch (e) {
      debugPrint('No se pudo consultar el borrado de los movimientos: $e');
    }
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final b = ref.watch(borradoMovimientosProvider);
    final terminado = b?.terminado ?? false;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final desde = b?.desde ?? ref.watch(relojProvider)();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconoGrande(
                        icono: terminado ? Ico.check : Ico.cloud,
                        fondo: terminado
                            ? context.colores.calmaSuave
                            : context.colores.moradoSuave,
                        color: terminado
                            ? context.colores.calmaTinta
                            : context.colores.moradoTinta,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        terminado
                            ? l.movimientosBorradoListo(nombre)
                            : l.movimientosBorrandoNube,
                        style: texto.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      terminado
                          ? l.movimientosAlertasIgual
                          : l.movimientosNoCierres,
                      style: texto.bodyLarge?.copyWith(
                        color: context.colores.tinta2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TarjetaBanda(
                      child: Column(
                        children: [
                          _Paso(
                            estado: _EstadoPaso.hecho,
                            titulo: l.movimientosYaNoGuardamos,
                            detalle: _conHora(
                              l.movimientosDesdeLas,
                              context.formato.hora(desde),
                            ),
                          ),
                          _Paso(
                            estado: terminado
                                ? _EstadoPaso.hecho
                                : _EstadoPaso.enCurso,
                            titulo: terminado
                                ? l.movimientosBorradosNube
                                : l.movimientosBorrandoNube,
                          ),
                          _Paso(
                            estado: _EstadoPaso.pendiente,
                            numero: 3,
                            titulo: l.movimientosEnLaPc,
                            detalle: TextSpan(text: l.movimientosPcPreguntara),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Boton(
                l.movimientosVolverPrivacidad,
                alPresionar: terminado
                    ? () {
                        ref.read(borradoMovimientosProvider.notifier).olvidar();
                        context.go(Rutas.privacidad);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [conHora] with the time where the localized [mensaje] puts it («Desde las 10:42»).
TextSpan _conHora(String Function(String) mensaje, String horaTexto) {
  final completo = mensaje(horaTexto);
  final i = completo.indexOf(horaTexto);
  if (i < 0) return TextSpan(text: completo);
  return conHora(
    completo.substring(0, i),
    horaTexto,
    completo.substring(i + horaTexto.length),
  );
}

enum _EstadoPaso { hecho, enCurso, pendiente }

class _Paso extends StatelessWidget {
  const _Paso({
    required this.estado,
    required this.titulo,
    this.detalle,
    this.numero,
  });

  final _EstadoPaso estado;
  final String titulo;
  final InlineSpan? detalle;
  final int? numero;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CirculoPaso(
          hecho: estado == _EstadoPaso.hecho,
          numero: numero,
          hijo: estado == _EstadoPaso.enCurso
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: context.colores.sobreInversa,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Theme.of(context).textTheme.titleMedium),
              if (detalle case final d?)
                Text.rich(d, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

/// «Movimientos en la nube» (screens 185 to 192, CA-37.1, CA-37.3, CA-37.4): off until the owner
/// chooses 7, 30, 90 or 365 days; a shorter period asks first from which date it deletes.
class PantallaMovimientosNube extends ConsumerStatefulWidget {
  const PantallaMovimientosNube({super.key});

  @override
  ConsumerState<PantallaMovimientosNube> createState() =>
      _PantallaMovimientosNubeState();
}

class _PantallaMovimientosNubeState
    extends ConsumerState<PantallaMovimientosNube> {
  bool _errorRed = false;
  bool _guardando = false;

  Future<void> _elegir(MovimientosEnLaNube actual, int? dias) async {
    if (dias == actual.retencionDias || _guardando) return;
    final antes = actual.retencionDias;
    final l = context.l10n;
    // Shorter, or off: it deletes data, so it asks first (CA-37.4).
    if (antes != null && (dias == null || dias < antes)) {
      final corte = ref
          .read(relojProvider)()
          .subtract(Duration(days: dias ?? 0));
      final si = await confirmar(
        context,
        icono: Ico.cloud,
        peligro: true,
        titulo: dias == null
            ? l.nubeApagarTitulo
            : l.nubeAcortarTitulo(textoPlazo(l, dias)),
        texto: dias == null
            ? l.nubeApagarTexto
            : l.nubeAcortarTexto(context.formato.fechaNumerica(corte)),
        aceptar: dias == null
            ? l.nubeNoGuardar
            : l.nubeGuardarPlazo(textoPlazo(l, dias)),
        cancelar: l.movimientosCancelar,
      );
      if (!si || !mounted) return;
    }
    setState(() {
      _guardando = true;
      _errorRed = false;
    });
    try {
      await ref.read(movimientosRepositorioProvider).cambiarRetencion(dias);
      ref.invalidate(movimientosEnLaNubeProvider);
      if (!mounted) return;
      mostrarToast(
        context,
        titulo: dias == null
            ? context.l10n.nubeToastApagado
            : context.l10n.nubeToastPlazo(textoPlazo(context.l10n, dias)),
        texto: dias == null
            ? context.l10n.nubeBorramos
            : context.l10n.nubeSeBorranSolos,
        icono: Ico.cloud,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      if (e.codigo == ProblemaApi.sinConexion) {
        setState(() => _errorRed = true);
      } else {
        mostrarToast(context, titulo: e.detalle, icono: Ico.warn);
        ref.invalidate(movimientosEnLaNubeProvider);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titular = ref.watch(esTitularProvider);
    final nube = ref.watch(movimientosEnLaNubeProvider);
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.movimientosEnLaNube),
        actions: [
          if (!titular)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: EtiquetaSoloVer()),
            ),
        ],
      ),
      body: switch (nube) {
        AsyncError(:final error) => ErrorDePantalla(
          error: error,
          alReintentar: () async => ref.invalidate(movimientosEnLaNubeProvider),
        ),
        AsyncData(value: final n) => _contenido(context, n, titular, nombre),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _contenido(
    BuildContext context,
    MovimientosEnLaNube n,
    bool titular,
    String nombre,
  ) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final permiso = n.consentimientoVigente;
    final habilitado = permiso && titular && !_guardando;
    final pcs = ref.watch(pcsProvider).value ?? const [];
    final sinConexion = pcs.where((p) => p.sinConexion).firstOrNull;
    final camaras = ref.watch(camarasProvider).value?.length;
    final actual = permiso ? n.retencionDias : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(l.nubeSeBorranSolos, style: texto.bodyMedium),
        const SizedBox(height: 16),
        if (!permiso) ...[
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.body,
            titulo: l.nubeFaltaPermiso(nombre),
            accion: titular
                ? Boton(
                    l.nubeVerPermiso,
                    pequeno: true,
                    alPresionar: () => context.push(Rutas.movimientos),
                  )
                : null,
          ),
          const SizedBox(height: 16),
        ] else if (!titular) ...[
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: l.nubeAccionCambiarPlazo,
          ),
          const SizedBox(height: 16),
        ],
        if (_errorRed) ...[
          Aviso(
            tono: TonoAviso.advertencia,
            icono: Ico.wifiOff,
            titulo: l.nubeErrorRed,
          ),
          const SizedBox(height: 16),
        ],
        Semantics(
          label: l.nubePlazoEtiqueta,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpcionRadio<int?>(
                valor: null,
                seleccion: actual,
                titulo: l.nubeNoGuardar,
                alElegir: habilitado ? (v) => _elegir(n, v) : null,
              ),
              for (final d in n.opciones)
                OpcionRadio<int?>(
                  valor: d,
                  seleccion: actual,
                  titulo: textoPlazo(l, d),
                  subtitulo: d == n.maximoRecomendadoDias
                      ? l.nubeMaximoRecomendado
                      : null,
                  alElegir: habilitado ? (v) => _elegir(n, v) : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TarjetaBanda(
          borde: true,
          relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: DatosTarjeta([
            FilaDato(
              clave: l.nubeEspacio,
              valor: l.nubeEspacioValor(n.mbMinimo, n.mbMaximo),
            ),
            if (permiso && n.retencionDias != null && n.datosDesde != null)
              FilaDato(
                clave: l.nubeDatosDesde,
                valor: context.formato.fechaNumerica(n.datosDesde!),
                mono: true,
              ),
            if (camaras != null)
              FilaDato(clave: l.nubeCamaras, valor: '$camaras'),
          ]),
        ),
        if (permiso && n.retencionDias != null && sinConexion != null) ...[
          const SizedBox(height: 12),
          Aviso(
            tono: TonoAviso.neutral,
            icono: Ico.clock,
            texto: l.nubePcSubira(sinConexion.nombre),
          ),
        ],
        const SizedBox(height: 12),
        Aviso(tono: TonoAviso.info, icono: Ico.video, texto: l.nubeNuncaVideo),
      ],
    );
  }
}
