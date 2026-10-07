import '../../../core/formato.dart';
import '../../../core/sesion/sesion.dart';

/// Living arrangement of the older adult (contract §2, from the prototype's profile screen).
enum Convivencia {
  solo('SOLO', 'Vive solo(a)', 'Pasa el día sin compañía'),
  conFamiliar('CON_FAMILIAR', 'Vive conmigo', 'Comparte la vivienda contigo'),
  conCuidador(
    'CON_CUIDADOR',
    'Vive con otro cuidador',
    'Un pariente o cuidador(a) está en casa',
  );

  const Convivencia(this.codigo, this.titulo, this.detalle);

  final String codigo;
  final String titulo;
  final String detalle;

  static Convivencia? desde(Object? valor) =>
      Convivencia.values.where((c) => c.codigo == valor).firstOrNull;
}

/// The older adult cared for (`adultoMayor`).
///
/// `edad` and `telefono` appear in the prototype but not in the contract (see docs/BLOCKERS.md): they
/// are read when the backend sends them and never sent.
class AdultoMayor {
  const AdultoMayor({
    required this.nombre,
    required this.direccion,
    required this.convivencia,
    this.edad,
    this.telefono,
  });

  final String nombre;
  final String direccion;
  final Convivencia? convivencia;
  final int? edad;
  final String? telefono;

  /// `Rosa`.
  String get nombrePila => nombre.trim().split(RegExp(r'\s+')).first;

  factory AdultoMayor.desdeJson(Map<String, dynamic> json) => AdultoMayor(
    nombre: json['nombre'] as String,
    direccion: json['direccion'] as String? ?? '',
    convivencia: Convivencia.desde(json['convivencia']),
    edad: json['edad'] as int?,
    telefono: json['telefono'] as String?,
  );

  /// Body of `POST /api/hogar` and `PUT /api/hogar/adulto-mayor`.
  Map<String, Object?> aJson() => {
    'nombre': nombre,
    'direccion': direccion,
    'convivencia': convivencia?.codigo,
  };
}

/// Informed consent record (`Consentimiento`), required by Law No. 29733 (CA-05.3).
class Consentimiento {
  const Consentimiento({
    required this.otorgadoEn,
    required this.otorgadoPor,
    required this.registradoPor,
    required this.vistaEnVivoAceptada,
    required this.vigente,
  });

  final DateTime otorgadoEn;
  final String otorgadoPor;
  final String registradoPor;
  final bool vistaEnVivoAceptada;
  final bool vigente;

  factory Consentimiento.desdeJson(Map<String, dynamic> json) => Consentimiento(
    otorgadoEn: fechaDesdeJson(json['otorgadoEn'])!,
    otorgadoPor: json['otorgadoPor'] as String,
    registradoPor:
        (json['registradoPor'] as Map<String, dynamic>?)?['nombre']
            as String? ??
        '',
    vistaEnVivoAceptada: json['vistaEnVivoAceptada'] as bool? ?? false,
    vigente: json['vigente'] as bool? ?? true,
  );
}

/// `GET /api/hogar`.
class Hogar {
  const Hogar({
    required this.hogarId,
    required this.adultoMayor,
    required this.rol,
    this.consentimiento,
  });

  final String hogarId;
  final AdultoMayor adultoMayor;
  final Rol? rol;
  final Consentimiento? consentimiento;

  /// Without a valid consent the camera does not send video (CA-05.2).
  bool get conConsentimiento => consentimiento?.vigente ?? false;

  factory Hogar.desdeJson(Map<String, dynamic> json) => Hogar(
    hogarId: json['hogarId'] as String,
    adultoMayor: AdultoMayor.desdeJson(
      json['adultoMayor'] as Map<String, dynamic>,
    ),
    rol: Rol.desde(json['rol']),
    consentimiento: json['consentimiento'] == null
        ? null
        : Consentimiento.desdeJson(
            json['consentimiento'] as Map<String, dynamic>,
          ),
  );
}
