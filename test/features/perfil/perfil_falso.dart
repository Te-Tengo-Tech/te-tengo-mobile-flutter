import 'dart:async';
import 'dart:typed_data';

import 'package:te_tengo/core/foto.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/perfil/data/perfil_repositorio.dart';
import 'package:te_tengo/features/perfil/data/selector_foto.dart';
import 'package:te_tengo/features/perfil/domain/perfil.dart';

final fotoCarmen = Foto(
  url: 'https://fotos.test/fotos/usuarios/u-carmen/f1.jpg?firma=1',
  expiraEn: DateTime(2026, 9, 23, 11, 42),
);

final fotoRosa = Foto(
  url: 'https://fotos.test/fotos/hogares/h-1/adulto-mayor/f2.jpg?firma=1',
  expiraEn: DateTime(2026, 9, 23, 11, 42),
);

Perfil perfilCarmen({Foto? foto}) => Perfil(
  id: 'u-carmen',
  nombre: 'Carmen Huamán',
  correo: 'carmen.huaman@gmail.com',
  telefono: '981 220 417',
  parentesco: 'Hija',
  foto: foto,
);

/// «Tu perfil» and the photos without a backend. [perfil] null is a backend older than the
/// profiles.
class PerfilRepositorioFalso implements PerfilRepositorio {
  PerfilRepositorioFalso([this.perfil]);

  Perfil? perfil;
  final guardados = <(String, String?, String?)>[];
  final contrasenas = <(String, String)>[];
  final subidas = <(DuenoFoto, Uint8List, String)>[];
  final quitadas = <DuenoFoto>[];
  ProblemaApi? errorGuardar;
  ProblemaApi? errorContrasena;

  /// Fails the next uploads, one by one.
  final erroresSubida = <ProblemaApi>[];

  /// Holds an upload half-way until it completes.
  Completer<void>? pausaSubida;

  @override
  Future<Perfil?> obtener() async => perfil;

  @override
  Future<Perfil> guardar({
    required String nombre,
    String? telefono,
    String? parentesco,
  }) async {
    guardados.add((nombre, telefono, parentesco));
    if (errorGuardar != null) throw errorGuardar!;
    final actual = perfil ?? perfilCarmen();
    return perfil = Perfil(
      id: actual.id,
      nombre: nombre,
      correo: actual.correo,
      telefono: telefono,
      parentesco: parentesco,
      foto: actual.foto,
    );
  }

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) async {
    contrasenas.add((actual, nueva));
    if (errorContrasena != null) throw errorContrasena!;
  }

  @override
  Future<Foto> subirFoto(
    DuenoFoto de,
    Uint8List bytes, {
    required String tipo,
    void Function(double avance)? alProgreso,
  }) async {
    subidas.add((de, bytes, tipo));
    alProgreso?.call(.5);
    if (pausaSubida != null) await pausaSubida!.future;
    if (erroresSubida.isNotEmpty) throw erroresSubida.removeAt(0);
    alProgreso?.call(1);
    final foto = de == DuenoFoto.yo ? fotoCarmen : fotoRosa;
    if (de == DuenoFoto.yo) perfil = perfil?.conFoto(foto);
    return foto;
  }

  @override
  Future<void> quitarFoto(DuenoFoto de) async {
    quitadas.add(de);
    if (de == DuenoFoto.yo) perfil = perfil?.conFoto(null);
  }
}

/// The camera and the gallery: returns [imagen], or throws [error].
class SelectorFotoFalso implements SelectorFoto {
  SelectorFotoFalso({Uint8List? imagen, this.error})
    : imagen = imagen ?? Uint8List.fromList([1, 2, 3]);

  Uint8List? imagen;
  Object? error;
  final pedidos = <(OrigenFoto, bool)>[];

  @override
  Future<Uint8List?> elegir(OrigenFoto origen, {bool frontal = false}) async {
    pedidos.add((origen, frontal));
    if (error != null) throw error!;
    return imagen;
  }
}
