import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/cache/cache_local.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/web/entorno.dart';
import '../../../l10n/l10n.dart';
import '../data/pcs_repositorio.dart';
import '../domain/pc.dart';
import 'campo_codigo.dart';
import 'escaner_qr.dart';
import 'navegacion_pc.dart';

/// Where this phone remembers that it already explained why it uses the camera (screen 122).
const claveCamaraExplicada = '${deDispositivo}camaraQrExplicada';

enum _Estado {
  /// Before the system dialog: why the camera is needed (screen 122).
  explicar,

  /// The camera preview with the frame (screen 125).
  escaneando,

  /// A Te Tengo QR was read: looking up the PC (screen 126).
  buscando,

  /// The camera is blocked for the app (screen 124).
  bloqueada,
}

/// A notice over the preview: a QR from somewhere else (screen 127), an expired code (139)...
class _Aviso {
  const _Aviso(this.titulo, this.texto, {this.contenido});

  final String titulo;
  final String? texto;
  final InlineSpan? contenido;
}

/// «Escanear el código QR» (screens 122 to 127 and 139): the phone's camera reads the QR that Te
/// Tengo Captura shows (CA-28.1). «Escribir el código» is always at hand (CA-28.2).
class PantallaEscanear extends ConsumerStatefulWidget {
  const PantallaEscanear({super.key, this.codigoVencido = false});

  /// Back from the approval screen because the code expired meanwhile (screen 139).
  final bool codigoVencido;

  @override
  ConsumerState<PantallaEscanear> createState() => _PantallaEscanearState();
}

class _PantallaEscanearState extends ConsumerState<PantallaEscanear> {
  _Estado? _estado;
  _Aviso? _aviso;
  EscanerQr? _escaner;
  bool _linterna = false;

  /// The last QR text read, so the same one is not handled twice in a row.
  String? _ultimo;
  Timer? _ocultarAviso;

  /// The expired-code notice is still to be shown; its texts need the context.
  late bool _avisarVencido = widget.codigoVencido;

