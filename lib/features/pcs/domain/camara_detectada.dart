import '../../../core/formato.dart';
import '../../camaras/domain/camara.dart';

/// A webcam a PC reported, in use in a room or «sin usar» (contract §9 `CamaraDetectada`). Its
/// [id] is the camera's id for every camera endpoint, and stays the same because the PC knows the
/// webcam by the operating system's device id (CA-29.4).
class CamaraDetectada {
  const CamaraDetectada({
    required this.id,
    required this.pcId,
    required this.nombreDispositivo,
    required this.enUso,
    required this.conectada,
    this.ambienteId,
    this.nombreHabitacion,
    this.estado,
    this.pausadaHasta,
    this.detectadaEn,
  });

  final String id;
  final String pcId;

  /// «Webcam USB HD», as the PC shows it.
  final String nombreDispositivo;

  /// In a room; false is «Sin usar».
  final bool enUso;

  /// In use: online by its heartbeats; otherwise plugged in at the PC's latest report.
  final bool conectada;
  final String? ambienteId;
  final String? nombreHabitacion;
  final EstadoConexion? estado;
  final DateTime? pausadaHasta;
  final DateTime? detectadaEn;

  bool get enPausa => pausadaHasta != null;

  factory CamaraDetectada.desdeJson(Map<String, dynamic> json) =>
      CamaraDetectada(
        id: json['id'] as String,
        pcId: json['pcId'] as String,
        nombreDispositivo: json['nombreDispositivo'] as String? ?? 'Cámara',
        enUso: json['enUso'] as bool? ?? false,
        conectada: json['conectada'] as bool? ?? false,
        ambienteId: json['ambienteId'] as String?,
        nombreHabitacion: json['nombreHabitacion'] as String?,
        estado: switch (json['estadoConexion']) {
          final String e => EstadoConexion.desde(e),
          _ => null,
        },
        pausadaHasta: fechaDesdeJson(json['pausadaHasta']),
        detectadaEn: fechaDesdeJson(json['detectadaEn']),
      );
}

/// A room of the household with its cameras in use (contract §9 `Ambiente`); the app says
/// «habitación».
class Ambiente {
  const Ambiente({
    required this.id,
    required this.nombre,
    this.camaras = const [],
  });

  final String id;
  final String nombre;

  /// At most one for now (CA-29.3).
  final List<CamaraDeAmbiente> camaras;

  /// The room already has a camera.
  bool get conCamara => camaras.isNotEmpty;

  factory Ambiente.desdeJson(Map<String, dynamic> json) => Ambiente(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    camaras: [
      for (final c in json['camaras'] as List<dynamic>? ?? const [])
        CamaraDeAmbiente.desdeJson(c as Map<String, dynamic>),
    ],
  );
}

/// The camera in use in a room, and its PC (`Ambiente.camaras`, `409 AMBIENTE_OCUPADO` `camara`).
class CamaraDeAmbiente {
  const CamaraDeAmbiente({
    required this.id,
    this.pcId,
    this.pcNombre,
    this.nombreDispositivo,
  });

  final String id;
  final String? pcId;
  final String? pcNombre;
  final String? nombreDispositivo;

  static CamaraDeAmbiente? desde(Object? json) =>
      json is Map<String, dynamic> ? CamaraDeAmbiente.desdeJson(json) : null;

  factory CamaraDeAmbiente.desdeJson(Map<String, dynamic> json) =>
      CamaraDeAmbiente(
        id: json['id'] as String,
        pcId: json['pcId'] as String?,
        pcNombre: json['pcNombre'] as String?,
        nombreDispositivo: json['nombreDispositivo'] as String?,
      );
}

/// Room names that mean a bathroom (contract §9: baño, servicios higiénicos, SS.HH., WC, aseo…),
/// the same words as the backend's rule, so the app says «Por privacidad, Te Tengo no admite cámaras
/// en el baño.» before sending them.
bool esBano(String nombre) {
  const tildes = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  final sinTildes = nombre
      .toLowerCase()
      .split('')
      .map((c) => tildes[c] ?? c)
      .join()
      .replaceAll(RegExp('[^a-z0-9]+'), ' ')
      .trim();
  return RegExp(
    r' (bano|banos|wc|aseo|toilet|ss hh|sshh|servicio higienico|'
    r'servicios higienicos|bath|bathroom) ',
  ).hasMatch(' $sinTildes ');
}
