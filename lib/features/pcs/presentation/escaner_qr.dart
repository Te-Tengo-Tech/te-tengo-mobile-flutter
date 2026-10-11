import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Why the phone's camera cannot scan.
enum FalloEscaner {
  /// The person did not allow the camera, or blocked it in the settings (screen 124).
  permisoDenegado,

  /// No camera, or the browser cannot use one (an insecure page, no `getUserMedia`).
  noDisponible,
}

/// The phone's camera reading QR codes: `mobile_scanner` on Android and iOS (ML Kit and Apple's
/// Vision) and on the web (`getUserMedia` with the browser's `BarcodeDetector`, or zxing-wasm where
/// there is none). Tests replace it, since the camera needs the platform.
abstract interface class EscanerQr {
  /// The camera preview. It asks for the camera permission when it starts (the system dialog of
  /// screen 123), calls [alLeer] with each QR read and [alFallar] when the camera cannot be used.
  Widget vista({
    required ValueChanged<String> alLeer,
    required ValueChanged<FalloEscaner> alFallar,
  });

  /// Turns the flashlight on or off; nothing where there is none.
  Future<void> alternarLinterna();

  void dispose();
}

typedef FabricaEscanerQr = EscanerQr Function();

final fabricaEscanerQrProvider = Provider<FabricaEscanerQr>(
  (ref) => EscanerMobileScanner.new,
);

class EscanerMobileScanner implements EscanerQr {
  final _control = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  Widget vista({
    required ValueChanged<String> alLeer,
    required ValueChanged<FalloEscaner> alFallar,
  }) => MobileScanner(
    controller: _control,
    onDetect: (captura) {
      for (final codigo in captura.barcodes) {
        final valor = codigo.rawValue;
        if (valor != null && valor.isNotEmpty) return alLeer(valor);
      }
    },
    errorBuilder: (context, error) {
      // Reported after the frame: the screen replaces the preview with its own state.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => alFallar(
          error.errorCode == MobileScannerErrorCode.permissionDenied
              ? FalloEscaner.permisoDenegado
              : FalloEscaner.noDisponible,
        ),
      );
      return const ColoredBox(color: Colors.black);
    },
  );

  @override
  Future<void> alternarLinterna() async {
    try {
      await _control.toggleTorch();
    } on Object {
      // No flashlight, or the camera is not running.
    }
  }

  @override
  void dispose() => unawaited(_control.dispose());
}
