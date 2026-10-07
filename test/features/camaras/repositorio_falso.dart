import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';

/// The pilot camera: one USB webcam in the living room.
final camaraSala = Camara(
  id: 'c1',
  nombreHabitacion: 'Sala',
  estado: EstadoConexion.enLinea,
  ultimaSenal: DateTime(2026, 9, 23, 10, 42),
  instaladaEn: DateTime(2026, 9, 22),
);

class CamarasRepositorioFalso implements CamarasRepositorio {
  CamarasRepositorioFalso([List<Camara>? camaras])
    : camaras = camaras ?? [camaraSala];

  List<Camara> camaras;
  final renombradas = <String, String>{};
  final pausas = <DuracionPausa>[];
  int reanudaciones = 0;
  ProblemaApi? errorPausa;

  /// End of the pause the fake returns.
  DateTime Function(DuracionPausa) finPausa = (d) => d.duracion == null
      ? DateTime(2026, 9, 24, 7)
      : DateTime(2026, 9, 23, 10, 42).add(d.duracion!);

  @override
  Future<List<Camara>> listar() async => camaras;

  @override
  Future<Camara> renombrar(String camaraId, String nombreHabitacion) async {
    renombradas[camaraId] = nombreHabitacion;
    return Camara(
      id: camaraId,
      nombreHabitacion: nombreHabitacion,
      estado: EstadoConexion.enLinea,
    );
  }

  @override
  Future<Camara> pausar(String camaraId, DuracionPausa duracion) async {
    pausas.add(duracion);
    if (errorPausa != null) throw errorPausa!;
    return _cambiar(camaraId, finPausa(duracion));
  }

  @override
  Future<Camara> reanudar(String camaraId) async {
    reanudaciones++;
    return _cambiar(camaraId, null);
  }

  Camara _cambiar(String camaraId, DateTime? pausadaHasta) {
    final c = camaras.firstWhere((c) => c.id == camaraId);
    final nueva = Camara(
      id: c.id,
      nombreHabitacion: c.nombreHabitacion,
      estado: c.estado,
      ultimaSenal: c.ultimaSenal,
      pausadaHasta: pausadaHasta,
      deteccionConfiable: c.deteccionConfiable,
      instaladaEn: c.instaladaEn,
    );
    camaras = [for (final x in camaras) x.id == camaraId ? nueva : x];
    return nueva;
  }
}
