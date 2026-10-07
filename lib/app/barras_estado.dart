import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dispositivo/conectividad.dart';
import '../core/ui/iconos.dart';
import 'tema/colores.dart';
import 'tema/tema.dart';

/// «Tu celular no tiene internet» (screen 27), above every tab.
class BarraSinInternet extends ConsumerWidget {
  const BarraSinInternet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sinInternetProvider).value != true) {
      return const SizedBox.shrink();
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colores.tinta,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icono(Ico.wifiOff, tamano: 22, color: Color(0xFFFFC76B)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu celular no tiene internet',
                    style: estiloTexto(16, 700, color: Colors.white),
                  ),
                  Text(
                    'Las alertas llegarán cuando vuelvas a conectarte. Si no '
                    'atiendes una a tiempo, avisamos a tu contacto secundario.',
                    style: estiloTexto(15, 400, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
