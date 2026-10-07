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
}
