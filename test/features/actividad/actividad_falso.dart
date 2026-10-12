import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/actividad/data/actividad_repositorio.dart';
import 'package:te_tengo/features/actividad/domain/actividad.dart';

Actividad actividad(
  String id,
  String tipo,
  DateTime cuando, {
  TipoActor actor = TipoActor.familiar,
  String? usuario = 'Carmen Huamán',
  String? usuarioId = 'u-carmen',
  String? pcId,
  String? pc,
  String? camaraId,
  String? objeto,
  String? antes,
  String? despues,
}) => Actividad(
  id: id,
  ocurridaEn: cuando,
  tipo: tipo,
  actor: actor,
  usuario: actor == TipoActor.familiar ? usuario : null,
  usuarioId: actor == TipoActor.familiar ? usuarioId : null,
  pcId: pcId,
  pc: pc,
  camaraId: camaraId,
  objeto: objeto,
  valorAnterior: antes,
  valorNuevo: despues,
);

/// The prototype's log (`actLog`), on 23/09/2026.
final registroDePrueba = [
  actividad(
    'ac1',
    'CAMARA_ASIGNADA',
    DateTime(2026, 9, 23, 10, 33),
    actor: TipoActor.pc,
    pcId: 'pc-sala',
    pc: 'Sala-Rosa',
    objeto: 'Logitech C920',
    despues: 'Dormitorio',
  ),
  actividad(
    'ac2',
    'MODO_AVANZADO_ACTIVADO',
    DateTime(2026, 9, 23, 10, 12),
    actor: TipoActor.pc,
    pcId: 'pc-sala',
    pc: 'Sala-Rosa',
  ),
  actividad(
    'ac3',
    'CAMARA_ASIGNADA',
    DateTime(2026, 9, 22, 18, 44),
    pcId: 'pc-cocina',
    pc: 'Cocina-Rosa',
    objeto: 'HD Pro Webcam',
    despues: 'Cocina',
  ),
  actividad(
    'ac4',
    'PC_VINCULADA',
    DateTime(2026, 9, 22, 18, 40),
    pcId: 'pc-cocina',
    pc: 'Cocina-Rosa',
    objeto: 'Cocina-Rosa',
  ),
  actividad(
    'ac5',
    'RETENCION_MOVIMIENTOS_CAMBIADA',
    DateTime(2026, 9, 21, 12, 20),
    objeto: 'Movimientos en la nube',
    antes: '7 días',
    despues: '30 días',
  ),
  actividad(
    'ac6',
    'CAMARA_PAUSADA',
    DateTime(2026, 9, 21, 8, 15),
    usuario: 'Luis Huamán',
    usuarioId: 'u-luis',
    pcId: 'pc-sala',
    pc: 'Sala-Rosa',
    objeto: 'Sala',
    despues: DateTime(2026, 9, 21, 9, 15).toUtc().toIso8601String(),
  ),
];

class ActividadRepositorioFalso implements ActividadRepositorio {
  ActividadRepositorioFalso([List<Actividad>? lista])
    : lista = lista ?? registroDePrueba;

  List<Actividad> lista;
  ProblemaApi? error;
  final consultas = <(String?, int, int)>[];

  @override
  Future<PaginaActividad> listar({
    String? pcId,
    String? tipo,
    int pagina = 0,
    int tamano = 50,
  }) async {
    if (tipo == null) consultas.add((pcId, pagina, tamano));
    if (error != null) throw error!;
    final filtrada = [
      for (final a in lista)
        if ((pcId == null || a.pcId == pcId) &&
            (tipo == null || a.tipo == tipo))
          a,
    ];
    return PaginaActividad(
      elementos: filtrada.skip(pagina * tamano).take(tamano).toList(),
      total: filtrada.length,
    );
  }
}
