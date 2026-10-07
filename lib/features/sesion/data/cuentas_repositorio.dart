import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion.dart';
import '../domain/cuenta.dart';

/// Accounts and sessions (contract §1): US-01, US-02, US-03.
abstract interface class CuentasRepositorio {
  /// `POST /api/cuentas` (CA-01.1). Errors: `409 CORREO_EN_USO`, `400 VALIDACION`.
  Future<Cuenta> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  });

  /// `POST /api/sesiones` (CA-02.1). Errors: `401 CREDENCIALES_INVALIDAS`,
  /// `423 CUENTA_BLOQUEADA {bloqueadaHasta}`.
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  });
}

class CuentasRepositorioApi implements CuentasRepositorio {
  CuentasRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<Cuenta> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/cuentas',
      data: {'correo': correo, 'contrasena': contrasena, 'nombre': nombre},
    );
    return Cuenta.desdeJson(r.data!);
  });

  @override
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/sesiones',
      data: {'correo': correo, 'contrasena': contrasena},
    );
    return Sesion.desdeJson(r.data!);
  });
}

final cuentasRepositorioProvider = Provider<CuentasRepositorio>(
  (ref) => CuentasRepositorioApi(ref.watch(clienteApiProvider)),
);
