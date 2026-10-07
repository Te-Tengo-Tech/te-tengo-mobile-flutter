import 'package:dio/dio.dart';

/// Error del backend en formato RFC 9457 (`ProblemDetail`) con su `codigo` estable.
class ProblemaApi implements Exception {
  const ProblemaApi({required this.codigo, required this.detalle, this.estado});

  final String codigo;
  final String detalle;
  final int? estado;

  factory ProblemaApi.desde(DioException error) {
    final datos = error.response?.data;
    if (datos is Map<String, dynamic>) {
      return ProblemaApi(
        codigo: datos['codigo'] as String? ?? 'DESCONOCIDO',
        detalle: datos['detail'] as String? ?? 'Ocurrió un error.',
        estado: error.response?.statusCode,
      );
    }
    return ProblemaApi(
      codigo: 'SIN_CONEXION',
      detalle: 'No hay conexión con Te Tengo. Revisa tu internet.',
      estado: error.response?.statusCode,
    );
  }

  @override
  String toString() => 'ProblemaApi($codigo, $detalle)';
}
