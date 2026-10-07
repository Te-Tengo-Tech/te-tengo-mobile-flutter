import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../red/cliente_api.dart';
import '../red/problema_api.dart';
import 'sesion.dart';

/// A household the user belongs to (`GET /api/hogares`).
class HogarResumen {
  const HogarResumen({
    required this.hogarId,
    required this.nombreAdultoMayor,
    required this.rol,
  });

  final String hogarId;
  final String nombreAdultoMayor;
  final Rol? rol;

  factory HogarResumen.desdeJson(Map<String, dynamic> json) => HogarResumen(
    hogarId: json['hogarId'] as String,
    nombreAdultoMayor: json['nombreAdultoMayor'] as String,
    rol: Rol.desde(json['rol']),
  );
}

/// Session lifecycle endpoints (contract §1 and §2).
abstract interface class SesionRepositorio {
  /// `DELETE /api/sesiones/actual`: revokes the refresh token (CA-02.4).
  Future<void> cerrar();

  /// `GET /api/hogares`.
  Future<List<HogarResumen>> hogares();

  /// `POST /api/sesiones/hogar`: a session for another household.
  Future<Sesion> cambiarHogar(String hogarId);
}

class SesionRepositorioApi implements SesionRepositorio {
  SesionRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<void> cerrar() =>
      llamarApi(() => _dio.delete<void>('/api/sesiones/actual'));

  @override
  Future<List<HogarResumen>> hogares() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/hogares');
    return (r.data ?? [])
        .map((j) => HogarResumen.desdeJson(j as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<Sesion> cambiarHogar(String hogarId) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/sesiones/hogar',
      data: {'hogarId': hogarId},
    );
    return Sesion.desdeJson(r.data!);
  });
}

final sesionRepositorioProvider = Provider<SesionRepositorio>(
  (ref) => SesionRepositorioApi(ref.watch(clienteApiProvider)),
);
