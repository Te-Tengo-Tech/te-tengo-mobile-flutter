import '../../../core/sesion/sesion.dart';

/// Member of the household (`GET /api/familiares`).
class Familiar {
  const Familiar({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final String usuarioId;
  final String nombre;
  final String correo;
  final Rol? rol;

  bool get esTitular => rol == Rol.titular;

  String get nombrePila => nombre.trim().split(RegExp(r'\s+')).first;

  factory Familiar.desdeJson(Map<String, dynamic> json) => Familiar(
    usuarioId: json['usuarioId'] as String,
    nombre: json['nombre'] as String,
    correo: json['correo'] as String,
    rol: Rol.desde(json['rol']),
  );
}

/// Invitation sent by email (`POST /api/invitaciones`).
class Invitacion {
  const Invitacion({required this.id, required this.correo, this.expiraEn});

  final String id;
  final String correo;
  final DateTime? expiraEn;

  factory Invitacion.desdeJson(Map<String, dynamic> json) => Invitacion(
    id: json['id'] as String,
    correo: json['correo'] as String,
    expiraEn: json['expiraEn'] == null
        ? null
        : DateTime.parse(json['expiraEn'] as String).toLocal(),
  );
}
