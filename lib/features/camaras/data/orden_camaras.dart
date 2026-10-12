import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';

/// The order of the cameras on this phone and its favourites (CA-41.4): favourites first, then the
/// others, each group in the order chosen. It rules «Cámaras», Inicio's dots, the room picker and
/// «Ver todas». Kept only on this phone («Solo en este celular»), so it is not sent to the backend
/// and survives signing out; the invited member orders their own.
class OrdenCamaras {
  const OrdenCamaras({this.orden = const [], this.favoritas = const {}});

  /// Camera ids in the order chosen; cameras not in it go after, in the backend's order.
  final List<String> orden;
  final Set<String> favoritas;

  bool esFavorita(String camaraId) => favoritas.contains(camaraId);

  /// [elementos] ordered: favourites first, each group in the chosen order (`camsOrdered`).
  List<T> ordenar<T>(Iterable<T> elementos, String Function(T) idDe) {
    final original = elementos.toList();
    int indice(int i) {
      final elegido = orden.indexOf(idDe(original[i]));
      return elegido < 0 ? 100000 + i : elegido;
    }

    final posiciones = List.generate(original.length, (i) => i)
      ..sort((a, b) {
        final fav =
            (esFavorita(idDe(original[b])) ? 1 : 0) -
            (esFavorita(idDe(original[a])) ? 1 : 0);
        return fav != 0 ? fav : indice(a) - indice(b);
      });
    return [for (final i in posiciones) original[i]];
  }

  /// Moves [id] to position [a] of [ids] (already ordered), without leaving its group
  /// (`camMoveTo`). Null when it does not move.
  OrdenCamaras? mover(List<String> ids, String id, int a) {
    final lista = ordenar(ids, (x) => x);
    final desde = lista.indexOf(id);
    if (desde < 0) return null;
    final grupo = [
      for (final (i, x) in lista.indexed)
        if (esFavorita(x) == esFavorita(id)) i,
    ];
    final destino = a.clamp(grupo.first, grupo.last);
    if (destino == desde) return null;
    lista
      ..removeAt(desde)
      ..insert(destino, id);
    return OrdenCamaras(orden: lista, favoritas: favoritas);
  }

  /// [id] can move [paso] places (−1 before, +1 after) within its group (`camCanMove`).
  bool puedeMover(List<String> ids, String id, int paso) {
    final lista = ordenar(ids, (x) => x);
    final i = lista.indexOf(id);
    final j = i + paso;
    return i >= 0 &&
        j >= 0 &&
        j < lista.length &&
        esFavorita(lista[j]) == esFavorita(id);
  }

  OrdenCamaras conFavorita(String id, bool favorita) => OrdenCamaras(
    orden: orden,
    favoritas: favorita ? {...favoritas, id} : ({...favoritas}..remove(id)),
  );

  String aJson() =>
      jsonEncode({'orden': orden, 'favoritas': favoritas.toList()});

  static OrdenCamaras desdeJson(String? texto) {
    if (texto == null) return const OrdenCamaras();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return OrdenCamaras(
        orden: [for (final x in json['orden'] as List? ?? const []) '$x'],
        favoritas: {
          for (final x in json['favoritas'] as List? ?? const []) '$x',
        },
      );
    } on Object {
      return const OrdenCamaras();
    }
  }
}

/// Where this phone keeps the order.
abstract interface class AlmacenOrdenCamaras {
  Future<OrdenCamaras> cargar();

  Future<void> guardar(OrdenCamaras orden);
}

class AlmacenOrdenCamarasMemoria implements AlmacenOrdenCamaras {
  AlmacenOrdenCamarasMemoria([this.actual = const OrdenCamaras()]);

  OrdenCamaras actual;

  @override
  Future<OrdenCamaras> cargar() async => actual;

  @override
  Future<void> guardar(OrdenCamaras orden) async => actual = orden;
}

/// Under a phone key of the local cache, which `vaciar()` keeps on sign-out. Camera ids are unique,
/// so the cameras of another household simply do not match.
class AlmacenOrdenCamarasLocal implements AlmacenOrdenCamaras {
  AlmacenOrdenCamarasLocal(this._cache);

  final CacheLocal _cache;
  static const clave = '${deDispositivo}orden-camaras';

  @override
  Future<OrdenCamaras> cargar() async {
    try {
      return OrdenCamaras.desdeJson(await _cache.leer(clave));
    } on Object {
      return const OrdenCamaras();
    }
  }

  @override
  Future<void> guardar(OrdenCamaras orden) =>
      _cache.guardar(clave, orden.aJson());
}

final almacenOrdenCamarasProvider = Provider<AlmacenOrdenCamaras>(
  (ref) => AlmacenOrdenCamarasLocal(ref.watch(cacheLocalProvider)),
);

/// The order of this phone: starts empty and takes the stored one as soon as it is read.
class OrdenCamarasController extends Notifier<OrdenCamaras> {
  bool _elegido = false;

  @override
  OrdenCamaras build() {
    unawaited(_cargar());
    return const OrdenCamaras();
  }

  Future<void> _cargar() async {
    final guardado = await ref.read(almacenOrdenCamarasProvider).cargar();
    if (ref.mounted && !_elegido) state = guardado;
  }

  Future<void> _aplicar(OrdenCamaras orden) async {
    _elegido = true;
    state = orden;
    try {
      await ref.read(almacenOrdenCamarasProvider).guardar(orden);
    } on Object {
      // Storage full or blocked: the order still applies until the app closes.
    }
  }

  /// Marks or unmarks [id] as a favourite.
  Future<void> favorita(String id, bool favorita) =>
      _aplicar(state.conFavorita(id, favorita));

  /// Moves [id] to position [a] of the ordered [ids], within its group; false when it cannot.
  bool mover(List<String> ids, String id, int a) {
    final nuevo = state.mover(ids, id, a);
    if (nuevo == null) return false;
    unawaited(_aplicar(nuevo));
    return true;
  }
}

final ordenCamarasProvider =
    NotifierProvider<OrdenCamarasController, OrdenCamaras>(
      OrdenCamarasController.new,
    );
