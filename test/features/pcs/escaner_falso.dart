import 'package:flutter/widgets.dart';
import 'package:te_tengo/features/pcs/presentation/escaner_qr.dart';

/// The phone's camera without the platform: the test reads a QR or makes the camera fail.
class EscanerFalso implements EscanerQr {
  ValueChanged<String>? _alLeer;
  ValueChanged<FalloEscaner>? _alFallar;
  int linterna = 0;
  bool abierto = false;

  @override
  Widget vista({
    required ValueChanged<String> alLeer,
    required ValueChanged<FalloEscaner> alFallar,
  }) {
    _alLeer = alLeer;
    _alFallar = alFallar;
    abierto = true;
    return const ColoredBox(color: Color(0xFF000000));
  }

  void leer(String valor) => _alLeer!(valor);

  void fallar(FalloEscaner fallo) => _alFallar!(fallo);

  @override
  Future<void> alternarLinterna() async => linterna++;

  @override
  void dispose() => abierto = false;
}
