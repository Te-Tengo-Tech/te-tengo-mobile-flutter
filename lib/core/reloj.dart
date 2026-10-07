import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time, replaceable in tests (`relojProvider.overrideWithValue(() => fixed)`).
typedef Reloj = DateTime Function();

final relojProvider = Provider<Reloj>((ref) => DateTime.now);
