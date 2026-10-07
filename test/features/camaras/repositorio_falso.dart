import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';

class CamarasRepositorioFalso implements CamarasRepositorio {
  CamarasRepositorioFalso(this.camaras);

  final List<Camara> camaras;
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
