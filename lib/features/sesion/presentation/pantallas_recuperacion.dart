import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../data/cuentas_repositorio.dart';
import '../domain/validacion.dart';
import 'pantalla_iniciar_sesion.dart';

/// US-03, screen 09: ask for a reset link.
class PantallaRecuperar extends ConsumerStatefulWidget {
  const PantallaRecuperar({super.key, this.correo});

  final String? correo;

  @override
  ConsumerState<PantallaRecuperar> createState() => _PantallaRecuperarState();
}

class _PantallaRecuperarState extends ConsumerState<PantallaRecuperar> {
  late final _correo = TextEditingController(text: widget.correo);
  String? _error;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correo = _correo.text.trim();
    setState(() {
      _error = validarCorreo(correo);
      _problema = null;
    });
    if (_error != null) return;
    setState(() => _enviando = true);
    try {
      await ref.read(cuentasRepositorioProvider).solicitarRecuperacion(correo);
      if (!mounted) return;
      context.pushReplacement(
        Uri(
          path: Rutas.enlaceEnviado,
          queryParameters: {'correo': correo},
        ).toString(),
      );
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _problema = e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            'Te enviaremos un enlace para crear una nueva.',
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
            alEnviar: (_) => _enviar(),
          ),
          Boton('Enviar enlace', cargando: _enviando, alPresionar: _enviar),
        ],
      ),
    );
  }
}

/// Screen 10: the same message whether or not the account exists (CA-03.1, CA-03.2).
class PantallaEnlaceEnviado extends ConsumerStatefulWidget {
  const PantallaEnlaceEnviado({super.key, required this.correo});

  final String correo;

  /// Wait before the link can be sent again.
  static const espera = Duration(seconds: 45);

  @override
  ConsumerState<PantallaEnlaceEnviado> createState() =>
      _PantallaEnlaceEnviadoState();
}

class _PantallaEnlaceEnviadoState extends ConsumerState<PantallaEnlaceEnviado> {
  Timer? _reloj;
  late int _restante;

  @override
  void initState() {
    super.initState();
    _iniciarEspera();
  }

  void _iniciarEspera() {
    _restante = PantallaEnlaceEnviado.espera.inSeconds;
    _reloj?.cancel();
    _reloj = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _restante--);
      if (_restante <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Future<void> _reenviar() async {
    setState(_iniciarEspera);
    try {
      await ref
          .read(cuentasRepositorioProvider)
          .solicitarRecuperacion(widget.correo);
    } on ProblemaApi catch (e) {
      if (mounted) mostrarToast(context, titulo: e.detalle, icono: Ico.warn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cuerpo = texto.bodyLarge!.copyWith(color: Colores.tinta2);
    final espera =
        '${_restante ~/ 60}:${(_restante % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.mail,
              fondo: Colores.moradoSuave,
              color: Colores.moradoTinta,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text('Revisa tu correo', style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Si '),
                TextSpan(
                  text: widget.correo,
                  style: cuerpo.copyWith(
                    color: Colores.tinta,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text:
                      ' tiene cuenta, te llegará un enlace. Vence en 30 minutos.',
                ),
              ],
            ),
            style: cuerpo,
          ),
          const SizedBox(height: 12),
          Text('¿No llega? Revisa la carpeta de spam.', style: texto.bodySmall),
          const SizedBox(height: 24),
          Boton(
            'Volver a iniciar sesión',
            alPresionar: () => context.go(
              Uri(
                path: Rutas.iniciarSesion,
                queryParameters: {'correo': widget.correo},
              ).toString(),
            ),
          ),
          const SizedBox(height: 12),
          if (_restante > 0)
            Semantics(
              enabled: false,
              button: true,
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Reenviar enlace en '),
                        TextSpan(text: espera, style: estiloMono(tamano: 18)),
                      ],
                    ),
                    style: estiloTexto(18, 700, color: Colores.tinta3),
                  ),
                ),
              ),
            )
          else
            Boton(
              'Reenviar enlace',
              estilo: EstiloBoton.fantasma,
              alPresionar: _reenviar,
            ),
        ],
      ),
    );
  }
}

