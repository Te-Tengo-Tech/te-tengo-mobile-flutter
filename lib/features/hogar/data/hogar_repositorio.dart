import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/hogar.dart';

/// Household, older adult and consent (contract §2).
abstract interface class HogarRepositorio {
  /// `GET /api/hogar`.
  Future<Hogar> obtener();
}

class HogarRepositorioApi implements HogarRepositorio {
  HogarRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<Hogar> obtener() => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>('/api/hogar');
    return Hogar.desdeJson(r.data!);
  });
}

final hogarRepositorioProvider = Provider<HogarRepositorio>(
  (ref) => HogarRepositorioApi(ref.watch(clienteApiProvider)),
);

/// The household of the session; reloaded when the session changes household.
final hogarProvider = FutureProvider<Hogar>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  return ref.watch(hogarRepositorioProvider).obtener();
});

/// First name of the older adult, once the household is loaded (`Rosa`).
final nombreAdultoMayorProvider = Provider<String?>(
  (ref) => ref.watch(hogarProvider).value?.adultoMayor.nombrePila,
);
