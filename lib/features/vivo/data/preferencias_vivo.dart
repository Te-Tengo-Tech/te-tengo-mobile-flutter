import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';
import '../domain/vista_en_vivo.dart';

/// What this phone chose to see live («Video», «Esqueleto» or both, CA-41.3) and whether «Ver
/// todas» opens in portrait: remembered on this phone only (device keys of the local cache, kept on
/// sign-out). Until a mode is chosen, a session keeps the mode the camera streams in.
class PreferenciasVivo {
  const PreferenciasVivo({this.modo, this.mosaicoVertical = false});

  /// Null until this phone chooses one.
  final ModoVista? modo;

  /// «Vertical» in «Ver todas»; landscape by default.
  final bool mosaicoVertical;
}

const _claveModo = '${deDispositivo}modo-vivo';
const _claveVertical = '${deDispositivo}mosaico-vertical';

class PreferenciasVivoController extends Notifier<PreferenciasVivo> {
  bool _cambiado = false;
  final _cargada = Completer<void>();

  /// Completes once the stored choices were read (or could not be).
  Future<void> get cargada => _cargada.future;

  @override
  PreferenciasVivo build() {
    unawaited(_cargar().whenComplete(_cargada.complete));
    return const PreferenciasVivo();
  }

  CacheLocal get _cache => ref.read(cacheLocalProvider);

  Future<void> _cargar() async {
    try {
      final modo = await _cache.leer(_claveModo);
      final vertical = await _cache.leer(_claveVertical);
      if (!ref.mounted || _cambiado) return;
      state = PreferenciasVivo(
        modo: modo == null ? null : ModoVista.desdeCodigo(modo),
        mosaicoVertical: vertical == 'si',
      );
    } on Object {
      // Nothing stored or a blocked storage: the defaults.
    }
  }

  Future<void> _guardar(String clave, String valor) async {
    try {
      await _cache.guardar(clave, valor);
    } on Object {
      // Storage full or blocked: it still applies until the app closes.
    }
  }

  Future<void> elegirModo(ModoVista modo) {
    _cambiado = true;
    state = PreferenciasVivo(
      modo: modo,
      mosaicoVertical: state.mosaicoVertical,
    );
    return _guardar(_claveModo, modo.codigo);
  }

  Future<void> elegirVertical(bool vertical) {
    _cambiado = true;
    state = PreferenciasVivo(modo: state.modo, mosaicoVertical: vertical);
    return _guardar(_claveVertical, vertical ? 'si' : 'no');
  }
}

final preferenciasVivoProvider =
    NotifierProvider<PreferenciasVivoController, PreferenciasVivo>(
      PreferenciasVivoController.new,
    );
