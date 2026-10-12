import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../data/perfil_repositorio.dart';

/// «Cambiar contraseña» (from «Tu perfil»): the current one, then the new one twice
/// (`PUT /api/cuenta/contrasena`). The other sessions stay open.
class PantallaCambiarContrasena extends ConsumerStatefulWidget {
  const PantallaCambiarContrasena({super.key});

  @override
  ConsumerState<PantallaCambiarContrasena> createState() =>
      _PantallaCambiarContrasenaState();
}

class _PantallaCambiarContrasenaState
    extends ConsumerState<PantallaCambiarContrasena> {
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _repetida = TextEditingController();
  Map<String, String> _errores = {};
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _repetida.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final actual = _actual.text;
    final nueva = _nueva.text;
    setState(() {
      _problema = null;
      _errores = {
        if (actual.isEmpty) 'actual': 'Escribe tu contraseña actual.',
        if (nueva.length < 8 || !RegExp(r'\d').hasMatch(nueva))
          'nueva': 'Usa al menos 8 caracteres y un número.'
        else if (nueva != _repetida.text)
          'repetida': 'Las contraseñas no coinciden.',
      };
    });
    if (_errores.isNotEmpty) return;
    setState(() => _enviando = true);
    try {
      await ref
          .read(perfilRepositorioProvider)
          .cambiarContrasena(actual: actual, nueva: nueva);
      if (!mounted) return;
      mostrarToast(context, titulo: 'Contraseña actualizada', icono: Ico.key);
      unawaited(Navigator.of(context).maybePop());
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'CONTRASENA_ACTUAL_INCORRECTA') {
          _errores = {'actual': 'No coincide con tu contraseña actual.'};
        } else if (e.codigo == 'VALIDACION' && e.campos.isNotEmpty) {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cambiar contraseña')),
    body: AutofillGroup(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CampoTexto(
            etiqueta: 'Contraseña actual',
            controlador: _actual,
            tipo: TipoCampo.contrasena,
            error: _errores['actual'],
            autocompletar: const [AutofillHints.password],
            accionTeclado: TextInputAction.next,
          ),
          CampoTexto(
            etiqueta: 'Nueva contraseña',
            controlador: _nueva,
            tipo: TipoCampo.contrasena,
            error: _errores['nueva'],
            ayuda: '8 caracteres o más, con un número.',
            autocompletar: const [AutofillHints.newPassword],
            accionTeclado: TextInputAction.next,
          ),
          CampoTexto(
            etiqueta: 'Repite la nueva contraseña',
            controlador: _repetida,
            tipo: TipoCampo.contrasena,
            error: _errores['repetida'],
            autocompletar: const [AutofillHints.newPassword],
            alEnviar: (_) => _guardar(),
          ),
          Boton(
            'Guardar contraseña',
            cargando: _enviando,
            alPresionar: _guardar,
          ),
        ],
      ),
    ),
  );
}
