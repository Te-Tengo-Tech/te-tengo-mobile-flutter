import '../../../core/foto.dart';

/// The signed-in member's own profile (`GET /api/cuenta`, contract §13 `Perfil`).
class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
    this.parentesco,
    this.foto,
  });

  final String id;
  final String nombre;

  /// The sign-in; not editable.
  final String correo;
  final String? telefono;
  final String? parentesco;
  final Foto? foto;

  factory Perfil.desdeJson(Map<String, dynamic> json) => Perfil(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    correo: json['correo'] as String,
    telefono: json['telefono'] as String?,
    parentesco: json['parentesco'] as String?,
    foto: Foto.desdeJson(json['foto']),
  );

  Perfil conFoto(Foto? foto) => Perfil(
    id: id,
    nombre: nombre,
    correo: correo,
    telefono: telefono,
    parentesco: parentesco,
    foto: foto,
  );
}

/// Whose photo changes: the member's own («Tu perfil») or the older adult's («Persona cuidada»,
/// owner only).
enum DuenoFoto {
  yo('YO', 'yo'),
  adultoMayor('ADULTO_MAYOR', 'adulto-mayor');

  const DuenoFoto(this.codigo, this.ruta);

  /// `de` of `POST /api/fotos/subidas`.
  final String codigo;

  /// `{de}` of `DELETE /api/fotos/{de}`.
  final String ruta;
}

/// The pre-signed upload of `POST /api/fotos/subidas`.
class SubidaFoto {
  const SubidaFoto({
    required this.subidaId,
    required this.url,
    required this.cabeceras,
  });

  final String subidaId;
  final String url;
  final Map<String, String> cabeceras;

  factory SubidaFoto.desdeJson(Map<String, dynamic> json) => SubidaFoto(
    subidaId: json['subidaId'] as String,
    url: json['url'] as String,
    cabeceras: {
      for (final e
          in (json['cabeceras'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: '${e.value}',
    },
  );
}
