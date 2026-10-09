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
    this.noConfiableDesde,
  });

  final String id;
  final String nombreHabitacion;
  final EstadoConexion estado;
  final DateTime? ultimaSenal;

  /// Set while the camera is paused (CA-22.2).
  final DateTime? pausadaHasta;

  /// False after more than 5 minutes with only discarded frames (CA-15.3).
  final bool deteccionConfiable;

  /// When the project team installed the camera («Instalada el», CA-06.1).
  final DateTime? instaladaEn;

  /// Since when detection is unreliable (CA-15.3); null while it is reliable.
  final DateTime? noConfiableDesde;

  bool get enPausa => pausadaHasta != null;

  factory Camara.desdeJson(Map<String, dynamic> json) => Camara(
    id: json['id'] as String,
    nombreHabitacion: json['nombreHabitacion'] as String,
    estado: EstadoConexion.desde(json['estadoConexion'] as String),
    ultimaSenal: fechaDesdeJson(json['ultimaSenal']),
    pausadaHasta: fechaDesdeJson(json['pausadaHasta']),
    deteccionConfiable: json['deteccionConfiable'] as bool? ?? true,
    instaladaEn: fechaDesdeJson(json['instaladaEn']),
    noConfiableDesde: fechaDesdeJson(json['noConfiableDesde']),
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

/// Pause lengths of the prototype's pause sheet (contract `duracion`, CA-22.1).
enum DuracionPausa {
  min30('MIN_30', '30 minutos', Duration(minutes: 30)),
  hora1('HORA_1', '1 hora', Duration(hours: 1)),
  horas2('HORAS_2', '2 horas', Duration(hours: 2)),
  hastaManana('HASTA_MANANA', 'Hasta mañana', null);

  const DuracionPausa(this.codigo, this.texto, this.duracion);

  final String codigo;
  final String texto;

  /// Null for «Hasta mañana», which ends at 07:00 the next day.
  final Duration? duracion;

  /// «hasta las 11:12», or «a las 07:00».
  String fin(DateTime ahora) => duracion == null
      ? 'a las $horaManana'
      : 'hasta las ${hora(ahora.add(duracion!))}';

  /// Resume time of «Hasta mañana» (contract: next 07:00 in the household time zone).
  static const horaManana = '07:00';
}

/// «11:42», or «07:00 de mañana» when the pause ends another day.
String finDePausa(DateTime fin, DateTime ahora) =>
    mismoDia(fin, ahora) ? hora(fin) : '${hora(fin)} de mañana';

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
