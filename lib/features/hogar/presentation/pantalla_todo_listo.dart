import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/marca.dart';
import '../../../core/web/entorno.dart';
import '../../../l10n/l10n.dart';
import '../../ajustes/presentation/permiso_avisos.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../inicio/presentation/pantalla_inicio.dart';
import '../../instalar/presentation/instalar_app.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../data/hogar_repositorio.dart';
import 'constancia.dart';

/// «Todo listo» (screens 18, 24 and 27 merged), after setup step 2 (docs/ONBOARDING.md):
/// - the consent certificate when it was just recorded (CA-05.1, CA-05.3), or that it is missing;
/// - the notifications, explained before the phone asks (CA-16.2, CA-16.3): «Permitir» asks the
///   system or the browser; an iPhone browser tab first shows how to add the app to the home
///   screen, because Safari only allows notifications there;
/// - what was left for later: the PC (Inicio's «Agregar PC», Ajustes › «Cámaras y PCs») and the
///   family (Familia › «Invitar»).
class PantallaTodoListo extends ConsumerWidget {
  const PantallaTodoListo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    final hogar = ref.watch(hogarProvider).value;
    final pcs = ref.watch(pcsProvider).value;
    final pc = pcs?.firstOrNull;
    final consentimiento = hogar?.consentimiento;
    final conConsentimiento = hogar?.conConsentimiento ?? false;
    final hayCamaras =
        (ref.watch(camarasProvider).value ?? const []).isNotEmpty;
    final activas = ref.watch(notificacionesActivasProvider).value ?? false;
    final permiso = ref.watch(permisoNotificacionesProvider);
    final debeInstalar = ref.watch(entornoNavegadorProvider).debeInstalar;
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
                l.onboardingTodoListo(hogar?.adultoMayor.nombrePila ?? ''),
                style: texto.headlineMedium,
              ),
            ),
            if (conConsentimiento && consentimiento != null) ...[
              const SizedBox(height: 8),
              Text(
                // With no camera chosen yet, detection starts once the PC is linked.
                hayCamaras
                    ? l.consentimientoCamarasDetectan
                    : l.consentimientoDetectaranAlVincular,
                style: texto.bodyLarge?.copyWith(color: context.colores.tinta2),
              ),
              const SizedBox(height: 20),
              TarjetaConstancia(consentimiento: consentimiento),
            ],
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(l.onboardingQueNoSePase, style: texto.titleLarge),
            ),
            const SizedBox(height: 8),
            Text(l.onboardingAunqueCerrada, style: texto.bodyMedium),
            const SizedBox(height: 16),
            const AvisoInstalarApp(separacion: 16),
            ListaTarjeta(
              children: [
                FilaLista(
                  inicio: const IconoFila(Ico.bell),
                  titulo: l.onboardingNotificaciones,
                  subtitulo: l.onboardingParaRecibir,
                  fin: activas
                      ? const PermisoActivado()
                      : debeInstalar
                      ? null
                      : Boton(
                          l.onboardingPermitir,
                          estilo: EstiloBoton.secundario,
                          pequeno: true,
                          alPresionar: () =>
                              activarNotificaciones(context, ref),
                        ),
                ),
                if (permiso.ajustesDeSonido)
                  FilaSonarEnSilencio(
                    icono: true,
                    subtitulo: l.onboardingSuenanIgual,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ListaTarjeta(
              children: [
                if (!conConsentimiento)
                  FilaLista(
                    inicio: const _IconoResumen(Ico.lock, activo: false),
                    titulo: l.onboardingFaltaConsentimiento,
                    subtitulo: l.onboardingRegistraloInicio,
                  ),
                if (pc != null)
                  FilaLista(
                    inicio: _IconoResumen(
                      Ico.pc,
                      activo: pc.camaras.isNotEmpty && conConsentimiento,
                    ),
                    titulo: l.onboardingPcVinculada(pc.nombre),
                    subtitulo: pc.camaras.isEmpty
                        ? l.onboardingFaltaElegirCamaras
                        : _camaras(l, [
                            for (final c in pc.camaras) c.nombreHabitacion,
                          ], detectando: conConsentimiento),
                  )
                else if (pcs != null)
                  FilaLista(
                    inicio: const _IconoResumen(Ico.pc, activo: false),
                    titulo: l.onboardingSinPc,
                    subtitulo: l.onboardingAgregaPc,
                  ),
                FilaLista(
                  inicio: const _IconoResumen(Ico.users, activo: false),
                  titulo: l.onboardingSinSecundario,
                  subtitulo: l.onboardingInvitaloFamilia,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Boton(
              l.onboardingIrInicio,
              alPresionar: () => context.go(Rutas.inicio),
            ),
          ],
        ),
      ),
    );
  }
}

/// «2 cámaras: Sala y Cocina», with « · sin detectar» while there is no consent.
String _camaras(
  AppLocalizations l,
  List<String> habitaciones, {
  required bool detectando,
}) {
  final camaras = l.onboardingPcCamaras(
    habitaciones.length,
    l.formato.enumerar(habitaciones),
  );
  return detectando ? camaras : l.onboardingSinDetectar(camaras);
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
