import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/ui/iconos.dart';
import '../data/orden_camaras.dart';

/// A favourite's star (`.fav-btn.on`): coral with a dark coral outline, so it reads on white and on
/// dark; in high contrast, the prototype's darker coral.
class EstrellaFavorita extends StatelessWidget {
  const EstrellaFavorita({super.key, this.tamano = 22});

  final double tamano;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Icono(
        Ico.starOn,
        tamano: tamano,
        color: context.colores.contraste
            ? const Color(0xFF86291B)
            : Colores.coral,
      ),
      Icono(Ico.star, tamano: tamano, color: const Color(0xFF86291B)),
    ],
  );
}

/// The small star after a favourite room's name (the room picker, «Ver todas»).
class MarcaFavorita extends StatelessWidget {
  const MarcaFavorita({super.key, this.tamano = 18});

  final double tamano;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Favorita',
    child: EstrellaFavorita(tamano: tamano),
  );
}

/// The 44 px star that marks or unmarks a room as a favourite on this phone (`favBtn`). [sobreImagen]
/// draws it as a white disc over the room card's illustration.
class BotonFavorita extends ConsumerWidget {
  const BotonFavorita({
    super.key,
    required this.camaraId,
    required this.habitacion,
    this.sobreImagen = false,
  });

  final String camaraId;
  final String habitacion;
  final bool sobreImagen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorita = ref.watch(ordenCamarasProvider).esFavorita(camaraId);
    final c = context.colores;
    void alternar() =>
        ref.read(ordenCamarasProvider.notifier).favorita(camaraId, !favorita);
    final icono = favorita
        ? const EstrellaFavorita()
        : Icono(Ico.star, tamano: 22, color: c.tinta2);
    return Semantics(
      button: true,
      toggled: favorita,
      label: 'Favorita: $habitacion',
      excludeSemantics: true,
      onTap: alternar,
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Material(
            color: sobreImagen ? Colors.white : Colors.transparent,
            shape: CircleBorder(
              side: sobreImagen && c.contraste
                  ? const BorderSide(color: Color(0xFF4F4566), width: 1.5)
                  : BorderSide.none,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: alternar,
              child: SizedBox.square(
                dimension: 44,
                child: Center(child: icono),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