  @override
  void initState() {
    super.initState();
    unawaited(_empezar());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avisarVencido) {
      _avisarVencido = false;
      _aviso = _avisoVencido(context.l10n);
    }
  }

  _Aviso _avisoVencido(AppLocalizations l) =>
      _Aviso(l.pcsCodigoVencidoTitulo, l.pcsCodigoVencidoTexto);

  Future<void> _empezar() async {
    bool explicada;
    try {
      explicada =
          await ref.read(cacheLocalProvider).leer(claveCamaraExplicada) != null;
    } on Object {
      explicada = false;
    }
    if (!mounted) return;
    if (explicada) {
      _abrirCamara();
    } else {
      setState(() => _estado = _Estado.explicar);
    }
  }

  /// «Permitir»: the camera starts, and the system asks for the permission (screen 123).
  Future<void> _permitir() async {
    try {
      await ref.read(cacheLocalProvider).guardar(claveCamaraExplicada, 'si');
    } on Object {
      // It will be explained again next time.
    }
    _abrirCamara();
  }

  void _abrirCamara() {
    _escaner ??= ref.read(fabricaEscanerQrProvider)();
    setState(() => _estado = _Estado.escaneando);
  }

  void _alFallar(FalloEscaner fallo) {
    if (!mounted || _estado == _Estado.bloqueada) return;
    _cerrarCamara();
    setState(() => _estado = _Estado.bloqueada);
  }

  void _cerrarCamara() {
    _escaner?.dispose();
    _escaner = null;
    _linterna = false;
  }

  void _mostrarAviso(_Aviso aviso) {
    _ocultarAviso?.cancel();
    setState(() => _aviso = aviso);
    _ocultarAviso = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _aviso = null);
    });
  }

  Future<void> _alLeer(String valor) async {
    if (_estado != _Estado.escaneando || valor == _ultimo) return;
    _ultimo = valor;
    final codigo = codigoDeQr(valor);
    if (codigo == null) {
      final l = context.l10n;
      return _mostrarAviso(_Aviso(l.pcsQrAjenoTitulo, l.pcsQrAjenoTexto));
    }
    if (!ref.read(esTitularProvider)) {
      context.pushReplacement(Rutas.aprobarPc(codigo));
      return;
    }
    setState(() {
      _estado = _Estado.buscando;
      _aviso = null;
    });
    try {
      final consulta = await ref.read(pcsRepositorioProvider).consultar(codigo);
      if (!mounted) return;
      context.pushReplacement(
        Rutas.aprobarPc(consulta.codigo),
        extra: consulta,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      final error = ErrorDeCodigo.desde(e);
      if (error.tipo == TipoErrorCodigo.soloTitular) {
        context.pushReplacement(Rutas.aprobarPc(codigo));
        return;
      }
      if (error.tipo == TipoErrorCodigo.yaVinculada) {
        avisarPcYaVinculada(context);
        return;
      }
      setState(() => _estado = _Estado.escaneando);
      final l = context.l10n;
      _mostrarAviso(switch (error.tipo) {
        TipoErrorCodigo.vencido => _avisoVencido(l),
        TipoErrorCodigo.bloqueado => _Aviso(
          l.pcsDemasiadosIntentos,
          null,
          contenido: textoBloqueo(l, error.bloqueadaHasta),
        ),
        TipoErrorCodigo.sinConexion => _Aviso(
          l.pcsSinInternet,
          l.pcsRevisaConexion,
        ),
        _ => _Aviso(error.texto(l), null),
      });
      // The same QR can be read again once the notice is shown.
      _ultimo = null;
    }
  }

  void _escribir() => context.pushReplacement(Rutas.escribirCodigo);

  @override
  void dispose() {
    _ocultarAviso?.cancel();
    _cerrarCamara();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.noche,
      appBar: AppBar(
        backgroundColor: Colores.noche,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: context.l10n.pcsVolver,
          icon: const Icono(Ico.back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.l10n.pcsAgregarPc,
          style: estiloTexto(20, 700, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: switch (_estado) {
              null => const SizedBox.shrink(),
              _Estado.explicar => _Explicar(
                alPermitir: _permitir,
                alEscribir: _escribir,
              ),
              _Estado.bloqueada => _Bloqueada(
                alEscribir: _escribir,
                alAbrirAjustes: ref.watch(entornoNavegadorProvider).esWeb
                    ? null
                    : () => unawaited(openAppSettings()),
              ),
              _Estado.escaneando || _Estado.buscando => _Visor(
                escaner: _escaner!,
                buscando: _estado == _Estado.buscando,
                aviso: _aviso,
                linterna: _linterna,
                alLeer: _alLeer,
                alFallar: _alFallar,
                alLinterna: () {
                  setState(() => _linterna = !_linterna);
                  unawaited(_escaner?.alternarLinterna());
                },
              ),
            },
          ),
          _Pie(alEscribir: _escribir),
        ],
      ),
    );
  }
}

class _Visor extends StatelessWidget {
  const _Visor({
    required this.escaner,
    required this.buscando,
    required this.aviso,
    required this.linterna,
    required this.alLeer,
    required this.alFallar,
    required this.alLinterna,
  });

  final EscanerQr escaner;
  final bool buscando;
  final _Aviso? aviso;
  final bool linterna;
  final ValueChanged<String> alLeer;
  final ValueChanged<FalloEscaner> alFallar;
  final VoidCallback alLinterna;

