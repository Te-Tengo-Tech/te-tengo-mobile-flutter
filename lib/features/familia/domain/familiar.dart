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

/// Alert order and wait time (`GET /api/hogar/aviso`): CA-10.1 to CA-10.4.
class ConfiguracionAviso {
  const ConfiguracionAviso({
    required this.principalId,
    this.secundarioId,
    this.esperaMinutos = esperaPredeterminada,
  });

  /// 5 minutes until the owner chooses another wait (CA-10.3).
  static const esperaPredeterminada = 5;

  /// Waits allowed by the contract (CA-10.2).
  static const esperas = [3, 5, 10];

  final String principalId;
  final String? secundarioId;
  final int esperaMinutos;

  factory ConfiguracionAviso.desdeJson(Map<String, dynamic> json) =>
      ConfiguracionAviso(
        principalId: json['principalId'] as String,
        secundarioId: json['secundarioId'] as String?,
        esperaMinutos: json['esperaMinutos'] as int? ?? esperaPredeterminada,
      );

  Map<String, Object?> aJson() => {
    'principalId': principalId,
    'secundarioId': secundarioId,
    'esperaMinutos': esperaMinutos,
  };

  ConfiguracionAviso con({
    String? principalId,
    String? secundarioId,
    bool sinSecundario = false,
    int? esperaMinutos,
  }) => ConfiguracionAviso(
    principalId: principalId ?? this.principalId,
    secundarioId: sinSecundario ? null : secundarioId ?? this.secundarioId,
    esperaMinutos: esperaMinutos ?? this.esperaMinutos,
  );
}

/// Role of a member in the alert order.
enum PapelAviso {
  principal('Principal'),
  secundario('Secundario'),
  familiar('Recibe alertas');

  const PapelAviso(this.etiqueta);

  final String etiqueta;
}
