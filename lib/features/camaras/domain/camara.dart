/// Cámara del hogar (mismo modelo que el módulo `camaras` del backend).
class Camara {
  const Camara({
    required this.id,
    required this.nombreHabitacion,
    required this.estado,
    this.ultimaSenal,
  });

  final String id;
  final String nombreHabitacion;
  final EstadoConexion estado;
  final DateTime? ultimaSenal;

  factory Camara.desdeJson(Map<String, dynamic> json) => Camara(
    id: json['id'] as String,
    nombreHabitacion: json['nombreHabitacion'] as String,
    estado: EstadoConexion.desde(json['estadoConexion'] as String),
    ultimaSenal: json['ultimaSenal'] == null
        ? null
        : DateTime.parse(json['ultimaSenal'] as String).toLocal(),
  );
}

enum EstadoConexion {
  enLinea,
  desconectada;

  static EstadoConexion desde(String valor) => valor == 'EN_LINEA'
      ? EstadoConexion.enLinea
      : EstadoConexion.desconectada;
}
