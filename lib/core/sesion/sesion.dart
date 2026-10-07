import '../formato.dart';

/// Role of the user in the active household (JWT claim `rol`).
enum Rol {
  titular('TITULAR'),
  invitado('INVITADO');

  const Rol(this.codigo);

  final String codigo;

  static Rol? desde(Object? valor) =>
      Rol.values.where((r) => r.codigo == valor).firstOrNull;
}

/// Signed-in user (`Sesion.usuario`).
class Usuario {
  const Usuario({required this.id, required this.nombre, required this.correo});

  final String id;
  final String nombre;
  final String correo;

  /// First name, as the prototype greets and signs (`Carmen`).
  String get nombrePila => nombre.trim().split(RegExp(r'\s+')).first;

  factory Usuario.desdeJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    correo: json['correo'] as String,
  );

  Map<String, Object?> aJson() => {
    'id': id,
    'nombre': nombre,
    'correo': correo,
  };
}

/// `Sesion` of the API contract (§1).
///
/// `hogarId` is null until the account creates or joins a household; the token carries `hogar_id`,
/// so the app never sends the household itself.
class Sesion {
  const Sesion({
    required this.tokenAcceso,
    required this.tokenRefresco,
    required this.usuario,
    this.expiraEn,
    this.hogarId,
    this.rol,
  });

  final String tokenAcceso;
  final String tokenRefresco;
  final DateTime? expiraEn;
  final Usuario usuario;
  final String? hogarId;
  final Rol? rol;

  bool get tieneHogar => hogarId != null;

  /// Only the owner can edit the profile, consent, camera name, family and alert order (CA-08.4).
  bool get esTitular => rol == Rol.titular;

  factory Sesion.desdeJson(Map<String, dynamic> json) => Sesion(
    tokenAcceso: json['tokenAcceso'] as String,
    tokenRefresco: json['tokenRefresco'] as String,
    expiraEn: switch (json['expiraEn']) {
      final String texto => fechaDesdeJson(texto),
      final int segundos => DateTime.now().add(Duration(seconds: segundos)),
      _ => null,
    },
    usuario: Usuario.desdeJson(json['usuario'] as Map<String, dynamic>),
    hogarId: json['hogarId'] as String?,
    rol: Rol.desde(json['rol']),
  );

  Map<String, Object?> aJson() => {
    'tokenAcceso': tokenAcceso,
    'tokenRefresco': tokenRefresco,
    'expiraEn': expiraEn?.toUtc().toIso8601String(),
    'usuario': usuario.aJson(),
    'hogarId': hogarId,
    'rol': rol?.codigo,
  };
}
