import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// «Tomar una foto» or «Elegir de la galería».
enum OrigenFoto { camara, galeria }

/// The phone (or the browser) did not let the app use the camera or the photos. [bloqueado]: it
/// will not ask again, so only the phone's settings can allow it.
class PermisoFotoDenegado implements Exception {
  const PermisoFotoDenegado({required this.origen, required this.bloqueado});

  final OrigenFoto origen;
  final bool bloqueado;
}

/// Gets a picture from the camera or the gallery; null when the person cancels. Throws
/// [PermisoFotoDenegado].
abstract interface class SelectorFoto {
  Future<Uint8List?> elegir(OrigenFoto origen, {bool frontal = false});
}

/// `image_picker`: the system camera and photo picker on Android and iOS, a file input in the
/// browser (with `capture` for the camera on phones). The picture comes already reduced to
/// [ladoMaximo] px, so a 12 MP photo is never decoded at full size.
class SelectorFotoSistema implements SelectorFoto {
  SelectorFotoSistema({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const ladoMaximo = 1600.0;

  @override
  Future<Uint8List?> elegir(OrigenFoto origen, {bool frontal = false}) async {
    // Android's system photo picker and iOS's PHPicker need no permission; the camera does once the
    // app declares it (the QR scanner does).
    if (origen == OrigenFoto.camara && !kIsWeb) {
      var estado = await Permission.camera.status;
      if (!estado.isGranted && !estado.isLimited) {
        estado = await Permission.camera.request();
      }
      if (estado.isPermanentlyDenied || estado.isRestricted) {
        throw PermisoFotoDenegado(origen: origen, bloqueado: true);
      }
      if (!estado.isGranted && !estado.isLimited) {
        throw PermisoFotoDenegado(origen: origen, bloqueado: false);
      }
    }
    try {
      final archivo = await _picker.pickImage(
        source: origen == OrigenFoto.camara
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: ladoMaximo,
        maxHeight: ladoMaximo,
        imageQuality: 90,
        preferredCameraDevice: frontal ? CameraDevice.front : CameraDevice.rear,
        requestFullMetadata: false,
      );
      return archivo?.readAsBytes();
    } on PlatformException catch (e) {
      // iOS: `camera_access_denied` / `photo_access_denied` once the person said no.
      if (e.code.contains('access_denied')) {
        throw PermisoFotoDenegado(origen: origen, bloqueado: true);
      }
      rethrow;
    }
  }
}

final selectorFotoProvider = Provider<SelectorFoto>(
  (ref) => SelectorFotoSistema(),
);
