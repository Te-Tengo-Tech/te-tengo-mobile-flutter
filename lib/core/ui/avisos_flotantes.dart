import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';
import 'aviso.dart';
import 'iconos.dart';
import 'marca.dart';

/// Kind of floating notice.
enum TipoFlotante {
  /// Dark non-blocking toast (`.toast`).
  toast,

  /// White in-app notification with the app icon (`.inapp`), shown while the app is open.
  enApp,
}

class AvisoFlotante {
  const AvisoFlotante({
    required this.titulo,
    this.texto,
    this.icono = Ico.check,
    this.tono = TonoAviso.ok,
    this.tipo = TipoFlotante.toast,
    this.alTocar,
  });

  final String titulo;
  final String? texto;
  final Ico icono;
  final TonoAviso tono;
  final TipoFlotante tipo;

  /// Action of an in-app notification (open the camera, the alert...).
  final VoidCallback? alTocar;

  Duration get duracion => tipo == TipoFlotante.toast
      ? const Duration(milliseconds: 3400)
      : const Duration(milliseconds: 5200);
}

class AvisosFlotantes extends Notifier<AvisoFlotante?> {
  @override
  AvisoFlotante? build() => null;

  void mostrar(AvisoFlotante aviso) => state = aviso;

  void cerrar() => state = null;
}

final avisoFlotanteProvider = NotifierProvider<AvisosFlotantes, AvisoFlotante?>(
  AvisosFlotantes.new,
);

/// Shows the floating notices on top of the app, under the status bar.
class AnfitrionAvisos extends ConsumerStatefulWidget {
  const AnfitrionAvisos({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AnfitrionAvisos> createState() => _AnfitrionAvisosState();
}

class _AnfitrionAvisosState extends ConsumerState<AnfitrionAvisos> {
  Timer? _reloj;

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(avisoFlotanteProvider, (_, aviso) {
      _reloj?.cancel();
      if (aviso != null) {
        _reloj = Timer(
          aviso.duracion,
          () => ref.read(avisoFlotanteProvider.notifier).cerrar(),
        );
      }
    });
    final aviso = ref.watch(avisoFlotanteProvider);
    final sinAnimacion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: sinAnimacion
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              switchInCurve: const Cubic(.16, 1, .3, 1),
              transitionBuilder: (hijo, animacion) => FadeTransition(
                opacity: animacion,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, -.3),
                    end: Offset.zero,
                  ).animate(animacion),
                  child: hijo,
                ),
              ),
              child: aviso == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey(aviso),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: aviso.tipo == TipoFlotante.toast
                          ? _Toast(aviso)
                          : _EnApp(
                              aviso,
                              alCerrar: () => ref
                                  .read(avisoFlotanteProvider.notifier)
                                  .cerrar(),
                            ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast(this.aviso);

  final AvisoFlotante aviso;

  @override
  Widget build(BuildContext context) {
    final colorIcono = switch (aviso.tono) {
      TonoAviso.ok => const Color(0xFF7FD9A8),
      TonoAviso.advertencia => const Color(0xFFFFC76B),
      _ => Colors.white,
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: Colores.tinta,
        borderRadius: BorderRadius.circular(18),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icono(aviso.icono, tamano: 22, color: colorIcono),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      aviso.titulo,
                      style: estiloTexto(16, 700, color: Colors.white),
                    ),
                    if (aviso.texto case final t? when t.isNotEmpty)
                      Text(t, style: estiloTexto(15, 400, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnApp extends StatelessWidget {
  const _EnApp(this.aviso, {required this.alCerrar});

  final AvisoFlotante aviso;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    container: true,
    button: aviso.alTocar != null,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 8,
      shadowColor: const Color(0x29000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          alCerrar();
          aviso.alTocar?.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const IconoApp(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(aviso.titulo, style: estiloTexto(16, 700)),
                    if (aviso.texto case final t? when t.isNotEmpty)
                      Text(
                        t,
                        style: estiloTexto(15, 400, color: Colores.tinta2),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// App icon (`LOGO`): purple square with radius 28/120 and the symbol.
class IconoApp extends StatelessWidget {
  const IconoApp({super.key, this.tamano = 44});

  final double tamano;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(
      '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg">'
      '<rect width="120" height="120" rx="28" fill="#4A2A85"/>'
      '${svgSimbolo(oscuro: true).replaceAll(RegExp(r'</?svg[^>]*>'), '')}'
      '</svg>',
      width: tamano,
      height: tamano,
    ),
  );
}

/// Shows a floating notice from anywhere below the [ProviderScope].
void mostrarAvisoFlotante(BuildContext context, AvisoFlotante aviso) =>
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(avisoFlotanteProvider.notifier).mostrar(aviso);
