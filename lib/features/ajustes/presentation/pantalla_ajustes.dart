import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../actividad/data/actividad_repositorio.dart';
import '../../actividad/presentation/pantalla_actividad.dart';
import '../../actualizaciones/presentation/fila_acerca_de.dart';
import '../../../app/rutas.dart';
import '../../../core/reloj.dart';
import '../../../core/dispositivo/permiso_notificaciones.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/plegable.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../../core/ui/aviso.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/pc.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/domain/familiar.dart';
import '../../hogar/domain/hogar.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../sesion/presentation/cerrar_sesion.dart';
import '../../widget/data/widget_sistema.dart';
import '../../widget/presentation/pasos_widget.dart';
import '../../perfil/data/fotos.dart';
import 'pantalla_preferencias.dart';

/// `78 años · Vive solo(a)` (the age only when the backend sends it).
String resumenAdultoMayor(AppLocalizations l, AdultoMayor a) => [
  if (a.edad case final edad?) l.ajustesEdad(edad),
  switch (a.convivencia) {
    Convivencia.solo => l.ajustesViveSolo,
    Convivencia.conFamiliar => l.ajustesViveContigo,
    Convivencia.conCuidador => l.ajustesViveConCuidador,
    null => '',
  },
].where((t) => t.isNotEmpty).join(' · ');

