import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vista_en_vivo_repositorio.dart';

/// A screen the live view of [camaraId] is opened from: once, when it opens, the camera's agent is
/// asked to get ready (`preparar`), so the live view starts sooner. Nothing is sent from the home.
class PrepararVivo extends ConsumerStatefulWidget {
  const PrepararVivo({super.key, required this.camaraId, required this.child});

  final String camaraId;
  final Widget child;

  @override
  ConsumerState<PrepararVivo> createState() => _PrepararVivoState();
}

class _PrepararVivoState extends ConsumerState<PrepararVivo> {
  @override
  void initState() {
    super.initState();
    prepararVivo(ref, widget.camaraId);
  }

  @override
  void didUpdateWidget(PrepararVivo anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.camaraId != widget.camaraId) {
      prepararVivo(ref, widget.camaraId);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
