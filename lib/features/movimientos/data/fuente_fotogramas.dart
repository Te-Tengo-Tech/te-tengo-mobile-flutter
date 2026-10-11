import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/fotogramas.dart';

/// The movement decoder of this build; null: none (docs/BLOCKERS.md, «Replay decoding»).
final decodificadorMovimientosProvider = Provider<DecodificadorMovimientos?>(
  (ref) => null,
);

/// Downloads a movement file from its pre-signed URL (no session header), checks its `sha256`
/// before drawing (contract §11) and decodes it.
class FuenteFotogramas {
  FuenteFotogramas(this._decodificador, {Dio? dio}) : _dio = dio ?? Dio();

  final DecodificadorMovimientos _decodificador;
  final Dio _dio;

  Future<List<Fotograma>> cargar(String url, {String? sha256Esperado}) async {
    final r = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = Uint8List.fromList(r.data ?? const []);
    if (sha256Esperado != null &&
        sha256.convert(bytes).toString() != sha256Esperado.toLowerCase()) {
      throw const FormatException('El archivo de movimientos no coincide.');
    }
    return _decodificador.decodificar(bytes);
  }
}

/// Null without a decoder.
final fuenteFotogramasProvider = Provider<FuenteFotogramas?>((ref) {
  final d = ref.watch(decodificadorMovimientosProvider);
  return d == null ? null : FuenteFotogramas(d);
});
