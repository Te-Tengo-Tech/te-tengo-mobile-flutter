import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/iconos.dart';
import '../features/alertas/data/alertas_repositorio.dart';
import '../features/alertas/presentation/pantalla_alerta.dart';
import 'rutas.dart';
import 'tema/colores.dart';
import 'tema/paleta.dart';
import 'tema/tema.dart';

/// Bottom bar with 4 tabs: Inicio, Historial, Familia and Ajustes (DESIGN.md, Components). It is
/// the same for the owner and for an invited member.
class ShellPestanas extends ConsumerWidget {
  const ShellPestanas({
    super.key,
    required this.navegacion,
    this.encima = const [],
  });

  final StatefulNavigationShell navegacion;

  /// Bars shown above every tab (no internet, active alert).
  final List<Widget> encima;

  static const _pestanas = [
    ('Inicio', Ico.home),
    ('Historial', Ico.hist),
    ('Familia', Ico.users),
    ('Ajustes', Ico.sliders),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // An active alert opens by itself once, even if its push failed (CA-16.4).
    ref.listen(alertaActivaProvider, (_, siguiente) {
      final alerta = siguiente.value;
      if (alerta == null) return;
      if (ref.read(alertasVistasProvider).contains(alerta.id)) return;
      ref.read(alertasVistasProvider.notifier).marcar(alerta.id);
      context.push(Rutas.alerta(alerta.id));
    });
    final alertasActivas = ref.watch(alertaActivaProvider).value == null
        ? 0
        : 1;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ...encima,
            Expanded(child: navegacion),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: context.colores.barra,
          surfaceTintColor: Colors.transparent,
          indicatorColor: context.colores.moradoSuave,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (estados) => estiloTexto(
              13,
              700,
              color: estados.contains(WidgetState.selected)
                  ? context.colores.moradoTinta
                  : context.colores.tinta3,
            ),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colores.linea)),
          ),
          child: NavigationBar(
            selectedIndex: navegacion.currentIndex,
            onDestinationSelected: (i) => navegacion.goBranch(
              i,
              initialLocation: i == navegacion.currentIndex,
            ),
            destinations: [
              for (var i = 0; i < _pestanas.length; i++)
                NavigationDestination(
                  label: _pestanas[i].$1,
                  tooltip: '',
                  icon: _icono(i, context.colores.tinta3, alertasActivas),
                  selectedIcon: _icono(
                    i,
                    context.colores.moradoTinta,
                    alertasActivas,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icono(int i, Color color, int alertasActivas) {
    final icono = Icono(_pestanas[i].$2, tamano: 26, color: color);
    if (i != 1 || alertasActivas == 0) return icono;
    return Badge(
      label: Text('$alertasActivas'),
      backgroundColor: Colores.caida,
      child: Semantics(label: '1 alerta activa', child: icono),
    );
  }
}
