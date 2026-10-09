import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Canned backend response.
class Respuesta {
  const Respuesta(this.estado, [this.cuerpo]);

  /// RFC 9457 error with its `codigo`.
  factory Respuesta.problema(
    int estado,
    String codigo, {
    String detalle = 'Detalle del backend.',
    Map<String, Object?> extras = const {},
  }) => Respuesta(estado, {
    'title': 'Error',
    'status': estado,
    'detail': detalle,
    'codigo': codigo,
    ...extras,
  });

  final int estado;
  final Object? cuerpo;
}

/// Fake Dio transport: answers `METHOD /path` with queued responses (the last one repeats) and
/// records every request. No real network in tests.
class AdaptadorFalso implements HttpClientAdapter {
  final peticiones = <RequestOptions>[];

  /// Simulates a phone without connection: every request fails before reaching the backend.
  bool sinConexion = false;
  final _respuestas = <String, List<Respuesta>>{};

  /// Queues [respuesta] for `metodo ruta`.
  void cuando(String metodo, String ruta, Respuesta respuesta) =>
      (_respuestas['$metodo $ruta'] ??= []).add(respuesta);

  /// Requests made to `metodo ruta`.
  List<RequestOptions> hechas(String metodo, String ruta) =>
      peticiones.where((p) => p.method == metodo && p.path == ruta).toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions opciones,
    Stream<Uint8List>? cuerpo,
    Future<void>? cancelacion,
  ) async {
    peticiones.add(opciones);
    if (sinConexion) throw const SocketException('Sin conexión');
    final cola = _respuestas['${opciones.method} ${opciones.path}'];
    if (cola == null || cola.isEmpty) {
      throw StateError(
        'Sin respuesta para ${opciones.method} ${opciones.path}',
      );
    }
    final r = cola.length > 1 ? cola.removeAt(0) : cola.first;
    final esError = r.estado >= 400;
    return ResponseBody.fromString(
      r.cuerpo == null ? '' : jsonEncode(r.cuerpo),
      r.estado,
      headers: {
        Headers.contentTypeHeader: [
          esError ? 'application/problem+json' : 'application/json',
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
