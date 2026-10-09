import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/formato.dart';
import '../../../core/web/navegador.dart';
import '../domain/alerta.dart';

/// Saves the file behind a short-lived pre-signed [url] as [nombre]; returns the saved name.
typedef GuardarArchivo = Future<String> Function(Uri url, String nombre);

/// `alerta-21-sep-1205.mp4`, as the prototype names a downloaded recording.
String nombreGrabacion(Alerta a) {
  final t = a.ocurridaEn;
  return 'alerta-${t.day}-${nombreMesCorto(t.month)}-'
      '${hora(t).replaceAll(':', '')}.mp4';
}

/// Downloads into the app documents folder, which iOS shows in Archivos (`UIFileSharingEnabled`)
/// and Android keeps in the app storage. The URL is pre-signed, so it needs no session header.
Future<String> guardarEnDocumentos(Uri url, String nombre) async {
  final carpeta = Platform.isIOS
      ? await getApplicationDocumentsDirectory()
      : await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
  await Dio().downloadUri(
    url,
    '${carpeta.path}${Platform.pathSeparator}$nombre',
  );
  return nombre;
}

/// In the browser (the PWA) the download is the browser's own: it goes to its downloads folder
/// (Archivos › Descargas on an iPhone).
Future<String> guardarEnNavegador(Uri url, String nombre) async {
  descargarEnNavegador(url, nombre);
  return nombre;
}

final guardarArchivoProvider = Provider<GuardarArchivo>(
  (ref) => kIsWeb ? guardarEnNavegador : guardarEnDocumentos,
);
