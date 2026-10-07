import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ui/iconos.dart';
import 'tema/colores.dart';
import 'tema/tema.dart';

/// Bottom bar with 4 tabs: Inicio, Historial, Familia and Ajustes (DESIGN.md, Components). It is
/// the same for the owner and for an invited member.
class ShellPestanas extends StatelessWidget {
  const ShellPestanas({
    super.key,
    required this.navegacion,
    this.encima = const [],
    this.alertasActivas = 0,
  });

  final StatefulNavigationShell navegacion;

  /// Bars shown above every tab (no internet, active alert).
  final List<Widget> encima;

  /// Badge on «Historial» while an alert is active.
  final int alertasActivas;

  static const _pestanas = [
    ('Inicio', Ico.home),
    ('Historial', Ico.hist),
    ('Familia', Ico.users),
    ('Ajustes', Ico.sliders),
  ];

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.white.withValues(alpha: .96),
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colores.moradoSuave,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (estados) => estiloTexto(
              13,
              700,
              color: estados.contains(WidgetState.selected)
                  ? Colores.moradoTinta
                  : Colores.tinta3,
            ),
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colores.linea)),
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
                  icon: _icono(i, Colores.tinta3),
                  selectedIcon: _icono(i, Colores.moradoTinta),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icono(int i, Color color) {
    final icono = Icono(_pestanas[i].$2, tamano: 26, color: color);
    if (i != 1 || alertasActivas == 0) return icono;
    return Badge(
      label: Text('$alertasActivas'),
      backgroundColor: Colores.caida,
      child: Semantics(label: '1 alerta activa', child: icono),
    );
  }
}
