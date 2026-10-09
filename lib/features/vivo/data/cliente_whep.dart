import 'package:dio/dio.dart';

/// MediaMTX did not accept the WHEP offer: `404` while the camera is not publishing yet, another
/// status when WebRTC cannot serve this stream (the app then plays LL-HLS).
class OfertaRechazada implements Exception {
  const OfertaRechazada(this.estado);

  final int? estado;

  /// The path has no stream yet: the camera starts publishing a moment after the session opens.
  bool get sinTransmision => estado == 404;

  @override
  String toString() => 'OfertaRechazada($estado)';
}

/// MediaMTX's answer to a WHEP offer.
class RespuestaWhep {
  const RespuestaWhep({required this.sdp, this.recurso});

  /// The SDP answer, with every candidate of the server (no trickle needed).
  final String sdp;

  /// The WHEP session resource (`Location`), deleted when playback ends.
  final Uri? recurso;
}

/// WHEP signalling (RFC 9725) with MediaMTX: one `POST` of the SDP offer, one `DELETE` at the end.
///
/// The viewer token travels only as the `token` query parameter of the endpoint, never in an
/// `Authorization` header (contract §4). MediaMTX 1.21 documents `Authorization: Bearer` for HLS and
/// WebRTC tokens (docs/2-features/06-authentication.md, «Provide tokens / JWTs»), but with
/// `authMethod: http` it also hands the request's raw query to the auth hook (`query` in the hook's
/// payload, same page), which is how the API authorizes HLS and WebRTC reads and later finds each
/// WebRTC reader by its token to end it with the session. MediaMTX keeps that query in the session's
/// `Location`, so the `DELETE` carries it too (MediaMTX does not authorize the `DELETE`: the session
/// id in the path is its secret). No API client headers are sent (`Api-Version`, the member's
/// `Authorization`): MediaMTX's CORS only allows `Authorization`, `Content-Type` and `If-Match`.
class ClienteWhep {
  ClienteWhep([Dio? dio]) : _dio = dio ?? _http;

  final Dio _dio;

  static final _http = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );

  /// Posts the [oferta] to [endpoint]; throws [OfertaRechazada] for an answer other than `2xx`.
  Future<RespuestaWhep> ofrecer(
    Uri endpoint,
    String oferta, {
    String? token,
  }) async {
    final url = conToken(endpoint, token);
    final respuesta = await _dio.postUri<String>(
      url,
      data: oferta,
      options: Options(
        contentType: 'application/sdp',
        responseType: ResponseType.plain,
        headers: {'Accept': 'application/sdp'},
        validateStatus: (_) => true,
      ),
    );
    final estado = respuesta.statusCode;
    final sdp = respuesta.data;
    if (estado == null || estado < 200 || estado > 299 || sdp == null) {
      throw OfertaRechazada(estado);
    }
    final ubicacion = respuesta.headers.value('location');
    return RespuestaWhep(
      sdp: sdp,
      recurso: ubicacion == null ? null : url.resolve(ubicacion),
    );
  }

  /// Ends the WHEP session at once, instead of when MediaMTX notices the peer is gone. Errors are
  /// ignored: the session also ends on its own.
  Future<void> cerrar(Uri recurso) async {
    try {
      await _dio.deleteUri<void>(
        recurso,
        options: Options(validateStatus: (_) => true),
      );
    } on DioException {
      // Nothing to do: MediaMTX closes it when the peer connection times out.
    }
  }
}

/// [endpoint] with the viewer [token] as its `token` query parameter, unless it already has one
/// (the API's `urlWebrtc` carries it; this only covers a URL without it).
Uri conToken(Uri endpoint, String? token) {
  if (token == null ||
      token.isEmpty ||
      endpoint.queryParameters.containsKey('token')) {
    return endpoint;
  }
  return endpoint.replace(
    queryParameters: {...endpoint.queryParameters, 'token': token},
  );
}
