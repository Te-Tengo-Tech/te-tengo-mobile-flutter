import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/formato.dart';
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

/// Version of the movements consent text this app shows and records (CA-35.2). It must match the
/// API's `versionTextoVigente` (`TT_MOVIMIENTOS_VERSION_TEXTO`); a consent keeps the version it was
/// given with, and its document shows that version's text.
///
/// - `1`: the prototype's text.
/// - `2`: «Dónde» names the cloud store (Cloudflare R2) and the cross-border flow of the change
///   request (2.6); pending legal review (docs/BLOCKERS.md).
const versionTextoMovimientos = '2';

/// The sections of the movements consent (`movSec`): icon, title, summary and the full text, shared
/// by the screen and its document (CA-35.1), in the text [version] (the current one by default).
List<(Ico, String, String, String)> seccionesMovimientos(
  String nombre, {
  String version = versionTextoMovimientos,
}) => [
  (
    Ico.eye,
    'Para qué',
    'Ver qué pasó y mejorar la detección',
    'Ver qué pasó antes y después de un aviso, y mejorar la detección.',
  ),
  (
    Ico.body,
    'Qué guardamos',
    'Puntos del cuerpo, sin imagen',
    'Solo puntos del cuerpo (hombros, caderas, rodillas…), sin imagen ni video.',
  ),
  (
    Ico.cloud,
    'Dónde',
    'PC y, si quieres, nube',
    version == '1'
        ? 'En la PC de la casa y, si lo eliges, en la nube (servidores fuera '
              'del Perú).'
        : 'En la PC de la casa y, si lo eliges, en la nube: Cloudflare R2, con '
              'servidores fuera del Perú. Guardarlos ahí es un flujo '
              'transfronterizo de datos personales.',
  ),
  (
    Ico.clock,
    'Cuánto tiempo',
    'Tú eliges el plazo',
    'Nube: de 7 días a 1 año. PC: también sin borrar.',
  ),
  (
    Ico.users,
    'Quién puede verlos',
    'La familia, con registro',
    'Solo la familia vinculada; cada repetición queda registrada.',
  ),
  (
    Ico.shield,
    'Sus derechos',
    'Ley N.° 29733',
    '$nombre puede ver, corregir o borrar sus datos, u oponerse a su uso: '
        'privacidad@tetengo.pe (Ley N.° 29733).',
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
        () => _errorRepresentante = 'Escribe el nombre del representante.',
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
        titulo: 'Permiso registrado',
        texto: 'Ahora puedes elegir si se guardan en la nube.',
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
    final si = await confirmar(
      context,
      icono: Ico.body,
      titulo: '¿Dejar de guardar los movimientos de $nombre?',
      texto:
          'Borraremos los de la nube; la PC preguntará si también los borra. Las '
          'alertas siguen igual.',
      aceptar: 'Dejar de guardar',
      cancelar: 'Cancelar',
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
                ? 'Sin internet'
                : e.detalle,
            texto: e.codigo == ProblemaApi.sinConexion
                ? 'Revisa tu conexión y vuelve a intentarlo.'
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
      appBar: AppBar(title: const Text('Guardar movimientos')),
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
    final titular = ref.watch(esTitularProvider);
    final nombre = adulto.nombrePila;
    final completo = adulto.nombre;
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            '¿Guardamos los movimientos de $nombre?',
            style: texto.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Es opcional: las alertas funcionan igual.',
          style: texto.bodyMedium,
        ),
        const SizedBox(height: 12),
        IlustracionEsqueleto(color: context.colores.moradoTinta),
        const SizedBox(height: 12),
        ListaTarjeta(
          children: [
            for (final (icono, titulo, resumen, cuerpo) in seccionesMovimientos(
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
          const EtiquetaCampo('¿Quién da el permiso?'),
          const SizedBox(height: 6),
          OpcionRadio<bool>(
            valor: false,
            seleccion: _representante,
            titulo: '$nombre, en persona',
            alElegir: (v) => setState(() => _representante = v),
          ),
          OpcionRadio<bool>(
            valor: true,
            seleccion: _representante,
            titulo: 'Su representante',
            alElegir: (v) => setState(() => _representante = v),
          ),
          if (_representante) ...[
            const SizedBox(height: 8),
            CampoTexto(
              etiqueta: 'Nombre del representante',
              controlador: _nombreRepresentante,
              marcador: 'Nombre y apellido',
              error: _errorRepresentante,
              longitudMaxima: 120,
              alCambiar: (_) => setState(() => _errorRepresentante = null),
            ),
          ],
          const SizedBox(height: 8),
          Casilla(
            marcada: _acepto,
            texto:
                '$nombre aceptó que se guarden sus movimientos para estos fines.',
            alCambiar: (v) => setState(() => _acepto = v),
          ),
          if (_errorRed) ...[
            const SizedBox(height: 12),
            const Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              titulo: 'No pudimos registrar el permiso',
              texto: 'Nada se guardó.',
            ),
          ],
          if (_problema != null) ...[
            const SizedBox(height: 12),
            MensajeProblema(_problema!),
          ],
          const SizedBox(height: 16),
          Boton(
            'Registrar el permiso',
            cargando: _guardando,
            alPresionar: _acepto ? () => _registrar(completo) : null,
          ),
          const SizedBox(height: 8),
          Boton(
            'Ahora no',
            estilo: EstiloBoton.fantasma,
            alPresionar: () => Navigator.of(context).maybePop(),
          ),
        ] else ...[
          const SizedBox(height: 16),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'registrar este permiso',
          ),
        ],
        const SizedBox(height: 8),
        Boton(
          'Leer el documento completo',
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
            titulo: 'Falta el consentimiento',
            texto: 'Sin él no detectamos caídas.',
            accion: titular
                ? Boton(
                    'Registrar consentimiento',
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
              titulo: 'Movimientos en la nube',
              subtitulo: nube == null ? null : resumenNube(nube.retencionDias),
              alTocar: () => context.push(Rutas.nube),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (titular)
          Boton(
            'Dejar de guardar movimientos',
            estilo: EstiloBoton.peligroContorno,
            alPresionar: alDejar,
          )
        else
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'retirar este permiso',
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
                    'Permiso para guardar movimientos',
                    style: texto.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DatosTarjeta([
              FilaDato(
                clave: 'Otorgado por',
                valor: c.representante
                    ? '${c.otorgadoPor} (representante)'
                    : c.otorgadoPor,
              ),
              FilaDato(clave: 'Registrado por', valor: c.registradoPor),
              FilaDato(
                clave: 'Fecha',
                valor: '',
                valorRico: TextSpan(
                  children: [
                    TextSpan(text: '${fechaNumerica(c.otorgadoEn)} · '),
                    TextSpan(text: hora(c.otorgadoEn), style: estiloCifras),
                  ],
                ),
              ),
              FilaDato(clave: 'Versión del texto', valor: c.versionTexto),
            ]),
            const SizedBox(height: 8),
            Text(
              'Constancia exigida por la Ley N.° 29733 para datos sensibles.',
              style: texto.bodySmall,
            ),
            const SizedBox(height: 4),
            Boton(
              'Leer el documento aceptado',
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
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? 'la persona cuidada';
    final c = ref.watch(consentimientoMovimientosProvider).value;
    // The document of a consent in force is the text it was given with.
    final version = c != null && c.vigente && c.constancia != null
        ? c.constancia!.versionTexto
        : versionTextoMovimientos;
    return PantallaDocumento(
      titulo: 'Guardar movimientos',
      introduccion:
          'Permiso aparte y opcional. Lo acepta $nombre o su representante.',
      secciones: [
        for (final (_, titulo, _, cuerpo) in seccionesMovimientos(
          nombre,
          version: version,
        ))
          (titulo, [cuerpo]),
        (
          'Cómo se registra',
          [
            'Guardamos quién lo otorgó, quién lo registró, fecha, hora y versión '
                'del texto (Ley N.° 29733).',
          ],
        ),
        (
          'Cómo retirarlo',
          [
            'El titular lo retira en Ajustes › Privacidad. Borramos los de la nube; '
                'la PC pregunta si también los borra.',
          ],
        ),
      ],
      pie: c == null
          ? null
          : Text(
              'Versión del texto: $version.',
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
                            ? 'Listo. Ya no guardamos los movimientos de $nombre.'
                            : 'Borrando los movimientos de la nube…',
                        style: texto.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      terminado
                          ? 'Las alertas siguen igual.'
                          : 'No cierres la app.',
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
                            titulo: 'Ya no guardamos movimientos',
                            detalle: conHora('Desde las ', hora(desde)),
                          ),
                          _Paso(
                            estado: terminado
                                ? _EstadoPaso.hecho
                                : _EstadoPaso.enCurso,
                            titulo: terminado
                                ? 'Movimientos borrados de la nube'
                                : 'Borrando los movimientos de la nube…',
                          ),
                          const _Paso(
                            estado: _EstadoPaso.pendiente,
                            numero: 3,
                            titulo: 'En la PC de la casa',
                            detalle: TextSpan(
                              text: 'Preguntará si también se borran ahí.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Boton(
                'Volver a Privacidad',
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
            ? '¿Dejar de guardar en la nube?'
            : '¿Guardar solo ${textoPlazo(dias)}?',
        texto:
            '${dias == null ? 'Borraremos todos los movimientos de la nube.' : 'Borraremos los movimientos anteriores al ${fechaNumerica(corte)}.'} '
            'No se pueden recuperar.',
        aceptar: dias == null
            ? 'No guardar en la nube'
            : 'Guardar ${textoPlazo(dias)}',
        cancelar: 'Cancelar',
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
        titulo:
            'Movimientos en la nube: '
            '${dias == null ? 'no guardar' : textoPlazo(dias)}',
        texto: dias == null
            ? 'Borramos los movimientos de la nube.'
            : 'Se borran solos al cumplirse el plazo.',
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
        title: const Text('Movimientos en la nube'),
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
    final permiso = n.consentimientoVigente;
    final habilitado = permiso && titular && !_guardando;
    final pcs = ref.watch(pcsProvider).value ?? const [];
    final sinConexion = pcs.where((p) => p.sinConexion).firstOrNull;
    final camaras = ref.watch(camarasProvider).value?.length;
    final actual = permiso ? n.retencionDias : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text('Se borran solos al cumplirse el plazo.', style: texto.bodyMedium),
        const SizedBox(height: 16),
        if (!permiso) ...[
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.body,
            titulo: 'Falta el permiso de $nombre para guardar movimientos',
            accion: titular
                ? Boton(
                    'Ver el permiso',
                    pequeno: true,
                    alPresionar: () => context.push(Rutas.movimientos),
                  )
                : null,
          ),
          const SizedBox(height: 16),
        ] else if (!titular) ...[
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'cambiar el plazo',
          ),
          const SizedBox(height: 16),
        ],
        if (_errorRed) ...[
          const Aviso(
            tono: TonoAviso.advertencia,
            icono: Ico.wifiOff,
            titulo: 'No pudimos guardar el cambio',
          ),
          const SizedBox(height: 16),
        ],
        Semantics(
          label: 'Plazo en la nube',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpcionRadio<int?>(
                valor: null,
                seleccion: actual,
                titulo: 'No guardar en la nube',
                alElegir: habilitado ? (v) => _elegir(n, v) : null,
              ),
              for (final d in n.opciones)
                OpcionRadio<int?>(
                  valor: d,
                  seleccion: actual,
                  titulo: textoPlazo(d),
                  subtitulo: d == n.maximoRecomendadoDias
                      ? 'Máximo recomendado'
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
              clave: 'Espacio aproximado',
              valor:
                  '${n.mbMinimo} a ${n.mbMaximo} MB por cámara al día (estimado)',
            ),
            if (permiso && n.retencionDias != null && n.datosDesde != null)
              FilaDato(
                clave: 'Hay movimientos desde',
                valor: fechaNumerica(n.datosDesde!),
                mono: true,
              ),
            if (camaras != null) FilaDato(clave: 'Cámaras', valor: '$camaras'),
          ]),
        ),
        if (permiso && n.retencionDias != null && sinConexion != null) ...[
          const SizedBox(height: 12),
          Aviso(
            tono: TonoAviso.neutral,
            icono: Ico.clock,
            texto:
                'La PC ${sinConexion.nombre} subirá sus movimientos al '
                'reconectarse.',
          ),
        ],
        const SizedBox(height: 12),
        const Aviso(
          tono: TonoAviso.info,
          icono: Ico.video,
          texto: 'Nunca guardamos video en la nube.',
        ),
      ],
    );
  }
}
