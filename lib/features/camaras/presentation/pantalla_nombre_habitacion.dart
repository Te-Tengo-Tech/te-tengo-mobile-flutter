import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/colores.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';

/// US-06, screens 20, 21 and 32: rename the room of the camera (owner only). Empty names are
/// rejected (CA-06.3); later alerts use the new name (CA-06.2).
class PantallaNombreHabitacion extends ConsumerStatefulWidget {
  const PantallaNombreHabitacion({
    super.key,
    required this.camaraId,
    required this.nombreActual,
    this.enConfiguracion = false,
  });

  final String camaraId;
  final String nombreActual;

  /// Step 3 of 4 of the setup.
  final bool enConfiguracion;

  /// Suggestions from the design.
  static const sugerencias = [
    'Sala',
    'Sala comedor',
    'Comedor',
    'Dormitorio',
    'Cocina',
  ];

  /// Same limit as the backend (`1–40 chars`).
  static const largoMaximo = 40;

  @override
  ConsumerState<PantallaNombreHabitacion> createState() =>
      _PantallaNombreHabitacionState();
}

class _PantallaNombreHabitacionState
    extends ConsumerState<PantallaNombreHabitacion> {
  late final _control = TextEditingController(text: widget.nombreActual);
  String? _error;
  ProblemaApi? _problema;
  bool _guardando = false;

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  /// Collapses spaces and capitalizes the first letter, as the prototype.
  String get _nombre {
    final n = _control.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return n.isEmpty ? n : n[0].toUpperCase() + n.substring(1);
  }

  Future<void> _guardar() async {
    final nombre = _nombre;
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe el nombre de la habitación.');
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
      _problema = null;
    });
    try {
      await ref
          .read(camarasRepositorioProvider)
          .renombrar(widget.camaraId, nombre);
      ref.invalidate(camarasProvider);
      if (!mounted) return;
      context.pop();
      mostrarToast(
        context,
        titulo: 'Nombre guardado: $nombre',
        texto: 'Las próximas alertas dirán «${enHabitacion(nombre)}».',
        icono: Ico.pin,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'CAMARA_NOMBRE_VACIO':
            _error = 'Escribe el nombre de la habitación.';
          case 'CAMARA_NOMBRE_MUY_LARGO':
            _error = e.detalle;
          default:
            _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final nombre = _nombre;
    return Scaffold(
      appBar: widget.enConfiguracion
          ? const CabeceraConfiguracion(paso: 3, titulo: 'Cámara')
          : AppBar(title: const Text('Nombre de la habitación')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          widget.enConfiguracion ? 0 : 4,
          20,
          28,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(
              '¿Cómo se llama esta habitación?',
              style: texto.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Es donde el equipo del proyecto instaló la cámara. El nombre '
            'aparece en cada alerta para que sepas al instante dónde fue.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CampoTexto(
            etiqueta: 'Nombre de la habitación',
            controlador: _control,
            error: _error,
            marcador: 'Ej.: Sala comedor',
            ayuda: 'Elige una sugerencia o escribe otro nombre.',
            longitudMaxima: PantallaNombreHabitacion.largoMaximo,
            alCambiar: (_) => setState(() => _error = null),
            alEnviar: (_) => _guardar(),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Semantics(
              label: 'Sugerencias',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in PantallaNombreHabitacion.sugerencias)
                    ChipOpcion(
                      texto: s,
                      elegido: nombre == s,
                      alTocar: () => setState(() {
                        _control.text = s;
                        _error = null;
                      }),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TarjetaBanda(
            borde: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Así se verá en las próximas alertas',
                  style: texto.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icono(Ico.fall, tamano: 22, color: Colores.caida),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nombre.isEmpty
                            ? 'Posible caída …'
                            : 'Posible caída ${enHabitacion(nombre)}',
                        style: texto.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Las alertas anteriores conservan el nombre que tenían.',
                  style: texto.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Boton('Guardar nombre', cargando: _guardando, alPresionar: _guardar),
        ],
      ),
    );
  }
}
