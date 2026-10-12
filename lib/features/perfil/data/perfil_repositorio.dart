import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/foto.dart';
import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/perfil.dart';

/// The member's own profile and the photos (contract §13).
abstract interface class PerfilRepositorio {
  /// `GET /api/cuenta`. Null with a backend older than the profiles (`404`).
  Future<Perfil?> obtener();

  /// `PUT /api/cuenta`: a blank [telefono] or [parentesco] clears it. Errors: `400 VALIDACION`.
  Future<Perfil> guardar({
    required String nombre,
    String? telefono,
    String? parentesco,
  });

  /// `PUT /api/cuenta/contrasena`. Errors: `422 CONTRASENA_ACTUAL_INCORRECTA`, `400 VALIDACION`.
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  });

  /// `POST /api/fotos/subidas`, the pre-signed `PUT` of [bytes] and
  /// `POST /api/fotos/subidas/{subidaId}/confirmacion`. [alProgreso] goes from 0 to 1 while the
  /// picture is sent. Errors: `403 SOLO_TITULAR`, `413 FOTO_MUY_GRANDE`,
  /// `415 FOTO_FORMATO_NO_ADMITIDO`, `410 SUBIDA_VENCIDA`, `404 SUBIDA_NO_ENCONTRADA`.
  Future<Foto> subirFoto(
    DuenoFoto de,
    Uint8List bytes, {
    required String tipo,
    void Function(double avance)? alProgreso,
  });

  /// `DELETE /api/fotos/{de}` («Quitar la foto»). Errors: `403 SOLO_TITULAR`.
  Future<void> quitarFoto(DuenoFoto de);
}

class PerfilRepositorioApi implements PerfilRepositorio {
  PerfilRepositorioApi(this._dio, this._almacenamiento);

  final Dio _dio;

  /// Sends the picture straight to the object store: no session token, no `Api-Version`.
  final Dio _almacenamiento;

  @override
  Future<Perfil?> obtener() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/cuenta');
      return Perfil.desdeJson(r.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<Perfil> guardar({
    required String nombre,
    String? telefono,
    String? parentesco,
  }) => llamarApi(() async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/api/cuenta',
      data: {'nombre': nombre, 'telefono': telefono, 'parentesco': parentesco},
    );
    return Perfil.desdeJson(r.data!);
  });

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) => llamarApi(() async {
    await _dio.put<void>(
      '/api/cuenta/contrasena',
      data: {'actual': actual, 'nueva': nueva},
    );
  });

  @override
  Future<Foto> subirFoto(
    DuenoFoto de,
    Uint8List bytes, {
    required String tipo,
    void Function(double avance)? alProgreso,
  }) async {
    final subida = await llamarApi(() async {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/fotos/subidas',
        data: {'de': de.codigo, 'tipo': tipo, 'tamanoBytes': bytes.length},
      );
      return SubidaFoto.desdeJson(r.data!);
    });
    try {
      await _almacenamiento.put<void>(
        subida.url,
        data: Stream.value(bytes),
        options: Options(
          headers: {
            ...subida.cabeceras,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
        onSendProgress: alProgreso == null
            ? null
            : (enviados, total) {
                if (total > 0) alProgreso(enviados / total);
              },
      );
      alProgreso?.call(1);
    } on DioException catch (e) {
      throw ProblemaApi(
        codigo: e.response == null ? ProblemaApi.sinConexion : 'SUBIDA_FALLIDA',
        detalle: 'No se pudo subir la foto. Vuelve a intentarlo.',
        estado: e.response?.statusCode,
      );
    }
    return llamarApi(() async {
      final r = await _dio.post<Map<String, dynamic>>(
        '/api/fotos/subidas/${subida.subidaId}/confirmacion',
      );
      return Foto.desdeJson(r.data)!;
    });
  }

  @override
  Future<void> quitarFoto(DuenoFoto de) => llamarApi(() async {
    await _dio.delete<void>('/api/fotos/${de.ruta}');
  });
}

/// Plain client for the pre-signed uploads (tests swap its transport like the API's).
final clienteAlmacenamientoProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 60),
    ),
  );
  final adaptador = ref.watch(adaptadorHttpProvider);
  if (adaptador != null) dio.httpClientAdapter = adaptador;
  return dio;
});

final perfilRepositorioProvider = Provider<PerfilRepositorio>(
  (ref) => PerfilRepositorioApi(
    ref.watch(clienteApiProvider),
    ref.watch(clienteAlmacenamientoProvider),
  ),
);

/// The signed-in member's profile; null with an older backend.
final perfilProvider = FutureProvider<Perfil?>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.usuario.id));
  return ref.watch(perfilRepositorioProvider).obtener();
});
