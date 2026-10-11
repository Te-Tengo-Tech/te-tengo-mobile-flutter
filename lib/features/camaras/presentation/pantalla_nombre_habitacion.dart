import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/colores.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/camara_detectada.dart';
import '../../pcs/presentation/piezas_pc.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';

/// US-06, screens 23, 24 and 170: rename the room of the camera (owner only). Empty names are
/// rejected (CA-06.3); later alerts use the new name (CA-06.2). A room that already has another
/// camera cannot be chosen: one camera per room (CA-29.3), and never a bathroom.
class PantallaNombreHabitacion extends ConsumerStatefulWidget {
  const PantallaNombreHabitacion({
    super.key,
    required this.camaraId,
    required this.nombreActual,
    this.enConfiguracion = false,
  });

  final String camaraId;
  final String nombreActual;

  /// Step 3 of 5 of the setup.
  final bool enConfiguracion;

  /// Suggestions from the design.
  static const sugerencias = [
    'Sala',
    'Sala comedor',
    'Comedor',
    'Dormitorio',
    'Cocina',
    'Pasillo',
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

  /// The rooms whose camera is another one (`GET /api/ambientes`).
  List<Ambiente> get _ocupadas => [
    for (final a in ref.read(ambientesProvider).value ?? const <Ambiente>[])
      if (a.camaras.any((c) => c.id != widget.camaraId)) a,
  ];

  /// «Ya hay una cámara en la Sala. Por ahora, cada habitación usa una sola cámara.»
  String _ocupada(String habitacion) =>
      'Ya hay una cámara ${enHabitacion(habitacion)}. Por ahora, cada '
      'habitación usa una sola cámara.';

  Future<void> _guardar() async {
    final nombre = _nombre;
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe el nombre de la habitación.');
      return;
    }
    if (esBano(nombre)) {
      setState(
        () => _error = 'Por privacidad, Te Tengo no admite cámaras en el baño.',
      );
      return;
    }
    final ocupada = _ocupadas
        .where((a) => a.nombre.toLowerCase() == nombre.toLowerCase())
        .firstOrNull;
    if (ocupada != null) {
      setState(() => _error = _ocupada(ocupada.nombre));
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
      ref
        ..invalidate(camarasProvider)
        ..invalidate(pcsProvider)
        ..invalidate(ambientesProvider);
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
          case 'AMBIENTE_OCUPADO':
            _error = _ocupada(e.extras['ambiente'] as String? ?? nombre);
          case 'AMBIENTE_NO_PERMITIDO':
            _error = 'Por privacidad, Te Tengo no admite cámaras en el baño.';
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
    ref.watch(ambientesProvider);
    final ocupadas = {for (final a in _ocupadas) a.nombre.toLowerCase()};
    return Scaffold(
      appBar: widget.enConfiguracion
          ? CabeceraConfiguracion(
              paso: 3,
              titulo: 'Cámara',
              escala: MediaQuery.textScalerOf(context),
            )
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
          Text('Aparece en cada alerta.', style: texto.bodyMedium),
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
                    ChipHabitacion(
                      texto: s,
                      elegido: nombre == s,
                      ocupada: ocupadas.contains(s.toLowerCase()),
                      alTocar: () => setState(() {
                        _control.text = s;
                        _error = null;
                      }),
                    ),
                ],
              ),
            ),
          ),
          if (ocupadas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Las habitaciones que ya tienen cámara no se pueden elegir.',
              style: texto.bodySmall,
            ),
          ],
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
