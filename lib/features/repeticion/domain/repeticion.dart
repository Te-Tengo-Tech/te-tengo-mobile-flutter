import '../../../core/formato.dart';
import '../../alertas/domain/alerta.dart';

/// A movement file of a replay (contract §11): Parquet + zstd, one per camera and 5 minutes.
class ArchivoMovimientos {
  const ArchivoMovimientos({
    required this.id,
    required this.desde,
    required this.hasta,
    required this.url,
    this.sha256,
    this.fotogramas = 0,
  });

  final String id;
  final DateTime desde;
  final DateTime hasta;
  final String url;
  final String? sha256;
  final int fotogramas;

  factory ArchivoMovimientos.desdeJson(Map<String, dynamic> json) =>
      ArchivoMovimientos(
        id: json['id'] as String,
        desde: fechaDesdeJson(json['desde'])!,
        hasta: fechaDesdeJson(json['hasta'])!,
        url: json['url'] as String,
        sha256: json['sha256'] as String?,
        fotogramas: (json['fotogramas'] as num?)?.toInt() ?? 0,
      );
}

/// `Repeticion` (contract §11, US-39): a replay session of a camera; creating it is logged in the
/// access log (CA-39.3).
class Repeticion {
  const Repeticion({
    required this.id,
    required this.camaraId,
    required this.habitacion,
    required this.desde,
    required this.hasta,
    this.disponiblesDesde,
    this.guardadoEnLaNube = true,
    this.archivos = const [],
  });

  final String id;
  final String camaraId;
  final String habitacion;
  final DateTime desde;
  final DateTime hasta;

  /// Start of the oldest stored movement (CA-39.4).
  final DateTime? disponiblesDesde;
  final bool guardadoEnLaNube;

  /// Oldest first.
  final List<ArchivoMovimientos> archivos;

  factory Repeticion.desdeJson(Map<String, dynamic> json) => Repeticion(
    id: json['id'] as String,
    camaraId: json['camaraId'] as String,
    habitacion: json['habitacion'] as String? ?? '',
    desde: fechaDesdeJson(json['desde'])!,
    hasta: fechaDesdeJson(json['hasta'])!,
    disponiblesDesde: fechaDesdeJson(json['disponiblesDesde']),
    guardadoEnLaNube: json['guardadoEnLaNube'] as bool? ?? true,
    archivos: [
      for (final a in json['archivos'] as List<dynamic>? ?? const [])
        ArchivoMovimientos.desdeJson(a as Map<String, dynamic>),
    ],
  );
}

/// A replay in the access log (`GET /api/accesos-repeticiones`).
class AccesoRepeticion {
  const AccesoRepeticion({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.camaraId,
    required this.habitacion,
    required this.momentoDesde,
    required this.inicio,
    required this.duracionSegundos,
    this.momentoHasta,
  });

  final String id;
  final String usuarioId;
  final String nombre;
  final String camaraId;
  final String habitacion;
  final DateTime momentoDesde;
  final DateTime? momentoHasta;
  final DateTime inicio;
  final int duracionSegundos;

  factory AccesoRepeticion.desdeJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>? ?? const {};
    return AccesoRepeticion(
      id: json['id'] as String,
      usuarioId: usuario['id'] as String? ?? '',
      nombre: usuario['nombre'] as String? ?? '',
      camaraId: json['camaraId'] as String? ?? '',
      habitacion: json['habitacion'] as String? ?? '',
      momentoDesde: fechaDesdeJson(json['momentoDesde'])!,
      momentoHasta: fechaDesdeJson(json['momentoHasta']),
      inicio: fechaDesdeJson(json['inicio'])!,
      duracionSegundos: (json['duracionSegundos'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A mark of the player's timeline (`RP_EV`).
enum TipoEvento {
  caida('Caída'),
  inestable('Inestable'),
  levanto('Se levantó');

  const TipoEvento(this.texto);

  final String texto;
}

class EventoCamara {
  const EventoCamara({
    required this.en,
    required this.tipo,
    required this.alerta,
  });

  final DateTime en;
  final TipoEvento tipo;
  final Alerta alerta;
}

/// The timeline's events of a camera (contract §11: from `GET /api/alertas`, filtered by camera):
/// each fall or unstable movement, and «Se levantó» when a fall recovered. Oldest first.
List<EventoCamara> eventosDe(Iterable<Alerta> alertas, String camaraId) {
  final ev = <EventoCamara>[];
  for (final a in alertas) {
    if (a.camaraId != camaraId) continue;
    ev.add(
      EventoCamara(
        en: a.ocurridaEn,
        tipo: a.esCaida ? TipoEvento.caida : TipoEvento.inestable,
        alerta: a,
      ),
    );
    if (a.esCaida && a.recuperadaEn != null) {
      ev.add(
        EventoCamara(en: a.recuperadaEn!, tipo: TipoEvento.levanto, alerta: a),
      );
    }
  }
  ev.sort((x, y) => x.en.compareTo(y.en));
  return ev;
}

/// A stretch of the timeline without movements (CA-39.5).
class Tramo {
  const Tramo(this.desde, this.hasta, this.motivo);

  final DateTime desde;
  final DateTime hasta;

  /// «Sin persona en la imagen», «Cámara en pausa», «Cámara desconectada», «La PC no responde».
  final String motivo;

  bool contiene(DateTime t) => !t.isBefore(desde) && t.isBefore(hasta);
}

/// Inside a replay's window, the stretches no file covers.
List<Tramo> huecosDe(
  List<ArchivoMovimientos> archivos,
  DateTime desde,
  DateTime hasta,
) {
  final tramos = <Tramo>[];
  var cursor = desde;
  for (final a in archivos) {
    if (!a.hasta.isAfter(desde) || !a.desde.isBefore(hasta)) continue;
    if (a.desde.isAfter(cursor)) {
      tramos.add(Tramo(cursor, a.desde, 'Sin datos'));
    }
    if (a.hasta.isAfter(cursor)) cursor = a.hasta;
  }
  if (cursor.isBefore(hasta)) tramos.add(Tramo(cursor, hasta, 'Sin datos'));
  return tramos;
}
