import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';

/// A fall in the living room at 10:42, notified 6 s later.
Alerta caidaSala({
  String id = 'a-1',
  bool confirmada = false,
  DateTime? notificadaEn,
  bool sinNotificar = false,
  DateTime? recuperadaEn,
  EstadoAlerta estado = EstadoAlerta.activa,
  TipoAlerta tipo = TipoAlerta.caida,
  bool origenInestable = false,
  String? atendidaPor,
  DateTime? atendidaEn,
  DateTime? escaladaEn,
  EstadoClip clip = EstadoClip.disponible,
  DateTime? ocurridaEn,
}) {
  final ocurrida = ocurridaEn ?? DateTime(2026, 9, 23, 10, 42);
  return Alerta(
    id: id,
    tipo: tipo,
    estado: estado,
    confirmada: confirmada,
    camaraId: 'c1',
    habitacion: 'Sala',
    ocurridaEn: ocurrida,
    notificadaEn: sinNotificar
        ? null
        : notificadaEn ?? ocurrida.add(const Duration(seconds: 6)),
    recuperadaEn: recuperadaEn,
    origenInestable: origenInestable,
    atendidaPor: atendidaPor,
    atendidaEn: atendidaEn,
    escaladaEn: escaladaEn,
    clip: clip,
  );
}

class AlertasRepositorioFalso implements AlertasRepositorio {
  AlertasRepositorioFalso([List<Alerta>? alertas]) : alertas = alertas ?? [];

  List<Alerta> alertas;
  final filtros = <FiltroAlertas>[];
  ProblemaApi? errorListar;

  @override
  Future<PaginaAlertas> listar(FiltroAlertas filtro) async {
    filtros.add(filtro);
    if (errorListar != null) throw errorListar!;
    final lista =
        alertas
            .where((a) => filtro.estado == null || a.estado == filtro.estado)
            .where((a) => filtro.tipo == null || a.tipo == filtro.tipo)
            .where(
              (a) =>
                  filtro.desde == null || !a.ocurridaEn.isBefore(filtro.desde!),
            )
            .toList()
          ..sort((a, b) => b.ocurridaEn.compareTo(a.ocurridaEn));
    return PaginaAlertas(
      elementos: lista.take(filtro.tamano).toList(),
      total: lista.length,
    );
  }

  @override
  Future<Alerta> obtener(String id) async {
    final a = alertas.where((a) => a.id == id).firstOrNull;
    if (a == null) {
      throw const ProblemaApi(
        codigo: 'ALERTA_NO_ENCONTRADA',
        detalle: 'No encontramos esa alerta.',
        estado: 404,
      );
    }
    return a;
  }
}
