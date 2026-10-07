import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../data/hogar_repositorio.dart';
import '../domain/hogar.dart';
import 'constancia.dart';

/// Who grants the consent.
enum _Otorgante { directo, representante }

/// US-05, screens 16 and 17: informed consent. It states that linked family members can watch the
/// camera live at any time, and it is recorded only if both boxes are checked (CA-05.4).
class PantallaConsentimiento extends ConsumerStatefulWidget {
  const PantallaConsentimiento({super.key, this.enConfiguracion = false});

  /// Step 2 of 4 of the setup; otherwise opened from Inicio or Ajustes.
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
          ? const CabeceraConfiguracion(paso: 2, titulo: 'Consentimiento')
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
          'Antes de activar la cámara de su casa, $nombre o su representante '
          'debe aceptar cómo usaremos sus datos. Si no lo acepta, no lo '
          'registres: la cámara no enviará video.',
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
                  '$nombre fue informada y acepta el uso de la cámara en su '
                  'vivienda para detectar caídas, y que sus familiares '
                  'vinculados la vean en vivo en cualquier momento.',
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
                'Marca las dos casillas para registrar el consentimiento. Solo '
                'se registra si $nombre lo acepta.',
              ),
          ],
        ),
        Text(
          'Guardaremos la fecha y la hora en que lo registres, como constancia '
          'según la Ley N.° 29733. Si $nombre no acepta, elige «Ahora no»: la '
          'cámara quedará instalada, pero detenida.',
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

/// Summary of the consent (`consentBody`), with the live-view clause highlighted in soft purple.
class ResumenConsentimiento extends StatelessWidget {
  const ResumenConsentimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    Widget seccion(String titulo, String cuerpo) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: estiloTexto(16, 700)),
          const SizedBox(height: 2),
          Text(cuerpo, style: texto.bodyMedium),
        ],
      ),
    );
    return TarjetaBanda(
      banda: Banda.morado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          seccion(
            'Qué hacemos',
            'La cámara instalada en su vivienda envía video a Te Tengo, donde '
                'analizamos la postura del cuerpo para detectar caídas y '
                'movimientos inestables.',
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colores.moradoSuave,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCD3EE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icono(
                      Ico.eye,
                      tamano: 20,
                      color: Colores.moradoTinta,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vista en vivo en cualquier momento',
                        style: estiloTexto(16, 700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Los familiares vinculados a esta cuenta pueden ver la cámara '
                  'en vivo cuando quieran, no solo durante una alerta. Cada '
                  'acceso queda registrado: quién la vio, cuándo y cuánto tiempo.',
                  style: texto.bodyMedium,
                ),
              ],
            ),
          ),
          seccion(
            'Qué no hacemos',
            'No reconocemos rostros ni grabamos de forma continua. La vista en '
                'vivo no se guarda.',
          ),
          const Divider(),
          seccion(
            'Qué guardamos y cuánto',
            'Solo el clip de cada alerta, durante 30 días. Luego se elimina.',
          ),
          const Divider(),
          seccion(
            'Sus derechos',
            'Según la Ley N.° 29733 de Protección de Datos Personales, puede '
                'acceder a sus datos, corregirlos, pedir su eliminación u '
                'oponerse a su uso, y revocar este consentimiento cuando quiera.',
          ),
        ],
      ),
    );
  }
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
              const Align(
                alignment: Alignment.centerLeft,
                child: IconoGrande(
                  icono: Ico.shield,
                  fondo: Colores.calmaSuave,
                  color: Colores.calmaTinta,
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
                'La cámara de la casa empezó a enviar video: desde ahora '
                'detectamos caídas. Puedes revisarlo o revocarlo cuando '
                'quieras en Ajustes.',
                style: texto.bodyLarge?.copyWith(color: Colores.tinta2),
              ),
              const SizedBox(height: 20),
              if (h.consentimiento case final c?)
                TarjetaConstancia(
                  consentimiento: c,
                  nombreAdultoMayor: h.adultoMayor.nombrePila,
                ),
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
