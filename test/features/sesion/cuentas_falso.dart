import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/sesion/data/cuentas_repositorio.dart';
import 'package:te_tengo/features/sesion/domain/cuenta.dart';

import '../../apoyo/datos.dart';

class CuentasRepositorioFalso implements CuentasRepositorio {
  CuentasRepositorioFalso({
    this.errorRegistro,
    this.errorSesion,
    this.errorConfirmacion,
    this.sesion,
  });

  ProblemaApi? errorRegistro;
  ProblemaApi? errorSesion;
  ProblemaApi? errorConfirmacion;
  final recuperaciones = <String>[];
  final confirmaciones = <Map<String, String>>[];
  Sesion? sesion;
  final registros = <Map<String, String>>[];
  final inicios = <Map<String, String>>[];

  @override
  Future<Cuenta> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    registros.add({
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
    });
    if (errorRegistro != null) throw errorRegistro!;
    return Cuenta(id: 'u-1', correo: correo, nombre: nombre);
  }

  @override
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    inicios.add({'correo': correo, 'contrasena': contrasena});
    if (errorSesion != null) throw errorSesion!;
    return sesion ?? sesionSinHogar;
  }

  @override
  Future<void> solicitarRecuperacion(String correo) async =>
      recuperaciones.add(correo);

  @override
  Future<void> confirmarRecuperacion({
    required String token,
    required String nuevaContrasena,
  }) async {
    confirmaciones.add({'token': token, 'nuevaContrasena': nuevaContrasena});
    if (errorConfirmacion != null) throw errorConfirmacion!;
  }
}
