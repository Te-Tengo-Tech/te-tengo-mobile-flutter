import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/camara.dart';

/// Acceso a las cámaras del hogar de la sesión.
abstract interface class CamarasRepositorio {
  Future<List<Camara>> listar();

  Future<Camara> renombrar(String camaraId, String nombreHabitacion);
}

class CamarasRepositorioApi implements CamarasRepositorio {
  CamarasRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Camara>> listar() async {
    try {
      final respuesta = await _dio.get<List<dynamic>>('/api/camaras');
      return (respuesta.data ?? [])
          .map((json) => Camara.desdeJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<Camara> renombrar(String camaraId, String nombreHabitacion) async {
    try {
      final respuesta = await _dio.patch<Map<String, dynamic>>(
        '/api/camaras/$camaraId',
        data: {'nombreHabitacion': nombreHabitacion},
      );
      return Camara.desdeJson(respuesta.data!);
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }
}

final camarasRepositorioProvider = Provider<CamarasRepositorio>(
  (ref) => CamarasRepositorioApi(ref.watch(clienteApiProvider)),
);

final camarasProvider = FutureProvider<List<Camara>>(
  (ref) => ref.watch(camarasRepositorioProvider).listar(),
);
