import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../data/hogar_repositorio.dart';
import 'formulario_adulto_mayor.dart';
import 'pantalla_persona_cuidada.dart' show AvisoUnaSolaPersona;

/// US-04, screens 14 and 15 (setup step 1 of 2): register the older adult. The household is created
/// with `POST /api/hogar` and its session is stored (CA-04.1); empty fields are highlighted (CA-04.3).
class PantallaPersonaSetup extends ConsumerStatefulWidget {
  const PantallaPersonaSetup({super.key});

  @override
  ConsumerState<PantallaPersonaSetup> createState() =>
      _PantallaPersonaSetupState();
}

class _PantallaPersonaSetupState extends ConsumerState<PantallaPersonaSetup> {
  final _formulario = FormularioAdultoMayor();
  bool _faltanDatos = false;
  bool _yaRegistrado = false;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _formulario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final completo = _formulario.validar(context.l10n);
    setState(() {
      _faltanDatos = !completo;
      _yaRegistrado = false;
      _problema = null;
    });
    if (!completo) return;
    setState(() => _enviando = true);
    try {
      final sesion = await ref
          .read(hogarRepositorioProvider)
          .crear(_formulario.valor);
      await ref.read(sesionControllerProvider.notifier).iniciar(sesion);
      if (mounted) context.go(Rutas.configConsentimiento);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'HOGAR_YA_REGISTRADO':
            _yaRegistrado = true;
          case 'VALIDACION' when e.campos.isNotEmpty:
            _formulario.erroresDelBackend(e.campos);
            _faltanDatos = true;
          default:
            _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    return Scaffold(
      appBar: CabeceraConfiguracion(
        paso: 1,
        titulo: l.hogarPersonaCuidadaTitulo,
        escala: MediaQuery.textScalerOf(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Semantics(
            header: true,
            child: Text(l.hogarAQuienCuidar, style: texto.titleLarge),
          ),
          const SizedBox(height: 16),
          if (_faltanDatos) ...[
            Aviso(
              tono: TonoAviso.error,
              icono: Ico.warn,
              titulo: l.hogarCompletaCampos,
            ),
            const SizedBox(height: 16),
          ],
          if (_yaRegistrado) ...[
            const AvisoUnaSolaPersona(),
            const SizedBox(height: 16),
          ],
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CamposAdultoMayor(
            formulario: _formulario,
            alCambiar: () => setState(() {}),
          ),
          Boton(
            l.hogarGuardarYContinuar,
            cargando: _enviando,
            alPresionar: _guardar,
          ),
        ],
      ),
    );
  }
}
