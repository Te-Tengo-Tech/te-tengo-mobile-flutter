import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/familia/domain/familiar.dart';

const carmen = Familiar(
  usuarioId: 'u-carmen',
  nombre: 'Carmen Huamán',
  correo: 'carmen.huaman@gmail.com',
  rol: Rol.titular,
);

const luis = Familiar(
  usuarioId: 'u-luis',
  nombre: 'Luis Huamán',
  correo: 'luis.huaman.r@gmail.com',
  rol: Rol.invitado,
);

class FamiliaRepositorioFalso implements FamiliaRepositorio {
  FamiliaRepositorioFalso([List<Familiar>? familiares])
    : familiares = familiares ?? [carmen, luis];

  List<Familiar> familiares;
  ProblemaApi? errorInvitar;
  final invitaciones = <String>[];

  @override
  Future<List<Familiar>> listar() async => familiares;

  @override
  Future<Invitacion> invitar(String correo) async {
    invitaciones.add(correo);
    if (errorInvitar != null) throw errorInvitar!;
    return Invitacion(id: 'i-1', correo: correo);
  }
}
