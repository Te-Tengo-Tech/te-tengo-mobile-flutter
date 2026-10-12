import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';

/// «Tamaño de letra» in «Preferencias» (screen 113): «Estándar» keeps the phone's text size and
/// «Grande» makes it 25 % larger on top of it (the prototype's `.screen.big`). A device setting,
/// like the theme and the contrast.
enum TamanoLetra {
  estandar('estandar', 'Estándar', 1),
  grande('grande', 'Grande', 1.25);

  const TamanoLetra(this.codigo, this.texto, this.factor);

  final String codigo;
  final String texto;

  /// Applied over the phone's own text scale.
  final double factor;

  static TamanoLetra desde(String? codigo) => TamanoLetra.values.firstWhere(
    (t) => t.codigo == codigo,
    orElse: () => estandar,
  );
}

abstract interface class AlmacenTamanoLetra {
  Future<TamanoLetra> cargar();

  Future<void> guardar(TamanoLetra tamano);
}

/// Kept in the local database under a phone key (`CacheLocal.vaciar` keeps it).
class AlmacenTamanoLetraLocal implements AlmacenTamanoLetra {
  AlmacenTamanoLetraLocal(this._cache);

  final CacheLocal _cache;
  static const clave = '${deDispositivo}letra';

  @override
  Future<TamanoLetra> cargar() async {
    try {
      return TamanoLetra.desde(await _cache.leer(clave));
    } on Object {
      return TamanoLetra.estandar;
    }
  }

  @override
  Future<void> guardar(TamanoLetra tamano) =>
      _cache.guardar(clave, tamano.codigo);
}

/// Read in `main()` before the first frame; a database that does not answer in [espera] keeps the
/// standard size.
Future<TamanoLetra> cargarTamanoLetra(
  CacheLocal cache, {
  Duration espera = const Duration(seconds: 2),
}) => AlmacenTamanoLetraLocal(
  cache,
).cargar().timeout(espera, onTimeout: () => TamanoLetra.estandar);

final almacenTamanoLetraProvider = Provider<AlmacenTamanoLetra>(
  (ref) => AlmacenTamanoLetraLocal(ref.watch(cacheLocalProvider)),
);

/// The value read in `main()`; overridden there.
final tamanoLetraInicialProvider = Provider<TamanoLetra>(
  (ref) => TamanoLetra.estandar,
);

class TamanoLetraController extends Notifier<TamanoLetra> {
  @override
  TamanoLetra build() => ref.watch(tamanoLetraInicialProvider);

  /// Applies it at once and keeps it on this phone.
  Future<void> elegir(TamanoLetra tamano) async {
    state = tamano;
    try {
      await ref.read(almacenTamanoLetraProvider).guardar(tamano);
    } on Object {
      // Storage full or blocked: the choice still applies until the app closes.
    }
  }
}

final tamanoLetraProvider =
    NotifierProvider<TamanoLetraController, TamanoLetra>(
      TamanoLetraController.new,
    );

/// Scales the phone's text by the chosen size below [child].
class EscalaLetra extends ConsumerWidget {
  const EscalaLetra({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factor = ref.watch(tamanoLetraProvider).factor;
    if (factor == 1) return child;
    final datos = MediaQuery.of(context);
    final sistema = datos.textScaler;
    return MediaQuery(
      data: datos.copyWith(textScaler: _Escala(sistema, factor)),
      child: child,
    );
  }
}

/// The phone's scale (linear or not) times [factor].
class _Escala extends TextScaler {
  const _Escala(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _Escala && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
