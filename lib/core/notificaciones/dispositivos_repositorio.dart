import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../formato.dart';
import '../red/cliente_api.dart';
import '../red/problema_api.dart';

/// `Dispositivo` of the contract (§7): whether the backend still sends pushes to this phone.
class DispositivoPush {
  const DispositivoPush({
    required this.id,
    required this.activo,
    this.vistoEn,
    this.desactivadoEn,
  });

  /// Null only with a backend older than 0.3.1, whose `POST` answered no body.
  final String? id;

  /// False once the push service said the token no longer exists: registering it again does not
  /// help, the app needs a new token.
  final bool activo;
  final DateTime? vistoEn;
  final DateTime? desactivadoEn;

  static DispositivoPush desdeJson(Object? json) {
    if (json is! Map) return const DispositivoPush(id: null, activo: true);
    return DispositivoPush(
      id: json['id'] as String?,
      activo: json['activo'] as bool? ?? true,
      vistoEn: fechaDesdeJson(json['vistoEn']),
      desactivadoEn: fechaDesdeJson(json['desactivadoEn']),
    );
  }
}

/// Push device registration (contract §7).
abstract interface class DispositivosRepositorio {
  /// `POST /api/dispositivos {tokenPush, plataforma}` → `201 Dispositivo`. An upsert: the app calls
  /// it on every start and return to the foreground, and the backend records when it was seen.
  Future<DispositivoPush> registrar({
    required String tokenPush,
    required String plataforma,
  });

  /// `GET /api/dispositivos/{id}`; null when the backend does not know it
  /// (`404 DISPOSITIVO_NO_ENCONTRADO`).
  Future<DispositivoPush?> consultar(String id);

  /// `DELETE /api/dispositivos/{tokenPush}`. The access token is passed because it runs while the
  /// session is being closed.
  Future<void> eliminar(String tokenPush, {String? tokenAcceso});
}

class DispositivosRepositorioApi implements DispositivosRepositorio {
  DispositivosRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<DispositivoPush> registrar({
    required String tokenPush,
    required String plataforma,
  }) => llamarApi(() async {
    final respuesta = await _dio.post<Object?>(
      '/api/dispositivos',
      data: {'tokenPush': tokenPush, 'plataforma': plataforma},
    );
    return DispositivoPush.desdeJson(respuesta.data);
  });

  @override
  Future<DispositivoPush?> consultar(String id) async {
    try {
      return await llamarApi(() async {
        final respuesta = await _dio.get<Object?>(
          '/api/dispositivos/${Uri.encodeComponent(id)}',
        );
        return DispositivoPush.desdeJson(respuesta.data);
      });
    } on ProblemaApi catch (e) {
      if (e.estado == 404) return null;
      rethrow;
    }
  }

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
