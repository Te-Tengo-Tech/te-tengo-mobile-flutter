import 'package:flutter/material.dart';

import '../../app/tema/paleta.dart';
import 'botones.dart';
import 'iconos.dart';

/// Confirmation dialog of the prototype (`dialog()`): icon, title, text and two stacked buttons.
/// Returns true when the first button is chosen.
Future<bool> confirmar(
  BuildContext context, {
  required Ico icono,
  required String titulo,
  required String texto,
  required String aceptar,
  required String cancelar,
  bool peligro = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: peligro
                        ? context.colores.caidaSuave
                        : context.colores.moradoSuave,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icono(
                    icono,
                    tamano: 28,
                    color: peligro
                        ? context.colores.caidaTinta
                        : context.colores.moradoTinta,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                header: true,
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(texto, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Boton(
                aceptar,
                estilo: peligro ? EstiloBoton.peligro : EstiloBoton.primario,
                alPresionar: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 12),
              Boton(
                cancelar,
                estilo: EstiloBoton.secundario,
                alPresionar: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return r ?? false;
}
