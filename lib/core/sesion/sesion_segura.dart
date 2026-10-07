import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session token in the operating system secure storage (Keychain / Keystore).
///
/// The token carries the `hogar_id` claim: the backend filters everything by that household, so the
/// app never sends the household itself (backend multi-tenancy).
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
