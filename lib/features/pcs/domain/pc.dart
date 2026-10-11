import '../../../core/formato.dart';
import '../../camaras/domain/camara.dart';

/// Where a PC came from (contract §9 `origen`).
enum OrigenPc {
  /// Linked from the app with its code (US-28).
  vinculacion,

  /// Installed by the project team before PCs could be linked («PC de la casa»).
  instalacion;

  static OrigenPc desde(Object? valor) =>
      valor == 'INSTALACION' ? instalacion : vinculacion;
}

/// A PC of the household running Te Tengo Captura, with its cameras in use (contract §9 `Pc`).
class Pc {
  const Pc({
    required this.id,
    required this.nombre,
    required this.estado,
    this.sistemaOperativo,
    this.versionAgente,
    this.ultimaSenal,
    this.vinculadaEn,
    this.vinculadaPor,
    this.origen = OrigenPc.vinculacion,
    this.camaras = const [],
    this.camarasSinUsar = 0,
  });

  final String id;
  final String nombre;
  final String? sistemaOperativo;
  final String? versionAgente;

  /// A heartbeat of the PC or of one of its cameras in the last 90 s (CA-30.2, CA-30.3).
  final EstadoConexion estado;

  /// «Sin conexión desde las 09:58».
  final DateTime? ultimaSenal;
  final DateTime? vinculadaEn;

  /// First name and id of who approved it; null for installations.
  final ({String id, String nombre})? vinculadaPor;
  final OrigenPc origen;

  /// The PC's cameras in use, each in its room.
  final List<Camara> camaras;

  /// Webcams the PC detected that have no room yet: «N cámaras sin usar».
  final int camarasSinUsar;

  bool get enLinea => estado == EstadoConexion.enLinea;

  /// No heartbeat in the last 90 s (CA-30.3). A PC that never sent one was just linked and is
  /// getting its tokens, so it does not count as offline.
  bool get sinConexion => !enLinea && ultimaSenal != null;

  /// «Te Tengo Captura 0.5.0», or null when the PC did not report its version.
  String? get programa =>
      versionAgente == null ? null : 'Te Tengo Captura $versionAgente';

  factory Pc.desdeJson(Map<String, dynamic> json) {
    final por = json['vinculadaPor'];
    return Pc(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      sistemaOperativo: json['sistemaOperativo'] as String?,
      versionAgente: json['versionAgente'] as String?,
      estado: EstadoConexion.desde(json['estadoConexion'] as String? ?? ''),
      ultimaSenal: fechaDesdeJson(json['ultimaSenal']),
      vinculadaEn: fechaDesdeJson(json['vinculadaEn']),
      vinculadaPor: por is Map<String, dynamic>
          ? (id: por['id'] as String, nombre: por['nombre'] as String)
          : null,
      origen: OrigenPc.desde(json['origen']),
      camaras: [
        for (final c in json['camaras'] as List<dynamic>? ?? const [])
          Camara.desdeJson(c as Map<String, dynamic>),
      ],
      camarasSinUsar: (json['camarasSinUsar'] as num?)?.toInt() ?? 0,
    );
  }
}

/// What the approval screen shows before «Aprobar» (`POST /api/vinculaciones/consulta`, CA-28.4).
class ConsultaPc {
  const ConsultaPc({
    required this.codigo,
    required this.nombrePc,
    this.sistemaOperativo,
    this.versionAgente,
    this.expiraEn,
  });

  /// `KQWT-MXHD`.
  final String codigo;
  final String nombrePc;
  final String? sistemaOperativo;
  final String? versionAgente;
  final DateTime? expiraEn;

  factory ConsultaPc.desdeJson(Map<String, dynamic> json) => ConsultaPc(
    codigo: json['codigo'] as String,
    nombrePc: json['nombrePc'] as String,
    sistemaOperativo: json['sistemaOperativo'] as String?,
    versionAgente: json['versionAgente'] as String?,
    expiraEn: fechaDesdeJson(json['expiraEn']),
  );
}

/// The 20 consonants of the link code (contract §9: no vowels, no digits).
const letrasDelCodigo = 'BCDFGHJKLMNPQRSTVWXZ';

/// Letters of a link code.
const largoDelCodigo = 8;

/// What the user typed or scanned, kept to the code's letters: upper case, without the hyphen,
/// vowels, digits or anything else, and at most 8 (CA-28.2).
String limpiarCodigo(String texto) => texto
    .toUpperCase()
    .split('')
    .where(letrasDelCodigo.contains)
    .take(largoDelCodigo)
    .join();

/// Whether [texto] has letters or digits the code never uses (vowels, digits): the field shows
/// «El código solo lleva consonantes, sin números».
bool tieneLetrasAjenas(String texto) => texto.toUpperCase().split('').any((c) {
  final letraODigito = RegExp(r'[A-Z0-9ÁÉÍÓÚÑÜ]').hasMatch(c);
  return letraODigito && !letrasDelCodigo.contains(c);
});

/// `KQWT-MXHD` from the clean letters.
String formatoCodigo(String limpio) => limpio.length <= 4
    ? limpio
    : '${limpio.substring(0, 4)}-${limpio.substring(4)}';

/// The code of a scanned QR: the PC shows `https://app.tetengo.reqsai.tech/vincular?codigo=…`
/// (`verification_uri_complete`, contract §9). Any `…/vincular?codigo=` link is accepted, since the
/// domain is pending confirmation; null when the QR is not one of them.
String? codigoDeQr(String valor) {
  final uri = Uri.tryParse(valor.trim());
  if (uri == null || !uri.hasScheme) return null;
  final esquema = uri.scheme.toLowerCase();
  if (esquema != 'https' && esquema != 'http' && esquema != 'tetengo') {
    return null;
  }
  final segmentos = uri.pathSegments.where((s) => s.isNotEmpty);
  if (segmentos.isEmpty || segmentos.last != 'vincular') return null;
  return codigoValido(uri.queryParameters['codigo']);
}

/// The formatted code when [valor] holds exactly 8 of the code's letters (case and hyphen
/// ignored); null otherwise.
String? codigoValido(String? valor) {
  if (valor == null) return null;
  final sinGuion = valor.replaceAll(RegExp(r'[\s-]'), '');
  final limpio = limpiarCodigo(sinGuion);
  if (limpio.length != largoDelCodigo || sinGuion.length != largoDelCodigo) {
    return null;
  }
  return formatoCodigo(limpio);
}
