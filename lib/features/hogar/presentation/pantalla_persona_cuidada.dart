import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../familia/data/familia_repositorio.dart';
import '../data/hogar_repositorio.dart';
import '../domain/hogar.dart';
import 'formulario_adulto_mayor.dart';

/// Screens 95 and 80: the older adult's data in Ajustes. The owner edits it
/// (`PUT /api/hogar/adulto-mayor`); an invited member sees it read-only (CA-08.4). Each account
/// cares for a single person (CA-04.2).
class PantallaPersonaCuidada extends ConsumerWidget {
  const PantallaPersonaCuidada({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hogar = ref.watch(hogarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Persona cuidada')),
      body: hogar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDePantalla(
          error: e,
          alReintentar: () => ref.refresh(hogarProvider.future),
        ),
        data: (h) => _Formulario(hogar: h),
      ),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.hogar});

  final Hogar hogar;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _formulario = FormularioAdultoMayor(widget.hogar.adultoMayor);
  bool _otraPersona = false;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _formulario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.validar()) return setState(() {});
    setState(() {
      _enviando = true;
      _problema = null;
    });
    try {
      await ref
          .read(hogarRepositorioProvider)
          .actualizarAdultoMayor(_formulario.valor);
      ref.invalidate(hogarProvider);
      if (mounted) mostrarToast(context, titulo: 'Cambios guardados');
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'VALIDACION' && e.campos.isNotEmpty) {
          _formulario.erroresDelBackend(e.campos);
        } else {
          _problema = e;
        }
      });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titular = ref.watch(esTitularProvider);
    final nombre = widget.hogar.adultoMayor.nombrePila;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        if (!titular) ...[
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'cambiar los datos de $nombre',
          ),
          const SizedBox(height: 16),
        ],
        if (_problema != null) ...[
          MensajeProblema(_problema!),
          const SizedBox(height: 16),
        ],
        CamposAdultoMayor(
          formulario: _formulario,
          habilitado: titular,
          alCambiar: () => setState(() {}),
        ),
        if (titular) ...[
          Boton('Guardar cambios', cargando: _enviando, alPresionar: _guardar),
          const EncabezadoSeccion('¿Cuidas a otra persona?'),
          if (_otraPersona)
            const AvisoUnaSolaPersona()
          else
            Boton(
              'Agregar otra persona',
              estilo: EstiloBoton.secundario,
              icono: Ico.plus,
              alPresionar: () => setState(() => _otraPersona = true),
            ),
        ],
      ],
    );
  }
}

/// CA-04.2: each account manages a single older adult.
class AvisoUnaSolaPersona extends StatelessWidget {
  const AvisoUnaSolaPersona({super.key});

  @override
  Widget build(BuildContext context) => const Aviso(
    tono: TonoAviso.info,
    icono: Ico.info,
    titulo: 'Cada cuenta cuida a una sola persona',
    texto:
        'Te Tengo no usa reconocimiento facial, así que no puede distinguir '
        'entre dos personas en la misma casa. Para cuidar a alguien más, crea '
        'otra cuenta con un correo distinto.',
  );
}