/// Ajustes tab (screens 100, 85 and 167): «Persona cuidada», «Monitoreo», «Este celular» and
/// «Cuenta». An invited member sees what only the owner can change with
/// the lock and «Solo ver» (CA-08.4).
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionControllerProvider);
    final hogar = ref.watch(hogarProvider).value;
    final titular = sesion?.esTitular ?? false;
    final soloVer = titular ? null : const EtiquetaSoloVer();
    final texto = Theme.of(context).textTheme;
    final duena = ref.watch(nombreTitularProvider) ?? '';
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final aviso = ref.watch(avisoProvider).value;
    String? nombreCon(PapelAviso papel) => miembros
        .where((m) => m.papel == papel)
        .firstOrNull
        ?.familiar
        .nombrePila;
    final principal = nombreCon(PapelAviso.principal);
    final secundario = nombreCon(PapelAviso.secundario);
    final espera =
        aviso?.esperaMinutos ?? ConfiguracionAviso.esperaPredeterminada;
    final consentimiento = hogar?.consentimiento;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Semantics(
            header: true,
            child: Text(l.ajustesTitulo, style: texto.headlineMedium),
          ),
        ),
        if (!titular) ...[
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.users,
            titulo: l.ajustesInvitadoTitulo,
            texto: l.ajustesInvitadoTexto(duena),
          ),
          const SizedBox(height: 16),
        ],
        if (hogar != null) ...[
          EncabezadoSeccion(l.ajustesPersonaCuidada, arriba: 4),
          ListaTarjeta(
            children: [
              FilaLista(
                inicio: Avatar(
                  Avatar.inicialesDe(hogar.adultoMayor.nombre),
                  tono: TonoAvatar.rosa,
                  foto: ref.watch(fotoAdultoMayorProvider),
                ),
                titulo: hogar.adultoMayor.nombre,
                subtitulo: resumenAdultoMayor(l, hogar.adultoMayor),
                fin: soloVer,
                chevron: titular,
                alTocar: () => context.push(Rutas.personaCuidada),
              ),
            ],
          ),
        ],
        EncabezadoSeccion(l.ajustesMonitoreo, arriba: hogar == null ? 4 : 28),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.cam),
              titulo: l.ajustesCamarasYPcs,
              subtitulo: _resumenCamaras(
                l,
                ref.watch(pcsProvider).value,
                ref.watch(camarasProvider).value,
              ),
              alTocar: () => context.push(Rutas.pcs),
            ),
            if (principal != null)
              FilaLista(
                inicio: const IconoFila(Ico.swap),
                titulo: l.ajustesOrdenAviso,
                subtitulo: secundario == null
                    ? l.ajustesOrdenSinSecundario(principal, espera)
                    : l.ajustesOrdenConSecundario(
                        principal,
                        secundario,
                        espera,
                      ),
                fin: soloVer,
                chevron: titular,
                alTocar: () => context.push(Rutas.ordenAviso),
              ),
            FilaLista(
              inicio: const IconoFila(Ico.shield),
              titulo: l.ajustesPrivacidad,
              subtitulo: consentimiento != null && consentimiento.vigente
                  ? l.ajustesConsentimientoVigente(
                      l.formato.fechaConAnio(consentimiento.otorgadoEn),
                    )
                  : l.ajustesSinConsentimiento,
              fin: soloVer,
              chevron: titular,
              alTocar: () => context.push(Rutas.privacidad),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.list),
              titulo: l.ajustesActividad,
              subtitulo: switch (ref.watch(ultimaActividadProvider)) {
                AsyncData(value: final a) => resumenUltimoCambio(
                  l,
                  a,
                  ref.watch(relojProvider)(),
                ),
                _ => null,
              },
              alTocar: () => context.push(Rutas.actividad),
            ),
          ],
        ),
        EncabezadoSeccion(l.ajustesEsteCelular),
        // This phone's settings, so the invited member changes them too.
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: const IconoFila(Ico.bell),
              titulo: l.ajustesNotificaciones,
              subtitulo: switch (ref.watch(notificacionesActivasProvider)) {
                AsyncData(value: true) => l.ajustesActivadas,
                AsyncData(value: false) => l.ajustesDesactivadas,
                _ => null,
              },
              alTocar: () => context.push(Rutas.notificaciones),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.sun),
              titulo: l.ajustesPreferencias,
              subtitulo: resumenPreferencias(l, ref),
              alTocar: () => context.push(Rutas.preferencias),
            ),
            // This phone's app and its updates (US-43, screen 379).
            const FilaAcercaDe(),
            // The home-screen widget (US-44): Android and iOS, not the web.
            if (ref.watch(widgetDelSistemaProvider).disponible)
              FilaPlegable(
                icono: Ico.grid,
                titulo: l.ajustesAgregarWidget,
                resumen: hogar == null
                    ? null
                    : l.ajustesWidgetResumen(hogar.adultoMayor.nombrePila),
                child: const PasosWidget(),
              ),
          ],
        ),
        EncabezadoSeccion(l.ajustesCuenta),
        ListaTarjeta(
          children: [
            FilaLista(
              inicio: Avatar(
                Avatar.inicialesDe(sesion?.usuario.nombre ?? ''),
                foto: ref.watch(fotoDeUsuarioProvider(sesion?.usuario.id)),
              ),
              titulo: titular
                  ? l.ajustesTuCuentaTitular
                  : l.ajustesTuCuentaInvitado,
              subtitulo: sesion?.usuario.correo,
              alTocar: () => context.push(Rutas.tuPerfil),
            ),
            FilaLista(
              inicio: const IconoFila(Ico.logout, peligro: true),
              titulo: l.ajustesCerrarSesion,
              peligro: true,
              chevron: false,
              alTocar: () => cerrarSesion(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const PieVersion(),
      ],
    );
  }
}

/// «4 cámaras · 2 PCs», «Cocina-Rosa sin conexión» or «Aún no hay una PC vinculada» (screen 167).
String? _resumenCamaras(
  AppLocalizations l,
  List<Pc>? pcs,
  List<Camara>? camaras,
) {
  if (pcs == null) {
    return camaras == null ? null : l.ajustesCamaras(camaras.length);
  }
  if (pcs.isEmpty) return l.ajustesSinPc;
  final sinConexion = pcs.where((p) => p.sinConexion).firstOrNull;
  if (sinConexion != null) return l.ajustesPcSinConexion(sinConexion.nombre);
  final n = camaras?.length ?? pcs.fold<int>(0, (t, p) => t + p.camaras.length);
  return '${l.ajustesCamaras(n)} · ${l.ajustesPcs(pcs.length)}';
}
