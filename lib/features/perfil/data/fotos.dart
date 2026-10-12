import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/foto.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../domain/perfil.dart';
import 'perfil_repositorio.dart';

/// The older adult's photo, wherever they appear (Inicio, the alert, Ajustes, the widget).
final fotoAdultoMayorProvider = Provider<Foto?>(
  (ref) => ref.watch(hogarProvider).value?.adultoMayor.foto,
);

/// A member's photo by their `usuarioId`: the own one from «Tu perfil» (fresher after a change),
/// the others from `GET /api/familiares`.
final fotoDeUsuarioProvider = Provider.family<Foto?, String?>((ref, id) {
  if (id == null) return null;
  final yo = ref.watch(sesionControllerProvider)?.usuario.id;
  if (id == yo) {
    final perfil = ref.watch(perfilProvider).value;
    if (perfil != null) return perfil.foto;
  }
  return ref
      .watch(familiaresProvider)
      .value
      ?.where((f) => f.usuarioId == id)
      .firstOrNull
      ?.foto;
});

/// A photo being changed: [avance] while it is sent (null while it is prepared or confirmed), or
/// the [problema] of the last attempt, with the picture kept for «Volver a intentarlo».
class EstadoCambioFoto {
  const EstadoCambioFoto({
    this.subiendo = false,
    this.quitando = false,
    this.avance,
    this.problema,
    this.pendiente,
  });

  final bool subiendo;
  final bool quitando;
  final double? avance;
  final ProblemaApi? problema;
  final Uint8List? pendiente;

  bool get ocupado => subiendo || quitando;
}

/// Uploads or removes the photo of [de], then reloads whatever shows it.
class CambioFoto extends Notifier<EstadoCambioFoto> {
  CambioFoto(this.de);

  final DuenoFoto de;

  @override
  EstadoCambioFoto build() => const EstadoCambioFoto();

  /// True when the new photo is stored.
  Future<bool> subir(Uint8List png) async {
    if (state.ocupado) return false;
    state = EstadoCambioFoto(subiendo: true, pendiente: png);
    try {
      await ref
          .read(perfilRepositorioProvider)
          .subirFoto(
            de,
            png,
            tipo: 'image/png',
            alProgreso: (avance) => state = EstadoCambioFoto(
              subiendo: true,
              avance: avance,
              pendiente: png,
            ),
          );
      _aplicar();
      state = const EstadoCambioFoto();
      return true;
    } on ProblemaApi catch (e) {
      state = EstadoCambioFoto(problema: e, pendiente: png);
      return false;
    }
  }

  /// «Volver a intentarlo» with the same picture.
  Future<bool> reintentar() async {
    final png = state.pendiente;
    return png == null ? false : subir(png);
  }

  /// «Quitar la foto»: the initials come back.
  Future<bool> quitar() async {
    if (state.ocupado) return false;
    state = const EstadoCambioFoto(quitando: true);
    try {
      await ref.read(perfilRepositorioProvider).quitarFoto(de);
      _aplicar();
      state = const EstadoCambioFoto();
      return true;
    } on ProblemaApi catch (e) {
      state = EstadoCambioFoto(problema: e);
      return false;
    }
  }

  void descartarError() => state = const EstadoCambioFoto();

  void _aplicar() {
    switch (de) {
      case DuenoFoto.yo:
        ref
          ..invalidate(perfilProvider)
          ..invalidate(familiaresProvider);
      case DuenoFoto.adultoMayor:
        ref.invalidate(hogarProvider);
    }
  }
}

final cambioFotoProvider =
    NotifierProvider.family<CambioFoto, EstadoCambioFoto, DuenoFoto>(
      CambioFoto.new,
    );

/// Every photo's signature lasts an hour (`expiraEn`): just before the first one ends, the
/// household, the family and the profile are read again, so the avatars keep their pictures.
final renovacionFotosProvider = Provider<void>((ref) {
  final fotos = <Foto?>[
    ref.watch(fotoAdultoMayorProvider),
    ref.watch(perfilProvider).value?.foto,
    for (final f in ref.watch(familiaresProvider).value ?? const <Familiar>[])
      f.foto,
  ].nonNulls;
  if (fotos.isEmpty) return;
  final primera = fotos
      .map((f) => f.expiraEn)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  var espera = primera.difference(DateTime.now()) - const Duration(minutes: 2);
  if (espera < const Duration(seconds: 30)) {
    espera = const Duration(seconds: 30);
  }
  final temporizador = Timer(espera, () {
    ref
      ..invalidate(hogarProvider)
      ..invalidate(familiaresProvider)
      ..invalidate(perfilProvider);
  });
  ref.onDispose(temporizador.cancel);
});
