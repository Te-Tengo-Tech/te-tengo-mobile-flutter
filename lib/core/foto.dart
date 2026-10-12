import 'formato.dart';

/// A person's photo (contract §13 `Foto`): a pre-signed `GET` of the stored JPEG, valid until
/// [expiraEn]. Without one the app shows the person's initials.
class Foto {
  const Foto({required this.url, required this.expiraEn});

  final String url;
  final DateTime expiraEn;

  /// Null when the backend sends no photo, or is older than the photos (no `foto` field).
  static Foto? desdeJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final url = json['url'];
    final expira = fechaDesdeJson(json['expiraEn']);
    if (url is! String || url.isEmpty || expira == null) return null;
    return Foto(url: url, expiraEn: expira);
  }

  Map<String, Object?> aJson() => {
    'url': url,
    'expiraEn': expiraEn.toUtc().toIso8601String(),
  };

  /// The object's address without the signature: the key changes with every new photo, so two
  /// URLs with the same path are the same picture.
  String get ruta {
    final uri = Uri.tryParse(url);
    return uri == null ? url : uri.replace(query: '').toString();
  }

  @override
  bool operator ==(Object other) =>
      other is Foto && other.url == url && other.expiraEn == expiraEn;

  @override
  int get hashCode => Object.hash(url, expiraEn);
}

/// The first URL seen for each photo, while it is valid: a new signature of the same object then
/// reuses the image already downloaded (Flutter's image cache is keyed by URL).
final _vistas = <String, Foto>{};

/// The URL to draw [foto] with: the one already in the image cache when it is the same picture
/// and its signature still has a minute left.
String urlEstable(Foto foto, {DateTime? ahora}) {
  final momento = ahora ?? DateTime.now();
  final previa = _vistas[foto.ruta];
  if (previa != null &&
      previa.expiraEn.isAfter(momento.add(const Duration(minutes: 1)))) {
    return previa.url;
  }
  _vistas[foto.ruta] = foto;
  return foto.url;
}
