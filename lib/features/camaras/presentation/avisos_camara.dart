import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/aviso.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';

/// Camera connection notices while the app is open (screens 28 and 29, CA-07.2, CA-07.3).
class AvisosCamara {
  AvisosCamara(this._ref);

  final Ref _ref;

  /// «La cámara de la Sala se desconectó» with what to check; tapping opens the camera.
  void desconectada({required String habitacion, void Function()? abrir}) {
    _ref.invalidate(camarasProvider);
    final l = textosDelSistema();
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            tipo: TipoFlotante.enApp,
            titulo: l.camaraAvisoDesconectadaTitulo(
              deHabitacion(habitacion, l),
            ),
            texto: l.camaraAvisoDesconectadaTexto,
            alTocar: abrir,
          ),
        );
  }

  /// «La cámara de la Sala volvió a estar en línea»: monitoring is back.
  void reconectada({required String habitacion, required DateTime cuando}) {
    _ref.invalidate(camarasProvider);
    final l = textosDelSistema();
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            icono: Ico.wifi,
            tono: TonoAviso.ok,
            titulo: l.camaraAvisoReconectadaTitulo(deHabitacion(habitacion, l)),
            texto: l.camaraAvisoReconectadaTexto(l.formato.hora(cuando)),
          ),
        );
  }

  /// «La cámara de la Sala se reactivó» when a pause ends by itself (screen 35, CA-22.3).
  void reactivada({required String habitacion, required DateTime cuando}) {
    _ref.invalidate(camarasProvider);
    final l = textosDelSistema();
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            tipo: TipoFlotante.enApp,
            icono: Ico.cam,
            tono: TonoAviso.ok,
            titulo: l.camaraAvisoReactivadaTitulo(deHabitacion(habitacion, l)),
            texto: l.camaraAvisoReactivadaTexto(l.formato.hora(cuando)),
          ),
        );
  }

  /// «La detección no es confiable en la Sala» with what to check (screen 36, CA-15.3).
  void noConfiable({
    required String habitacion,
    required String nombre,
    void Function()? abrir,
  }) {
    _ref.invalidate(camarasProvider);
    final l = textosDelSistema();
    _ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            tipo: TipoFlotante.enApp,
            titulo: l.camaraAvisoNoConfiableTitulo(enHabitacion(habitacion, l)),
            texto: l.camaraAvisoNoConfiableTexto(nombre),
            alTocar: abrir,
          ),
        );
  }
}

final avisosCamaraProvider = Provider<AvisosCamara>(AvisosCamara.new);
