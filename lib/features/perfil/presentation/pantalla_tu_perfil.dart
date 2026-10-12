import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/fotos.dart';
import '../data/perfil_repositorio.dart';
import '../domain/perfil.dart';
import 'cabecera_foto.dart';

/// The phone the prototype accepts: digits and spaces, an optional leading `+`.
final telefonoValido = RegExp(r'^\+?[\d ]{7,15}$');

/// «Tu perfil» (screens 102 and 103): the member's photo, name, phone and relationship with the
/// older adult (the family sees them), the e-mail they sign in with, and «Cambiar contraseña».
/// Every member opens it from Ajustes › «Tu cuenta».
class PantallaTuPerfil extends ConsumerWidget {
  const PantallaTuPerfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilProvider);
    final sesion = ref.watch(sesionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tu perfil')),
      body: switch (perfil) {
        AsyncData(value: final p?) => _Formulario(perfil: p),
        // A backend older than the profiles: what the session knows, read-only.
        AsyncData(value: null) when sesion != null => _SoloLectura(
          usuario: sesion.usuario,
        ),
        AsyncError(:final error) => ErrorDePantalla(
          error: error,
          alReintentar: () => ref.refresh(perfilProvider.future),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _SoloLectura extends StatefulWidget {
  const _SoloLectura({required this.usuario});

  final Usuario usuario;

  @override
  State<_SoloLectura> createState() => _SoloLecturaState();
}

class _SoloLecturaState extends State<_SoloLectura> {
  late final _nombre = TextEditingController(text: widget.usuario.nombre);
  late final _correo = TextEditingController(text: widget.usuario.correo);

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    children: [
      CabeceraFoto(
        de: DuenoFoto.yo,
        nombre: widget.usuario.nombre,
        foto: null,
        puedeCambiar: false,
      ),
      CampoTexto(
        etiqueta: 'Nombre y apellido',
        controlador: _nombre,
        habilitado: false,
      ),
      CampoTexto(
        etiqueta: 'Correo electrónico',
        controlador: _correo,
        tipo: TipoCampo.correo,
        habilitado: false,
        ayuda: 'Con él inicias sesión.',
      ),
    ],
  );
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _nombre = TextEditingController(text: widget.perfil.nombre);
  late final _telefono = TextEditingController(text: widget.perfil.telefono);
  late final _parentesco = TextEditingController(
    text: widget.perfil.parentesco,
  );
  late final _correo = TextEditingController(text: widget.perfil.correo);
  Map<String, String> _errores = {};
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _parentesco.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final telefono = _telefono.text.trim();
    setState(() {
      _problema = null;
      _errores = {
        if (nombre.isEmpty) 'nombre': 'Escribe tu nombre y apellido.',
        if (telefono.isNotEmpty && !telefonoValido.hasMatch(telefono))
          'telefono': 'Revisa el teléfono: solo números.',
      };
    });
    if (_errores.isNotEmpty) return;
    setState(() => _enviando = true);
    final anterior = widget.perfil.nombre;
    try {
      final perfil = await ref
          .read(perfilRepositorioProvider)
          .guardar(
            nombre: nombre,
            telefono: telefono.isEmpty ? null : telefono,
            parentesco: _parentesco.text.trim().isEmpty
                ? null
                : _parentesco.text.trim(),
          );
      final sesion = ref.read(sesionControllerProvider);
      if (sesion != null && sesion.usuario.nombre != perfil.nombre) {
        await ref
            .read(sesionControllerProvider.notifier)
            .iniciar(
              sesion.conUsuario(
                Usuario(
                  id: sesion.usuario.id,
                  nombre: perfil.nombre,
                  correo: sesion.usuario.correo,
                ),
              ),
            );
      }
      ref
        ..invalidate(perfilProvider)
        ..invalidate(familiaresProvider);
      if (!mounted) return;
      mostrarToast(
        context,
        titulo: 'Cambios guardados',
        texto: anterior != perfil.nombre
            ? 'Tu familia verá tu nombre nuevo.'
            : null,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'VALIDACION' && e.campos.isNotEmpty) {
          _errores = {
            for (final c in e.campos.entries) c.key.split('.').last: c.value,
          };
        } else {
          _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.perfil;
    final adulto = ref.watch(nombreAdultoMayorProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        CabeceraFoto(
          de: DuenoFoto.yo,
          nombre: p.nombre,
          // The fresh one after a change, before the profile is read again.
          foto: ref.watch(fotoDeUsuarioProvider(p.id)) ?? p.foto,
          puedeCambiar: true,
        ),
        if (_problema != null) ...[
          MensajeProblema(_problema!),
          const SizedBox(height: 16),
        ],
        CampoTexto(
          etiqueta: 'Nombre y apellido',
          controlador: _nombre,
          error: _errores['nombre'],
          autocompletar: const [AutofillHints.name],
          accionTeclado: TextInputAction.next,
          longitudMaxima: 80,
        ),
        CampoTexto(
          etiqueta: 'Teléfono',
          controlador: _telefono,
          tipo: TipoCampo.telefono,
          error: _errores['telefono'],
          autocompletar: const [AutofillHints.telephoneNumber],
          accionTeclado: TextInputAction.next,
          longitudMaxima: 20,
        ),
        CampoTexto(
          etiqueta: adulto == null ? 'Parentesco' : 'Parentesco con $adulto',
          controlador: _parentesco,
          error: _errores['parentesco'],
          marcador: 'Ej.: Hija, sobrino, vecina',
          longitudMaxima: 40,
        ),
        CampoTexto(
          etiqueta: 'Correo electrónico',
          controlador: _correo,
          tipo: TipoCampo.correo,
          habilitado: false,
          ayuda: 'Con él inicias sesión.',
        ),
        Boton('Guardar cambios', cargando: _enviando, alPresionar: _guardar),
        const SizedBox(height: 20),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.key),
              titulo: 'Cambiar contraseña',
              alTocar: () => context.push(Rutas.cambiarContrasena),
            ),
          ],
        ),
      ],
    );
  }
}
