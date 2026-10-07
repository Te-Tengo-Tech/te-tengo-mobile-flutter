import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/lista.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';

/// Role tag (`.role`): «Principal» filled, «Secundario» soft, «Recibe alertas» gray.
class EtiquetaPapel extends StatelessWidget {
  const EtiquetaPapel(this.papel, {super.key});

  final PapelAviso papel;

  @override
  Widget build(BuildContext context) {
    final (fondo, color) = switch (papel) {
      PapelAviso.principal => (Colores.morado, Colors.white),
      PapelAviso.secundario => (Colores.moradoSuave, Colores.moradoTinta),
      PapelAviso.familiar => (Colores.fondo2, Colores.tinta2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(papel.etiqueta, style: estiloTexto(13, 800, color: color)),
    );
  }
}

const _tonos = [TonoAvatar.morado, TonoAvatar.azul, TonoAvatar.arena];

/// Avatar tone of the n-th member, as the prototype alternates them.
TonoAvatar tonoDe(int indice) => _tonos[indice % _tonos.length];

/// Member row of the family list (`famRow`).
class FilaMiembro extends StatelessWidget {
  const FilaMiembro({
    super.key,
    required this.miembro,
    required this.indice,
    required this.esYo,
    this.alTocar,
  });

  final MiembroFamilia miembro;
  final int indice;
  final bool esYo;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final f = miembro.familiar;
    return FilaLista(
      inicio: Avatar(Avatar.inicialesDe(f.nombre), tono: tonoDe(indice)),
      titulo: esYo ? '${f.nombre} (tú)' : f.nombre,
      subtitulo: f.esTitular ? 'titular de la cuenta' : null,
      fin: EtiquetaPapel(miembro.papel),
      alTocar: alTocar,
    );
  }
}