/// Screen 12, opened from the email link: set a new password. An expired link goes to screen 11
/// (CA-03.3).
class PantallaNuevaContrasena extends ConsumerStatefulWidget {
  const PantallaNuevaContrasena({super.key, required this.token, this.correo});

  final String token;

  /// Account of the link, when the link carries it.
  final String? correo;

  @override
  ConsumerState<PantallaNuevaContrasena> createState() =>
      _PantallaNuevaContrasenaState();
}

class _PantallaNuevaContrasenaState
    extends ConsumerState<PantallaNuevaContrasena> {
  final _clave = TextEditingController();
  final _repetida = TextEditingController();
  String? _error;
  String? _errorRepetida;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _clave.dispose();
    _repetida.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final clave = _clave.text;
    setState(() {
      _error = validarContrasenaNueva(clave, vacio: null);
      _errorRepetida = _error == null && clave != _repetida.text
          ? 'Las contraseñas no coinciden.'
          : null;
      _problema = null;
    });
    if (_error != null || _errorRepetida != null) return;
    setState(() => _enviando = true);
    try {
      await ref
          .read(cuentasRepositorioProvider)
          .confirmarRecuperacion(token: widget.token, nuevaContrasena: clave);
      if (!mounted) return;
      context.go(
        Uri(
          path: Rutas.iniciarSesion,
          queryParameters: {
            'correo': ?widget.correo,
            'aviso': AvisoInicioSesion.claveActualizada.codigo,
          },
        ).toString(),
      );
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 'ENLACE_VENCIDO') {
        context.go(Rutas.enlaceVencido);
      } else if (e.codigo == 'VALIDACION' && e.campos.isNotEmpty) {
        setState(() => _error = e.campos.values.first);
      } else {
        setState(() => _problema = e);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _barraCerrar(context, 'Nueva contraseña'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (widget.correo != null) ...[
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Para la cuenta '),
                  TextSpan(
                    text: widget.correo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CampoTexto(
            etiqueta: 'Nueva contraseña',
            controlador: _clave,
            tipo: TipoCampo.contrasena,
            error: _error,
            ayuda: ayudaContrasena,
            autocompletar: const [AutofillHints.newPassword],
          ),
          CampoTexto(
            etiqueta: 'Repite la contraseña',
            controlador: _repetida,
            tipo: TipoCampo.contrasena,
            error: _errorRepetida,
            autocompletar: const [AutofillHints.newPassword],
            alEnviar: (_) => _guardar(),
          ),
          Boton(
            'Guardar contraseña',
            cargando: _enviando,
            alPresionar: _guardar,
          ),
        ],
      ),
    );
  }
}

/// Screen 11: the reset link expired; a new one can be requested (CA-03.3).
class PantallaEnlaceVencido extends StatelessWidget {
  const PantallaEnlaceVencido({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: _barraCerrar(context, 'Nueva contraseña'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.clock,
              fondo: Colores.avisoSuave,
              color: Colores.aviso,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text('Este enlace ya venció', style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text(
            'Duran 30 minutos y sirven una sola vez. Pide uno nuevo.',
            style: texto.bodyLarge?.copyWith(color: Colores.tinta2),
          ),
          const SizedBox(height: 24),
          Boton(
            'Pedir un enlace nuevo',
            alPresionar: () => context.go(Rutas.recuperar),
          ),
          const SizedBox(height: 8),
          Boton(
            'Volver a iniciar sesión',
            estilo: EstiloBoton.fantasma,
            alPresionar: () => context.go(Rutas.iniciarSesion),
          ),
        ],
      ),
    );
  }
}

AppBar _barraCerrar(BuildContext context, String titulo) => AppBar(
  automaticallyImplyLeading: false,
  leading: IconButton(
    tooltip: 'Cerrar',
    icon: const Icono(Ico.x),
    onPressed: () => context.go(Rutas.iniciarSesion),
  ),
  title: Text(titulo),
);
