import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/vista_en_vivo.dart';

/// Live view sessions of the household cameras (US-23).
abstract interface class VistaEnVivoRepositorio {
  /// Opens a session; `409 CAMARA_DESCONECTADA` or `409 CAMARA_EN_PAUSA` when unavailable.
  Future<SesionVivo> abrir(String camaraId, {String? alertaId});

  /// Closes it; the backend records who watched, when and for how long (CA-24.1).
  Future<void> cerrar(String sesionId);

  /// Who watched, when and for how long, newest first (CA-24.2).
  Future<List<AccesoVivo>> accesos();
}

class VistaEnVivoRepositorioApi implements VistaEnVivoRepositorio {
  VistaEnVivoRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<SesionVivo> abrir(String camaraId, {String? alertaId}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/api/camaras/$camaraId/vista-en-vivo',
        data: {'alertaId': alertaId},
      );
      return SesionVivo.desdeJson(respuesta.data!);
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<void> cerrar(String sesionId) async {
    try {
      await _dio.delete<void>('/api/vista-en-vivo/$sesionId');
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<List<AccesoVivo>> accesos() async {
    try {
      final respuesta = await _dio.get<List<dynamic>>(
        '/api/accesos-vista-en-vivo',
      );
      return (respuesta.data ?? [])
          .map((j) => AccesoVivo.desdeJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }
}

final vistaEnVivoRepositorioProvider = Provider<VistaEnVivoRepositorio>(
  (ref) => VistaEnVivoRepositorioApi(ref.watch(clienteApiProvider)),
);

final accesosVivoProvider = FutureProvider<List<AccesoVivo>>(
  (ref) => ref.watch(vistaEnVivoRepositorioProvider).accesos(),
);

/// Opens the stream of JPEG frames of a session.
typedef AbrirTransmision = Stream<Uint8List> Function(Uri url);

/// The contract's transport: a `wss://` relay of binary frames (see docs/BLOCKERS.md).
Stream<Uint8List> transmisionWebSocket(Uri url) {
  WebSocketChannel? canal;
  StreamSubscription<dynamic>? suscripcion;
  late final StreamController<Uint8List> salida;
  salida = StreamController<Uint8List>(
    onListen: () {
      canal = WebSocketChannel.connect(url);
      suscripcion = canal!.stream.listen(
        (mensaje) {
          if (mensaje is List<int>) {
            if (jpegDeFotograma(mensaje) case final jpeg?) salida.add(jpeg);
          }
        },
        onError: salida.addError,
        onDone: salida.close,
      );
    },
    onCancel: () async {
      await suscripcion?.cancel();
      await canal?.sink.close();
    },
  );
  return salida.stream;
}

final transmisionProvider = Provider<AbrirTransmision>(
  (ref) => transmisionWebSocket,
);
