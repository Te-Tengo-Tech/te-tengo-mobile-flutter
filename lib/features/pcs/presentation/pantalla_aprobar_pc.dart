import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/pcs_repositorio.dart';
import '../domain/pc.dart';
import 'campo_codigo.dart';
import 'navegacion_pc.dart';
import 'piezas_pc.dart';

/// «Aprobar la PC» (screens 134 to 141): the PC's name, system and program, and what it will be able
/// to do, before «Aprobar» or «No reconozco esta PC» (CA-28.4). Only the owner approves (CA-28.5).
/// The PC's QR opens it directly (`/vincular?codigo=…`).
class PantallaAprobarPc extends ConsumerStatefulWidget {
  const PantallaAprobarPc({
    super.key,
    required this.codigo,
    this.consulta,
    this.enConfiguracion = false,
  });

  /// As scanned or typed; shown as `KQWT-MXHD`.
  final String codigo;

  /// Already looked up by the scanner or the code screen.
  final ConsultaPc? consulta;
  final bool enConfiguracion;

  @override
  ConsumerState<PantallaAprobarPc> createState() => _PantallaAprobarPcState();
}

class _PantallaAprobarPcState extends ConsumerState<PantallaAprobarPc> {
  late ConsultaPc? _consulta = widget.consulta;
  ErrorDeCodigo? _errorConsulta;
  bool _aprobando = false;
  bool _rechazando = false;

  /// «No pudimos vincular la PC» (screen 138).
  bool _errorRed = false;
  ProblemaApi? _problema;

  /// The code of the link, or null when the link has none that could be a code.
  late final String? _codigo = codigoValido(widget.codigo);

  bool get _soloTitular =>
      !ref.read(esTitularProvider) ||
      _errorConsulta?.tipo == TipoErrorCodigo.soloTitular;

  @override
  void initState() {
    super.initState();
    if (_consulta == null && ref.read(esTitularProvider)) {
      unawaited(_consultar());
    }
  }

