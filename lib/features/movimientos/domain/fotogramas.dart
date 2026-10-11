import 'dart:typed_data';
import 'dart:ui';

/// One instant of the stored movements: the body landmarks the PC computed, never an image
/// (CA-35.1). [puntos] follow the 17 COCO keypoints (nose, eyes, ears, shoulders, elbows, wrists,
/// hips, knees, ankles), normalised to the camera's image (0 to 1); null when not seen.
class Fotograma {
  const Fotograma({required this.en, required this.puntos});

  final DateTime en;
  final List<Offset?> puntos;
}

/// The bones drawn between the COCO keypoints.
const huesos = [
  (5, 6), (5, 7), (7, 9), (6, 8), (8, 10), // shoulders and arms
  (5, 11), (6, 12), (11, 12), // trunk
  (11, 13), (13, 15), (12, 14), (14, 16), // legs
];

/// Reads one movement file (Parquet compressed with zstd, written by Te Tengo Captura) into
/// frames. **No implementation ships yet:** the Parquet columns are not fixed by any contract and
/// there is no reliable Parquet reader for Dart on every target (docs/BLOCKERS.md, «Replay
/// decoding»), so [decodificadorMovimientosProvider] is null and the screens say they cannot draw
/// the movements.
abstract interface class DecodificadorMovimientos {
  /// [bytes] already checked against the file's `sha256`.
  Future<List<Fotograma>> decodificar(Uint8List bytes);
}

/// The frame shown at [en]: the latest at or before it, if it is recent enough (frames exist only
/// while a person is in the image, CA-39.5).
Fotograma? fotogramaEn(
  List<Fotograma> fotogramas,
  DateTime en, {
  Duration margen = const Duration(seconds: 1),
}) {
  Fotograma? mejor;
  for (final f in fotogramas) {
    if (f.en.isAfter(en)) break;
    mejor = f;
  }
  if (mejor == null || en.difference(mejor.en) > margen) return null;
  return mejor;
}
