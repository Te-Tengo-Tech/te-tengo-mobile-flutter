import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/domain/validacion.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';
import 'fila_miembro.dart';

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
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Invitar a un familiar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            'Le enviaremos un enlace para crear su acceso.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
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
                  'Ver alertas, clips, historial y la cámara en vivo (con '
                  'registro)',
                ),
                const _Punto(
                  Ico.check,
                  Colores.calma,
                  'Marcar alertas y pausar la cámara',
                ),
                _Punto(
                  Ico.lock,
                  context.colores.tinta3,
                  'No podrá cambiar los datos de $nombre, el consentimiento, la '
                  'cámara ni la familia',
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

/// Screen 70: options of a member for the owner (change the alert order, remove access).
Future<void> opcionesMiembro(
  BuildContext context,
  MiembroFamilia miembro, {
  required int indice,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _HojaMiembro(miembro: miembro, indice: indice),
);

class _HojaMiembro extends ConsumerWidget {
  const _HojaMiembro({required this.miembro, required this.indice});

  final MiembroFamilia miembro;
  final int indice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = miembro.familiar;
    final yo = ref.watch(sesionControllerProvider)?.usuario.id == f.usuarioId;
    final espera =
        ref.watch(avisoProvider).value?.esperaMinutos ??
        ConfiguracionAviso.esperaPredeterminada;
    final texto = Theme.of(context).textTheme;
    final opciones = [
      if (miembro.papel != PapelAviso.principal)
        FilaLista(
          inicio: const IconoFila(Ico.swap),
          titulo: 'Hacer contacto principal',
          subtitulo: 'Recibirá cada alerta primero',
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.principal),
        ),
      // The family always keeps a principal contact: it changes by choosing another one.
      if (miembro.papel == PapelAviso.familiar)
        FilaLista(
          inicio: const IconoFila(Ico.users),
          titulo: 'Hacer contacto secundario',
          subtitulo: 'Recibe la alerta si nadie atiende en $espera min',
          chevron: false,
          alTocar: () => _cambiarPapel(context, ref, PapelAviso.secundario),
        ),
      if (!yo && miembro.papel != PapelAviso.principal)
        FilaLista(
          inicio: const IconoFila(Ico.trash, peligro: true),
          titulo: 'Retirar acceso',
          peligro: true,
          chevron: false,
          alTocar: () => _retirar(context, ref),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Avatar(Avatar.inicialesDe(f.nombre), tono: tonoDe(indice)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(f.nombre, style: texto.titleLarge),
                      ),
                      Text(f.correo, style: texto.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (yo || miembro.papel == PapelAviso.principal) ...[
              Aviso(
                tono: TonoAviso.neutral,
                icono: Ico.info,
                texto: yo
                    ? 'Eres titular: solo tú invitas, retiras accesos y cambias '
                          'el orden de aviso. Para dejar de ser principal, elige '
                          'a otra persona.'
                    : 'Para retirar su acceso, primero elige a otro contacto '
                          'principal.',
              ),
              const SizedBox(height: 12),
            ],
            if (opciones.isNotEmpty) ListaTarjeta(children: opciones),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarPapel(
    BuildContext context,
    WidgetRef ref,
    PapelAviso papel,
  ) async {
    final f = miembro.familiar;
    final actual = await ref.read(avisoProvider.future);
    final nuevo = papel == PapelAviso.principal
        // The old principal takes the place the new one leaves (secondary or none).
        ? ConfiguracionAviso(
            principalId: f.usuarioId,
            secundarioId: actual.secundarioId == f.usuarioId
                ? actual.principalId
                : actual.secundarioId,
            esperaMinutos: actual.esperaMinutos,
          )
        : actual.con(secundarioId: f.usuarioId);
    try {
      await ref.read(familiaRepositorioProvider).guardarAviso(nuevo);
      ref.invalidate(avisoProvider);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      mostrarToast(
        context,
        titulo:
            '${f.nombrePila} ahora es contacto '
            '${papel == PapelAviso.principal ? 'principal' : 'secundario'}',
        texto: 'El orden de aviso se actualizó.',
        icono: Ico.users,
      );
    } on ProblemaApi catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  Future<void> _retirar(BuildContext context, WidgetRef ref) async {
    final f = miembro.familiar;
    final secundario = miembro.papel == PapelAviso.secundario;
    final nombre = ref.read(nombreAdultoMayorProvider) ?? '';
    final si = await confirmar(
      context,
      icono: Ico.trash,
      titulo: '¿Retirar el acceso de ${f.nombre}?',
      texto:
          'Dejará de recibir las alertas de $nombre y no podrá ver el historial '
          'ni los clips.${secundario ? ' Te quedarás sin contacto secundario.' : ''}',
      aceptar: 'Retirar acceso',
      cancelar: 'Cancelar',
      peligro: true,
    );
    if (!si || !context.mounted) return;
    try {
      await ref.read(familiaRepositorioProvider).retirar(f.usuarioId);
      ref
        ..invalidate(familiaresProvider)
        ..invalidate(avisoProvider);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      mostrarToast(
        context,
        titulo: '${f.nombrePila} ya no recibe alertas',
        texto: secundario ? 'Te quedaste sin contacto secundario.' : null,
      );
    } on ProblemaApi catch (e) {
      if (context.mounted) _error(context, e);
    }
  }

  void _error(BuildContext context, ProblemaApi e) => mostrarToast(
    context,
    titulo: e.detalle,
    icono: Ico.warn,
    tono: TonoAviso.advertencia,
  );
}
