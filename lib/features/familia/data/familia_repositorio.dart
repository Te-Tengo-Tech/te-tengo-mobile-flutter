import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/familiar.dart';

/// Family and alert routing (contract §3).
abstract interface class FamiliaRepositorio {
  /// `GET /api/familiares`.
  Future<List<Familiar>> listar();
}

class FamiliaRepositorioApi implements FamiliaRepositorio {
  FamiliaRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Familiar>> listar() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/familiares');
    return (r.data ?? [])
        .map((j) => Familiar.desdeJson(j as Map<String, dynamic>))
        .toList();
  });
}

final familiaRepositorioProvider = Provider<FamiliaRepositorio>(
  (ref) => FamiliaRepositorioApi(ref.watch(clienteApiProvider)),
);

final familiaresProvider = FutureProvider<List<Familiar>>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  return ref.watch(familiaRepositorioProvider).listar();
});

/// First name of the owner, for the read-only notices («Solo Carmen (titular) puede…»).
final nombreTitularProvider = Provider<String?>((ref) {
  final sesion = ref.watch(sesionControllerProvider);
  if (sesion?.esTitular ?? false) return sesion!.usuario.nombrePila;
  final familia = ref.watch(familiaresProvider).value;
  return familia?.where((f) => f.esTitular).firstOrNull?.nombrePila;
});
