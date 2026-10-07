import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../red/cliente_api.dart';
import '../red/problema_api.dart';

/// Push device registration (contract §7).
abstract interface class DispositivosRepositorio {
  /// `POST /api/dispositivos {tokenPush, plataforma}`.
  Future<void> registrar({
    required String tokenPush,
    required String plataforma,
  });

  /// `DELETE /api/dispositivos/{tokenPush}`. The access token is passed because it runs while the
  /// session is being closed.
  Future<void> eliminar(String tokenPush, {String? tokenAcceso});
}

class DispositivosRepositorioApi implements DispositivosRepositorio {
  DispositivosRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<void> registrar({
    required String tokenPush,
    required String plataforma,
  }) => llamarApi(
    () => _dio.post<void>(
      '/api/dispositivos',
      data: {'tokenPush': tokenPush, 'plataforma': plataforma},
    ),
  );

  @override
  Future<void> eliminar(String tokenPush, {String? tokenAcceso}) => llamarApi(
    () => _dio.delete<void>(
      '/api/dispositivos/${Uri.encodeComponent(tokenPush)}',
      options: tokenAcceso == null
          ? null
          : Options(headers: {'Authorization': 'Bearer $tokenAcceso'}),
    ),
  );
}

final dispositivosRepositorioProvider = Provider<DispositivosRepositorio>(
  (ref) => DispositivosRepositorioApi(ref.watch(clienteApiProvider)),
);
