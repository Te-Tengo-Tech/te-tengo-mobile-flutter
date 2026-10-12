import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/movimientos.dart';

/// The consent to store movements and their cloud retention (contract §11, US-35, US-37).
abstract interface class MovimientosRepositorio {
  Future<ConsentimientoMovimientos> consentimiento();

  /// Registers the consent the older adult (or [representante]) gave (CA-35.2).
  Future<ConsentimientoMovimientos> registrar({
    required String otorgadoPor,
    required bool representante,
    required String versionTexto,
  });

  /// «Dejar de guardar movimientos» (CA-35.4): returns how many cloud files it deletes.
  Future<int?> revocar();

  Future<MovimientosEnLaNube> nube();

  /// 7, 30, 90 or 365 days, or null to stop storing in the cloud (CA-37.1, CA-37.4).
  Future<MovimientosEnLaNube> cambiarRetencion(int? dias);
}

class MovimientosRepositorioApi implements MovimientosRepositorio {
  MovimientosRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<ConsentimientoMovimientos> consentimiento() => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/hogar/consentimiento-movimientos',
    );
    return ConsentimientoMovimientos.desdeJson(r.data!);
  });

  @override
  Future<ConsentimientoMovimientos> registrar({
    required String otorgadoPor,
    required bool representante,
    required String versionTexto,
  }) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/hogar/consentimiento-movimientos',
      data: {
        'otorgadoPor': otorgadoPor,
        'representante': representante,
        'aceptado': true,
        'versionTexto': versionTexto,
      },
    );
    return ConsentimientoMovimientos.desdeJson(r.data!);
  });

  @override
  Future<int?> revocar() => llamarApi(() async {
    final r = await _dio.delete<Map<String, dynamic>>(
      '/api/hogar/consentimiento-movimientos',
    );
    return (r.data?['archivos'] as num?)?.toInt();
  });

  @override
  Future<MovimientosEnLaNube> nube() => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/hogar/movimientos-en-la-nube',
    );
    return MovimientosEnLaNube.desdeJson(r.data!);
  });

  @override
  Future<MovimientosEnLaNube> cambiarRetencion(int? dias) =>
      llamarApi(() async {
        final r = await _dio.put<Map<String, dynamic>>(
          '/api/hogar/movimientos-en-la-nube',
          data: {'retencionDias': dias},
        );
        return MovimientosEnLaNube.desdeJson(r.data!);
      });
}

final movimientosRepositorioProvider = Provider<MovimientosRepositorio>(
  (ref) => MovimientosRepositorioApi(ref.watch(clienteApiProvider)),
);

final consentimientoMovimientosProvider =
    FutureProvider<ConsentimientoMovimientos>(
      (ref) => ref.watch(movimientosRepositorioProvider).consentimiento(),
    );

final movimientosEnLaNubeProvider = FutureProvider<MovimientosEnLaNube>(
  (ref) => ref.watch(movimientosRepositorioProvider).nube(),
);

/// The deletion of the cloud movements after «Dejar de guardar» (screens 182, 183): started by
/// the revocation, finished by the push `MOVIMIENTOS_ELIMINADOS` or by asking the API, whichever
/// comes first.
class BorradoMovimientos {
  const BorradoMovimientos({required this.desde, this.terminado = false});

  final DateTime desde;
  final bool terminado;
}

class BorradoMovimientosController extends Notifier<BorradoMovimientos?> {
  @override
  BorradoMovimientos? build() => null;

  void iniciar(DateTime desde) => state = BorradoMovimientos(desde: desde);

  void terminar() {
    final s = state;
    if (s != null && !s.terminado) {
      state = BorradoMovimientos(desde: s.desde, terminado: true);
    }
  }

  void olvidar() => state = null;
}

final borradoMovimientosProvider =
    NotifierProvider<BorradoMovimientosController, BorradoMovimientos?>(
      BorradoMovimientosController.new,
    );
