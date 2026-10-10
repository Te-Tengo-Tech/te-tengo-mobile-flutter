import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
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
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/estado_camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/domain/validacion.dart';
import '../data/familia_repositorio.dart';

/// Wait before the secondary contact is told, until the owner changes it (CA-10.3).
const esperaPredeterminada = 5;

/// US-08, screen 26 (setup step 4 of 5): invite another family member (CA-08.1).
class PantallaInvitarSetup extends ConsumerStatefulWidget {
  const PantallaInvitarSetup({super.key});

  @override
  ConsumerState<PantallaInvitarSetup> createState() =>
      _PantallaInvitarSetupState();
}

class _PantallaInvitarSetupState extends ConsumerState<PantallaInvitarSetup> {
  final _correo = TextEditingController();
  String? _error;
  String? _invitado;
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
    setState(() {
      _error =
          validarCorreo(correo, vacio: 'Escribe el correo de tu familiar.') ??
          (correo.toLowerCase() == propio.toLowerCase()
              ? 'Ese es tu propio correo. Invita a otra persona.'
              : null);
      _problema = null;
    });
    if (_error != null) return;
    setState(() => _enviando = true);
    try {
      final invitacion = await ref
          .read(familiaRepositorioProvider)
          .invitar(correo);
      if (mounted) setState(() => _invitado = invitacion.correo);
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

  void _seguir() => context.go(
    Uri(
      path: Rutas.configAvisos,
      queryParameters: {'invitado': ?_invitado},
    ).toString(),
  );

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final invitado = _invitado;
    return Scaffold(
      appBar: CabeceraConfiguracion(
        paso: 4,
        titulo: 'Familia',
        escala: MediaQuery.textScalerOf(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Semantics(
            header: true,
            child: Text('Invita a otro familiar', style: texto.titleLarge),
          ),
          const SizedBox(height: 8),
          Text(
            'Recibirá las alertas de $nombre y, si no atiendes una en '
            '$esperaPredeterminada min, le avisaremos.',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (invitado != null) ...[
            Aviso(
              tono: TonoAviso.ok,
              icono: Ico.check,
              titulo: 'Invitación enviada',
              contenido: TextSpan(
                children: [
                  const TextSpan(text: 'Le enviamos un enlace a '),
                  TextSpan(
                    text: invitado,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text: '. Será tu contacto secundario cuando acepte.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Boton('Continuar', alPresionar: _seguir),
          ] else ...[
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 16),
            ],
            CampoTexto(
              etiqueta: 'Correo de tu familiar',
              controlador: _correo,
              tipo: TipoCampo.correo,
              error: _error,
              marcador: 'nombre@correo.com',
              alEnviar: (_) => _invitar(),
            ),
            Boton(
              'Enviar invitación',
              icono: Ico.send,
              cargando: _enviando,
              alPresionar: _invitar,
            ),
            const SizedBox(height: 8),
            Boton(
              'Hacerlo después',
              estilo: EstiloBoton.fantasma,
              alPresionar: _seguir,
            ),
          ],
        ],
      ),
    );
  }
}

/// Screen 24: setup summary («Todo listo»).
class PantallaTodoListo extends ConsumerWidget {
  const PantallaTodoListo({super.key, this.invitado});

  /// Email invited in the previous step, if any.
  final String? invitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final hogar = ref.watch(hogarProvider).value;
    final camara = ref.watch(camarasProvider).value?.firstOrNull;
    final consentimiento = hogar?.consentimiento;
    final conConsentimiento = hogar?.conConsentimiento ?? false;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          children: [
            const Align(alignment: Alignment.centerLeft, child: Logotipo()),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                'Todo listo. Ya estás cerca de '
                '${hogar?.adultoMayor.nombrePila ?? ''}.',
                style: texto.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Te avisaremos aunque tengas la app cerrada.',
              style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
            ),
            const SizedBox(height: 20),
            ListaTarjeta(
              children: [
                if (camara != null)
                  Builder(
                    builder: (context) {
                      final estado = camara.estadoVisible(
                        conConsentimiento: conConsentimiento,
                      );
                      return FilaLista(
                        inicio: IconoEstadoCamara(estado: estado),
                        titulo:
                            'Cámara ${deHabitacion(camara.nombreHabitacion)}',
                        subtitulo: estado == EstadoVisible.enLinea
                            ? estado.texto
                            : '${estado.texto} · no envía video',
                      );
                    },
                  ),
                if (conConsentimiento && consentimiento != null)
                  FilaLista(
                    inicio: const _IconoResumen(Ico.shield, activo: true),
                    titulo: 'Consentimiento registrado',
                    subtitulo:
                        'Constancia del ${fechaCorta(consentimiento.otorgadoEn)} '
                        '· ${hora(consentimiento.otorgadoEn)}',
                  )
                else
                  const FilaLista(
                    inicio: _IconoResumen(Ico.lock, activo: false),
                    titulo: 'Falta el consentimiento',
                    subtitulo: 'Regístralo desde Inicio para activar la cámara',
                  ),
                FilaLista(
                  inicio: _IconoResumen(Ico.users, activo: invitado != null),
                  titulo: invitado != null
                      ? '1 familiar invitado'
                      : 'Sin contacto secundario',
                  subtitulo:
                      invitado ?? 'Puedes invitar a alguien desde Familia',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Boton('Ir al inicio', alPresionar: () => context.go(Rutas.inicio)),
          ],
        ),
      ),
    );
  }
}

/// Row icon of the summary: green when done, gray when missing (`.camline`).
class _IconoResumen extends StatelessWidget {
  const _IconoResumen(this.icono, {required this.activo});

  final Ico icono;
  final bool activo;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: activo ? context.colores.calmaSuave : context.colores.fondo2,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icono(
      icono,
      tamano: 22,
      color: activo ? context.colores.calmaTinta : context.colores.tinta3,
    ),
  );
}
