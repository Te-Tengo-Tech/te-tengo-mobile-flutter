import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';

/// Downloads the APK of a new version and checks it against the published SHA-256 (CA-43.5,
/// contract §12 «Downloads are checked»).
class DescargaApk {
  DescargaApk(this._dio);

  final Dio _dio;

  /// Downloads [url] to [destino], reporting the progress from 0 to 1 (null while the size is
  /// unknown). Throws the [DioException] of a failed or cancelled download, after deleting the
  /// partial file.
  Future<File> descargar(
    Uri url,
    File destino, {
    required void Function(double? progreso) alAvanzar,
    CancelToken? cancelar,
  }) async {
    await destino.parent.create(recursive: true);
    try {
      await _dio.downloadUri(
        url,
        destino.path,
        cancelToken: cancelar,
        deleteOnError: true,
        onReceiveProgress: (recibidos, total) =>
            alAvanzar(total > 0 ? (recibidos / total).clamp(0, 1) : null),
      );
    } on Object {
      if (destino.existsSync()) await destino.delete();
      rethrow;
    }
    return destino;
  }

  /// The file's SHA-256 is [esperado] (64 hex, any case).
  static Future<bool> coincide(File archivo, String esperado) async {
    final suma = await sha256.bind(archivo.openRead()).first;
    return suma.toString() == esperado.trim().toLowerCase();
  }
}

/// The download is a file on the release's host, not an API call: its own client, without the
/// session token or the API's headers.
final descargaApkProvider = Provider<DescargaApk>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 2),
    ),
  );
  final adaptador = ref.watch(adaptadorHttpProvider);
  if (adaptador != null) dio.httpClientAdapter = adaptador;
  return DescargaApk(dio);
});
