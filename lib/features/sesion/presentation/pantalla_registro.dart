import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../data/cuentas_repositorio.dart';
import '../domain/validacion.dart';

/// US-01, screens 02–04: create an account. Empty fields are highlighted (CA-01.3) and a registered
/// email is rejected (CA-01.2). On success the app signs in and shows the confirmation (CA-01.1).
class PantallaRegistro extends ConsumerStatefulWidget {
  const PantallaRegistro({super.key});

  @override
  ConsumerState<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends ConsumerState<PantallaRegistro> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  Map<String, String> _errores = {};
  bool _faltanDatos = false;
  bool _correoEnUso = false;
  ProblemaApi? _problema;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final clave = _clave.text;
    final errores = <String, String>{
      if (nombre.isEmpty) 'nombre': 'Escribe tu nombre y apellido.',
      'correo': ?validarCorreo(correo),
      'contrasena': ?validarContrasenaNueva(clave),
    };
    setState(() {
      _errores = errores;
      _faltanDatos = nombre.isEmpty || correo.isEmpty || clave.isEmpty;
      _correoEnUso = false;
      _problema = null;
    });
    if (errores.isNotEmpty) return;
    setState(() => _enviando = true);
    final repositorio = ref.read(cuentasRepositorioProvider);
    try {
      await repositorio.registrar(
        nombre: nombre,
        correo: correo,
        contrasena: clave,
      );
      final sesion = await repositorio.iniciarSesion(
        correo: correo,
        contrasena: clave,
      );
      // The router guards move a new account without household to «Tu cuenta está lista».
      await ref.read(sesionControllerProvider.notifier).iniciar(sesion);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.codigo) {
          case 'CORREO_EN_USO':
            _correoEnUso = true;
            _errores = {'correo': 'Este correo ya está registrado.'};
          case 'VALIDACION':
            _errores = e.campos;
            _faltanDatos = e.campos.isNotEmpty;
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
    final correo = Uri.encodeQueryComponent(_correo.text.trim());
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(
            'Con tu cuenta recibirás las alertas y verás el historial de la '
            'persona que cuidas.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_correoEnUso) ...[
            Aviso(
              tono: TonoAviso.error,
              icono: Ico.warn,
              titulo: 'Ese correo ya tiene una cuenta',
              texto:
                  'Inicia sesión con él o recupera tu contraseña si no la recuerdas.',
              accion: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Enlace(
                    'Iniciar sesión con este correo',
                    alTocar: () =>
                        context.push('${Rutas.iniciarSesion}?correo=$correo'),
                  ),
                  Enlace(
                    'Recuperar mi contraseña',
                    alTocar: () =>
                        context.push('${Rutas.recuperar}?correo=$correo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_faltanDatos) ...[
            const Aviso(
              tono: TonoAviso.error,
              icono: Ico.warn,
              titulo: 'Faltan datos obligatorios',
              texto: 'Completa los campos marcados para crear tu cuenta.',
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
                  etiqueta: 'Tu nombre y apellido',
                  controlador: _nombre,
                  error: _errores['nombre'],
                  ayuda: 'Así sabrán los demás quién atendió cada alerta.',
                  autocompletar: const [AutofillHints.name],
                  accionTeclado: TextInputAction.next,
                ),
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controlador: _correo,
                  tipo: TipoCampo.correo,
                  error: _errores['correo'],
                  autocompletar: const [AutofillHints.email],
                  accionTeclado: TextInputAction.next,
                ),
                CampoTexto(
                  etiqueta: 'Contraseña',
                  controlador: _clave,
                  tipo: TipoCampo.contrasena,
                  error: _errores['contrasena'],
                  ayuda: ayudaContrasena,
                  autocompletar: const [AutofillHints.newPassword],
                  alEnviar: (_) => _crear(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Boton('Crear cuenta', cargando: _enviando, alPresionar: _crear),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Al crear tu cuenta aceptas los '),
                TextSpan(text: 'Términos de uso', style: _enlace),
                const TextSpan(text: ' y la '),
                TextSpan(text: 'Política de privacidad', style: _enlace),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: texto.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('¿Ya tienes cuenta?', style: texto.bodyMedium),
              Enlace(
                'Inicia sesión',
                alTocar: () => context.pushReplacement(Rutas.iniciarSesion),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final _enlace = estiloTexto(
  15,
  700,
  color: Colores.moradoTinta,
).copyWith(decoration: TextDecoration.underline);
