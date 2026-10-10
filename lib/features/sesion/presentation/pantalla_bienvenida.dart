import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/marca.dart';
import '../../instalar/presentation/instalar_app.dart';

/// Welcome (screen 01).
class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight - 32),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Logotipo(),
                    ),
                    const SizedBox(height: 20),
                    // Web app on an iPhone tab: install it before signing in, because the
                    // home-screen app does not share Safari's session.
                    const AvisoInstalarApp(separacion: 20),
                    const _Ilustracion(),
                    const SizedBox(height: 20),
                    Text(
                      'Cuida a tu familiar aunque no estés en casa.',
                      style: texto.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Una cámara en su casa detecta caídas y te avisa al '
                      'instante.',
                      style: texto.bodyLarge?.copyWith(color: Colores.tinta2),
                    ),
                    const SizedBox(height: 16),
                    const _Vineta(Ico.user, 'Sin pulseras ni botones'),
                    const _Vineta(
                      Ico.video,
                      'En vivo con su permiso, con registro',
                    ),
                    const _Vineta(Ico.shield, 'Datos protegidos por ley'),
                    const Spacer(),
                    const SizedBox(height: 18),
                    Boton(
                      'Crear cuenta',
                      alPresionar: () => context.push(Rutas.registro),
                    ),
                    const SizedBox(height: 12),
                    Boton(
                      'Ya tengo una cuenta',
                      estilo: EstiloBoton.secundario,
                      alPresionar: () => context.push(Rutas.iniciarSesion),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ilustracion extends StatelessWidget {
  const _Ilustracion();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: AspectRatio(
      aspectRatio: 16 / 11,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Habitacion(nombre: 'Sala'),
          Positioned(top: 10, left: 10, child: EtiquetaClip.escudo()),
        ],
      ),
    ),
  );
}

/// Dark tag over an illustration (`.clip .tag`).
class EtiquetaClip extends StatelessWidget {
  const EtiquetaClip({super.key, required this.texto, this.icono});

  factory EtiquetaClip.escudo() => const EtiquetaClip(
    texto: 'Solo postura, nunca rostros',
    icono: Ico.shield,
  );

  final String texto;
  final Ico? icono;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xC717121F),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icono != null) ...[
          Icono(icono!, tamano: 14, color: Colors.white),
          const SizedBox(width: 6),
        ],
        Text(texto, style: estiloTexto(13, 700, color: Colors.white)),
      ],
    ),
  );
}

class _Vineta extends StatelessWidget {
  const _Vineta(this.icono, this.texto);

  final Ico icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icono(icono, tamano: 22, color: Colores.morado),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(texto, style: estiloTexto(16, 400).copyWith(height: 1.4)),
        ),
      ],
    ),
  );
}
