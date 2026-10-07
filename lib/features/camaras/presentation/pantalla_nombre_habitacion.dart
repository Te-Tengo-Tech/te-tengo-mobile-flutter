import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/red/problema_api.dart';
import '../data/camaras_repositorio.dart';

/// US-06 / CA-06.2 y CA-06.3: cambiar el nombre de la habitación; vacío no se permite.
class PantallaNombreHabitacion extends ConsumerStatefulWidget {
  const PantallaNombreHabitacion({
    super.key,
    required this.camaraId,
    required this.nombreActual,
  });

  final String camaraId;
  final String nombreActual;

  /// Sugerencias del diseño.
  static const sugerencias = [
    'Sala',
    'Sala comedor',
    'Comedor',
    'Dormitorio',
    'Cocina',
  ];

  @override
  ConsumerState<PantallaNombreHabitacion> createState() =>
      _PantallaNombreHabitacionState();
}

class _PantallaNombreHabitacionState
    extends ConsumerState<PantallaNombreHabitacion> {
  late final _control = TextEditingController(text: widget.nombreActual);
  final _formulario = GlobalKey<FormState>();
  bool _guardando = false;
  String? _errorServidor;

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _errorServidor = null;
    });
    try {
      await ref
          .read(camarasRepositorioProvider)
          .renombrar(widget.camaraId, _control.text.trim());
      ref.invalidate(camarasProvider);
      if (mounted) context.go('/camaras');
    } on ProblemaApi catch (e) {
      setState(() => _errorServidor = e.detalle);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Nombre de la habitación')),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _control,
              autofocus: true,
              maxLength: 40,
              decoration: const InputDecoration(labelText: 'Habitación'),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Escribe el nombre de la habitación.'
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sugerencia in PantallaNombreHabitacion.sugerencias)
                  ActionChip(
                    label: Text(sugerencia),
                    onPressed: () => setState(() => _control.text = sugerencia),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Así se verá en las próximas alertas',
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _control.text.trim().isEmpty
                  ? '—'
                  : 'Caída en ${_control.text.trim()}',
              style: texto.titleMedium,
            ),
            if (_errorServidor != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorServidor!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
