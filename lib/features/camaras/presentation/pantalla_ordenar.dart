import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/aviso.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/camaras_en_casa.dart';
import '../data/orden_camaras.dart';
import 'favorita.dart';

/// «Ordenar» (screens 330, 339 and 342; CA-41.4): the favourites first, then the others; each row
/// drags by its handle within its group, or moves with «Subir» and «Bajar», and its star moves it to
/// the other group. The order is kept on this phone and rules «Cámaras», Inicio, the room picker
/// and «Ver todas». The invited member orders their own.
class PantallaOrdenarCamaras extends ConsumerWidget {
  const PantallaOrdenarCamaras({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camaras = ref.watch(camarasEnCasaProvider);
    final orden = ref.watch(ordenCamarasProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Listo'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: switch (camaras) {
        AsyncData(value: final lista) => _Lista(lista: lista, orden: orden),
        AsyncError(:final error) => ErrorDePantalla(
          error: error,
          alReintentar: () async => ref.invalidate(camarasEnCasaProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.lista, required this.orden});

  final List<CamaraEnCasa> lista;
  final OrdenCamaras orden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = [for (final c in lista) c.camara.id];
    final favoritas = lista
        .where((c) => orden.esFavorita(c.camara.id))
        .toList();
    final demas = lista.where((c) => !orden.esFavorita(c.camara.id)).toList();
    void mover(String id, int a) =>
        ref.read(ordenCamarasProvider.notifier).mover(ids, id, a);
    Widget grupo(String titulo, List<CamaraEnCasa> g, int inicio) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EncabezadoSeccion(titulo, arriba: 22),
        _Grupo(
          camaras: g,
          // Drop index within the group → index in the whole ordered list.
          alSoltar: (id, a) => mover(id, inicio + a),
          puedeMover: (id, paso) => orden.puedeMover(ids, id, paso),
          alMover: (id, paso) => mover(id, ids.indexOf(id) + paso),
        ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(
          'Favoritas primero. Solo en este celular.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (favoritas.isNotEmpty) grupo('Favoritas', favoritas, 0),
        if (demas.isNotEmpty)
          grupo(
            favoritas.isEmpty ? 'Cámaras' : 'Las demás',
            demas,
            favoritas.length,
          ),
      ],
    );
  }
}

/// One group, in a card: drag by the handle, or «Subir» / «Bajar».
class _Grupo extends StatelessWidget {
  const _Grupo({
    required this.camaras,
    required this.alSoltar,
    required this.puedeMover,
    required this.alMover,
  });

  final List<CamaraEnCasa> camaras;
  final void Function(String id, int a) alSoltar;
  final bool Function(String id, int paso) puedeMover;
  final void Function(String id, int paso) alMover;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      decoration: BoxDecoration(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraDe(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (desde, a) => alSoltar(camaras[desde].camara.id, a),
          children: [
            for (final (i, cam) in camaras.indexed)
              _Fila(
                key: ValueKey(cam.camara.id),
                indice: i,
                camara: cam,
                primera: i == 0,
                puedeSubir: puedeMover(cam.camara.id, -1),
                puedeBajar: puedeMover(cam.camara.id, 1),
                alMover: (paso) => alMover(cam.camara.id, paso),
              ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    super.key,
    required this.indice,
    required this.camara,
    required this.primera,
    required this.puedeSubir,
    required this.puedeBajar,
    required this.alMover,
  });

  final int indice;
  final CamaraEnCasa camara;
  final bool primera;
  final bool puedeSubir;
  final bool puedeBajar;
  final ValueChanged<int> alMover;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final habitacion = camara.habitacion;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.tarjeta,
        border: primera
            ? null
            : Border(
                top: BorderSide(color: c.linea, width: c.anchoDivisor),
              ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: indice,
                child: Semantics(
                  label: 'Arrastrar $habitacion',
                  child: SizedBox.square(
                    dimension: 44,
                    child: Center(
                      child: Icono(Ico.grip, tamano: 22, color: c.tinta3),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  habitacion,
                  style: estiloTexto(17, 700, color: c.tinta),
                ),
              ),
              BotonFavorita(camaraId: camara.camara.id, habitacion: habitacion),
              _BotonMover(
                icono: Ico.up,
                etiqueta: 'Subir $habitacion',
                alTocar: puedeSubir ? () => alMover(-1) : null,
              ),
              _BotonMover(
                icono: Ico.down,
                etiqueta: 'Bajar $habitacion',
                alTocar: puedeBajar ? () => alMover(1) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round 44 px «Subir» / «Bajar» (`.ord-b`).
class _BotonMover extends StatelessWidget {
  const _BotonMover({
    required this.icono,
    required this.etiqueta,
    required this.alTocar,
  });

  final Ico icono;
  final String etiqueta;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final activo = alTocar != null;
    return Semantics(
      button: true,
      enabled: activo,
      label: etiqueta,
      excludeSemantics: true,
      onTap: alTocar,
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Material(
            color: activo ? c.moradoSuave : c.fondo2,
            shape: CircleBorder(
              side: c.contraste
                  ? BorderSide(color: c.linea2, width: 1.5)
                  : BorderSide.none,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: alTocar,
              child: SizedBox.square(
                dimension: 44,
                child: Center(
                  child: Icono(
                    icono,
                    tamano: 20,
                    color: activo ? c.moradoTinta : c.tinta3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
