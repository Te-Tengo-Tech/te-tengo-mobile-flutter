import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/cache_local.dart';
import '../cache/interceptor_cache.dart';
import '../configuracion.dart';
import '../sesion/almacen_sesion.dart';
import '../sesion/sesion_controller.dart';
import 'interceptor_sesion.dart';

BaseOptions _opciones() => BaseOptions(
  baseUrl: urlApi,
  headers: {'Api-Version': versionApi},
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
);

/// Transport of the backend client; tests replace it with a fake adapter.
final adaptadorHttpProvider = Provider<HttpClientAdapter?>((ref) => null);

/// Backend HTTP client: base URL, `Api-Version` header, session token and token refresh.
final clienteApiProvider = Provider<Dio>((ref) {
  final almacen = ref.watch(almacenSesionProvider);
  final adaptador = ref.watch(adaptadorHttpProvider);
  final dio = Dio(_opciones());
  final refresco = Dio(_opciones());
  if (adaptador != null) {
    dio.httpClientAdapter = adaptador;
    refresco.httpClientAdapter = adaptador;
  }
  dio.interceptors.add(
    InterceptorSesion(
      dio: dio,
      almacen: almacen,
      refresco: refresco,
      alCambiar: (sesion) =>
          ref.read(sesionControllerProvider.notifier).actualizada(sesion),
    ),
  );
  dio.interceptors.add(
    InterceptorCache(
      cache: ref.watch(cacheLocalProvider),
      hogarId: () => almacen.actual?.hogarId,
    ),
  );
  return dio;
});
