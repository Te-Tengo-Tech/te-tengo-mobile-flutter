import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../data/camaras_repositorio.dart';
import 'estado_camara.dart';

/// US-06 / CA-06.1 and US-07 / CA-07.1: household cameras with status and last-signal time.
class PantallaCamaras extends ConsumerWidget {
  const PantallaCamaras({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camaras = ref.watch(camarasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara')),
      body: camaras.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is ProblemaApi
                  ? error.detalle
                  : 'No se pudo cargar la cámara.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (lista) => lista.isEmpty
            ? const Center(child: Text('Todavía no hay una cámara instalada.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final camara = lista[i];
                  final senal = camara.ultimaSenal;
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        camara.nombreHabitacion,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          EstadoCamara(
                            estado: camara.estadoVisible(
                              conConsentimiento: true,
                            ),
                          ),
                          if (senal != null)
                            Text(
                              'Última señal: ${senal.hour.toString().padLeft(2, '0')}:'
                              '${senal.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontFamily: fuenteMono),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => context.go(
                        '/camaras/${camara.id}/nombre?actual=${Uri.encodeComponent(camara.nombreHabitacion)}',
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
