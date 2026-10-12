import '../../../core/formato.dart';

/// Longest note of a report (contract `POST /api/reportes-de-caida`).
const notaMaxima = 300;

/// «¿Hubo una caída y no avisó?» (US-40, CA-40.4): a fall the family saw and the detection did
/// not alert. It is stored for the team's evaluation as a possible false negative; it creates no
/// alert and notifies nobody.
class ReporteCaida {
  const ReporteCaida({
    required this.ocurridaAproximadamenteEn,
    this.camaraId,
    this.habitacion,
    this.nota,
  });

  /// The camera of the chosen room (the backend records its room).
  final String? camaraId;

  /// A room without a camera; null with [camaraId], and both null for «No sé».
  final String? habitacion;
  final DateTime ocurridaAproximadamenteEn;
  final String? nota;

  Map<String, dynamic> aJson() => {
    'camaraId': camaraId,
    'habitacion': habitacion,
    'ocurridaAproximadamenteEn': ocurridaAproximadamenteEn
        .toUtc()
        .toIso8601String(),
    'nota': nota,
  };

  factory ReporteCaida.desdeJson(Map<String, dynamic> json) => ReporteCaida(
    camaraId: json['camaraId'] as String?,
    habitacion: json['habitacion'] as String?,
    ocurridaAproximadamenteEn: fechaDesdeJson(
      json['ocurridaAproximadamenteEn'],
    )!,
    nota: json['nota'] as String?,
  );
}

/// `201` of the report.
class ReporteRecibido {
  const ReporteRecibido({
    required this.id,
    required this.recibidoEn,
    required this.movimientosDisponibles,
  });

  final String id;
  final DateTime recibidoEn;

  /// The movements of that moment may be in the cloud (consent and retention on).
  final bool movimientosDisponibles;

  factory ReporteRecibido.desdeJson(Map<String, dynamic> json) =>
      ReporteRecibido(
        id: json['id'] as String,
        recibidoEn: fechaDesdeJson(json['recibidoEn'])!,
        movimientosDisponibles:
            json['movimientosDisponibles'] as bool? ?? false,
      );
}

/// «07:30» → minutes since midnight; null when it is not a time written as HH:MM.
int? minutosDeHora(String texto) {
  final m = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(texto.trim());
  if (m == null) return null;
  return int.parse(m[1]!) * 60 + int.parse(m[2]!);
}

/// The time field while typing: digits only, with the colon after the hour («0730» → «07:30»).
String formatoHora(String texto) {
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  final d = digitos.length > 4 ? digitos.substring(0, 4) : digitos;
  return d.length <= 2 ? d : '${d.substring(0, 2)}:${d.substring(2)}';
}
