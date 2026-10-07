import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer («Llamar a Rosa»). Without a number it opens the empty dialer.
typedef Llamar = Future<void> Function(String? telefono);

final llamarProvider = Provider<Llamar>(
  (ref) => (telefono) async {
    final numero = (telefono ?? '').replaceAll(RegExp(r'[^\d+]'), '');
    await launchUrl(Uri(scheme: 'tel', path: numero));
  },
);
