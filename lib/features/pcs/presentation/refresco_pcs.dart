import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../camaras/data/camaras_repositorio.dart';
import '../data/pcs_repositorio.dart';

/// Keeps the PCs, and the webcams of [pcId], fresh while the screen is on top and the app in the
/// foreground: a PC that was just linked starts sending heartbeats and reporting its webcams a few
/// seconds later, and a PC may go offline or come back meanwhile (CA-30.3). It also reads them
/// again when the screen opens, since another screen may have loaded them earlier.
class RefrescoPcs extends ConsumerStatefulWidget {
  const RefrescoPcs({super.key, this.pcId, required this.child});

  /// [implementation choice]: about a heartbeat of the PC, cheap for the backend.
  static const cada = Duration(seconds: 10);

  final String? pcId;
  final Widget child;

  @override
  ConsumerState<RefrescoPcs> createState() => _RefrescoPcsState();
}

class _RefrescoPcsState extends ConsumerState<RefrescoPcs> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    // After the first frame: providers cannot change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refrescar());
    _temporizador = Timer.periodic(RefrescoPcs.cada, (_) => _alTick());
  }

  void _alTick() {
    if (!mounted) return;
    final ciclo = WidgetsBinding.instance.lifecycleState;
    final enPrimerPlano = ciclo == null || ciclo == AppLifecycleState.resumed;
    final visible =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    if (enPrimerPlano && visible) _refrescar();
  }

  void _refrescar() {
    if (!mounted) return;
    ref
      ..invalidate(pcsProvider)
      ..invalidate(camarasProvider);
    if (widget.pcId case final id?) {
      ref.invalidate(camarasDetectadasProvider(id));
    }
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
