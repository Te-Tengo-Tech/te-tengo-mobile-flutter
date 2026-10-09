import 'package:te_tengo/core/sesion/sesion.dart';

const usuarioCarmen = Usuario(
  id: 'u-carmen',
  nombre: 'Carmen Huamán',
  correo: 'carmen.huaman@gmail.com',
);

const usuarioLuis = Usuario(
  id: 'u-luis',
  nombre: 'Luis Huamán',
  correo: 'luis.huaman.r@gmail.com',
);

/// Owner session with a household.
const sesionTitular = Sesion(
  tokenAcceso: 'acceso-1',
  tokenRefresco: 'refresco-1',
  usuario: usuarioCarmen,
  hogarId: 'h-1',
  rol: Rol.titular,
);

/// Invited member session.
const sesionInvitado = Sesion(
  tokenAcceso: 'acceso-luis',
  tokenRefresco: 'refresco-luis',
  usuario: usuarioLuis,
  hogarId: 'h-1',
  rol: Rol.invitado,
);

/// New account without a household yet.
const sesionSinHogar = Sesion(
  tokenAcceso: 'acceso-0',
  tokenRefresco: 'refresco-0',
  usuario: usuarioCarmen,
);

Map<String, Object?> sesionJson({
  String acceso = 'acceso-2',
  String refresco = 'refresco-2',
  String? hogarId = 'h-1',
  String? rol = 'TITULAR',
}) => {
  'tokenAcceso': acceso,
  'tokenRefresco': refresco,
  'expiraEn': '2026-10-07T16:04:31Z',
  'usuario': {
    'id': 'u-carmen',
    'nombre': 'Carmen Huamán',
    'correo': 'carmen.huaman@gmail.com',
  },
  'hogarId': hogarId,
  'rol': rol,
};
