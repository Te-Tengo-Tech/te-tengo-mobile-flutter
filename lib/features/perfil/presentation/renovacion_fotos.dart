import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fotos.dart';

/// Keeps the photos' signatures fresh while the tabs are open (`renovacionFotosProvider`).
class RenovacionFotos extends ConsumerWidget {
  const RenovacionFotos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(renovacionFotosProvider);
    return const SizedBox.shrink();
  }
}
