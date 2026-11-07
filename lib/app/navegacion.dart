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
import '../l10n/l10n.dart';

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

  static const _iconos = [Ico.home, Ico.hist, Ico.users, Ico.sliders];

  static List<String> _nombres(AppLocalizations l) => [
    l.navInicio,
    l.navHistorial,
    l.navFamilia,
    l.navAjustes,
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
    final nombres = _nombres(context.l10n);
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
          // The selected tab shows with its pill and its label: every icon is the same color.
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
              for (var i = 0; i < _iconos.length; i++)
                NavigationDestination(
                  label: nombres[i],
                  tooltip: '',
                  icon: _icono(
                    context,
                    i,
                    context.colores.icono,
                    alertasActivas,
                  ),
                  selectedIcon: _icono(
                    context,
                    i,
                    context.colores.icono,
                    alertasActivas,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icono(BuildContext context, int i, Color color, int alertasActivas) {
    final icono = Icono(_iconos[i], tamano: 26, color: color);
    if (i != 1 || alertasActivas == 0) return icono;
    return Badge(
      label: Text('$alertasActivas'),
      backgroundColor: Colores.caida,
      child: Semantics(
        label: context.l10n.navAlertasActivas(alertasActivas),
        child: icono,
      ),
    );
  }
}
