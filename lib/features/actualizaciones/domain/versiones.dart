import '../../../core/formato.dart';

/// A `MAJOR.MINOR.PATCH` version, compared numerically (contract §12). A build suffix (`+12`) or
/// a pre-release tag (`-rc.1`) is ignored: `0.5.3+12` is `0.5.3`.
class NumeroVersion implements Comparable<NumeroVersion> {
  const NumeroVersion(this.mayor, this.menor, this.parche);

  final int mayor;
  final int menor;
  final int parche;

  /// Null when [texto] is not a version (`''`, `'beta'`).
  static NumeroVersion? leer(String? texto) {
    final limpio = (texto ?? '').trim().split(RegExp('[+-]')).first;
    if (limpio.isEmpty) return null;
    final partes = limpio.split('.');
    if (partes.length > 3) return null;
    final numeros = [for (final p in partes) int.tryParse(p)];
    if (numeros.any((n) => n == null || n < 0)) return null;
    while (numeros.length < 3) {
      numeros.add(0);
    }
    return NumeroVersion(numeros[0]!, numeros[1]!, numeros[2]!);
  }

  @override
  int compareTo(NumeroVersion otra) {
    if (mayor != otra.mayor) return mayor.compareTo(otra.mayor);
    if (menor != otra.menor) return menor.compareTo(otra.menor);
    return parche.compareTo(otra.parche);
  }

  bool operator <(NumeroVersion otra) => compareTo(otra) < 0;

  @override
  bool operator ==(Object other) =>
      other is NumeroVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(mayor, menor, parche);

  @override
  String toString() => '$mayor.$menor.$parche';
}

/// True when [instalada] is older than [publicada]. An unreadable version is never older.
bool esAnterior(String? instalada, String? publicada) {
  final a = NumeroVersion.leer(instalada);
  final b = NumeroVersion.leer(publicada);
  return a != null && b != null && a < b;
}

/// The latest published version of one app (contract §12 `Version`).
class VersionPublicada {
  const VersionPublicada({
    required this.version,
    this.versionMinima,
    this.url,
    this.sha256,
    this.tamanoBytes,
    this.publicadaEn,
    this.notas = const [],
  });

  /// `0.6.0`.
  final String version;

  /// CA-43.8: an installed version below it is no longer supported; null: every version is.
  final String? versionMinima;

  /// The file (windows, mac, apk), the store page (play, ios) or the app (pwa).
  final String? url;

  /// SHA-256 of the file at [url] (64 lowercase hex); null for play, ios and pwa.
  final String? sha256;
  final int? tamanoBytes;
  final DateTime? publicadaEn;

  /// «Qué cambió»: short lines for the family.
  final List<String> notas;

  /// [instalada] has an update.
  bool hayNuevaPara(String instalada) => esAnterior(instalada, version);

  /// [instalada] must update (CA-43.8).
  bool esObligatoriaPara(String instalada) =>
      esAnterior(instalada, versionMinima);

  static VersionPublicada? desdeJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final version = json['version'];
    if (version is! String || NumeroVersion.leer(version) == null) return null;
    return VersionPublicada(
      version: version,
      versionMinima: json['versionMinima'] as String?,
      url: json['url'] as String?,
      sha256: (json['sha256'] as String?)?.toLowerCase(),
      tamanoBytes: (json['tamanoBytes'] as num?)?.toInt(),
      publicadaEn: fechaDesdeJson(json['publicadaEn']),
      notas: [
        for (final n in json['notas'] as List<dynamic>? ?? const [])
          if (n is String && n.trim().isNotEmpty) n.trim(),
      ],
    );
  }
}

/// The channels of the mobile app (contract §12, «Which channel»).
enum Canal {
  /// The installable web app.
  pwa,

  /// Android installed from the APK (sideload).
  apk,

  /// Android installed by Google Play.
  play,

  /// iPhone, from TestFlight or the App Store.
  ios,
}

/// `GET /api/versiones` (contract §12).
class Versiones {
  const Versiones({
    this.windows,
    this.mac,
    this.apk,
    this.play,
    this.ios,
    this.pwa,
    this.paginaDescargas,
  });

  final VersionPublicada? windows;
  final VersionPublicada? mac;
  final VersionPublicada? apk;
  final VersionPublicada? play;
  final VersionPublicada? ios;
  final VersionPublicada? pwa;
  final String? paginaDescargas;

  factory Versiones.desdeJson(Map<String, dynamic> json) => Versiones(
    windows: VersionPublicada.desdeJson(json['windows']),
    mac: VersionPublicada.desdeJson(json['mac']),
    apk: VersionPublicada.desdeJson(json['apk']),
    play: VersionPublicada.desdeJson(json['play']),
    ios: VersionPublicada.desdeJson(json['ios']),
    pwa: VersionPublicada.desdeJson(json['pwa']),
    paginaDescargas: json['paginaDescargas'] as String?,
  );

  VersionPublicada? de(Canal canal) => switch (canal) {
    Canal.pwa => pwa,
    Canal.apk => apk,
    Canal.play => play,
    Canal.ios => ios,
  };

  /// Te Tengo Captura for a PC's `sistemaOperativo` («Windows 10 Pro», «macOS 14»): `windows` or
  /// `mac`; null when the system is unknown.
  VersionPublicada? captura(String? sistemaOperativo) {
    final so = (sistemaOperativo ?? '').toLowerCase();
    if (so.contains('windows')) return windows;
    if (so.contains('mac') || so.contains('os x')) return mac;
    return null;
  }
}

/// «8,4 MB», the size of a download.
String tamanoLegible(int bytes) {
  final mb = bytes / 1000000;
  if (mb < 0.1) return '0,1 MB';
  return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
}

/// How a PC's Te Tengo Captura compares with the published one (CA-43.7).
enum EstadoVersionPc {
  /// «al día».
  alDia,

  /// «versión anterior».
  anterior,

  /// No version reported, an unknown system, or nothing published.
  desconocido,
}

/// Compares a PC's `versionAgente` with `windows` or `mac` by its `sistemaOperativo` (contract
/// §12).
EstadoVersionPc estadoVersionPc(
  Versiones? versiones, {
  required String? versionAgente,
  required String? sistemaOperativo,
}) {
  final publicada = versiones?.captura(sistemaOperativo);
  final instalada = NumeroVersion.leer(versionAgente);
  final ultima = NumeroVersion.leer(publicada?.version);
  if (instalada == null || ultima == null) return EstadoVersionPc.desconocido;
  return instalada < ultima ? EstadoVersionPc.anterior : EstadoVersionPc.alDia;
}
