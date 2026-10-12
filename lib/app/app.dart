import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dispositivo/permiso_notificaciones.dart';
import '../core/ui/avisos_flotantes.dart';
import '../features/ajustes/data/apariencia.dart';
import '../features/actualizaciones/presentation/guardia_actualizaciones.dart';
import '../features/ajustes/data/contraste.dart';
import '../features/alertas/data/alertas_repositorio.dart';
import '../features/widget/presentation/actualizador_widget.dart';
import 'push.dart';
import 'router.dart';
import 'tema/tema.dart';

/// Family member / caregiver app (the "Aplicación del familiar/cuidador" container of the C4 model).
class TeTengoApp extends ConsumerStatefulWidget {
  const TeTengoApp({super.key});

  @override
  ConsumerState<TeTengoApp> createState() => _TeTengoAppState();
}

class _TeTengoAppState extends ConsumerState<TeTengoApp> {
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    // Notification permission can change in the system settings while the app is in background.
    _ciclo = AppLifecycleListener(
      onResume: () {
        ref
          ..invalidate(notificacionesActivasProvider)
          ..invalidate(alertaActivaProvider);
        // Every return registers the phone again: the backend records when it was last seen, a
        // token that was not ready (iOS waits for APNs) or a permission granted in the system
        // settings is registered now, and a token the push service dropped is replaced.
        unawaited(ref.read(gestorPushProvider).registrar(forzar: true));
      },
    );
    unawaited(ref.read(gestorPushProvider).iniciar());
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // «Aumentar el contraste» in Ajustes › «Preferencias», or the phone's own accessibility
    // setting (the high-contrast themes below).
    final contraste = ref.watch(contrasteProvider);
    return MaterialApp.router(
      title: 'Te Tengo',
      debugShowCheckedModeBanner: false,
      theme: temaTeTengo(contraste: contraste),
      darkTheme: temaTeTengo(oscuro: true, contraste: contraste),
      highContrastTheme: temaTeTengo(contraste: true),
      highContrastDarkTheme: temaTeTengo(oscuro: true, contraste: true),
      // The theme in «Preferencias»: follows the phone (or the browser) by default, or stays light
      // or dark on this device.
      themeMode: ref.watch(aparienciaProvider).modo,
      routerConfig: ref.watch(routerProvider),
      // The home-screen widget follows what the app reads (US-44); US-43 looks for a new version
      // and covers the app below the minimum one.
      builder: (context, hijo) => AnfitrionAvisos(
        child: ActualizadorWidget(
          child: GuardiaActualizaciones(
            child: hijo ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
