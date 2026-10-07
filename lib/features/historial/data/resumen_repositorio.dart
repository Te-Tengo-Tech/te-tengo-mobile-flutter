import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../domain/resumen_semanal.dart';

/// Weekly summary (US-27).
abstract interface class ResumenRepositorio {
  /// `GET /api/resumen-semanal?semana=2026-W38`.
  Future<ResumenSemanal> obtener(String semana);
}

class ResumenRepositorioApi implements ResumenRepositorio {
  ResumenRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<ResumenSemanal> obtener(String semana) => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/resumen-semanal',
      queryParameters: {'semana': semana},
    );
    return ResumenSemanal.desdeJson(r.data!);
  });
}

final resumenRepositorioProvider = Provider<ResumenRepositorio>(
  (ref) => ResumenRepositorioApi(ref.watch(clienteApiProvider)),
);

/// Week shown in the summary: 0 is this week, -1 the previous one…
class SemanaElegida extends Notifier<int> {
  @override
  int build() => 0;

  void mover(int paso) => state = (state + paso).clamp(-520, 0);
}

final semanaElegidaProvider = NotifierProvider<SemanaElegida, int>(
  SemanaElegida.new,
);

/// Monday of the week [desplazamiento] weeks from now.
DateTime lunesDeSemana(Ref ref, int desplazamiento) {
  final hoy = ref.read(relojProvider)();
  final lunes = lunesDe(hoy);
  return DateTime(lunes.year, lunes.month, lunes.day + 7 * desplazamiento);
}

final resumenSemanalProvider = FutureProvider.family<ResumenSemanal, int>((
  ref,
  desplazamiento,
) {
  final lunes = lunesDeSemana(ref, desplazamiento);
  return ref.watch(resumenRepositorioProvider).obtener(semanaIso(lunes));
});

/// Alerts of that week, for the day grid.
final alertasDeSemanaProvider = FutureProvider.family<List<Alerta>, int>((
  ref,
  desplazamiento,
) async {
  final lunes = lunesDeSemana(ref, desplazamiento);
  final pagina = await ref
      .watch(alertasRepositorioProvider)
      .listar(
        FiltroAlertas(
          desde: lunes,
          hasta: DateTime(lunes.year, lunes.month, lunes.day + 7),
          tamano: 100,
        ),
      );
  return pagina.elementos;
});

/// The newest alert, for «Último evento» on the home screen.
final ultimoEventoProvider = FutureProvider<Alerta?>((ref) async {
  final pagina = await ref
      .watch(alertasRepositorioProvider)
      .listar(const FiltroAlertas(tamano: 1));
  return pagina.elementos.firstOrNull;
});
