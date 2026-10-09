import '../formato.dart';

/// `tipo` of the push data payload (contract §7).
enum TipoPush {
  alertaCaida('ALERTA_CAIDA'),
  alertaMovimientoInestable('ALERTA_MOVIMIENTO_INESTABLE'),
  alertaActualizadaACaida('ALERTA_ACTUALIZADA_A_CAIDA'),
  caidaConfirmada('CAIDA_CONFIRMADA'),
  seLevanto('SE_LEVANTO'),
  alertaAtendida('ALERTA_ATENDIDA'),
  alertaEscalada('ALERTA_ESCALADA'),
  sinContactoSecundario('SIN_CONTACTO_SECUNDARIO'),
  camaraDesconectada('CAMARA_DESCONECTADA'),
  camaraReconectada('CAMARA_RECONECTADA'),
  deteccionNoConfiable('DETECCION_NO_CONFIABLE'),
  pausaFinalizada('PAUSA_FINALIZADA'),
  datosEliminados('DATOS_ELIMINADOS');

  const TipoPush(this.codigo);

  final String codigo;

  static TipoPush? desde(Object? valor) =>
      values.where((t) => t.codigo == valor).firstOrNull;

  /// Pushes about an alert, which open the alert screen.
  bool get deAlerta => switch (this) {
    alertaCaida ||
    alertaMovimientoInestable ||
    alertaActualizadaACaida ||
    caidaConfirmada ||
    seLevanto ||
    alertaEscalada ||
    sinContactoSecundario => true,
    _ => false,
  };

  /// Pushes about the camera.
  bool get deCamara => switch (this) {
    camaraDesconectada ||
    camaraReconectada ||
    deteccionNoConfiable ||
    pausaFinalizada => true,
    _ => false,
  };
}

/// Data payload `{tipo, alertaId?, camaraId?, habitacion?, ocurridaEn}`.
class MensajePush {
  const MensajePush({
    required this.tipo,
    this.alertaId,
    this.camaraId,
    this.habitacion,
    this.ocurridaEn,
  });

  final TipoPush tipo;
  final String? alertaId;
  final String? camaraId;
  final String? habitacion;
  final DateTime? ocurridaEn;

  /// Null when the payload has an unknown `tipo`.
  static MensajePush? desdeDatos(Map<String, dynamic> datos) {
    final tipo = TipoPush.desde(datos['tipo']);
    if (tipo == null) return null;
    String? texto(String clave) {
      final v = datos[clave];
      return v is String && v.isNotEmpty ? v : null;
    }

    return MensajePush(
      tipo: tipo,
      alertaId: texto('alertaId'),
      camaraId: texto('camaraId'),
      habitacion: texto('habitacion'),
      ocurridaEn: fechaDesdeJson(texto('ocurridaEn')),
    );
  }
}
