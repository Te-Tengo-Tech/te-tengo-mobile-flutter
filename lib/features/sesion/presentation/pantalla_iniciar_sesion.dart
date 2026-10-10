import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/marca.dart';
import '../../../core/ui/piezas.dart';
import '../data/cuentas_repositorio.dart';

/// Notice shown when the sign-in screen opens (`?aviso=`).
enum AvisoInicioSesion {
  /// After signing out (CA-02.4).
  sesionCerrada('cerrada'),

  /// After a password reset (US-03).
  claveActualizada('clave');

  const AvisoInicioSesion(this.codigo);

  final String codigo;

  static AvisoInicioSesion? desde(String? valor) =>
      values.where((a) => a.codigo == valor).firstOrNull;
}

/// US-02, screens 06–08: sign in. Wrong credentials are denied with a message (CA-02.2); after 5
/// failures the account is locked for 15 minutes and the unlock time is shown (CA-02.3).
class PantallaIniciarSesion extends ConsumerStatefulWidget {
  const PantallaIniciarSesion({super.key, this.correo, this.aviso});

  /// Email to prefill (after signing out or from the register screen).
  final String? correo;

  /// Notice shown on arrival.
  final AvisoInicioSesion? aviso;

  /// Failures after which the backend locks the account (CA-02.3).
  static const intentosAntesDelBloqueo = 5;

  @override
  ConsumerState<PantallaIniciarSesion> createState() =>
      _PantallaIniciarSesionState();
}

class _PantallaIniciarSesionState extends ConsumerState<PantallaIniciarSesion> {
  late final _correo = TextEditingController(text: widget.correo);
  final _clave = TextEditingController();
  Map<String, String> _errores = {};
  bool _faltanDatos = false;
  bool _incorrectos = false;
  int _fallos = 0;
  DateTime? _bloqueadaHasta;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final aviso = widget.aviso;
    if (aviso == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (aviso) {
        case AvisoInicioSesion.sesionCerrada:
          mostrarToast(
            context,
            titulo: 'Sesión cerrada',
            texto: 'Inicia sesión para volver a recibir alertas.',
            icono: Ico.logout,
            tono: TonoAviso.neutral,
          );
        case AvisoInicioSesion.claveActualizada:
          mostrarToast(
            context,
            titulo: 'Contraseña actualizada',
            texto: 'Ya puedes iniciar sesión con ella.',
          );
      }
    });
  }

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final correo = _correo.text.trim();
    final clave = _clave.text;
    setState(() {
      _faltanDatos = correo.isEmpty || clave.isEmpty;
      _errores = {
        if (correo.isEmpty) 'correo': 'Escribe tu correo.',
        if (clave.isEmpty) 'contrasena': 'Escribe tu contraseña.',
      };
      _incorrectos = false;
      _problema = null;
    });
    if (_faltanDatos) return;
    setState(() => _enviando = true);
    try {
      final sesion = await ref
          .read(cuentasRepositorioProvider)
          .iniciarSesion(correo: correo, contrasena: clave);
      // CA-02.1: the router guards open the app (or the setup if there is no household yet).
      await ref.read(sesionControllerProvider.notifier).iniciar(sesion);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'CREDENCIALES_INVALIDAS':
            _fallos++;
            _incorrectos = true;
          case 'CUENTA_BLOQUEADA':
            _bloqueadaHasta =
                fechaDesdeJson(e.extras['bloqueadaHasta']) ??
                DateTime.now().add(const Duration(minutes: 15));
          case 'VALIDACION':
            _errores = e.campos;
            if (e.campos.isEmpty) _problema = e;
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
    final bloqueada = _bloqueadaHasta != null;
    final restantes = PantallaIniciarSesion.intentosAntesDelBloqueo - _fallos;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            const Align(alignment: Alignment.centerLeft, child: Logotipo()),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text('Inicia sesión', style: texto.headlineMedium),
            ),
            const SizedBox(height: 16),
            if (bloqueada) ...[
              Aviso(
                tono: TonoAviso.error,
                icono: Ico.lock,
                titulo: 'Bloqueado por 15 minutos',
                contenido: conHora(
                  '5 intentos fallidos. Vuelve a intentarlo a las ',
                  hora(_bloqueadaHasta!),
                  '.',
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_incorrectos) ...[
              Aviso(
                tono: TonoAviso.error,
                icono: Ico.warn,
                titulo: 'Correo o contraseña incorrectos',
                texto: _fallos >= 3 && restantes > 0
                    ? 'Te queda${restantes == 1 ? '' : 'n'} $restantes '
                          'intento${restantes == 1 ? '' : 's'} antes de un '
                          'bloqueo de 15 min.'
                    : 'Revisa cómo los escribiste.',
              ),
              const SizedBox(height: 16),
            ],
            if (_faltanDatos) ...[
              const Aviso(
                tono: TonoAviso.error,
                icono: Ico.warn,
                titulo: 'Escribe tu correo y tu contraseña',
              ),
              const SizedBox(height: 16),
            ],
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 16),
            ],
            AutofillGroup(
              child: Column(
                children: [
                  CampoTexto(
                    etiqueta: 'Correo electrónico',
                    controlador: _correo,
                    tipo: TipoCampo.correo,
                    error: _errores['correo'],
                    habilitado: !bloqueada,
                    autocompletar: const [AutofillHints.email],
                    accionTeclado: TextInputAction.next,
                  ),
                  CampoTexto(
                    etiqueta: 'Contraseña',
                    controlador: _clave,
                    tipo: TipoCampo.contrasena,
                    error: _errores['contrasena'],
                    habilitado: !bloqueada,
                    autocompletar: const [AutofillHints.password],
                    alEnviar: (_) => _entrar(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Enlace(
                '¿Olvidaste tu contraseña?',
                alTocar: () => context.push(_rutaRecuperar),
              ),
            ),
            const SizedBox(height: 12),
            if (bloqueada)
              Boton(
                'Recuperar contraseña',
                estilo: EstiloBoton.secundario,
                alPresionar: () => context.push(_rutaRecuperar),
              )
            else
              Boton(
                'Iniciar sesión',
                cargando: _enviando,
                alPresionar: _entrar,
              ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('¿Aún no tienes cuenta?', style: texto.bodyMedium),
                Enlace('Crea una', alTocar: () => context.push(Rutas.registro)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _rutaRecuperar {
    final correo = _correo.text.trim();
    return correo.isEmpty
        ? Rutas.recuperar
        : '${Rutas.recuperar}?correo=${Uri.encodeQueryComponent(correo)}';
  }
}
