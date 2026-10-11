import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';

import '../domain/fotogramas.dart';

/// The light replay format TTMOV v1 (contract §11, «Light replay format»; backend ADR 0011): what
/// Te Tengo Captura uploads next to each Parquet movement file and each clip's landmarks, so the
/// app can draw them on Android, iOS and the web. Pure Dart: gzip through `package:archive`
/// (`dart:io`'s zlib on the phones, its own inflate on the web), then a little-endian payload.
class ArchivoTtmov {
  const ArchivoTtmov({
    required this.t0Ms,
    required this.duracionMs,
    required this.fpsObjetivo,
    required this.conZ,
    required this.puntosPorPose,
    required this.fotogramas,
  });

  /// Start of the file, UTC epoch milliseconds; it covers `[t0Ms, t0Ms + duracionMs)`.
  final int t0Ms;
  final int duracionMs;
  final int fpsObjetivo;
  final bool conZ;
  final int puntosPorPose;
  final List<FotogramaTtmov> fotogramas;
}

/// One frame with the stored integers (the Parquet file's quantization).
class FotogramaTtmov {
  const FotogramaTtmov({
    required this.tMs,
    required this.fase,
    this.evento,
    this.x,
    this.y,
    this.v,
    this.z,
  });

  final int tMs;

  /// `normal`, `inicio_caida` or `en_el_suelo`.
  final String fase;

  /// `caida`, `caida_confirmada`, `movimiento_inestable`, `recuperacion`,
  /// `deteccion_no_confiable`; null: none.
  final String? evento;

  /// Null without a person in the frame.
  final Uint16List? x;
  final Uint16List? y;
  final Uint8List? v;
  final Int16List? z;

  bool get conPose => x != null;
}

const _magia = [0x54, 0x54, 0x4D, 0x56]; // TTMV
const _version = 1;
const _banderaZ = 0x01;
const _cabecera = 24;
const _fases = ['normal', 'inicio_caida', 'en_el_suelo'];
const _eventos = [
  'caida',
  'caida_confirmada',
  'movimiento_inestable',
  'recuperacion',
  'deteccion_no_confiable',
];

