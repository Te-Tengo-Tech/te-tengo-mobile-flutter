import 'package:dio/dio.dart';

import '../sesion/almacen_sesion.dart';
import '../sesion/sesion.dart';

/// Adds `Authorization: Bearer` and, on `401 SESION_EXPIRADA`, refreshes the tokens once with
/// `POST /api/sesiones/refresco` and retries the request.
///
/// Concurrent failures share a single refresh. When the refresh fails, the session is cleared and
/// the original error reaches the caller.
class InterceptorSesion extends Interceptor {
  InterceptorSesion({
    required this.dio,
    required this.almacen,
    required this.refresco,
    required this.alCambiar,
  });

  static const rutaRefresco = '/api/sesiones/refresco';
  static const _reintentada = 'tt_reintentada';

  /// Client that retries the original request.
  final Dio dio;
  final AlmacenSesion almacen;

  /// Client without this interceptor, for the refresh call.
  final Dio refresco;
  final void Function(Sesion?) alCambiar;

  Future<Sesion?>? _enCurso;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = almacen.actual?.tokenAcceso;
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final opciones = err.requestOptions;
    final datos = err.response?.data;
    final expirada =
        err.response?.statusCode == 401 &&
        datos is Map &&
        datos['codigo'] == 'SESION_EXPIRADA';
    if (!expirada ||
        opciones.extra[_reintentada] == true ||
        opciones.path == rutaRefresco ||
        almacen.actual == null) {
      return handler.next(err);
    }
    final usado = opciones.headers['Authorization'];
    final actual = almacen.actual!;
    // Another request may have refreshed the tokens already.
    final nueva = usado != 'Bearer ${actual.tokenAcceso}'
        ? actual
        : await (_enCurso ??= _refrescar(
            actual,
          ).whenComplete(() => _enCurso = null));
    if (nueva == null) return handler.next(err);
    opciones.headers['Authorization'] = 'Bearer ${nueva.tokenAcceso}';
    opciones.extra[_reintentada] = true;
    try {
      handler.resolve(await dio.fetch<dynamic>(opciones));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<Sesion?> _refrescar(Sesion actual) async {
    try {
      final r = await refresco.post<Map<String, dynamic>>(
        rutaRefresco,
        data: {'tokenRefresco': actual.tokenRefresco},
      );
      final nueva = Sesion.desdeJson(r.data!);
      await almacen.guardar(nueva);
      alCambiar(nueva);
      return nueva;
    } on DioException {
      await almacen.borrar();
      alCambiar(null);
      return null;
    }
  }
}
