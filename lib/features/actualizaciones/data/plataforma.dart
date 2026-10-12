import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/estado_actualizacion.dart';
import '../domain/versiones.dart';
import 'recarga.dart';

/// This app's version and channel, read once (contract §12, «Which channel»): `pwa` on the web,
/// `play` when Google Play installed the Android app (`installerStore`), `apk` on other Android
/// installs and `ios` on the iPhone. Null when it cannot be known: then nothing about updates is
/// shown.
///
/// On the web the version comes from the build's `version.json`, read when the app starts: it is
/// the build this page loaded (the files are revalidated on every load, `deploy/pwa/_headers`).
final infoAppProvider = FutureProvider<InfoApp?>((ref) async {
  try {
    final p = await PackageInfo.fromPlatform();
    final canal = canalPara(
      web: kIsWeb,
      android: defaultTargetPlatform == TargetPlatform.android,
      ios: defaultTargetPlatform == TargetPlatform.iOS,
      instalador: p.installerStore,
    );
    if (canal == null || NumeroVersion.leer(p.version) == null) return null;
    return InfoApp(
      version: p.version,
      canal: canal,
      tiendaIos: tiendaIosPara(p.installerStore),
    );
  } on Object catch (e) {
    debugPrint('Sin versión de la app: $e');
    return null;
  }
});

/// What the Android installer did.
enum ResultadoInstalador { instalada, cancelada, fallo }

/// The Android side of the APK update (`MainActivity`, channel `tech.tetengo.te_tengo/actualizaciones`).
abstract interface class InstaladorApk {
  /// Android's «Instalar apps desconocidas» permission for this app
  /// (`PackageManager.canRequestPackageInstalls()`).
  Future<bool> puedeInstalar();

  /// Opens «Instalar apps desconocidas» for this app (`ACTION_MANAGE_UNKNOWN_APP_SOURCES`).
  Future<void> abrirAjustesPermiso();

  /// Opens the Android installer with the file at [ruta] (a FileProvider `content://` URI).
  Future<ResultadoInstalador> instalar(String ruta);
}

class InstaladorApkAndroid implements InstaladorApk {
  const InstaladorApkAndroid();

  static const canal = MethodChannel('tech.tetengo.te_tengo/actualizaciones');

  @override
  Future<bool> puedeInstalar() async {
    try {
      return await canal.invokeMethod<bool>('puedeInstalar') ?? false;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> abrirAjustesPermiso() async {
    try {
      await canal.invokeMethod<void>('abrirAjustesPermiso');
    } on Object catch (e) {
      debugPrint('No se abrieron los ajustes: $e');
    }
  }

  @override
  Future<ResultadoInstalador> instalar(String ruta) async {
    try {
      final r = await canal.invokeMethod<String>('instalar', {'ruta': ruta});
      return switch (r) {
        'instalada' => ResultadoInstalador.instalada,
        'cancelada' => ResultadoInstalador.cancelada,
        _ => ResultadoInstalador.fallo,
      };
    } on Object catch (e) {
      debugPrint('No se abrió el instalador: $e');
      return ResultadoInstalador.fallo;
    }
  }
}

final instaladorApkProvider = Provider<InstaladorApk>(
  (ref) => const InstaladorApkAndroid(),
);

/// Google Play's in-app updates (CA-43.5). The app is not on Google Play yet: every call is
/// guarded and answers false on any error, and then the app does nothing.
abstract interface class ActualizacionPlay {
  /// The flexible flow: Play's sheet, the download in the background, then the restart. True when
  /// it finished.
  Future<bool> flexible();

  /// The immediate (full-screen) flow, for a version below the minimum (CA-43.8).
  Future<bool> inmediata();
}

class ActualizacionPlayEnApp implements ActualizacionPlay {
  const ActualizacionPlayEnApp();

  Future<AppUpdateInfo?> _info() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable
          ? info
          : null;
    } on Object catch (e) {
      debugPrint('Google Play no responde: $e');
      return null;
    }
  }

  @override
  Future<bool> flexible() async {
    final info = await _info();
    if (info == null || !info.flexibleUpdateAllowed) return false;
    try {
      final r = await InAppUpdate.startFlexibleUpdate();
      if (r != AppUpdateResult.success) return false;
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } on Object catch (e) {
      debugPrint('Google Play no actualizó: $e');
      return false;
    }
  }

  @override
  Future<bool> inmediata() async {
    final info = await _info();
    if (info == null || !info.immediateUpdateAllowed) return false;
    try {
      return await InAppUpdate.performImmediateUpdate() ==
          AppUpdateResult.success;
    } on Object catch (e) {
      debugPrint('Google Play no actualizó: $e');
      return false;
    }
  }
}

final actualizacionPlayProvider = Provider<ActualizacionPlay>(
  (ref) => const ActualizacionPlayEnApp(),
);

/// Opens a store page (App Store, TestFlight, Google Play) outside the app. False when it could
/// not.
typedef AbrirEnlace = Future<bool> Function(Uri url);

final abrirEnlaceProvider = Provider<AbrirEnlace>(
  (ref) => (url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  },
);

/// Reloads the web app with the new build (CA-43.4): the service worker is updated first.
final recargarAppProvider = Provider<Future<void> Function()>(
  (ref) => recargarConVersionNueva,
);

/// Where the downloaded APK is kept: the app's cache folder `actualizaciones/`, the one the
/// FileProvider shares with the installer (`android/app/src/main/res/xml/actualizaciones.xml`).
final carpetaActualizacionesProvider = FutureProvider<Directory>((ref) async {
  final base = await getTemporaryDirectory();
  return Directory('${base.path}/actualizaciones');
});
