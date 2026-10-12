import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../domain/fotogramas.dart';
import 'decodificador_ttmov.dart';

/// The movement decoder of this build: the light replay format TTMOV v1 (contract §11), on every
/// platform. Null would leave the screens saying they cannot draw the movements.
final decodificadorMovimientosProvider = Provider<DecodificadorMovimientos?>(
  (ref) => const DecodificadorTtmov(),
);

/// Downloads a light movement file from its pre-signed URL (no session header), checks its
/// `sha256` before drawing (contract §11) and decodes it. On the web the storage must allow the
/// PWA's origin (CORS) for these downloads.
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
  if (d == null) return null;
  // Tests replace the HTTP adapter: the downloads never leave them either.
  final adaptador = ref.watch(adaptadorHttpProvider);
  final dio = Dio();
  if (adaptador != null) dio.httpClientAdapter = adaptador;
  return FuenteFotogramas(d, dio: dio);
});
