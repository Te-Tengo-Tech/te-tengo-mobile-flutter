import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/lista.dart';
import '../../perfil/data/fotos.dart';
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
      PapelAviso.secundario => (
        context.colores.moradoSuave,
        context.colores.moradoTinta,
      ),
      PapelAviso.familiar => (context.colores.fondo2, context.colores.tinta2),
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

/// «Hija · titular», «Hijo», «titular de la cuenta» (`famRow`): the relationship the member wrote
/// in «Tu perfil», and whether they own the account.
String? resumenMiembro(Familiar f) => switch ((f.parentesco, f.esTitular)) {
  (final String p, true) => '$p · titular',
  (final String p, false) => p,
  (null, true) => 'titular de la cuenta',
  (null, false) => null,
};

/// Member row of the family list (`famRow`), with their photo.
class FilaMiembro extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final f = miembro.familiar;
    return FilaLista(
      inicio: Avatar(
        Avatar.inicialesDe(f.nombre),
        tono: tonoDe(indice),
        foto: ref.watch(fotoDeUsuarioProvider(f.usuarioId)) ?? f.foto,
      ),
      titulo: esYo ? '${f.nombre} (tú)' : f.nombre,
      subtitulo: resumenMiembro(f),
      fin: EtiquetaPapel(miembro.papel),
      alTocar: alTocar,
    );
  }
}
