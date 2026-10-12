import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/actualizacion_controller.dart';
import '../data/interrupcion.dart';
import '../domain/estado_actualizacion.dart';
import 'pantalla_version_obligatoria.dart';
import 'rutas_actualizaciones.dart';

/// Above the router: looks for a new version when the app opens, when it comes back from the
/// background and once a day (`PlanBusqueda`); follows the screen on top so nothing about the
/// update interrupts an alert or a live view (CA-43.9); covers the app with the minimum-version
/// screen (CA-43.8) or «Actualizando…» (PWA); and opens «Permite instalar la actualización» when
/// Android needs its permission.
class GuardiaActualizaciones extends ConsumerStatefulWidget {
  const GuardiaActualizaciones({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GuardiaActualizaciones> createState() =>
      _GuardiaActualizacionesState();
}

class _GuardiaActualizacionesState
    extends ConsumerState<GuardiaActualizaciones> {
  late final AppLifecycleListener _ciclo;
  Timer? _diaria;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(
      onResume: () => _buscar(MotivoBusqueda.reanudar),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(actualizacionProvider.notifier);
      unawaited(controller.alAbrir());
      _buscar(MotivoBusqueda.abrir);
    });
  }

  void _buscar(MotivoBusqueda motivo) {
    _programarDiaria();
    unawaited(ref.read(actualizacionProvider.notifier).buscar(motivo));
  }

  /// One more check a day after the last one, while the app stays open.
  void _programarDiaria() {
    _diaria?.cancel();
    _diaria = Timer(PlanBusqueda.cadaDia, () => _buscar(MotivoBusqueda.diaria));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _seguirRouter(ref.read(routerProvider));
  }

  void _seguirRouter(GoRouter router) {
    if (identical(router, _router)) return;
    _router?.routerDelegate.removeListener(_alCambiarRuta);
    _router = router..routerDelegate.addListener(_alCambiarRuta);
    WidgetsBinding.instance.addPostFrameCallback((_) => _anotarRuta());
  }

  void _alCambiarRuta() {
    if (!mounted) return;
    // The router notifies while the tree builds; a provider changes only between frames.
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _anotarRuta());
      return;
    }
    _anotarRuta();
  }

  void _anotarRuta() {
    if (!mounted) return;
    final router = _router;
    if (router == null) return;
    // A pushed screen (an alert opened from a push or by itself) is the last imperative match.
    final actual = router.routerDelegate.currentConfiguration;
    final ultimo = actual.isEmpty ? null : actual.last;
    final ruta = ultimo is ImperativeRouteMatch
        ? ultimo.matches.uri.path
        : actual.uri.path;
    ref.read(rutaActualProvider.notifier).cambiar(ruta);
  }

  @override
  void dispose() {
    _ciclo.dispose();
    _diaria?.cancel();
    _router?.routerDelegate.removeListener(_alCambiarRuta);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    _seguirRouter(router);
    final estado = ref.watch(actualizacionProvider);
    ref.listen(actualizacionProvider.select((e) => e.pedirPermiso), (_, pedir) {
      if (!pedir) return;
      ref.read(actualizacionProvider.notifier).permisoMostrado();
      unawaited(router.push(RutasActualizaciones.permiso));
    });
    // The verified APK waits for the alert or the live view to close (CA-43.9).
    if (estado.fase == FaseActualizacion.esperando) {
      ref.listen(interrupcionActivaProvider, (_, activa) {
        if (!activa) {
          unawaited(ref.read(actualizacionProvider.notifier).continuar());
        }
      });
    }
    final ruta = ref.watch(rutaActualProvider);
    final libre =
        esRutaProtegida(ruta) ||
        RutasActualizaciones.libres.any(
          (r) => ruta == r || ruta.startsWith('$r/'),
        );
    final cubierta = cubiertaPara(estado, rutaLibre: libre);
    final cubierto = cubierta != Cubierta.ninguna;
    return Stack(
      fit: StackFit.expand,
      children: [
        // The app stays built underneath: an active alert still opens itself (CA-16.4), and then
        // the cover steps aside.
        Offstage(offstage: cubierto, child: widget.child),
        if (cubierto)
          Positioned.fill(
            child: InheritedGoRouter(
              goRouter: router,
              child: Overlay(
                key: ValueKey(cubierta),
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => cubierta == Cubierta.actualizando
                        ? const PantallaActualizando()
                        : const PantallaVersionObligatoria(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
