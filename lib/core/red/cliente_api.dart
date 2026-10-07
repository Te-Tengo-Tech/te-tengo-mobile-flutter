import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../configuracion.dart';
import '../sesion/sesion_segura.dart';

/// Cliente HTTP del backend: base URL, cabecera `Api-Version` y token de la sesión.
final clienteApiProvider = Provider<Dio>((ref) {
  final sesion = ref.watch(sesionSeguraProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: urlApi,
      headers: {'Api-Version': versionApi},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opciones, manejador) async {
        final token = await sesion.token();
        if (token != null) {
          opciones.headers['Authorization'] = 'Bearer $token';
        }
        manejador.next(opciones);
      },
    ),
  );
  return dio;
});
