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
import '../data/pcs_repositorio.dart';
import '../domain/pc.dart';
import 'campo_codigo.dart';
import 'escaner_qr.dart';

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
  const PantallaEscanear({
    super.key,
    this.enConfiguracion = false,
    this.codigoVencido = false,
  });

  final bool enConfiguracion;

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

  @override
  void initState() {
    super.initState();
    if (widget.codigoVencido) {
      _aviso = const _Aviso(
        'Este código ya venció o ya se usó',
        'La PC ya muestra uno nuevo: escríbelo o escanéalo.',
      );
    }
    unawaited(_empezar());
  }

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
      return _mostrarAviso(
        const _Aviso(
          'Ese código no es de Te Tengo Captura',
          'Apunta al código QR que muestra la PC.',
        ),
      );
    }
    final config = widget.enConfiguracion;
    if (!ref.read(esTitularProvider)) {
      context.pushReplacement(Rutas.aprobarPc(codigo, config: config));
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
        Rutas.aprobarPc(consulta.codigo, config: config),
        extra: consulta,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      final error = ErrorDeCodigo.desde(e);
      if (error.tipo == TipoErrorCodigo.soloTitular) {
        context.pushReplacement(Rutas.aprobarPc(codigo, config: config));
        return;
      }
      setState(() => _estado = _Estado.escaneando);
      _mostrarAviso(switch (error.tipo) {
        TipoErrorCodigo.vencido => const _Aviso(
          'Este código ya venció o ya se usó',
          'La PC ya muestra uno nuevo: escríbelo o escanéalo.',
        ),
        TipoErrorCodigo.bloqueado => _Aviso(
          'Demasiados intentos',
          null,
          contenido: textoBloqueo(error.bloqueadaHasta),
        ),
        TipoErrorCodigo.sinConexion => const _Aviso(
          'Sin internet',
          'Revisa tu conexión y vuelve a intentarlo.',
        ),
        _ => _Aviso(error.texto, null),
      });
      // The same QR can be read again once the notice is shown.
      _ultimo = null;
    }
  }

  void _escribir() => context.pushReplacement(
    Rutas.enPaso(Rutas.escribirCodigo, config: widget.enConfiguracion),
  );

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
          tooltip: 'Volver',
          icon: const Icono(Ico.back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Agregar PC',
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
              label: 'Cámara del celular',
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
                    'Apunta al QR de la PC',
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
                              'Buscando la PC…',
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
                  label: 'Linterna',
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
          'Te Tengo usará la cámara para leer el QR.',
          style: estiloTexto(24, 800, color: Colors.white),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'No guarda imágenes.',
        style: estiloTexto(17, 400, color: Colores.nocheTexto),
      ),
      const SizedBox(height: 20),
      Boton(
        'Permitir',
        estilo: EstiloBoton.blanco,
        colorTexto: Colores.morado,
        alPresionar: alPermitir,
      ),
      const SizedBox(height: 12),
      Boton(
        'Escribir el código',
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
      const Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.lock,
        titulo: 'La cámara del celular está bloqueada',
      ),
      const SizedBox(height: 16),
      Boton(
        'Escribir el código',
        icono: Ico.keyboard,
        estilo: EstiloBoton.blanco,
        colorTexto: Colores.morado,
        alPresionar: alEscribir,
      ),
      if (alAbrirAjustes != null) ...[
        const SizedBox(height: 12),
        Boton(
          'Abrir los ajustes del celular',
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
            '¿No puedes escanearlo?',
            textAlign: TextAlign.center,
            style: estiloTexto(17, 400, color: Colores.nocheTexto),
          ),
          const SizedBox(height: 10),
          Boton(
            'Escribir el código',
            icono: Ico.keyboard,
            estilo: EstiloBoton.sobreRojo,
            alPresionar: alEscribir,
          ),
        ],
      ),
    ),
  );
}
