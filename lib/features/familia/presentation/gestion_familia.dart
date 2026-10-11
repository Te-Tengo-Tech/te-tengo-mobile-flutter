import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/domain/validacion.dart';
import '../data/familia_repositorio.dart';

/// Screen 66: the owner invites another family member by email (CA-08.1). The prototype also asks
/// for name, relationship and role, which the contract does not take (docs/BLOCKERS.md).
class PantallaInvitar extends ConsumerStatefulWidget {
  const PantallaInvitar({super.key});

  @override
  ConsumerState<PantallaInvitar> createState() => _PantallaInvitarState();
}

class _PantallaInvitarState extends ConsumerState<PantallaInvitar> {
  final _correo = TextEditingController();
  String? _error;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _invitar() async {
    final correo = _correo.text.trim();
    final propio = ref.read(sesionControllerProvider)?.usuario.correo ?? '';
    final familia = ref.read(familiaresProvider).value ?? const [];
    final nombre = ref.read(nombreAdultoMayorProvider) ?? '';
    setState(() {
      _error =
          validarCorreo(correo, vacio: 'Escribe su correo electrónico.') ??
          (correo.toLowerCase() == propio.toLowerCase()
              ? 'Ese es tu propio correo. Invita a otra persona.'
              : familia.any(
                  (f) => f.correo.toLowerCase() == correo.toLowerCase(),
                )
              ? 'Esa persona ya está en la familia de $nombre.'
              : null);
      _problema = null;
    });
    if (_error != null) return;
    setState(() => _enviando = true);
    try {
      final invitacion = await ref
          .read(familiaRepositorioProvider)
          .invitar(correo);
      if (!mounted) return;
      Navigator.of(context).pop();
      mostrarToast(
        context,
        titulo: 'Invitación enviada',
        texto: 'Le enviamos un enlace a ${invitacion.correo}.',
        icono: Ico.send,
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'YA_ES_FAMILIAR' || e.codigo == 'VALIDACION') {
          _error = e.campos['correo'] ?? e.detalle;
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
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Invitar a un familiar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CampoTexto(
            etiqueta: 'Correo electrónico',
            controlador: _correo,
            tipo: TipoCampo.correo,
            error: _error,
            autocompletar: const [AutofillHints.email],
            alEnviar: (_) => _invitar(),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colores.tarjeta,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colores.linea, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Qué podrá hacer', style: texto.titleMedium),
                const SizedBox(height: 8),
                const _Punto(
                  Ico.check,
                  Colores.calma,
                  'Ver alertas, historial y la cámara en vivo',
                ),
                const _Punto(
                  Ico.check,
                  Colores.calma,
                  'Marcar alertas y pausar la cámara',
                ),
                _Punto(
                  Ico.lock,
                  context.colores.tinta3,
                  'No cambia datos, consentimiento, cámaras ni familia',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Boton(
            'Enviar invitación',
            icono: Ico.send,
            cargando: _enviando,
            alPresionar: _invitar,
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto(this.icono, this.color, this.texto);

  final Ico icono;
  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icono(icono, tamano: 20, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: estiloTexto(16, 400, color: context.colores.tinta),
          ),
        ),
      ],
    ),
  );
}
