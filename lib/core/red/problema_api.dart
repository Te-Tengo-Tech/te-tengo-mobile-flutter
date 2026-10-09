import 'package:dio/dio.dart';

/// Backend error in RFC 9457 format (`ProblemDetail`) with its stable `codigo`.
class ProblemaApi implements Exception {
  const ProblemaApi({
    required this.codigo,
    required this.detalle,
    this.estado,
    this.titulo,
    this.campos = const {},
    this.extras = const {},
  });

  /// Code used when the device could not reach the backend.
  static const sinConexion = 'SIN_CONEXION';

  final String codigo;
  final String detalle;
  final int? estado;
  final String? titulo;

  /// `400 VALIDACION`: field → message, so the screen can highlight it (CA-01.3, CA-04.3).
  final Map<String, String> campos;

  /// Extra properties stated by the contract (`bloqueadaHasta`, `pausadaHasta`...).
  final Map<String, Object?> extras;

  factory ProblemaApi.desde(DioException error) {
    final datos = error.response?.data;
    if (datos is Map<String, dynamic>) {
      final campos = datos['campos'];
      const conocidas = {
        'type',
        'title',
        'status',
        'detail',
        'instance',
        'codigo',
        'campos',
      };
      return ProblemaApi(
        codigo: datos['codigo'] as String? ?? 'DESCONOCIDO',
        detalle: datos['detail'] as String? ?? 'Ocurrió un error.',
        titulo: datos['title'] as String?,
        estado: error.response?.statusCode ?? datos['status'] as int?,
        campos: campos is Map
            ? campos.map((k, v) => MapEntry(k as String, '$v'))
            : const {},
        extras: {
          for (final e in datos.entries)
            if (!conocidas.contains(e.key)) e.key: e.value,
        },
      );
    }
    return ProblemaApi(
      codigo: sinConexion,
      detalle: 'No hay conexión con Te Tengo. Revisa tu internet.',
      estado: error.response?.statusCode,
    );
  }

  @override
  String toString() => 'ProblemaApi($codigo, $detalle)';
}

/// Runs a Dio call and turns its errors into [ProblemaApi].
Future<T> llamarApi<T>(Future<T> Function() llamada) async {
  try {
    return await llamada();
  } on DioException catch (e) {
    throw ProblemaApi.desde(e);
  }
}