  Future<void> _consultar() async {
    final codigo = _codigo;
    if (codigo == null) {
      setState(
        () => _errorConsulta = const ErrorDeCodigo(
          TipoErrorCodigo.incorrecto,
          'Ese código no existe. Revísalo letra por letra.',
        ),
      );
      return;
    }
    setState(() => _errorConsulta = null);
    try {
      final consulta = await ref.read(pcsRepositorioProvider).consultar(codigo);
      if (mounted) setState(() => _consulta = consulta);
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _errorConsulta = ErrorDeCodigo.desde(e));
    }
  }

  Future<void> _aprobar() async {
    final consulta = _consulta;
    if (consulta == null || _aprobando) return;
    setState(() {
      _aprobando = true;
      _errorRed = false;
      _problema = null;
    });
    try {
      final pc = await ref
          .read(pcsRepositorioProvider)
          .aprobar(consulta.codigo);
      ref
        ..invalidate(pcsProvider)
        ..invalidate(camarasProvider);
      if (!mounted) return;
      _alVincular(pc);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      final error = ErrorDeCodigo.desde(e);
      switch (error.tipo) {
        case TipoErrorCodigo.vencido:
          // The code expired while deciding (screen 139): scan the new one.
          context.pushReplacement(
            Uri(
              path: Rutas.escanear,
              queryParameters: {
                'vencido': '1',
                if (widget.enConfiguracion) 'config': '1',
              },
            ).toString(),
          );
        case TipoErrorCodigo.sinConexion:
          setState(() => _errorRed = true);
        case TipoErrorCodigo.soloTitular:
          setState(() => _errorConsulta = error);
        default:
          setState(() => _problema = e);
      }
    } finally {
      if (mounted) setState(() => _aprobando = false);
    }
  }

  /// In setup, back to step 3, which now shows the linked PC; otherwise «PC vinculada».
  void _alVincular(Pc pc) {
    final hayOrigen = cerrarVinculacion(context);
    if (widget.enConfiguracion) {
      if (!hayOrigen) context.go(Rutas.configCamara);
      return;
    }
    if (hayOrigen) {
      unawaited(context.push(Rutas.pcVinculada(pc.id)));
    } else {
      context.go(Rutas.pcVinculada(pc.id));
    }
  }

  /// «No reconozco esta PC» (screen 141): the PC is not linked.
  Future<void> _rechazar() async {
    final consulta = _consulta;
    if (consulta == null || _rechazando) return;
    setState(() => _rechazando = true);
    try {
      await ref.read(pcsRepositorioProvider).rechazar(consulta.codigo);
    } on ProblemaApi {
      // Expired or offline: the PC is not linked either way.
    }
    if (!mounted) return;
    setState(() => _rechazando = false);
    await _avisarRechazo();
    if (!mounted) return;
    if (!cerrarVinculacion(context)) {
      context.go(widget.enConfiguracion ? Rutas.configCamara : Rutas.inicio);
    }
  }

  Future<void> _avisarRechazo() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroePc(
              icono: Ico.shield,
              fondo: context.colores.caidaSuave,
              color: context.colores.caidaTinta,
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'No vinculamos la PC',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La PC no tendrá acceso. No escanees códigos ajenos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Boton('Entendido', alPresionar: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    ),
  );

  void _otroCodigo(String ruta) => context.pushReplacement(
    Rutas.enPaso(ruta, config: widget.enConfiguracion),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobar la PC'),
        // Opened from the PC's QR there is nothing behind it.
        leading: context.canPop()
            ? null
            : IconButton(
                tooltip: 'Cerrar',
                icon: const Icono(Ico.x),
                onPressed: () => context.go(
                  widget.enConfiguracion ? Rutas.configCamara : Rutas.inicio,
                ),
              ),
      ),
      body: _cuerpo(context),
    );
  }

  Widget _cuerpo(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final error = _errorConsulta;
    final soloTitular = _soloTitular;
    if (!soloTitular && error != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const HeroePc(),
          const SizedBox(height: 16),
          if (error.tipo == TipoErrorCodigo.bloqueado)
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.clock,
              titulo: error.texto,
              contenido: textoBloqueo(error.bloqueadaHasta),
            )
          else if (error.tipo == TipoErrorCodigo.vencido)
            const Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.clock,
              titulo: 'Este código ya venció o ya se usó',
              texto: 'La PC ya muestra uno nuevo: escríbelo o escanéalo.',
            )
          else if (error.tipo == TipoErrorCodigo.sinConexion)
            const Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              titulo: 'Sin internet',
              texto: 'Revisa tu conexión y vuelve a intentarlo.',
            )
          else
            Aviso(tono: TonoAviso.error, icono: Ico.warn, texto: error.texto),
          const SizedBox(height: 20),
          if (error.tipo == TipoErrorCodigo.sinConexion)
            Boton(
              'Volver a intentarlo',
              icono: Ico.refresh,
              alPresionar: _consultar,
            )
          else if (error.tipo != TipoErrorCodigo.bloqueado) ...[
            Boton(
              'Escanear el código QR',
              icono: Ico.scan,
              alPresionar: () => _otroCodigo(Rutas.escanear),
            ),
            const SizedBox(height: 12),
            Boton(
              'Escribir el código',
              icono: Ico.keyboard,
              estilo: EstiloBoton.secundario,
              alPresionar: () => _otroCodigo(Rutas.escribirCodigo),
            ),
          ],
        ],
      );
    }
    final consulta = _consulta;
    final nombre = ref.watch(nombreAdultoMayorProvider);
    if ((!soloTitular && consulta == null) || nombre == null) {
      // Screen 134.
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Buscando la PC…', style: texto.bodyMedium),
            ],
          ),
        ),
      );
    }
    final codigo = consulta?.codigo ?? _codigo ?? widget.codigo;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        const HeroePc(),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            '¿Vinculamos esta PC a la casa de $nombre?',
            style: texto.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        if (_errorRed) ...[
          const Aviso(
            tono: TonoAviso.advertencia,
            icono: Ico.wifiOff,
            titulo: 'No pudimos vincular la PC',
            texto: 'Revisa tu conexión y vuelve a intentarlo.',
          ),
          const SizedBox(height: 16),
        ],
        if (_problema != null) ...[
          MensajeProblema(_problema!),
          const SizedBox(height: 16),
        ],
        TarjetaBanda(
          borde: true,
          relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: DatosTarjeta([
            if (consulta != null) ...[
              FilaDato(clave: 'Nombre de la PC', valor: consulta.nombrePc),
              if (consulta.sistemaOperativo case final so?)
                FilaDato(clave: 'Sistema', valor: so),
              if (consulta.versionAgente case final v?)
                FilaDato(clave: 'Programa', valor: 'Te Tengo Captura $v'),
            ],
            FilaDato(clave: 'Código', valor: codigo, mono: true),
          ]),
        ),
        const EncabezadoSeccion('Si la apruebas, esta PC podrá:'),
        const _Permiso(Ico.cam, 'Detectar caídas con sus cámaras'),
        const _Permiso(Ico.bell, 'Enviar avisos y clips de 12 s'),
        const _Permiso(Ico.video, 'Mostrar la vista en vivo'),
        const SizedBox(height: 12),
        Aviso(
          tono: TonoAviso.neutral,
          icono: Ico.info,
          texto:
              'Apruébala solo si estás frente a la PC de $nombre o tú la '
              'instalaste.',
        ),
        const SizedBox(height: 20),
        if (soloTitular)
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'vincular una PC. Pídele que escanee el código',
          )
        else ...[
          Boton(
            'Aprobar',
            icono: Ico.check,
            cargando: _aprobando,
            textoCargando: 'Vinculando…',
            alPresionar: _rechazando ? null : _aprobar,
          ),
          const SizedBox(height: 12),
          Boton(
            'No reconozco esta PC',
            estilo: EstiloBoton.peligroContorno,
            cargando: _rechazando,
            alPresionar: _aprobando ? null : _rechazar,
          ),
        ],
      ],
    );
  }
}

/// «Si la apruebas, esta PC podrá:» row: coral icon and text (`.can`).
class _Permiso extends StatelessWidget {
  const _Permiso(this.icono, this.texto);

  final Ico icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          // Coral is the brand accent, never an alert (DESIGN.md).
          decoration: BoxDecoration(
            color: Colores.coral.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icono(icono, tamano: 22, color: Colores.coral),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            texto,
            style: estiloTexto(17, 400, color: context.colores.tinta),
          ),
        ),
      ],
    ),
  );
}
