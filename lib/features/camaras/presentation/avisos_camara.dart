import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formato.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/iconos.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';

/// Camera connection notices while the app is open (screens 28 and 29, CA-07.2, CA-07.3).
class AvisosCamara {
  AvisosCamara(this._ref);

  final Ref _ref;

  /// «La cámara de la Sala se desconectó» with what to check; tapping opens the camera.
  void desconectada({required String habitacion, void Function()? abrir}) {
    _ref.invalidate(camarasProvider);
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            tipo: TipoFlotante.enApp,
            titulo: 'La cámara ${deHabitacion(habitacion)} se desconectó',
            texto:
                'Revisa el cable de la cámara, que la PC esté encendida y el '
                'internet de la casa.',
            alTocar: abrir,
          ),
        );
  }

  /// «La cámara de la Sala volvió a estar en línea»: monitoring is back.
  void reconectada({required String habitacion, required DateTime cuando}) {
    _ref.invalidate(camarasProvider);
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            icono: Ico.wifi,
            tono: TonoAviso.ok,
            titulo:
                'La cámara ${deHabitacion(habitacion)} volvió a estar en línea',
            texto: 'El monitoreo se restableció a las ${hora(cuando)}.',
          ),
        );
  }
}

final avisosCamaraProvider = Provider<AvisosCamara>(AvisosCamara.new);
