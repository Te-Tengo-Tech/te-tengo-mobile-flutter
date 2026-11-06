import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/web/entorno.dart';
import '../../../l10n/l10n.dart';

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
        titulo: context.l10n.instalarAvisoTitulo,
        texto: context.l10n.instalarAvisoTexto,
        accion: Boton(
          context.l10n.instalarVerComo,
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
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.instalarTitulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.share,
              fondo: context.colores.moradoSuave,
              color: Colores.morado,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(l.instalarEncabezado, style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text(
            l.instalarIntro,
            style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
          ),
          const SizedBox(height: 12),
          PasosNumerados([
            (l.instalarPaso1, null),
            (l.instalarPaso2, l.instalarPaso2Detalle),
            (l.instalarPaso3, l.instalarPaso3Detalle),
            (l.instalarPaso4, null),
            (l.instalarPaso5, l.instalarPaso5Detalle),
          ]),
        ],
      ),
    );
  }
}
