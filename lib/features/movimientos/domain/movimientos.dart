import '../../../core/formato.dart';

/// The certificate of the consent to store movements (contract §11 `constancia`, CA-35.2).
class ConstanciaMovimientos {
  const ConstanciaMovimientos({
    required this.otorgadoEn,
    required this.otorgadoPor,
    required this.representante,
    required this.registradoPor,
    required this.versionTexto,
    this.revocadoEn,
  });

  final DateTime otorgadoEn;

  /// The older adult, or their representative when [representante].
  final String otorgadoPor;
  final bool representante;
  final String registradoPor;
  final String versionTexto;
  final DateTime? revocadoEn;

  factory ConstanciaMovimientos.desdeJson(Map<String, dynamic> json) =>
      ConstanciaMovimientos(
        otorgadoEn: fechaDesdeJson(json['otorgadoEn'])!,
        otorgadoPor: json['otorgadoPor'] as String,
        representante: json['representante'] as bool? ?? false,
        registradoPor:
            (json['registradoPor'] as Map<String, dynamic>?)?['nombre']
                as String? ??
            '',
        versionTexto: '${json['versionTexto'] ?? ''}',
        revocadoEn: fechaDesdeJson(json['revocadoEn']),
      );
}

/// The deletion of the cloud movements after the latest revocation (CA-35.4).
class EliminacionMovimientos {
  const EliminacionMovimientos({
    required this.terminada,
    required this.archivos,
    required this.programadaEn,
    this.terminadaEn,
  });

  final bool terminada;
  final int archivos;
  final DateTime programadaEn;
  final DateTime? terminadaEn;

  static EliminacionMovimientos? desde(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final programada = fechaDesdeJson(json['programadaEn']);
    if (programada == null) return null;
    return EliminacionMovimientos(
      terminada: json['estado'] == 'TERMINADA',
      archivos: (json['archivos'] as num?)?.toInt() ?? 0,
      programadaEn: programada,
      terminadaEn: fechaDesdeJson(json['terminadaEn']),
    );
  }
}

/// `GET /api/hogar/consentimiento-movimientos` (US-35): separate and optional.
class ConsentimientoMovimientos {
  const ConsentimientoMovimientos({
    required this.vigente,
    required this.versionTextoVigente,
    this.constancia,
    this.eliminacion,
  });

  final bool vigente;

  /// The version of the text the app shows and registers (`"1"` for now).
  final String versionTextoVigente;

  /// The latest consent, in force or revoked; null if none was ever registered.
  final ConstanciaMovimientos? constancia;
  final EliminacionMovimientos? eliminacion;

  factory ConsentimientoMovimientos.desdeJson(Map<String, dynamic> json) =>
      ConsentimientoMovimientos(
        vigente: json['vigente'] as bool? ?? false,
        versionTextoVigente: '${json['versionTextoVigente'] ?? '1'}',
        constancia: switch (json['constancia']) {
          final Map<String, dynamic> c => ConstanciaMovimientos.desdeJson(c),
          _ => null,
        },
        eliminacion: EliminacionMovimientos.desde(json['eliminacion']),
      );
}

/// `GET /api/hogar/movimientos-en-la-nube` (US-37, CA-37.1).
class MovimientosEnLaNube {
  const MovimientosEnLaNube({
    required this.retencionDias,
    required this.opciones,
    required this.maximoRecomendadoDias,
    required this.mbMinimo,
    required this.mbMaximo,
    required this.consentimientoVigente,
    this.datosDesde,
    this.archivos = 0,
    this.tamanoBytes = 0,
  });

  /// Null: not stored in the cloud (the default).
  final int? retencionDias;
  final List<int> opciones;
  final int maximoRecomendadoDias;

  /// The change request's estimate per camera and day (40 to 80 MB).
  final int mbMinimo;
  final int mbMaximo;
  final bool consentimientoVigente;
  final DateTime? datosDesde;
  final int archivos;
  final int tamanoBytes;

  factory MovimientosEnLaNube.desdeJson(Map<String, dynamic> json) {
    final mb = json['mbPorCamaraPorDia'] as Map<String, dynamic>? ?? const {};
    return MovimientosEnLaNube(
      retencionDias: (json['retencionDias'] as num?)?.toInt(),
      opciones: [
        for (final o
            in json['opciones'] as List<dynamic>? ?? const [7, 30, 90, 365])
          (o as num).toInt(),
      ],
      maximoRecomendadoDias:
          (json['maximoRecomendadoDias'] as num?)?.toInt() ?? 365,
      mbMinimo: (mb['minimo'] as num?)?.toInt() ?? 40,
      mbMaximo: (mb['maximo'] as num?)?.toInt() ?? 80,
      consentimientoVigente: json['consentimientoVigente'] as bool? ?? false,
      datosDesde: fechaDesdeJson(json['datosDesde']),
      archivos: (json['archivos'] as num?)?.toInt() ?? 0,
      tamanoBytes: (json['tamanoBytes'] as num?)?.toInt() ?? 0,
    );
  }
}

/// «7 días», «30 días», «1 año» (`cloudLbl` without «Se guardan»).
String textoPlazo(int dias) => dias == 365 ? '1 año' : '$dias días';

/// «Se guardan 30 días», «Desactivado» (`cloudLbl`).
String resumenNube(int? dias) =>
    dias == null ? 'Desactivado' : 'Se guardan ${textoPlazo(dias)}';
