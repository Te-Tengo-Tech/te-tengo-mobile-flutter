import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'tema/tema.dart';

/// Aplicación del familiar/cuidador (contenedor «Aplicación del familiar/cuidador» del modelo C4).
class TeTengoApp extends ConsumerWidget {
  const TeTengoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Te Tengo',
      debugShowCheckedModeBanner: false,
      theme: temaTeTengo(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
