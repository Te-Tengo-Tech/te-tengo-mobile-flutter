import '../../../core/formato.dart';

enum TipoAlerta {
  caida('CAIDA'),
  movimientoInestable('MOVIMIENTO_INESTABLE');

  const TipoAlerta(this.codigo);

  final String codigo;

  static TipoAlerta desde(Object? v) =>
      values.where((t) => t.codigo == v).firstOrNull ?? caida;

  /// «Caída», «Movimiento inestable» (`typeName`).
  String get nombre => this == caida ? 'Caída' : 'Movimiento inestable';
}

enum EstadoAlerta {
  activa('ACTIVA'),
  atendida('ATENDIDA'),
  falsaAlarma('FALSA_ALARMA');

  const EstadoAlerta(this.codigo);

  final String codigo;

  static EstadoAlerta desde(Object? v) =>
      values.where((e) => e.codigo == v).firstOrNull ?? activa;
}

/// Availability of the event clip (CA-18.2, CA-26.3).
enum EstadoClip {
  disponible('DISPONIBLE'),
  noDisponible('NO_DISPONIBLE'),
  eliminado('ELIMINADO');

  const EstadoClip(this.codigo);

  final String codigo;

  static EstadoClip desde(Object? v) =>
      values.where((e) => e.codigo == v).firstOrNull ?? noDisponible;
}

/// `Alerta` of the contract (§5).
class Alerta {
  const Alerta({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.camaraId,
    required this.habitacion,
    required this.ocurridaEn,
    this.confirmada = false,
    this.notificadaEn,
    this.recuperadaEn,
    this.atendidaPor,
    this.atendidaEn,
    this.escaladaEn,
    this.origenInestable = false,
    this.clip = EstadoClip.disponible,
  });

  final String id;
  final TipoAlerta tipo;
  final EstadoAlerta estado;

  /// Still on the floor after 30 s (CA-13.1, CA-21.2).
  final bool confirmada;
  final String camaraId;
  final String habitacion;
  final DateTime ocurridaEn;

  /// Null while the push could not be delivered (CA-16.4).
  final DateTime? notificadaEn;

  /// «Se levantó» (CA-13.2, CA-21.1).
  final DateTime? recuperadaEn;

  /// Name of who attended or marked it (CA-19.1, CA-19.3).
  final String? atendidaPor;
  final DateTime? atendidaEn;

  /// Sent to the secondary contact (CA-20.1).
  final DateTime? escaladaEn;

  /// Started as unstable movement and became a fall (CA-17.3).
  final bool origenInestable;
  final EstadoClip clip;

  bool get esCaida => tipo == TipoAlerta.caida;
  bool get activa => estado == EstadoAlerta.activa;

  /// Severity of the contract: a fall is high, unstable movement is medium.
  bool get severidadAlta => esCaida;

  /// Confirmed on the floor and not recovered.
  bool get sigueEnElSuelo => esCaida && confirmada && recuperadaEn == null;

  /// When the fall was confirmed: 30 s on the floor (CA-13.1).
  DateTime get confirmadaEn => ocurridaEn.add(const Duration(seconds: 30));

  factory Alerta.desdeJson(Map<String, dynamic> json) {
    final atendidaPor = json['atendidaPor'];
    return Alerta(
      id: json['id'] as String,
      tipo: TipoAlerta.desde(json['tipo']),
      estado: EstadoAlerta.desde(json['estado']),
      confirmada: json['confirmada'] as bool? ?? false,
      camaraId: json['camaraId'] as String? ?? '',
      habitacion: json['habitacion'] as String? ?? '',
      ocurridaEn: fechaDesdeJson(json['ocurridaEn'])!,
      notificadaEn: fechaDesdeJson(json['notificadaEn']),
      recuperadaEn: fechaDesdeJson(json['recuperadaEn']),
      atendidaPor: atendidaPor is Map ? atendidaPor['nombre'] as String? : null,
      atendidaEn: fechaDesdeJson(json['atendidaEn']),
      escaladaEn: fechaDesdeJson(json['escaladaEn']),
      origenInestable: json['origenInestable'] as bool? ?? false,
      clip: EstadoClip.desde(json['clip']),
    );
  }
}

/// A page of `GET /api/alertas`.
class PaginaAlertas {
  const PaginaAlertas({required this.elementos, required this.total});

  final List<Alerta> elementos;
  final int total;

  factory PaginaAlertas.desdeJson(Map<String, dynamic> json) => PaginaAlertas(
    elementos: ((json['elementos'] as List<dynamic>?) ?? [])
        .map((j) => Alerta.desdeJson(j as Map<String, dynamic>))
        .toList(),
    total: json['total'] as int? ?? 0,
  );
}
