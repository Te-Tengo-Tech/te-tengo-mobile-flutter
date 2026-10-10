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
    setState(() {
      _errores = conCuenta
          ? {}
          : {
              if (nombre.isEmpty) 'nombre': 'Escribe tu nombre y apellido.',
              'clave': ?validarContrasenaNueva(clave),
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
                      ? '$titular te invitó a cuidar a ${adulto.split(' ').first}'
                      : 'Crear mi acceso',
                  style: texto.headlineMedium,
                ),
              ),
              if (adulto != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Crea tu acceso para recibir las alertas de $adulto en este '
                  'celular.',
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
                  etiqueta: 'Tu nombre y apellido',
                  controlador: _nombre,
                  error: _errores['nombre'],
                  autocompletar: const [AutofillHints.name],
                  accionTeclado: TextInputAction.next,
                ),
                if (correo != null)
                  CampoTexto(
                    etiqueta: 'Correo electrónico',
                    controlador: _correo,
                    tipo: TipoCampo.correo,
                    habilitado: false,
                    ayuda: 'Es el correo al que llegó la invitación.',
                  ),
                CampoTexto(
                  etiqueta: 'Crea una contraseña',
                  controlador: _clave,
                  tipo: TipoCampo.contrasena,
                  error: _errores['clave'],
                  ayuda: ayudaContrasena,
                  autocompletar: const [AutofillHints.newPassword],
                  alEnviar: (_) => _crear(conCuenta: false),
                ),
              ],
              Boton(
                'Crear mi acceso',
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
                        'Listo, $yo. Ya recibes las alertas de $adulto.',
                        style: texto.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Te llegarán aunque tengas la app cerrada.',
                      style: texto.bodyLarge?.copyWith(
                        color: context.colores.tinta2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListaTarjeta(
                      children: [
                        const FilaLista(
                          inicio: IconoFila(Ico.check),
                          titulo: 'Puedes',
                          subtitulo:
                              'Ver alertas, clips, historial y la cámara en '
                              'vivo. Marcar alertas y pausar la cámara.',
                        ),
                        FilaLista(
                          inicio: const IconoFila(Ico.lock),
                          titulo: 'Solo $titular puede',
                          subtitulo:
                              'Cambiar los datos de $adulto, el consentimiento, '
                              'la cámara y la familia.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Boton(
                'Ir al inicio',
                alPresionar: () => context.go(Rutas.inicio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
