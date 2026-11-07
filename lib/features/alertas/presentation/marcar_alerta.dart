import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
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
import '../../../l10n/l10n.dart';
import '../domain/alerta.dart';
import 'textos_alerta.dart';

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
      final l = context.l10n;
      mostrarToast(
        context,
        titulo: eleccion == _Final.falsa
            ? l.alertaMarcadaFalsa
            : l.alertaAtendidaToast,
        texto: l.alertaToastFamiliaVera(context.formato.hora(cuando)),
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
    final l = context.l10n;
    final formato = context.formato;
    final ahora = formato.hora(ref.watch(relojProvider)());
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
              child: Text(l.alertaMarcarPregunta, style: texto.titleLarge),
            ),
            const SizedBox(height: 8),
            Text.rich(
              textoConHora(
                l.alertaMarcarResumen(
                  a.tipo.nombre(l),
                  conArticulo(a.habitacion),
                  formato.hora(a.ocurridaEn),
                  a.habitacion,
                ),
                formato.hora(a.ocurridaEn),
              ),
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 16),
            OpcionRadio(
              valor: _Final.atendida,
              seleccion: _eleccion,
              titulo: l.alertaOpcionAtendida,
              subtitulo: l.alertaOpcionAtendidaDetalle(nombre),
              error: _faltaEleccion,
              alElegir: (v) => setState(() {
                _eleccion = v;
                _faltaEleccion = false;
              }),
            ),
            OpcionRadio(
              valor: _Final.falsa,
              seleccion: _eleccion,
              titulo: l.alertaOpcionFalsa,
              subtitulo: a.esCaida
                  ? l.alertaOpcionFalsaCaida
                  : l.alertaOpcionFalsaInestable,
              error: _faltaEleccion,
              alElegir: (v) => setState(() {
                _eleccion = v;
                _faltaEleccion = false;
              }),
            ),
            if (_faltaEleccion) MensajeCampo(l.alertaEligeOpcion),
            const SizedBox(height: 4),
            Text.rich(
              textoConHora(l.alertaQuedaraRegistrado(quien, ahora), ahora),
              style: texto.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 12),
            ],
            Boton(l.alertaGuardar, cargando: _guardando, alPresionar: _guardar),
          ],
        ),
      ),
    );
  }
}
