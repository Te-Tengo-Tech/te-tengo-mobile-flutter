import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../app/rutas.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../data/widget_sistema.dart';
import '../domain/estado_widget.dart';

/// «Ver en vivo» on the widget asked for the room picker (CA-44.2): Inicio opens it once the
/// cameras are read. The widget never opens the live view by itself.
class HabitacionesPendientes extends Notifier<bool> {
  @override
  bool build() => false;

  void pedir() => state = true;

  void atendido() => state = false;
}

final habitacionesPendientesProvider =
    NotifierProvider<HabitacionesPendientes, bool>(HabitacionesPendientes.new);

/// Keeps the home-screen widget in step with what the app knows (US-44): the active alert, the
/// cameras and the consent while there is a session, and «Abre la app para ver el estado» after
/// signing out (CA-44.3). Every change the app reads (on opening, on a push, every refresh) redraws
/// it. It also routes the widget's taps (CA-44.2).
class ActualizadorWidget extends ConsumerStatefulWidget {
  const ActualizadorWidget({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ActualizadorWidget> createState() => _ActualizadorWidgetState();
}

class _ActualizadorWidgetState extends ConsumerState<ActualizadorWidget> {
  StreamSubscription<Uri?>? _toques;
  EstadoWidget? _mostrado;

  @override
  void initState() {
    super.initState();
    final sistema = ref.read(widgetDelSistemaProvider);
    if (!sistema.disponible) return;
    _toques = sistema.toques.listen(_abrir, onError: (Object _) {});
    unawaited(sistema.abiertaDesde().then(_abrir));
  }

  /// A tap on the widget: the active alert, «Cámaras» or Inicio; «Ver en vivo» (`vivo=1`) opens
  /// Inicio with the room picker. Only routes of this app are followed.
  void _abrir(Uri? uri) {
    if (uri == null || uri.scheme != esquemaWidget || !mounted) return;
    final destino = Rutas.destinoDeWidget(
      Uri(queryParameters: uri.queryParameters),
    );
    ref.read(routerProvider).go(destino ?? Rutas.inicio);
    if (uri.queryParameters['vivo'] == '1') {
      ref.read(habitacionesPendientesProvider.notifier).pedir();
    }
  }

  void _mostrar(EstadoWidget estado) {
    if (estado == _mostrado) return;
    _mostrado = estado;
    unawaited(
      ref
          .read(widgetDelSistemaProvider)
          .mostrar(estado, ref.read(relojProvider)()),
    );
  }

  @override
  void dispose() {
    unawaited(_toques?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.read(widgetDelSistemaProvider).disponible) return widget.child;
    final sesion = ref.watch(sesionControllerProvider);
    EstadoWidget? estado;
    if (sesion == null) {
      estado = EstadoWidget.sinSesion;
    } else if (sesion.tieneHogar) {
      final alerta = ref.watch(alertaActivaProvider);
      final camaras = ref.watch(camarasEnCasaProvider).value;
      final hogar = ref.watch(hogarProvider).value;
      if (alerta.hasValue && camaras != null && hogar != null) {
        estado = estadoDelHogar(
          alerta: alerta.value,
          camaras: camaras,
          conConsentimiento: hogar.conConsentimiento,
          nombreAdulto: hogar.adultoMayor.nombre,
        );
      }
    }
    if (estado != null) {
      final nuevo = estado;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mostrar(nuevo);
      });
    }
    return widget.child;
  }
}
