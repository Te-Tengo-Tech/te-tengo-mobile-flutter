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

/// The JPEG of a relayed frame `[8-byte big-endian ms timestamp][JPEG]`; null when too short.
Uint8List? jpegDeFotograma(List<int> mensaje) {
  if (mensaje.length <= 8) return null;
  return mensaje is Uint8List
      ? Uint8List.sublistView(mensaje, 8)
      : Uint8List.fromList(mensaje.sublist(8));
}
