import '../../../core/formato.dart';

/// Household camera (contract §4 `Camara`).
class Camara {
  const Camara({
    required this.id,
    required this.nombreHabitacion,
    required this.estado,
    this.ultimaSenal,
    this.pausadaHasta,
    this.deteccionConfiable = true,
    this.instaladaEn,
  });

  final String id;
  final String nombreHabitacion;
  final EstadoConexion estado;
  final DateTime? ultimaSenal;

  /// Set while the camera is paused (CA-22.2).
  final DateTime? pausadaHasta;

  /// False after more than 5 minutes with only discarded frames (CA-15.3).
  final bool deteccionConfiable;

  /// Installation date; not in the contract (docs/BLOCKERS.md), read when present.
  final DateTime? instaladaEn;

  bool get enPausa => pausadaHasta != null;

  factory Camara.desdeJson(Map<String, dynamic> json) => Camara(
    id: json['id'] as String,
    nombreHabitacion: json['nombreHabitacion'] as String,
    estado: EstadoConexion.desde(json['estadoConexion'] as String),
    ultimaSenal: fechaDesdeJson(json['ultimaSenal']),
    pausadaHasta: fechaDesdeJson(json['pausadaHasta']),
    deteccionConfiable: json['deteccionConfiable'] as bool? ?? true,
    instaladaEn: fechaDesdeJson(json['instaladaEn']),
  );

  /// State shown to the family. Precedence of the prototype (`camState`): without consent the camera
  /// is stopped; then disconnected, paused, unreliable detection and online.
  EstadoVisible estadoVisible({required bool conConsentimiento}) {
    if (!conConsentimiento) return EstadoVisible.detenida;
    if (estado == EstadoConexion.desconectada) {
      return EstadoVisible.desconectada;
    }
    if (enPausa) return EstadoVisible.enPausa;
    if (!deteccionConfiable) return EstadoVisible.noConfiable;
    return EstadoVisible.enLinea;
  }
}

enum EstadoConexion {
  enLinea,
  desconectada;

  static EstadoConexion desde(String valor) => valor == 'EN_LINEA'
      ? EstadoConexion.enLinea
      : EstadoConexion.desconectada;
}

/// Camera states of DESIGN.md: always icon + text, never color alone.
enum EstadoVisible {
  enLinea('En línea'),
  desconectada('Desconectada'),
  enPausa('En pausa'),
  noConfiable('Detección no confiable'),
  detenida('Detenida');

  const EstadoVisible(this.texto);

  final String texto;
}

/// Article forms of the room names of the prototype (`ROOM_ART`): «la Sala», «el Dormitorio».
const _articulos = {
  'Sala': 'la Sala',
  'Sala comedor': 'la Sala comedor',
  'Dormitorio': 'el Dormitorio',
  'Cocina': 'la Cocina',
  'Pasillo': 'el Pasillo',
  'Comedor': 'el Comedor',
};

/// «la Sala» (or the name itself when it is not a known room).
String conArticulo(String habitacion) => _articulos[habitacion] ?? habitacion;

/// «en la Sala».
String enHabitacion(String habitacion) => 'en ${conArticulo(habitacion)}';

/// «de la Sala», «del Dormitorio».
String deHabitacion(String habitacion) {
  final a = _articulos[habitacion];
  if (a == null) return 'de $habitacion';
  return a.startsWith('el ') ? 'del ${a.substring(3)}' : 'de $a';
}
