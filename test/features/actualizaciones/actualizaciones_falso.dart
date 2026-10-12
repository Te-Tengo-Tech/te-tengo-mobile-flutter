import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/actualizaciones/data/descarga_apk.dart';
import 'package:te_tengo/features/actualizaciones/data/plataforma.dart';
import 'package:te_tengo/features/actualizaciones/data/versiones_repositorio.dart';
import 'package:te_tengo/features/actualizaciones/domain/estado_actualizacion.dart';
import 'package:te_tengo/features/actualizaciones/domain/versiones.dart';

/// The bytes of the fake APK 0.6.0 and their SHA-256.
final bytesApk = utf8.encode('apk falso de Te Tengo 0.6.0');
final sumaApk = sha256.convert(bytesApk).toString();

const notasEjemplo = [
  'Las alertas llegan más rápido.',
  'La letra grande ya no se corta.',
];

VersionPublicada publicada(
  String version, {
  String? minima,
  String? url = 'https://tetengo.example/te-tengo.apk',
  String? sha,
  int? tamano = 8400000,
  List<String> notas = notasEjemplo,
}) => VersionPublicada(
  version: version,
  versionMinima: minima,
  url: url,
  sha256: sha,
  tamanoBytes: tamano,
  notas: notas,
);

/// Every channel at [version] (with [minima]); the APK carries [bytesApk]'s checksum.
Versiones versionesEn(
  String version, {
  String? minima,
  String captura = '0.5.0',
  String? shaApk,
}) => Versiones(
  windows: publicada(captura, notas: const []),
  mac: publicada(captura, notas: const []),
  apk: publicada(version, minima: minima, sha: shaApk ?? sumaApk),
  play: publicada(
    version,
    minima: minima,
    url: 'https://play.google.com/store/apps/details?id=tech.tetengo.te_tengo',
  ),
  ios: publicada(
    version,
    minima: minima,
    url: 'https://testflight.apple.com/join/tetengo',
    tamano: null,
  ),
  pwa: publicada(
    version,
    minima: minima,
    url: 'https://app.tetengo.reqsai.tech/',
    tamano: null,
  ),
);

class VersionesFalsas implements VersionesRepositorio {
  VersionesFalsas([this.respuesta]);

  Versiones? respuesta;
  ProblemaApi? error;
  int lecturas = 0;

  @override
  Future<Versiones?> leer() async {
    lecturas++;
    if (error case final e?) throw e;
    return respuesta;
  }
}

class InstaladorFalso implements InstaladorApk {
  InstaladorFalso({
    this.permiso = true,
    this.resultado = ResultadoInstalador.instalada,
  });

  bool permiso;
  ResultadoInstalador resultado;
  final instalados = <String>[];
  int ajustesAbiertos = 0;

  @override
  Future<void> abrirAjustesPermiso() async => ajustesAbiertos++;

  @override
  Future<ResultadoInstalador> instalar(String ruta) async {
    instalados.add(ruta);
    return resultado;
  }

  @override
  Future<bool> puedeInstalar() async => permiso;
}

class PlayFalso implements ActualizacionPlay {
  PlayFalso({this.resultado = false});

  bool resultado;
  int flexibles = 0;
  int inmediatas = 0;

  @override
  Future<bool> flexible() async {
    flexibles++;
    return resultado;
  }

  @override
  Future<bool> inmediata() async {
    inmediatas++;
    return resultado;
  }
}

/// The APK's host: answers the download with [bytes], an HTTP [estado], no connection, or keeps
/// it open until it is cancelled.
class AdaptadorDescarga implements HttpClientAdapter {
  AdaptadorDescarga({List<int>? bytes}) : bytes = bytes ?? bytesApk;

  List<int> bytes;
  int estado = 200;
  bool sinConexion = false;
  bool colgada = false;
  final pedidos = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions opciones,
    Stream<Uint8List>? cuerpo,
    Future<void>? cancelacion,
  ) async {
    pedidos.add(opciones);
    if (sinConexion) throw const SocketException('Sin conexión');
    if (colgada) {
      await cancelacion;
      throw DioException.requestCancelled(
        requestOptions: opciones,
        reason: 'cancelada',
      );
    }
    return ResponseBody.fromBytes(
      Uint8List.fromList(bytes),
      estado,
      headers: {
        Headers.contentLengthHeader: ['${bytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const infoApk = InfoApp(version: '0.5.0', canal: Canal.apk);
const infoPlay = InfoApp(version: '0.5.0', canal: Canal.play);
const infoPwa = InfoApp(version: '0.5.0', canal: Canal.pwa);
const infoIos = InfoApp(
  version: '0.5.0',
  canal: Canal.ios,
  tiendaIos: TiendaIos.testflight,
);

/// Overrides for the update: this app, the API's answer, the installer, Play, the download and
/// its folder. Everything is fake.
List<Override> overridesActualizacion({
  InfoApp? info = infoApk,
  VersionesFalsas? versiones,
  InstaladorFalso? instalador,
  PlayFalso? play,
  AdaptadorDescarga? descarga,
  Directory? carpeta,
  List<Uri>? enlaces,
  List<int>? recargas,
}) => [
  infoAppProvider.overrideWith((ref) async => info),
  versionesRepositorioProvider.overrideWithValue(
    versiones ?? VersionesFalsas(),
  ),
  instaladorApkProvider.overrideWithValue(instalador ?? InstaladorFalso()),
  actualizacionPlayProvider.overrideWithValue(play ?? PlayFalso()),
  descargaApkProvider.overrideWithValue(
    DescargaApk(Dio()..httpClientAdapter = descarga ?? AdaptadorDescarga()),
  ),
  carpetaActualizacionesProvider.overrideWith(
    (ref) async =>
        carpeta ?? Directory.systemTemp.createTempSync('tt-actualizaciones'),
  ),
  abrirEnlaceProvider.overrideWithValue((url) async {
    enlaces?.add(url);
    return true;
  }),
  recargarAppProvider.overrideWithValue(() async => recargas?.add(1)),
];
