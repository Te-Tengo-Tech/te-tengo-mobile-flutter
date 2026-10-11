import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/features/movimientos/data/decodificador_ttmov.dart';

/// Golden fixtures written by Te Tengo Captura's encoder (`scripts/fixture_ligero.py` of
/// te-tengo-desktop-pywebview): a real 12 s clip around a fall, without and with `z`, and the
/// JSON of what its Python decoder reads. Decoding them here is the cross-language round trip.
const _carpeta = 'test/fixtures/movimientos';

Uint8List _bytes(String nombre) =>
    File('$_carpeta/$nombre.ttmov').readAsBytesSync();

Map<String, dynamic> _esperado(String nombre) =>
    jsonDecode(File('$_carpeta/$nombre.json').readAsStringSync())
        as Map<String, dynamic>;

/// A payload with a header and the given frame bytes, gzip-compressed.
Uint8List _archivo({
  int version = 1,
  int banderas = 0,
  int t0 = 1791646800000,
  int fotogramas = 0,
  List<int> cuerpo = const [],
  List<int> magia = const [0x54, 0x54, 0x4D, 0x56],
}) {
  final cabecera = ByteData(24)
    ..setUint8(4, version)
    ..setUint8(5, banderas)
    ..setUint8(6, 8)
    ..setUint8(7, 33)
    ..setUint32(8, t0 & 0xFFFFFFFF, Endian.little)
    ..setInt32(12, t0 ~/ 0x100000000, Endian.little)
    ..setUint32(16, 12000, Endian.little)
    ..setUint32(20, fotogramas, Endian.little);
  final carga = cabecera.buffer.asUint8List()..setRange(0, 4, magia);
  return const GZipEncoder().encodeBytes([...carga, ...cuerpo]);
}

void main() {
  for (final nombre in ['clip_caida', 'clip_caida_z']) {
    test('$nombre: lee los mismos enteros que el decodificador de la PC', () {
      final esperado = _esperado(nombre);
      final archivo = decodificarTtmov(_bytes(nombre));
      expect(archivo.t0Ms, esperado['t0Ms']);
      expect(archivo.duracionMs, esperado['duracionMs']);
      expect(archivo.fpsObjetivo, esperado['fpsObjetivo']);
      expect(archivo.conZ, esperado['conZ']);
      expect(archivo.puntosPorPose, 33);
      final fotogramas = esperado['fotogramas'] as List<dynamic>;
      expect(archivo.fotogramas, hasLength(fotogramas.length));
      for (var i = 0; i < fotogramas.length; i++) {
        final e = fotogramas[i] as Map<String, dynamic>;
        final f = archivo.fotogramas[i];
        expect(f.tMs, e['tMs'], reason: 'fotograma $i');
        expect(f.fase, e['fase'], reason: 'fotograma $i');
        expect(f.evento, e['evento'], reason: 'fotograma $i');
        expect(f.x, e['x'], reason: 'fotograma $i');
        expect(f.y, e['y'], reason: 'fotograma $i');
        expect(f.v, e['v'], reason: 'fotograma $i');
        if (archivo.conZ) expect(f.z, e['z'], reason: 'fotograma $i');
      }
    });
  }

  test('la caída y el «se levantó» del clip real', () {
    final archivo = decodificarTtmov(_bytes('clip_caida'));
    expect(
      [
        for (final f in archivo.fotogramas)
          if (f.evento != null) f.evento,
      ],
      ['caida', 'recuperacion'],
    );
    expect(archivo.fotogramas.where((f) => !f.conPose), hasLength(1));
  });

  test('dibuja los 17 puntos COCO, sin los poco visibles', () async {
    final archivo = decodificarTtmov(_bytes('clip_caida'));
    final fotogramas = await const DecodificadorTtmov().decodificar(
      _bytes('clip_caida'),
    );
    final conPose = archivo.fotogramas.where((f) => f.conPose).toList();
    expect(fotogramas, hasLength(conPose.length));
    final primero = conPose.first;
    final f = fotogramas.first;
    expect(f.en, DateTime.fromMillisecondsSinceEpoch(primero.tMs, isUtc: true));
    expect(f.puntos, hasLength(17));
    for (var i = 0; i < 17; i++) {
      final mp = cocoDesdeMediaPipe[i];
      final punto = f.puntos[i];
      if (primero.v![mp] < visibilidadMinima) {
        expect(punto, isNull);
      } else {
        expect(punto!.dx, closeTo(primero.x![mp] / 65535 * 2 - 0.5, 1e-9));
        expect(punto.dy, closeTo(primero.y![mp] / 65535 * 2 - 0.5, 1e-9));
      }
    }
    // The nose of a person standing in the image is inside it.
    expect(f.puntos[0]!.dx, inInclusiveRange(0, 1));
  });

  test('un fotograma armado a mano: deltas que dan la vuelta', () {
    List<int> pose(int dx, int dy, int dv) => [
      ...List.generate(66, (i) => i.isEven ? dx & 0xFF : dx >> 8),
      ...List.generate(66, (i) => i.isEven ? dy & 0xFF : dy >> 8),
      ...List.filled(33, dv),
    ];
    final dt = ByteData(4)..setInt32(0, 125, Endian.little);
    final atras = ByteData(4)..setInt32(0, -250, Endian.little);
    final archivo = decodificarTtmov(
      _archivo(
        fotogramas: 3,
        cuerpo: [
          ...dt.buffer.asUint8List(),
          0x01,
          ...pose(65535, 2, 255), // x 65535, y 2, v 255
          ...atras.buffer.asUint8List(),
          0x14, // no pose, en_el_suelo, caida_confirmada
          ...dt.buffer.asUint8List(),
          0x01,
          ...pose(3, 0xFFFF, 1), // x 2, y 1, v 0
        ],
      ),
    );
    final [a, b, c] = archivo.fotogramas;
    expect(a.tMs, 1791646800125);
    expect(a.x!.first, 65535);
    expect(a.y!.first, 2);
    expect(a.v!.first, 255);
    expect(b.tMs, 1791646799875);
    expect(b.conPose, isFalse);
    expect(b.fase, 'en_el_suelo');
    expect(b.evento, 'caida_confirmada');
    expect(c.tMs, 1791646800000);
    expect(c.x!.first, 2);
    expect(c.y!.first, 1);
    expect(c.v!.first, 0);
  });

  test('un archivo vacío no tiene fotogramas', () {
    expect(decodificarTtmov(_archivo()).fotogramas, isEmpty);
  });

  group('rechaza lo que no entiende', () {
    void rechaza(Uint8List bytes) =>
        expect(() => decodificarTtmov(bytes), throwsA(isA<FormatException>()));

    test('no es gzip (un Parquet)', () {
      rechaza(Uint8List.fromList(utf8.encode('PAR1 no es esto')));
    });
    test(
      'otra magia',
      () => rechaza(_archivo(magia: [0x50, 0x41, 0x52, 0x31])),
    );
    test('otra versión', () => rechaza(_archivo(version: 2)));
    test('una bandera desconocida', () => rechaza(_archivo(banderas: 2)));
    test('cabecera incompleta', () {
      rechaza(const GZipEncoder().encodeBytes([0x54, 0x54, 0x4D, 0x56, 1]));
    });
    test('faltan fotogramas', () => rechaza(_archivo(fotogramas: 1)));
    test('falta la pose', () {
      rechaza(_archivo(fotogramas: 1, cuerpo: [125, 0, 0, 0, 0x01, 1, 2]));
    });
  });
}