  @override
  Widget build(BuildContext context) {
    final aviso = this.aviso;
    return LayoutBuilder(
      builder: (context, limites) {
        final lado = (limites.biggest.shortestSide * 0.68).clamp(160.0, 300.0);
        return Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: context.l10n.pcsCamaraDelCelular,
              child: escaner.vista(alLeer: alLeer, alFallar: alFallar),
            ),
            Center(
              child: SizedBox.square(
                dimension: lado,
                child: const CustomPaint(painter: _Marco()),
              ),
            ),
            Positioned(
              top: 16,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    context.l10n.pcsApuntaAlQr,
                    textAlign: TextAlign.center,
                    style: estiloTexto(22, 700, color: Colors.white).copyWith(
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 8),
                      ],
                    ),
                  ),
                  if (aviso != null) ...[
                    const SizedBox(height: 12),
                    Aviso(
                      tono: TonoAviso.advertencia,
                      icono: Ico.qr,
                      titulo: aviso.titulo,
                      texto: aviso.texto,
                      contenido: aviso.contenido,
                    ),
                  ],
                ],
              ),
            ),
            if (buscando)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colores.nocheEtiqueta,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              context.l10n.pcsBuscandoPc,
                              style: estiloTexto(17, 700, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                right: 20,
                bottom: 20,
                child: Semantics(
                  button: true,
                  toggled: linterna,
                  label: context.l10n.pcsLinterna,
                  child: Material(
                    color: linterna ? Colors.white : const Color(0x33FFFFFF),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: alLinterna,
                      child: SizedBox.square(
                        dimension: 56,
                        child: Center(
                          child: Icono(
                            Ico.flash,
                            color: linterna ? Colores.tinta : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The square frame with coral corners (`.scan-frame`).
class _Marco extends CustomPainter {
  const _Marco();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colores.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final l = size.width * 0.18;
    final w = size.width;
    final h = size.height;
    for (final (a, b, c) in [
      (Offset(0, l), Offset.zero, Offset(l, 0)),
      (Offset(w - l, 0), Offset(w, 0), Offset(w, l)),
      (Offset(w, h - l), Offset(w, h), Offset(w - l, h)),
      (Offset(l, h), Offset(0, h), Offset(0, h - l)),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_Marco oldDelegate) => false;
}

class _Explicar extends StatelessWidget {
  const _Explicar({required this.alPermitir, required this.alEscribir});

  final VoidCallback alPermitir;
  final VoidCallback alEscribir;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0x33FF8F7E),
            shape: BoxShape.circle,
          ),
          child: const Icono(Ico.cam, tamano: 32, color: Colores.durazno),
        ),
      ),
      const SizedBox(height: 20),
      Semantics(
        header: true,
        child: Text(
          context.l10n.pcsExplicarCamara,
          style: estiloTexto(24, 800, color: Colors.white),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        context.l10n.pcsNoGuardaImagenes,
        style: estiloTexto(17, 400, color: Colores.nocheTexto),
      ),
      const SizedBox(height: 20),
      Boton(
        context.l10n.pcsPermitir,
        estilo: EstiloBoton.blanco,
        colorTexto: Colores.morado,
        alPresionar: alPermitir,
      ),
      const SizedBox(height: 12),
      Boton(
        context.l10n.pcsEscribirCodigo,
        estilo: EstiloBoton.sobreRojo,
        alPresionar: alEscribir,
      ),
    ],
  );
}

class _Bloqueada extends StatelessWidget {
  const _Bloqueada({required this.alEscribir, required this.alAbrirAjustes});

  final VoidCallback alEscribir;

  /// Null on the web, where the browser's own settings apply.
  final VoidCallback? alAbrirAjustes;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
    children: [
      Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.lock,
        titulo: context.l10n.pcsCamaraBloqueada,
      ),
      const SizedBox(height: 16),
      Boton(
        context.l10n.pcsEscribirCodigo,
        icono: Ico.keyboard,
        estilo: EstiloBoton.blanco,
        colorTexto: Colores.morado,
        alPresionar: alEscribir,
      ),
      if (alAbrirAjustes != null) ...[
        const SizedBox(height: 12),
        Boton(
          context.l10n.pcsAbrirAjustesCelular,
          estilo: EstiloBoton.sobreRojo,
          alPresionar: alAbrirAjustes,
        ),
      ],
    ],
  );
}

class _Pie extends StatelessWidget {
  const _Pie({required this.alEscribir});

  final VoidCallback alEscribir;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.pcsNoPuedesEscanear,
            textAlign: TextAlign.center,
            style: estiloTexto(17, 400, color: Colores.nocheTexto),
          ),
          const SizedBox(height: 10),
          Boton(
            context.l10n.pcsEscribirCodigo,
            icono: Ico.keyboard,
            estilo: EstiloBoton.sobreRojo,
            alPresionar: alEscribir,
          ),
        ],
      ),
    ),
  );
}
