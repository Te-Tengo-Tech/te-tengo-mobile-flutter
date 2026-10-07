import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token de sesión en el almacenamiento seguro del sistema operativo (Keychain / Keystore).
///
/// El token trae el claim `hogar_id`: el backend filtra todo por ese hogar, así que la app nunca envía
/// el hogar por su cuenta (multi-tenancy del backend).
class SesionSegura {
  SesionSegura(this._almacen);

  static const _clave = 'tt_token';
  final FlutterSecureStorage _almacen;

  Future<String?> token() => _almacen.read(key: _clave);

  Future<void> guardar(String token) =>
      _almacen.write(key: _clave, value: token);

  Future<void> cerrar() => _almacen.delete(key: _clave);
}

final sesionSeguraProvider = Provider<SesionSegura>(
  (ref) => SesionSegura(const FlutterSecureStorage()),
);
