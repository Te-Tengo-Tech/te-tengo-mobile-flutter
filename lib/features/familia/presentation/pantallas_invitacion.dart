import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/marca.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/domain/validacion.dart';
import '../data/familia_repositorio.dart';

/// Screen 68: the invitation link (`/invitacion/{token}`) creates the access of the invited member
/// (CA-08.2). The contract has no endpoint to read an invitation, so the names and the email come
/// from the link when it carries them (`?titular=…&adultoMayor=…&correo=…`, docs/BLOCKERS.md).
class PantallaAceptarInvitacion extends ConsumerStatefulWidget {
  const PantallaAceptarInvitacion({
    super.key,
    required this.token,
    this.titular,
    this.adultoMayor,
    this.correo,
  });

  final String token;
  final String? titular;
  final String? adultoMayor;
  final String? correo;

  @override
  ConsumerState<PantallaAceptarInvitacion> createState() =>
      _PantallaAceptarInvitacionState();
}

class _PantallaAceptarInvitacionState
    extends ConsumerState<PantallaAceptarInvitacion> {
  final _nombre = TextEditingController();
  final _clave = TextEditingController();
  late final _correo = TextEditingController(text: widget.correo);
  var _errores = <String, String>{};
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _clave.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _crear({required bool conCuenta}) async {
    final nombre = _nombre.text.trim();
    final clave = _clave.text;
    final l = context.l10n;
    setState(() {
      _errores = conCuenta
          ? {}
          : {
              if (nombre.isEmpty) 'nombre': l.sesionErrorNombre,
              'clave': ?validarContrasenaNueva(l, clave),
            };
      _problema = null;
    });
    if (_errores.isNotEmpty) return;
    setState(() => _enviando = true);
    try {
      final sesion = await ref
          .read(familiaRepositorioProvider)
          .aceptarInvitacion(
            widget.token,
            nombre: conCuenta ? null : nombre,
            contrasena: conCuenta ? null : clave,
          );
      await ref.read(sesionControllerProvider.notifier).iniciar(sesion);
      if (mounted) context.go(Rutas.accesoCreado);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.codigo == 'VALIDACION' && e.campos.isNotEmpty) {
          _errores = {
            'nombre': ?e.campos['nombre'],
            'clave': ?e.campos['contrasena'],
          };
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
    // A signed-in user joins with the account they already have.
    final conCuenta = ref.watch(sesionControllerProvider) != null;
    final titular = widget.titular;
    final adulto = widget.adultoMayor;
    final correo = widget.correo;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              const Align(alignment: Alignment.centerLeft, child: Logotipo()),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  titular != null && adulto != null
                      ? l.invitarTeInvito(titular, adulto.split(' ').first)
                      : l.invitarCrearAcceso,
                  style: texto.headlineMedium,
                ),
              ),
              if (adulto != null) ...[
                const SizedBox(height: 8),
                Text(
                  l.invitarCreaTuAcceso,
                  style: texto.bodyLarge?.copyWith(
                    color: context.colores.tinta2,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (_problema != null) ...[
                MensajeProblema(_problema!),
                const SizedBox(height: 16),
              ],
              if (!conCuenta) ...[
                CampoTexto(
                  etiqueta: l.sesionCampoNombre,
                  controlador: _nombre,
                  error: _errores['nombre'],
                  autocompletar: const [AutofillHints.name],
                  accionTeclado: TextInputAction.next,
                ),
                if (correo != null)
                  CampoTexto(
                    etiqueta: l.sesionCampoCorreo,
                    controlador: _correo,
                    tipo: TipoCampo.correo,
                    habilitado: false,
                  ),
                CampoTexto(
                  etiqueta: l.invitarCampoClave,
                  controlador: _clave,
                  tipo: TipoCampo.contrasena,
                  error: _errores['clave'],
                  ayuda: l.sesionAyudaContrasena,
                  autocompletar: const [AutofillHints.newPassword],
                  alEnviar: (_) => _crear(conCuenta: false),
                ),
              ],
              Boton(
                l.invitarCrearAcceso,
                cargando: _enviando,
                alPresionar: () => _crear(conCuenta: conCuenta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 69: the invited member's access is ready and the alerts are on.
class PantallaAccesoCreado extends ConsumerWidget {
  const PantallaAccesoCreado({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final yo = ref.watch(sesionControllerProvider)?.usuario.nombrePila ?? '';
    final adulto = ref.watch(nombreAdultoMayorProvider) ?? '';
    final titular = ref.watch(nombreTitularProvider) ?? '';
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 34),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconoGrande(
                        icono: Ico.bell,
                        fondo: context.colores.calmaSuave,
                        color: context.colores.calmaTinta,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        l.invitarListo(yo, adulto),
                        style: texto.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListaTarjeta(
                      children: [
                        FilaLista(
                          inicio: const IconoFila(Ico.check),
                          titulo: l.invitarPuedes,
                          subtitulo: l.invitarPuedesDetalle,
                        ),
                        FilaLista(
                          inicio: const IconoFila(Ico.lock),
                          titulo: l.invitarSoloPuede(titular),
                          subtitulo: l.invitarSoloPuedeDetalle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Boton(
                l.invitarIrInicio,
                alPresionar: () => context.go(Rutas.inicio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
