import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../camaras/domain/camara.dart';
import '../../historial/data/historial_provider.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';

enum _Final { atendida, falsa }

/// Screen 55: bottom sheet to mark the alert as attended or as a false alarm (US-19). Any member,
/// owner or invited, can mark it.
Future<void> marcarAlerta(BuildContext context, Alerta alerta) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HojaMarcar(alerta: alerta),
    );

class _HojaMarcar extends ConsumerStatefulWidget {
  const _HojaMarcar({required this.alerta});

  final Alerta alerta;

  @override
  ConsumerState<_HojaMarcar> createState() => _HojaMarcarState();
}

class _HojaMarcarState extends ConsumerState<_HojaMarcar> {
  _Final? _eleccion;
  bool _faltaEleccion = false;
  bool _guardando = false;
  ProblemaApi? _problema;

  Future<void> _guardar() async {
    final eleccion = _eleccion;
    if (eleccion == null) return setState(() => _faltaEleccion = true);
    setState(() {
      _guardando = true;
      _problema = null;
    });
    final repo = ref.read(alertasRepositorioProvider);
    final a = widget.alerta;
    try {
      final marcada = eleccion == _Final.atendida
          ? await repo.atender(a.id)
          : await repo.marcarFalsaAlarma(a.id);
      _refrescar(a.id);
      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      unawaited(router.pushReplacement(Rutas.detalleAlerta(a.id)));
      final cuando = marcada.atendidaEn ?? ref.read(relojProvider)();
      mostrarToast(
        context,
        titulo: eleccion == _Final.falsa
            ? 'Marcada como falsa alarma'
            : 'Alerta atendida',
        texto: 'La familia verá que la marcaste a las ${hora(cuando)}.',
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 'ALERTA_CERRADA') {
        // Someone else marked it first: the detail shows who and when (CA-19.3).
        _refrescar(a.id);
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        unawaited(router.pushReplacement(Rutas.detalleAlerta(a.id)));
        mostrarToast(context, titulo: e.detalle, icono: Ico.info);
      } else {
        setState(() => _problema = e);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _refrescar(String id) => ref
    ..invalidate(alertaProvider(id))
    ..invalidate(alertaActivaProvider)
    ..invalidate(historialProvider);

  @override
  Widget build(BuildContext context) {
    final a = widget.alerta;
    final texto = Theme.of(context).textTheme;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final quien = ref.watch(sesionControllerProvider)?.usuario.nombre ?? '';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                '¿Cómo terminó esta alerta?',
                style: texto.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              conHora(
                '${a.tipo.nombre} ${enHabitacion(a.habitacion)} a las ',
                hora(a.ocurridaEn),
                '.',
              ),
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 16),
            OpcionRadio(
              valor: _Final.atendida,
              seleccion: _eleccion,
              titulo: 'Atendida',
              subtitulo: '$nombre recibió ayuda o está bien',
              error: _faltaEleccion,
              alElegir: (v) => setState(() {
                _eleccion = v;
                _faltaEleccion = false;
              }),
            ),
            OpcionRadio(
              valor: _Final.falsa,
              seleccion: _eleccion,
              titulo: 'Falsa alarma',
              subtitulo:
                  'No hubo ${a.esCaida ? 'caída' : 'movimiento inestable'}. No '
                  'contará en el resumen.',
              error: _faltaEleccion,
              alElegir: (v) => setState(() {
                _eleccion = v;
                _faltaEleccion = false;
              }),
            ),
            if (_faltaEleccion) const MensajeCampo('Elige una opción.'),
            const SizedBox(height: 4),
            Text.rich(
              conHora(
                'Quedará registrado: $quien · ',
                hora(ref.watch(relojProvider)()),
              ),
              style: texto.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 12),
            ],
            Boton('Guardar', cargando: _guardando, alPresionar: _guardar),
          ],
        ),
      ),
    );
  }
}
