import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/configuracion.dart';
import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/versiones.dart';

/// The published versions of the apps (contract §12, US-43).
abstract interface class VersionesRepositorio {
  /// `GET /api/versiones`; null when the backend does not have it yet (an older backend answers
  /// `404`). Throws [ProblemaApi] (`SIN_CONEXION` without a connection).
  Future<Versiones?> leer();
}

class VersionesRepositorioApi implements VersionesRepositorio {
  VersionesRepositorioApi(this._dio);

  final Dio _dio;
  String? _etiqueta;
  Versiones? _ultimas;

  @override
  Future<Versiones?> leer() => llamarApi(() async {
    final r = await _dio.get<Object>(
      '/api/versiones',
      options: Options(
        // The browser revalidates with the ETag by itself, and `If-None-Match` is not a header the
        // API's CORS allows (contract, Conventions).
        headers: {if (!kIsWeb && _etiqueta != null) 'If-None-Match': _etiqueta},
        validateStatus: (s) => s == 200 || s == 304 || s == 404,
      ),
    );
    if (r.statusCode == 404) return null;
    if (r.statusCode == 304) return _ultimas;
    final datos = r.data;
    if (datos is! Map<String, dynamic>) return null;
    _etiqueta = r.headers.value('etag');
    return _ultimas = Versiones.desdeJson(datos);
  });
}

/// A client for the public `GET /api/versiones`: the API's base URL and `Api-Version`, but no
/// session token. The resource server answers `401` to an expired token even on a public path,
/// which would hide a new version (or the minimum version) from a signed-out or expired session.
final clienteVersionesProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlApi,
      headers: {'Api-Version': versionApi},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  final adaptador = ref.watch(adaptadorHttpProvider);
  if (adaptador != null) dio.httpClientAdapter = adaptador;
  return dio;
});

final versionesRepositorioProvider = Provider<VersionesRepositorio>(
  (ref) => VersionesRepositorioApi(ref.watch(clienteVersionesProvider)),
);
