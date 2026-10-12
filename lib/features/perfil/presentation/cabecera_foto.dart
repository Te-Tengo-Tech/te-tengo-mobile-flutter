import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/tema/paleta.dart';
import '../../../core/foto.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/web/entorno.dart';
import '../data/fotos.dart';
import '../data/selector_foto.dart';
import '../domain/perfil.dart';
import 'pantalla_recorte.dart';

/// What the person picked in «Foto de Carmen».
enum AccionFoto { tomar, galeria, quitar }

/// The large photo with «Cambiar foto» (`photoHead`) of «Tu perfil» and «Persona cuidada»: the
/// picture (or the initials), its upload progress, and «Volver a intentarlo» when it failed.
class CabeceraFoto extends ConsumerWidget {
  const CabeceraFoto({
    super.key,
    required this.de,
    required this.nombre,
    required this.foto,
    required this.puedeCambiar,
    this.tono = TonoAvatar.morado,
  });

  final DuenoFoto de;
  final String nombre;
  final Foto? foto;

  /// Only the owner changes the older adult's photo; each member, their own. False also with a
  /// backend older than the photos.
  final bool puedeCambiar;
  final TonoAvatar tono;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(cambioFotoProvider(de));
    final problema = estado.problema;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Avatar(
                Avatar.inicialesDe(nombre),
                tono: tono,
                tamano: 96,
                foto: foto,
              ),
              if (estado.ocupado)
                Semantics(
                  label: estado.quitando
                      ? 'Quitando la foto'
                      : 'Subiendo la foto',
                  value: estado.avance == null
                      ? null
                      : '${(estado.avance! * 100).round()} %',
                  child: SizedBox.square(
                    dimension: 106,
                    child: CircularProgressIndicator(
                      value: estado.avance,
                      strokeWidth: 4,
                      color: context.colores.moradoTinta,
                      backgroundColor: context.colores.linea,
                    ),
                  ),
                ),
            ],
          ),
          if (puedeCambiar) ...[
            const SizedBox(height: 12),
            Boton(
              'Cambiar foto',
              icono: Ico.cam,
              estilo: EstiloBoton.secundario,
              pequeno: true,
              cargando: estado.ocupado,
              textoCargando: estado.quitando
                  ? 'Quitando…'
                  : estado.avance == null
                  ? 'Subiendo…'
                  : 'Subiendo… ${(estado.avance! * 100).round()} %',
              alPresionar: () => cambiarFoto(
                context,
                ref,
                de: de,
                nombre: nombre,
                tieneFoto: foto != null,
              ),
            ),
          ],
          if (problema != null) ...[
            const SizedBox(height: 12),
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.warn,
              titulo: 'No se pudo cambiar la foto',
              texto: problema.detalle,
              accion: estado.pendiente == null
                  ? null
                  : Boton(
                      'Volver a intentarlo',
                      estilo: EstiloBoton.tinta,
                      pequeno: true,
                      alPresionar: () => _subir(
                        context,
                        ref,
                        de,
                        ref.read(cambioFotoProvider(de).notifier).reintentar,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// «Cambiar foto»: the sheet, then the camera or the gallery, the square crop and the upload; or
/// «Quitar la foto».
Future<void> cambiarFoto(
  BuildContext context,
  WidgetRef ref, {
  required DuenoFoto de,
  required String nombre,
  required bool tieneFoto,
}) async {
  final accion = await showModalBottomSheet<AccionFoto>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => HojaFoto(nombre: nombre, tieneFoto: tieneFoto),
  );
  if (accion == null || !context.mounted) return;
  final cambio = ref.read(cambioFotoProvider(de).notifier);
  if (accion == AccionFoto.quitar) {
    if (await cambio.quitar() && context.mounted) {
      mostrarToast(
        context,
        titulo: 'Foto quitada',
        texto: 'Se verán las iniciales.',
        icono: Ico.trash,
      );
    }
    return;
  }
  final origen = accion == AccionFoto.tomar
      ? OrigenFoto.camara
      : OrigenFoto.galeria;
  final Uint8List? original;
  try {
    original = await ref
        .read(selectorFotoProvider)
        .elegir(origen, frontal: de == DuenoFoto.yo);
  } on PermisoFotoDenegado catch (e) {
    if (context.mounted) await _sinPermiso(context, ref, e);
    return;
  } on Object {
    if (context.mounted) {
      mostrarToast(
        context,
        titulo: 'No pudimos abrir esa foto',
        texto: 'Elige otra.',
        icono: Ico.warn,
        tono: TonoAviso.advertencia,
      );
    }
    return;
  }
  if (original == null || !context.mounted) return;
  final recortada = await ref.read(recortadorFotoProvider)(context, original);
  if (recortada == null || !context.mounted) return;
  await _subir(context, ref, de, () => cambio.subir(recortada));
}

Future<void> _subir(
  BuildContext context,
  WidgetRef ref,
  DuenoFoto de,
  Future<bool> Function() subir,
) async {
  if (await subir() && context.mounted) {
    mostrarToast(
      context,
      titulo: 'Foto actualizada',
      texto: 'La verá toda la familia.',
    );
  }
}

/// The camera or the photos were not allowed: blocked ones can only be allowed in the phone's
/// settings (the QR scanner's pattern); a plain «no» is asked again next time.
Future<void> _sinPermiso(
  BuildContext context,
  WidgetRef ref,
  PermisoFotoDenegado e,
) async {
  final camara = e.origen == OrigenFoto.camara;
  final enNavegador = ref.read(entornoNavegadorProvider).esWeb;
  if (!e.bloqueado || enNavegador) {
    mostrarToast(
      context,
      titulo: camara
          ? 'Sin permiso para usar la cámara'
          : 'Sin permiso para ver tus fotos',
      texto: 'Puedes elegir otra opción.',
      icono: Ico.warn,
      tono: TonoAviso.advertencia,
    );
    return;
  }
  final abrir = await confirmar(
    context,
    icono: camara ? Ico.cam : Ico.download,
    titulo: camara
        ? 'La cámara del celular está bloqueada'
        : 'Tus fotos están bloqueadas para Te Tengo',
    texto: 'Permítelo en los ajustes del celular y vuelve a intentarlo.',
    aceptar: 'Abrir los ajustes del celular',
    cancelar: 'Ahora no',
  );
  if (abrir) unawaited(openAppSettings());
}

/// «Foto de Carmen» (screen 103): take one, pick one, or remove the current one.
class HojaFoto extends StatelessWidget {
  const HojaFoto({super.key, required this.nombre, required this.tieneFoto});

  final String nombre;
  final bool tieneFoto;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final pila = nombre.trim().split(RegExp(r'\s+')).first;
    FilaLista fila(AccionFoto a, Ico icono, String titulo) => FilaLista(
      inicio: IconoFila(icono, peligro: a == AccionFoto.quitar),
      titulo: titulo,
      peligro: a == AccionFoto.quitar,
      chevron: false,
      alTocar: () => Navigator.of(context).pop(a),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Foto de $pila', style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text('La ve toda la familia.', style: texto.bodyMedium),
          const SizedBox(height: 16),
          ListaTarjeta(
            borde: true,
            children: [
              fila(AccionFoto.tomar, Ico.cam, 'Tomar una foto'),
              fila(AccionFoto.galeria, Ico.download, 'Elegir de la galería'),
              if (tieneFoto)
                fila(AccionFoto.quitar, Ico.trash, 'Quitar la foto'),
            ],
          ),
        ],
      ),
    );
  }
}
