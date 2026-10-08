import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/web/entorno.dart';

// The copy of this file is not in the prototype (the web app is not in it): it is marked for team
// review in docs/BLOCKERS.md.

/// On an iPhone or iPad browser tab, the notice that alerts only arrive once Te Tengo is on the
/// home screen (iOS 16.4+ only gives Web Push to home-screen web apps). Nothing elsewhere.
class AvisoInstalarApp extends ConsumerWidget {
  const AvisoInstalarApp({super.key, this.separacion = 12});

  /// Space below the notice when it is shown.
  final double separacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(entornoNavegadorProvider).debeInstalar) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: separacion),
      child: Aviso(
        tono: TonoAviso.info,
        icono: Ico.bell,
        titulo: 'Agrega Te Tengo a tu pantalla de inicio',
        texto:
            'En el iPhone, las alertas solo llegan si abres Te Tengo desde '
            'su ícono.',
        accion: Boton(
          'Ver cómo',
          estilo: EstiloBoton.tinta,
          pequeno: true,
          alPresionar: () => context.push(Rutas.instalar),
        ),
      ),
    );
  }
}

/// «Agregar a la pantalla de inicio»: how to install the web app on an iPhone.
class PantallaInstalarApp extends StatelessWidget {
  const PantallaInstalarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar a la pantalla de inicio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.share,
              fondo: Colores.moradoSuave,
              color: Colores.morado,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              'Instala Te Tengo en tu iPhone',
              style: texto.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Así te llegarán las alertas de caída aunque tengas la app '
            'cerrada. Necesitas iOS 16.4 o posterior.',
            style: texto.bodyLarge?.copyWith(color: Colores.tinta2),
          ),
          const SizedBox(height: 12),
          const PasosNumerados([
            ('Abre esta página en Safari', null),
            (
              'Toca Compartir',
              'El cuadrado con una flecha hacia arriba, en la barra de Safari '
                  'o dentro del menú «···».',
            ),
            (
              'Elige «Agregar a inicio»',
              'Si no lo ves, toca «Ver más» y desliza la lista hacia arriba.',
            ),
            ('Toca «Agregar»', null),
            (
              'Abre Te Tengo desde su ícono',
              'Inicia sesión otra vez y toca «Activar notificaciones».',
            ),
          ]),
        ],
      ),
    );
  }
}
