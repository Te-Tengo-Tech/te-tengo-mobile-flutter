import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../../l10n/l10n.dart';
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

  /// Step 2 of 2 of the setup, then «Todo listo»; otherwise opened from Inicio or Ajustes.
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
            // The record stored by the backend: always this Spanish text, whatever the
            // phone's language (only the screens are translated).
            otorgadoPor: _otorgante == _Otorgante.directo
                ? adulto.nombre
                : 'Representante legal de ${adulto.nombre}',
          );
      ref
        ..invalidate(hogarProvider)
        ..invalidate(camarasProvider);
      if (!mounted) return;
      if (widget.enConfiguracion) {
        // «Todo listo» shows the certificate and asks for the notifications.
        context.go(Rutas.configListo);
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

  /// Consent is freely given: it can be left for later from Inicio (CA-05.2 then stops detection).
  void _ahoraNo() {
    if (widget.enConfiguracion) {
      context.go(Rutas.configListo);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hogar = ref.watch(hogarProvider);
    final titulo = context.l10n.consentimientoTitulo;
    return Scaffold(
      appBar: widget.enConfiguracion
          ? CabeceraConfiguracion(
              paso: 2,
              titulo: titulo,
              escala: MediaQuery.textScalerOf(context),
            )
          : AppBar(title: Text(titulo)),
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
    final l = context.l10n;
    final nombre = adulto.nombrePila;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        Text(l.consentimientoIntro(nombre), style: texto.bodyMedium),
        const SizedBox(height: 16),
        const ResumenConsentimiento(),
        const SizedBox(height: 20),
        EtiquetaCampo(l.consentimientoQuienOtorga),
        OpcionRadio(
          valor: _Otorgante.directo,
          seleccion: _otorgante,
          titulo: l.consentimientoDirectamente(adulto.nombre),
          alElegir: (v) => setState(() => _otorgante = v),
        ),
        OpcionRadio(
          valor: _Otorgante.representante,
          seleccion: _otorgante,
          titulo: l.consentimientoRepresentante,
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
              texto: l.consentimientoCasillaAcepta(nombre),
              alCambiar: (v) => setState(() {
                _acepta = v;
                if (_acepta && _leyo) _faltanCasillas = false;
              }),
            ),
            Casilla(
              marcada: _leyo,
              error: _faltanCasillas && !_leyo,
              texto: l.consentimientoCasillaLeyo,
              alCambiar: (v) => setState(() {
                _leyo = v;
                if (_acepta && _leyo) _faltanCasillas = false;
              }),
            ),
            if (_faltanCasillas) MensajeCampo(l.consentimientoFaltanCasillas),
          ],
        ),
        Text(l.consentimientoGuardamosFecha, style: texto.bodySmall),
        const SizedBox(height: 16),
        if (_problema != null) ...[
          MensajeProblema(_problema!),
          const SizedBox(height: 16),
        ],
        Boton(
          l.consentimientoRegistrar,
          cargando: _enviando,
          alPresionar: () => _registrar(adulto),
        ),
        const SizedBox(height: 8),
        Boton(
          l.consentimientoAhoraNo,
          estilo: EstiloBoton.fantasma,
          alPresionar: _ahoraNo,
        ),
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
          for (final (i, s) in seccionesConsentimiento(context.l10n).indexed)
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
          context.l10n.consentimientoLeerDocumento,
          alTocar: () => context.push(Rutas.documentoConsentimiento),
        ),
      ),
    ],
  );
}

/// Screen 18: consent recorded, with its certificate (CA-05.1, CA-05.3), when registered from
/// Inicio or Ajustes; in setup, «Todo listo» shows the same certificate.
class PantallaConsentimientoRegistrado extends ConsumerWidget {
  const PantallaConsentimientoRegistrado({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hogar = ref.watch(hogarProvider);
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
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
                  l.consentimientoRegistradoTitulo,
                  style: texto.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                // Screen 21: with no camera chosen yet, detection starts once the PC is linked.
                (ref.watch(camarasProvider).value ?? const []).isNotEmpty
                    ? l.consentimientoCamarasDetectan
                    : l.consentimientoDetectaranAlVincular,
                style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
              ),
              const SizedBox(height: 20),
              if (h.consentimiento case final c?)
                TarjetaConstancia(consentimiento: c),
              const SizedBox(height: 20),
              Boton(
                l.consentimientoVolverInicio,
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
    final l = context.l10n;
    final formato = context.formato;
    context.go(Rutas.inicio);
    if (camara != null) {
      mostrarToast(
        context,
        titulo: l.consentimientoCamaraActivada,
        texto: l.consentimientoCamaraDetectaDesde(
          deHabitacion(camara.nombreHabitacion),
          camara.nombreHabitacion,
          formato.hora(ref.read(relojProvider)()),
        ),
        icono: Ico.shield,
      );
    }
  }
}
