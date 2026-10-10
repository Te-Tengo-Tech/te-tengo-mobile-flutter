import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../data/hogar_repositorio.dart';
import '../domain/hogar.dart';
import '../../legal/presentation/textos_legales.dart';
import 'constancia.dart';

/// Who grants the consent.
enum _Otorgante { directo, representante }

/// US-05, screens 16 and 17: informed consent. It states that linked family members can watch the
/// camera live at any time, and it is recorded only if both boxes are checked (CA-05.4).
class PantallaConsentimiento extends ConsumerStatefulWidget {
  const PantallaConsentimiento({super.key, this.enConfiguracion = false});

  /// Step 2 of 5 of the setup; otherwise opened from Inicio or Ajustes.
  final bool enConfiguracion;

  @override
  ConsumerState<PantallaConsentimiento> createState() =>
      _PantallaConsentimientoState();
}

class _PantallaConsentimientoState
    extends ConsumerState<PantallaConsentimiento> {
  _Otorgante _otorgante = _Otorgante.directo;
  bool _acepta = false;
  bool _leyo = false;
  bool _faltanCasillas = false;
  ProblemaApi? _problema;
  bool _enviando = false;
  final _formulario = GlobalKey();

  Future<void> _registrar(AdultoMayor adulto) async {
    if (!_acepta || !_leyo) {
      setState(() => _faltanCasillas = true);
      final contexto = _formulario.currentContext;
      if (contexto != null) {
        await Scrollable.ensureVisible(contexto, alignment: .2);
      }
      return;
    }
    setState(() {
      _enviando = true;
      _problema = null;
    });
    try {
      await ref
          .read(hogarRepositorioProvider)
          .registrarConsentimiento(
            otorgadoPor: _otorgante == _Otorgante.directo
                ? adulto.nombre
                : 'Representante legal de ${adulto.nombre}',
          );
      ref
        ..invalidate(hogarProvider)
        ..invalidate(camarasProvider);
      if (!mounted) return;
      if (widget.enConfiguracion) {
        context.go(Rutas.configConstancia);
      } else {
        context.pushReplacement(Rutas.constancia);
      }
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'CONSENTIMIENTO_NO_ACEPTADO') {
          _faltanCasillas = true;
        } else {
          _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _ahoraNo() {
    if (widget.enConfiguracion) {
      context.go(Rutas.configCamara);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hogar = ref.watch(hogarProvider);
    return Scaffold(
      appBar: widget.enConfiguracion
          ? CabeceraConfiguracion(
              paso: 2,
              titulo: 'Consentimiento',
              escala: MediaQuery.textScalerOf(context),
            )
          : AppBar(title: const Text('Consentimiento')),
      body: hogar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDePantalla(
          error: e,
          alReintentar: () => ref.refresh(hogarProvider.future),
        ),
        data: (h) => _formularioDe(context, h.adultoMayor),
      ),
    );
  }

  Widget _formularioDe(BuildContext context, AdultoMayor adulto) {
    final texto = Theme.of(context).textTheme;
    final nombre = adulto.nombrePila;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        Semantics(
          header: true,
          child: Text('Consentimiento informado', style: texto.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(
          '$nombre o su representante debe aceptarlo antes de activar la '
          'cámara. Sin él, la cámara no envía video.',
          style: texto.bodyMedium,
        ),
        const SizedBox(height: 16),
        const ResumenConsentimiento(),
        const SizedBox(height: 20),
        const EtiquetaCampo('¿Quién otorga el consentimiento?'),
        OpcionRadio(
          valor: _Otorgante.directo,
          seleccion: _otorgante,
          titulo: '${adulto.nombre}, directamente',
          alElegir: (v) => setState(() => _otorgante = v),
        ),
        OpcionRadio(
          valor: _Otorgante.representante,
          seleccion: _otorgante,
          titulo: 'Su representante legal',
          alElegir: (v) => setState(() => _otorgante = v),
        ),
        const SizedBox(height: 8),
        Column(
          key: _formulario,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Casilla(
              marcada: _acepta,
              error: _faltanCasillas && !_acepta,
              texto:
                  '$nombre fue informada y acepta la cámara en su vivienda '
                  'para detectar caídas, y que sus familiares vinculados la '
                  'vean en vivo cuando quieran.',
              alCambiar: (v) => setState(() {
                _acepta = v;
                if (_acepta && _leyo) _faltanCasillas = false;
              }),
            ),
            Casilla(
              marcada: _leyo,
              error: _faltanCasillas && !_leyo,
              texto: 'Leí el resumen y el documento completo.',
              alCambiar: (v) => setState(() {
                _leyo = v;
                if (_acepta && _leyo) _faltanCasillas = false;
              }),
            ),
            if (_faltanCasillas)
              MensajeCampo(
                'Marca las dos casillas. Solo se registra si $nombre lo acepta.',
              ),
          ],
        ),
        Text(
          'Guardamos la fecha y la hora como constancia (Ley N.° 29733). Si '
          '$nombre no acepta, elige «Ahora no»: la cámara queda detenida.',
          style: texto.bodySmall,
        ),
        const SizedBox(height: 16),
        if (_problema != null) ...[
          MensajeProblema(_problema!),
          const SizedBox(height: 16),
        ],
        Boton(
          'Registrar consentimiento',
          cargando: _enviando,
          alPresionar: () => _registrar(adulto),
        ),
        const SizedBox(height: 8),
        Boton('Ahora no', estilo: EstiloBoton.fantasma, alPresionar: _ahoraNo),
      ],
    );
  }
}

/// Summary of the consent (`consentBody`): one fold per section, the live-view clause first, open
/// and with a filled icon, then «Leer el documento completo». Same text as the full document.
class ResumenConsentimiento extends StatelessWidget {
  const ResumenConsentimiento({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListaTarjeta(
        children: [
          for (final (i, s) in seccionesConsentimiento.indexed)
            FilaPlegable(
              icono: s.icono,
              titulo: s.titulo,
              resumen: s.resumen,
              abierta: i == 0,
              destacada: i == 0,
              child: Text(s.texto),
            ),
        ],
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: Enlace(
          'Leer el documento completo',
          alTocar: () => context.push(Rutas.documentoConsentimiento),
        ),
      ),
    ],
  );
}

/// Screen 18: consent recorded, with its certificate (CA-05.1, CA-05.3).
class PantallaConsentimientoRegistrado extends ConsumerWidget {
  const PantallaConsentimientoRegistrado({
    super.key,
    this.enConfiguracion = false,
  });

  final bool enConfiguracion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hogar = ref.watch(hogarProvider);
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: hogar.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorDePantalla(
            error: e,
            alReintentar: () => ref.refresh(hogarProvider.future),
          ),
          data: (h) => ListView(
            padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconoGrande(
                  icono: Ico.shield,
                  fondo: context.colores.calmaSuave,
                  color: context.colores.calmaTinta,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  'Consentimiento registrado',
                  style: texto.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La cámara ya envía video y detectamos caídas. Puedes '
                'revocarlo en Ajustes.',
                style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
              ),
              const SizedBox(height: 20),
              if (h.consentimiento case final c?)
                TarjetaConstancia(consentimiento: c),
              const SizedBox(height: 20),
              if (enConfiguracion)
                Boton(
                  'Continuar con la cámara',
                  alPresionar: () => context.go(Rutas.configCamara),
                )
              else
                Boton(
                  'Volver al inicio',
                  alPresionar: () => _volverAlInicio(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _volverAlInicio(BuildContext context, WidgetRef ref) {
    final camara = ref.read(camarasProvider).value?.firstOrNull;
    context.go(Rutas.inicio);
    if (camara != null) {
      mostrarToast(
        context,
        titulo: 'Cámara activada',
        texto:
            'La cámara ${deHabitacion(camara.nombreHabitacion)} envía video '
            'desde las ${hora(ref.read(relojProvider)())}.',
        icono: Ico.shield,
      );
    }
  }
}
