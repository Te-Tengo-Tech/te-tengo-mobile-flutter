import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'cache_local.dart';

/// Keeps the last answer of each household read (alerts, history pages, cameras, household,
/// family, summary, access log) and serves it when there is no connection. Keys carry the
/// household of the session, so households never mix.
class InterceptorCache extends Interceptor {
  InterceptorCache({required this.cache, required this.hogarId});

  final CacheLocal cache;
  final String? Function() hogarId;

  /// Marks a response served from the cache.
  static const desdeCache = 'tt_desde_cache';

  static const _rutas = [
    '/api/alertas',
    '/api/camaras',
    '/api/hogar',
    '/api/familiares',
    '/api/resumen-semanal',
    '/api/accesos-vista-en-vivo',
  ];

  bool _guardable(RequestOptions o) =>
      o.method == 'GET' &&
      // Clip links are pre-signed and expire.
      !o.path.endsWith('/clip') &&
      _rutas.any((r) => o.path == r || o.path.startsWith('$r/'));

  String? _clave(RequestOptions o) {
    final hogar = hogarId();
    if (hogar == null) return null;
    final consulta = o.queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return '$hogar|${o.path}?${consulta.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final respuesta = response;
    final o = respuesta.requestOptions;
    final clave = _clave(o);
    if (_guardable(o) &&
        clave != null &&
        respuesta.statusCode == 200 &&
        respuesta.data != null &&
        o.extra[desdeCache] != true) {
      unawaited(
        cache.guardar(clave, jsonEncode(respuesta.data)).catchError((_) {}),
      );
    }
    handler.next(respuesta);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final o = err.requestOptions;
    final clave = _clave(o);
    if (_guardable(o) && clave != null && sinConexion(err)) {
      try {
        final guardado = await cache.leer(clave);
        if (guardado != null) {
          o.extra[desdeCache] = true;
          return handler.resolve(
            Response<dynamic>(
              requestOptions: o,
              data: jsonDecode(guardado),
              statusCode: 200,
              extra: {desdeCache: true},
            ),
          );
        }
      } on Object {
        // An unreadable cache is the same as no cache.
      }
    }
    handler.next(err);
  }

  /// True when the request did not reach the backend.
  static bool sinConexion(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => true,
    DioExceptionType.unknown => e.error is SocketException,
    _ => false,
  };
}
