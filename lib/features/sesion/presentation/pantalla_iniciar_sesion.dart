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
import '../../../l10n/l10n.dart';
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
      final l = context.l10n;
      switch (aviso) {
        case AvisoInicioSesion.sesionCerrada:
          mostrarToast(
            context,
            titulo: l.sesionCerradaTitulo,
            texto: l.sesionCerradaTexto,
            icono: Ico.logout,
            tono: TonoAviso.neutral,
          );
        case AvisoInicioSesion.claveActualizada:
          mostrarToast(
            context,
            titulo: l.sesionContrasenaActualizada,
            texto: l.sesionClaveActualizadaTexto,
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
    final l = context.l10n;
    setState(() {
      _faltanDatos = correo.isEmpty || clave.isEmpty;
      _errores = {
        if (correo.isEmpty) 'correo': l.sesionErrorCorreo,
        if (clave.isEmpty) 'contrasena': l.sesionErrorContrasena,
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
    final l = context.l10n;
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
              child: Text(l.sesionIniciaSesion, style: texto.headlineMedium),
            ),
            const SizedBox(height: 16),
            if (bloqueada) ...[
              Aviso(
                tono: TonoAviso.error,
                icono: Ico.lock,
                titulo: l.sesionBloqueadoTitulo,
                contenido: _conHora(
                  l.sesionBloqueadoTexto,
                  context.formato.hora(_bloqueadaHasta!),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_incorrectos) ...[
              Aviso(
                tono: TonoAviso.error,
                icono: Ico.warn,
                titulo: l.sesionIncorrectos,
                texto: _fallos >= 3 && restantes > 0
                    ? l.sesionIntentosRestantes(restantes)
                    : null,
              ),
              const SizedBox(height: 16),
            ],
            if (_faltanDatos) ...[
              Aviso(
                tono: TonoAviso.error,
                icono: Ico.warn,
                titulo: l.sesionFaltanDatos,
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
                    etiqueta: l.sesionCampoCorreo,
                    controlador: _correo,
                    tipo: TipoCampo.correo,
                    error: _errores['correo'],
                    habilitado: !bloqueada,
                    autocompletar: const [AutofillHints.email],
                    accionTeclado: TextInputAction.next,
                  ),
                  CampoTexto(
                    etiqueta: l.sesionCampoContrasena,
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
                l.sesionOlvidaste,
                alTocar: () => context.push(_rutaRecuperar),
              ),
            ),
            const SizedBox(height: 12),
            if (bloqueada)
              Boton(
                l.recuperarContrasena,
                estilo: EstiloBoton.secundario,
                alPresionar: () => context.push(_rutaRecuperar),
              )
            else
              Boton(
                l.sesionIniciarSesion,
                cargando: _enviando,
                alPresionar: _entrar,
              ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l.sesionSinCuenta, style: texto.bodyMedium),
                Enlace(
                  l.sesionCreaUna,
                  alTocar: () => context.push(Rutas.registro),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// [mensaje] around the time, which keeps the monospaced style of [conHora].
  TextSpan _conHora(String Function(String hora) mensaje, String hora) {
    final partes = mensaje('\u0000').split('\u0000');
    return conHora(partes.first, hora, partes.last);
  }

  String get _rutaRecuperar {
    final correo = _correo.text.trim();
    return correo.isEmpty
        ? Rutas.recuperar
        : '${Rutas.recuperar}?correo=${Uri.encodeQueryComponent(correo)}';
  }
}