/// Decodes a TTMOV v1 file; throws [FormatException] for anything else.
ArchivoTtmov decodificarTtmov(Uint8List bytes) {
  final Uint8List carga;
  try {
    carga = const GZipDecoder().decodeBytes(bytes, verify: true);
  } on Object {
    throw const FormatException('No es un archivo gzip.');
  }
  if (carga.length < _cabecera) {
    throw const FormatException('Archivo de movimientos incompleto.');
  }
  for (var i = 0; i < 4; i++) {
    if (carga[i] != _magia[i]) {
      throw const FormatException('No es un archivo de movimientos.');
    }
  }
  final datos = ByteData.sublistView(carga);
  final banderas = carga[5];
  if (carga[4] != _version || banderas & ~_banderaZ != 0) {
    throw const FormatException('Versión de movimientos no soportada.');
  }
  final conZ = banderas & _banderaZ != 0;
  final puntos = carga[7];
  // getInt64 is not available when compiled to JavaScript: two 32-bit halves.
  final t0Ms =
      datos.getInt32(12, Endian.little) * 0x100000000 +
      datos.getUint32(8, Endian.little);
  final duracionMs = datos.getUint32(16, Endian.little);
  final n = datos.getUint32(20, Endian.little);
  final tamanoPose = puntos * (conZ ? 7 : 5);

  var x = Uint16List(puntos), y = Uint16List(puntos), z = Uint16List(puntos);
  var v = Uint8List(puntos);
  var posicion = _cabecera;
  var t = t0Ms;
  final fotogramas = <FotogramaTtmov>[];
  for (var f = 0; f < n; f++) {
    if (posicion + 5 > carga.length) {
      throw const FormatException('Archivo de movimientos incompleto.');
    }
    t += datos.getInt32(posicion, Endian.little);
    final estado = carga[posicion + 4];
    posicion += 5;
    final fase = (estado >> 1) & 0x03;
    final evento = (estado >> 3) & 0x07;
    final nombreFase = fase < _fases.length ? _fases[fase] : 'normal';
    final nombreEvento = evento >= 1 && evento <= _eventos.length
        ? _eventos[evento - 1]
        : null;
    if (estado & 0x01 == 0) {
      fotogramas.add(
        FotogramaTtmov(tMs: t, fase: nombreFase, evento: nombreEvento),
      );
      continue;
    }
    if (posicion + tamanoPose > carga.length) {
      throw const FormatException('Archivo de movimientos incompleto.');
    }
    // Each value is a delta from the previous pose, modulo 2^16 (or 2^8).
    final nx = Uint16List(puntos), ny = Uint16List(puntos);
    final nv = Uint8List(puntos);
    for (var k = 0; k < puntos; k++) {
      nx[k] = x[k] + datos.getUint16(posicion + 2 * k, Endian.little);
    }
    posicion += 2 * puntos;
    for (var k = 0; k < puntos; k++) {
      ny[k] = y[k] + datos.getUint16(posicion + 2 * k, Endian.little);
    }
    posicion += 2 * puntos;
    for (var k = 0; k < puntos; k++) {
      nv[k] = v[k] + carga[posicion + k];
    }
    posicion += puntos;
    Int16List? zs;
    if (conZ) {
      final nz = Uint16List(puntos);
      for (var k = 0; k < puntos; k++) {
        nz[k] = z[k] + datos.getUint16(posicion + 2 * k, Endian.little);
      }
      posicion += 2 * puntos;
      z = nz;
      zs = Int16List.view(Uint16List.fromList(nz).buffer);
    }
    x = nx;
    y = ny;
    v = nv;
    fotogramas.add(
      FotogramaTtmov(
        tMs: t,
        fase: nombreFase,
        evento: nombreEvento,
        x: nx,
        y: ny,
        v: nv,
        z: zs,
      ),
    );
  }
  return ArchivoTtmov(
    t0Ms: t0Ms,
    duracionMs: duracionMs,
    fpsObjetivo: carga[6],
    conZ: conZ,
    puntosPorPose: puntos,
    fotogramas: fotogramas,
  );
}

/// The 17 COCO keypoints the app draws ([huesos]), from MediaPipe Pose's 33 landmarks: nose,
/// eyes, ears, shoulders, elbows, wrists, hips, knees and ankles.
const cocoDesdeMediaPipe = [
  0, 2, 5, 7, 8, 11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28, //
];

/// Visibility below 0.5 is not drawn (contract): `q / 255 >= 0.5` ⇔ `q >= 128`.
const visibilidadMinima = 128;

/// MediaPipe's normalized coordinate of a stored x or y.
double coordenada(int q) => q / 65535 * 2 - 0.5;

/// The frames to draw: only those with a person, in the app's 17 keypoints.
List<Fotograma> fotogramasDe(ArchivoTtmov archivo) {
  final salida = <Fotograma>[];
  for (final f in archivo.fotogramas) {
    final x = f.x, y = f.y, v = f.v;
    if (x == null || y == null || v == null) continue;
    salida.add(
      Fotograma(
        en: DateTime.fromMillisecondsSinceEpoch(f.tMs, isUtc: true),
        puntos: [
          for (final i in cocoDesdeMediaPipe)
            i < x.length && v[i] >= visibilidadMinima
                ? Offset(coordenada(x[i]), coordenada(y[i]))
                : null,
        ],
      ),
    );
  }
  return salida;
}

/// The decoder of this build: TTMOV v1.
class DecodificadorTtmov implements DecodificadorMovimientos {
  const DecodificadorTtmov();

  @override
  Future<List<Fotograma>> decodificar(Uint8List bytes) async =>
      fotogramasDe(decodificarTtmov(bytes));
}
