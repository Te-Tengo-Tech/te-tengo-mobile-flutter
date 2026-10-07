import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import '../../apoyo/datos.dart';
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
  ConfiguracionAviso avisoActual = const ConfiguracionAviso(
    principalId: 'u-carmen',
    secundarioId: 'u-luis',
  );
  final avisosGuardados = <ConfiguracionAviso>[];
  final invitaciones = <String>[];
  final retirados = <String>[];
  final aceptaciones = <(String, String?, String?)>[];
  ProblemaApi? errorAceptar;
  Sesion sesionAceptada = sesionInvitado;

  @override
  Future<List<Familiar>> listar() async => familiares;

  @override
  Future<Invitacion> invitar(String correo) async {
    invitaciones.add(correo);
    if (errorInvitar != null) throw errorInvitar!;
    return Invitacion(id: 'i-1', correo: correo);
  }

  @override
  Future<Sesion> aceptarInvitacion(
    String token, {
    String? nombre,
    String? contrasena,
  }) async {
    aceptaciones.add((token, nombre, contrasena));
    if (errorAceptar != null) throw errorAceptar!;
    return sesionAceptada;
  }

  @override
  Future<void> retirar(String usuarioId) async {
    retirados.add(usuarioId);
    familiares = [
      for (final f in familiares)
        if (f.usuarioId != usuarioId) f,
    ];
    if (avisoActual.secundarioId == usuarioId) {
      avisoActual = avisoActual.con(sinSecundario: true);
    }
  }

  @override
  Future<ConfiguracionAviso> aviso() async => avisoActual;

  @override
  Future<ConfiguracionAviso> guardarAviso(ConfiguracionAviso aviso) async {
    avisosGuardados.add(aviso);
    return avisoActual = aviso;
  }
}
