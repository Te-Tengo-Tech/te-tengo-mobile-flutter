import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../data/actualizacion_controller.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/marca.dart';

/// «Permite instalar la actualización» (screen 363): the first time Android needs its «Instalar
/// apps desconocidas» permission, explained in three steps before its own settings open
/// (CA-43.5). Back from the settings with the permission, the Android installer opens; «Ahora no»
/// leaves «Falta el permiso de Android».
class PantallaPermisoInstalar extends ConsumerStatefulWidget {
  const PantallaPermisoInstalar({super.key});

  @override
  ConsumerState<PantallaPermisoInstalar> createState() =>
      _PantallaPermisoInstalarState();
}

class _PantallaPermisoInstalarState
    extends ConsumerState<PantallaPermisoInstalar> {
  late final AppLifecycleListener _ciclo;
  bool _fueAAjustes = false;

  /// The permission was given (the installer opened) or refused with «Ahora no».
  bool _resuelto = false;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(onResume: _alVolver);
  }

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  Future<void> _alVolver() async {
    if (!_fueAAjustes) return;
    final instala = await ref
        .read(actualizacionProvider.notifier)
        .alVolverDeAjustes();
    if (instala && mounted) {
      _resuelto = true;
      unawaited(Navigator.of(context).maybePop());
    }
  }

  Future<void> _abrirAjustes() async {
    _fueAAjustes = true;
    await ref.read(actualizacionProvider.notifier).abrirAjustesPermiso();
  }

  void _ahoraNo() {
    _resuelto = true;
    ref.read(actualizacionProvider.notifier).permisoAhoraNo();
    unawaited(Navigator.of(context).maybePop());
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final c = context.colores;
    return PopScope(
      onPopInvokedWithResult: (salio, _) {
        // Closing it without the permission is «Ahora no».
        if (salio && !_resuelto) {
          _resuelto = true;
          ref.read(actualizacionProvider.notifier).permisoAhoraNo();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Cerrar',
            icon: Icono(Ico.x, color: c.tinta),
            onPressed: _ahoraNo,
          ),
          title: const Text('Instalar la actualización'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.tarjeta,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.linea),
                ),
                child: Row(
                  children: [
                    const IconoApp(tamano: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Te Tengo',
                            style: estiloTexto(16, 700, color: c.tinta),
                          ),
                          Text(
                            'Permitir de esta fuente',
                            style: estiloTexto(15, 400, color: c.tinta2),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: null,
                      activeTrackColor: c.calmaTinta,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                'Permite instalar la actualización',
                style: texto.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Android lo pide una sola vez.',
                    style: texto.bodyMedium,
                  ),
                ),
                const AyudaInfo(
                  texto:
                      'Te Tengo no viene de una tienda, así que Android pide '
                      'permiso para instalar sus versiones nuevas. Solo acepta '
                      'las firmadas por Te Tengo.',
                  tema: 'el permiso de Android',
                ),
              ],
            ),
            const PasosNumerados([
              ('Toca «Abrir ajustes».', null),
              ('Activa «Permitir de esta fuente».', null),
              ('Vuelve a Te Tengo.', null),
            ]),
            const SizedBox(height: 20),
            Boton(
              'Abrir ajustes',
              icono: Ico.sliders,
              alPresionar: _abrirAjustes,
            ),
            const SizedBox(height: 8),
            Boton(
              'Ahora no',
              estilo: EstiloBoton.fantasma,
              alPresionar: _ahoraNo,
            ),
          ],
        ),
      ),
    );
  }
}
