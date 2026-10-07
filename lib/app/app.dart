import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dispositivo/permiso_notificaciones.dart';
import '../core/ui/avisos_flotantes.dart';
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
      onResume: () => ref.invalidate(notificacionesActivasProvider),
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
    return MaterialApp.router(
      title: 'Te Tengo',
      debugShowCheckedModeBanner: false,
      theme: temaTeTengo(),
      routerConfig: ref.watch(routerProvider),
      builder: (context, hijo) =>
          AnfitrionAvisos(child: hijo ?? const SizedBox.shrink()),
    );
  }
}
