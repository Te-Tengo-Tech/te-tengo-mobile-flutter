import 'dart:typed_data';

import '../../../core/formato.dart';

/// Live view session (`POST /api/camaras/{id}/vista-en-vivo`, CA-23.1, CA-23.2).
class SesionVivo {
  const SesionVivo({
    required this.sesionId,
    required this.urlTransmision,
    this.expiraEn,
  });

  final String sesionId;
  final Uri urlTransmision;
  final DateTime? expiraEn;

  factory SesionVivo.desdeJson(Map<String, dynamic> json) => SesionVivo(
    sesionId: json['sesionId'] as String,
    urlTransmision: Uri.parse(json['urlTransmision'] as String),
    expiraEn: fechaDesdeJson(json['expiraEn']),
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

/// The JPEG of a relayed frame `[8-byte big-endian ms timestamp][JPEG]`; null when too short.
Uint8List? jpegDeFotograma(List<int> mensaje) {
  if (mensaje.length <= 8) return null;
  return mensaje is Uint8List
      ? Uint8List.sublistView(mensaje, 8)
      : Uint8List.fromList(mensaje.sublist(8));
}
