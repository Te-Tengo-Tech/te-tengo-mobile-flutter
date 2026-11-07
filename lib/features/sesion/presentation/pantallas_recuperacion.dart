import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
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
      _error = validarCorreo(context.l10n, correo);
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
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.recuperarContrasena)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(l.recuperarTeEnviaremos, style: texto.bodyMedium),
          const SizedBox(height: 16),
          if (_problema != null) ...[
            MensajeProblema(_problema!),
            const SizedBox(height: 16),
          ],
          CampoTexto(
            etiqueta: l.sesionCampoCorreo,
            controlador: _correo,
            tipo: TipoCampo.correo,
            error: _error,
            autocompletar: const [AutofillHints.email],
            alEnviar: (_) => _enviar(),
          ),
          Boton(
            l.recuperarEnviarEnlace,
            cargando: _enviando,
            alPresionar: _enviar,
          ),
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
    final cuerpo = texto.bodyLarge!.copyWith(color: context.colores.tinta2);
    final espera =
        '${_restante ~/ 60}:${(_restante % 60).toString().padLeft(2, '0')}';
    final l = context.l10n;
    final siTiene = _alrededor(l.recuperarSiTieneCuenta);
    final reenviarEn = _alrededor(l.recuperarReenviarEn);
    return Scaffold(
      appBar: AppBar(title: Text(l.recuperarContrasena)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.mail,
              fondo: context.colores.moradoSuave,
              color: context.colores.moradoTinta,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(l.recuperarRevisaCorreo, style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: siTiene.$1),
                TextSpan(
                  text: widget.correo,
                  style: cuerpo.copyWith(
                    color: context.colores.tinta,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: siTiene.$2),
              ],
            ),
            style: cuerpo,
          ),
          const SizedBox(height: 12),
          Text(l.recuperarSpam, style: texto.bodySmall),
          const SizedBox(height: 24),
          Boton(
            l.recuperarVolverIniciar,
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
                        TextSpan(text: reenviarEn.$1),
                        TextSpan(text: espera, style: estiloMono(tamano: 18)),
                        if (reenviarEn.$2.isNotEmpty)
                          TextSpan(text: reenviarEn.$2),
                      ],
                    ),
                    style: estiloTexto(18, 700, color: context.colores.tinta3),
                  ),
                ),
              ),
            )
          else
            Boton(
              l.recuperarReenviar,
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
    final l = context.l10n;
    setState(() {
      _error = validarContrasenaNueva(l, clave, exigida: false);
      _errorRepetida = _error == null && clave != _repetida.text
          ? l.sesionErrorNoCoinciden
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
    final l = context.l10n;
    final paraCuenta = _alrededor(l.recuperarParaCuenta);
    return Scaffold(
      appBar: _barraCerrar(context, l.sesionNuevaContrasena),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          if (widget.correo != null) ...[
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: paraCuenta.$1),
                  TextSpan(
                    text: widget.correo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: paraCuenta.$2),
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
            etiqueta: l.sesionNuevaContrasena,
            controlador: _clave,
            tipo: TipoCampo.contrasena,
            error: _error,
            ayuda: l.sesionAyudaContrasena,
            autocompletar: const [AutofillHints.newPassword],
          ),
          CampoTexto(
            etiqueta: l.recuperarRepite,
            controlador: _repetida,
            tipo: TipoCampo.contrasena,
            error: _errorRepetida,
            autocompletar: const [AutofillHints.newPassword],
            alEnviar: (_) => _guardar(),
          ),
          Boton(
            l.sesionGuardarContrasena,
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
    final l = context.l10n;
    return Scaffold(
      appBar: _barraCerrar(context, l.sesionNuevaContrasena),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconoGrande(
              icono: Ico.clock,
              fondo: context.colores.avisoSuave,
              color: context.colores.aviso,
              tamano: 64,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(l.recuperarVencido, style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text(
            l.recuperarDura,
            style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
          ),
          const SizedBox(height: 24),
          Boton(
            l.recuperarPedirNuevo,
            alPresionar: () => context.go(Rutas.recuperar),
          ),
          const SizedBox(height: 8),
          Boton(
            l.recuperarVolverIniciar,
            estilo: EstiloBoton.fantasma,
            alPresionar: () => context.go(Rutas.iniciarSesion),
          ),
        ],
      ),
    );
  }
}

/// The text of [mensaje] before and after its one placeholder, which the screen styles apart.
(String, String) _alrededor(String Function(String) mensaje) {
  final partes = mensaje('\u0000').split('\u0000');
  return (partes.first, partes.last);
}

AppBar _barraCerrar(BuildContext context, String titulo) => AppBar(
  automaticallyImplyLeading: false,
  leading: IconButton(
    tooltip: context.l10n.recuperarCerrar,
    icon: Icono(Ico.x, color: context.colores.icono),
    onPressed: () => context.go(Rutas.iniciarSesion),
  ),
  title: Text(titulo),
);
