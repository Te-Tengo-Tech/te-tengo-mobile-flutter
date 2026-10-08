import '../../../core/formato.dart';

/// What the camera's stream shows; the agent draws it, so it applies to every viewer.
enum ModoVista {
  /// The camera frame.
  video('VIDEO'),

  /// The camera frame with the detected skeleton on top.
  videoConPostura('VIDEO_CON_POSTURA'),

  /// Only the skeleton on a plain background: no camera pixels leave the home.
  soloPostura('SOLO_POSTURA');

  const ModoVista(this.codigo);

  final String codigo;

  /// `VIDEO` when missing or unknown, the contract default.
  static ModoVista desdeCodigo(Object? codigo) =>
      values.where((m) => m.codigo == codigo).firstOrNull ?? video;
}

/// Live view session (`POST /api/camaras/{id}/vista-en-vivo`, CA-23.1, CA-23.2).
class SesionVivo {
  const SesionVivo({
    required this.sesionId,
    required this.urlTransmision,
    this.expiraEn,
    this.modo = ModoVista.video,
  });

  final String sesionId;

  /// LL-HLS playlist of the camera, authorized by the viewer token in its query.
  final Uri urlTransmision;
  final DateTime? expiraEn;
  final ModoVista modo;

  factory SesionVivo.desdeJson(Map<String, dynamic> json) => SesionVivo(
    sesionId: json['sesionId'] as String,
    urlTransmision: Uri.parse(json['urlTransmision'] as String),
    expiraEn: fechaDesdeJson(json['expiraEn']),
    modo: ModoVista.desdeCodigo(json['modo']),
  );
}

/// One recorded access to the live view (`GET /api/accesos-vista-en-vivo`, CA-24.1).
class AccesoVivo {
  const AccesoVivo({
    required this.usuarioId,
    required this.nombre,
    required this.inicio,
    required this.duracionSegundos,
    this.desdeAlerta = false,
  });

  final String usuarioId;
  final String nombre;
  final DateTime inicio;
  final int duracionSegundos;
  final bool desdeAlerta;

  factory AccesoVivo.desdeJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>;
    return AccesoVivo(
      usuarioId: usuario['id'] as String,
      nombre: usuario['nombre'] as String,
      inicio: fechaDesdeJson(json['inicio'])!,
      duracionSegundos: (json['duracionSegundos'] as num).toInt(),
      desdeAlerta: json['desdeAlerta'] as bool? ?? false,
    );
  }
}
