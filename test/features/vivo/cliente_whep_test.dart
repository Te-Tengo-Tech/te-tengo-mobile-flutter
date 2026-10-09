import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/features/vivo/data/cliente_whep.dart';

/// MediaMTX's WHEP endpoint, answering with a status, a body and a `Location`.
class _MediaMtxFalso implements HttpClientAdapter {
  final peticiones = <RequestOptions>[];
  final cuerpos = <String>[];
  int estado = 201;
  String cuerpo = 'v=0\r\no=- respuesta\r\n';
  String? ubicacion;
  bool sinConexion = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions opciones,
    Stream<Uint8List>? cuerpo,
    Future<void>? cancelacion,
  ) async {
    peticiones.add(opciones);
    if (cuerpo != null) {
      cuerpos.add(String.fromCharCodes(await cuerpo.expand((b) => b).toList()));
    }
    if (sinConexion) throw const SocketException('Sin conexión');
    return ResponseBody.fromString(
      opciones.method == 'POST' ? this.cuerpo : '',
      estado,
      headers: {
        Headers.contentTypeHeader: ['application/sdp'],
        'location': ?switch (ubicacion) {
          final u? => [u],
          null => null,
        },
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MediaMtxFalso mediamtx;
  late ClienteWhep cliente;
  const oferta = 'v=0\r\no=- oferta\r\n';
  final endpoint = Uri.parse(
    'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep?token=t-1',
  );

  setUp(() {
    mediamtx = _MediaMtxFalso();
    cliente = ClienteWhep(Dio()..httpClientAdapter = mediamtx);
  });

  test('envía la oferta SDP con el token y devuelve la respuesta', () async {
    mediamtx.ubicacion = '/vivo-webrtc/camaras/c1/whep/0b5e?token=t-1';
    final r = await cliente.ofrecer(endpoint, oferta, token: 't-1');
    final p = mediamtx.peticiones.single;
    expect(p.method, 'POST');
    expect(p.uri, endpoint);
    expect(p.contentType, 'application/sdp');
    // The token only in the query (contract §4); no API headers either: MediaMTX's CORS allows
    // Authorization, Content-Type and If-Match only.
    expect(p.headers.containsKey('Authorization'), isFalse);
    expect(p.headers.containsKey('Api-Version'), isFalse);
    expect(mediamtx.cuerpos.single, oferta);
    expect(r.sdp, mediamtx.cuerpo);
    expect(
      r.recurso.toString(),
      'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep/0b5e?token=t-1',
    );
  });

  test('sin token en la URL lo agrega a la query', () async {
    await cliente.ofrecer(
      Uri.parse('https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep'),
      oferta,
      token: 't 2',
    );
    final p = mediamtx.peticiones.single;
    expect(p.uri.queryParameters['token'], 't 2');
    expect(p.headers.containsKey('Authorization'), isFalse);
  });

  test('sin token envía la URL tal cual', () async {
    final sinToken = Uri.parse(
      'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep',
    );
    await cliente.ofrecer(sinToken, oferta);
    expect(mediamtx.peticiones.single.uri, sinToken);
  });

  test('sin Location no hay recurso que cerrar', () async {
    final r = await cliente.ofrecer(endpoint, oferta, token: 't-1');
    expect(r.recurso, isNull);
  });

  test('404 mientras la cámara no publica', () async {
    mediamtx.estado = 404;
    await expectLater(
      cliente.ofrecer(endpoint, oferta, token: 't-1'),
      throwsA(
        isA<OfertaRechazada>().having(
          (e) => e.sinTransmision,
          'sinTransmision',
          isTrue,
        ),
      ),
    );
  });

  test('otro estado rechaza la oferta', () async {
    for (final estado in [400, 401, 500]) {
      mediamtx.estado = estado;
      await expectLater(
        cliente.ofrecer(endpoint, oferta, token: 't-1'),
        throwsA(
          isA<OfertaRechazada>()
              .having((e) => e.estado, 'estado', estado)
              .having((e) => e.sinTransmision, 'sinTransmision', isFalse),
        ),
      );
    }
  });

  test('cerrar borra la sesión WHEP y no falla sin conexión', () async {
    final recurso = Uri.parse(
      'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep/0b5e?token=t-1',
    );
    mediamtx.estado = 200;
    await cliente.cerrar(recurso);
    expect(mediamtx.peticiones.single.method, 'DELETE');
    expect(mediamtx.peticiones.single.uri, recurso);
    mediamtx.sinConexion = true;
    await cliente.cerrar(recurso);
  });

  test('conToken mantiene un token que ya está', () {
    expect(conToken(endpoint, 'otro'), endpoint);
    expect(conToken(endpoint, null), endpoint);
  });
}
