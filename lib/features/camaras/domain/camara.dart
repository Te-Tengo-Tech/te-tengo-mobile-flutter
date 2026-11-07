import '../../../core/formato.dart';
import '../../../l10n/l10n.dart';

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
    this.pcId,
    this.ambienteId,
    this.nombreDispositivo,
  });

  final String id;
  final String nombreHabitacion;
  final EstadoConexion estado;
  final DateTime? ultimaSenal;

  /// Set while the camera is paused (CA-22.2).
  final DateTime? pausadaHasta;

  /// False after more than 5 minutes with only discarded frames (CA-15.3).
  final bool deteccionConfiable;

  /// When the Te Tengo team installed the camera («Instalada el», CA-06.1).
  final DateTime? instaladaEn;

  /// Since when detection is unreliable (CA-15.3); null while it is reliable.
  final DateTime? noConfiableDesde;

  /// The PC the camera is connected to (contract §9); null only for old rows.
  final String? pcId;

  /// The room (`ambiente`) the camera watches.
  final String? ambienteId;

  /// The webcam's name as the PC shows it («Webcam USB HD»); null for cameras installed by the
  /// project team.
  final String? nombreDispositivo;

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
    pcId: json['pcId'] as String?,
    ambienteId: json['ambienteId'] as String?,
    nombreDispositivo: json['nombreDispositivo'] as String?,
  );

  /// State shown to the family. Precedence of the prototype (`camState`): without consent the camera
  /// is stopped; then its PC offline, disconnected, paused, unreliable detection and online.
  ///
  /// [pcSinConexion]: the camera's PC does not answer (CA-30.3), shown as «Sin conexión · la PC no
  /// responde» instead of the camera being unplugged.
  EstadoVisible estadoVisible({
    required bool conConsentimiento,
    bool pcSinConexion = false,
  }) {
    if (!conConsentimiento) return EstadoVisible.detenida;
    if (pcSinConexion) return EstadoVisible.sinConexion;
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
  min30('MIN_30', Duration(minutes: 30)),
  hora1('HORA_1', Duration(hours: 1)),
  horas2('HORAS_2', Duration(hours: 2)),
  hastaManana('HASTA_MANANA', null);

  const DuracionPausa(this.codigo, this.duracion);

  final String codigo;

  /// Null for «Hasta mañana», which ends at 07:00 the next day.
  final Duration? duracion;

  /// «30 minutos», «1 hora», «2 horas», «Hasta mañana».
  String texto(AppLocalizations l) => switch (this) {
    min30 => l.camaraPausa30Min,
    hora1 => l.camaraPausa1Hora,
    horas2 => l.camaraPausa2Horas,
    hastaManana => l.camaraPausaHastaManana,
  };

  /// «hasta las 11:12», or «a las 07:00».
  String fin(DateTime ahora, AppLocalizations l) => duracion == null
      ? l.camaraPausaFinALas(l.formato.hora(DateTime(2000, 1, 1, 7)))
      : l.camaraPausaFinHasta(l.formato.hora(ahora.add(duracion!)));

  /// Resume time of «Hasta mañana» (contract: next 07:00 in the household time zone).
  static const horaManana = '07:00';
}

/// «11:42», or «07:00 de mañana» when the pause ends another day.
String finDePausa(DateTime fin, DateTime ahora, AppLocalizations l) =>
    mismoDia(fin, ahora)
    ? l.formato.hora(fin)
    : l.camaraFinDePausaManana(l.formato.hora(fin));

/// Camera states of DESIGN.md: always icon + text, never color alone.
enum EstadoVisible {
  enLinea,
  desconectada,
  enPausa,
  noConfiable,
  detenida,

  /// Its PC does not answer (CA-30.3): gray and dotted, unlike an unplugged camera.
  sinConexion;

  /// «En línea», «Desconectada», «En pausa», «Detección no confiable», «Detenida», «Sin conexión».
  String texto(AppLocalizations l) => switch (this) {
    enLinea => l.camaraEstadoEnLinea,
    desconectada => l.camaraEstadoDesconectada,
    enPausa => l.camaraEstadoEnPausa,
    noConfiable => l.camaraEstadoNoConfiable,
    detenida => l.camaraEstadoDetenida,
    sinConexion => l.camaraEstadoSinConexion,
  };
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

/// Spanish articles only in Spanish ([l] null is Spanish); other languages use the bare name.
bool _conArticulos(AppLocalizations? l) =>
    l == null || l.localeName.startsWith('es');

/// «la Sala» (or the name itself when it is not a known room, or the language is not Spanish).
String conArticulo(String habitacion, [AppLocalizations? l]) =>
    _conArticulos(l) ? _articulos[habitacion] ?? habitacion : habitacion;

/// «en la Sala» («in Sala» in English). Without [l], Spanish.
String enHabitacion(String habitacion, [AppLocalizations? l]) => l == null
    ? 'en ${conArticulo(habitacion)}'
    : l.camaraEnHabitacion(conArticulo(habitacion, l));

/// «de la Sala», «del Dormitorio»; in English the bare name, as in «Sala camera». Without [l],
/// Spanish.
String deHabitacion(String habitacion, [AppLocalizations? l]) {
  if (!_conArticulos(l)) return habitacion;
  final a = _articulos[habitacion];
  if (a == null) return 'de $habitacion';
  return a.startsWith('el ') ? 'del ${a.substring(3)}' : 'de $a';
}
