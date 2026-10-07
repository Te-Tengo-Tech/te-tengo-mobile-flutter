import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Inicio provisional: la tarjeta de estado del adulto mayor llega con las historias del Sprint 3.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Te Tengo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cerca de los tuyos, aunque estés lejos.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/camaras'),
            icon: const Icon(Icons.videocam_outlined),
            label: const Text('Ver la cámara'),
          ),
        ],
      ),
    );
  }
}
