import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/sesion/sesion.dart';
import '../core/sesion/sesion_controller.dart';
import '../features/actividad/presentation/pantalla_actividad.dart';
import '../features/actualizaciones/presentation/barra_actualizacion.dart';
import '../features/actualizaciones/presentation/rutas_actualizaciones.dart';
import '../features/familia/presentation/pantalla_familiar.dart';
import '../features/ajustes/presentation/pantalla_notificaciones.dart';
import '../features/ajustes/presentation/pantalla_preferencias.dart';
import '../features/perfil/presentation/pantalla_cambiar_contrasena.dart';
import '../features/perfil/presentation/pantalla_tu_perfil.dart';
import '../features/perfil/presentation/renovacion_fotos.dart';
import '../features/familia/presentation/gestion_familia.dart';
import '../features/familia/presentation/pantallas_invitacion.dart';
import '../features/vivo/presentation/pantalla_accesos.dart';
import '../features/vivo/presentation/pantalla_mosaico.dart';
import '../features/vivo/presentation/pantalla_vivo.dart';
import '../features/ajustes/presentation/pantalla_ajustes.dart';
import '../features/ajustes/presentation/pantalla_avisos_setup.dart';
import '../features/alertas/presentation/pantalla_alerta.dart';
import '../features/alertas/presentation/pantalla_detalle_alerta.dart';
import '../features/arranque/pantalla_arranque.dart';
import '../features/camaras/presentation/pantalla_camara.dart';
import '../features/camaras/presentation/pantalla_nombre_habitacion.dart';
import '../features/camaras/presentation/pantalla_ordenar.dart';
import '../features/familia/presentation/pantalla_familia.dart';
import '../features/familia/presentation/pantalla_orden_aviso.dart';
import '../features/familia/presentation/pantallas_configuracion_familia.dart';
import '../features/historial/presentation/pantalla_historial.dart';
import '../features/legal/presentation/pantallas_legales.dart';
import '../features/instalar/presentation/instalar_app.dart';
import '../features/hogar/presentation/pantalla_persona_cuidada.dart';
import '../features/hogar/presentation/pantalla_persona_setup.dart';
import '../features/inicio/presentation/pantalla_inicio.dart';
import '../features/hogar/presentation/pantallas_consentimiento.dart';
import '../features/hogar/presentation/pantallas_privacidad.dart';
import '../features/movimientos/presentation/pantallas_movimientos.dart';
import '../features/reportes/presentation/pantallas_reporte.dart';
import '../features/pcs/domain/pc.dart';
import '../features/pcs/presentation/pantalla_aprobar_pc.dart';
import '../features/pcs/presentation/pantalla_camaras.dart';
import '../features/pcs/presentation/pantalla_pc.dart';
import '../features/pcs/presentation/pantalla_elegir_camaras.dart';
import '../features/pcs/presentation/pantalla_escanear.dart';
import '../features/pcs/presentation/pantalla_escribir_codigo.dart';
import '../features/pcs/presentation/pantalla_pc_vinculada.dart';
import '../features/pcs/presentation/pantalla_vincular_pc.dart';
import '../features/sesion/presentation/pantalla_bienvenida.dart';
import '../features/sesion/presentation/pantalla_cuenta_creada.dart';
import '../features/sesion/presentation/pantalla_iniciar_sesion.dart';
import '../features/sesion/presentation/pantalla_registro.dart';
import '../features/sesion/presentation/pantallas_recuperacion.dart';
import 'barras_estado.dart';
import 'navegacion.dart';
import 'rutas.dart';

/// First location; tests start elsewhere.
final ubicacionInicialProvider = Provider<String>((ref) => Rutas.arranque);

final routerProvider = Provider<GoRouter>((ref) {
  final sesion = ValueNotifier<Sesion?>(ref.read(sesionControllerProvider));
  ref.listen(sesionControllerProvider, (_, nueva) => sesion.value = nueva);
  final router = GoRouter(
    initialLocation: ref.read(ubicacionInicialProvider),
    refreshListenable: sesion,
    redirect: (context, state) =>
        Rutas.destinoDeWidget(state.uri) ??
        Rutas.redirigir(sesion.value, state.uri.path),
    routes: [
      GoRoute(
        path: Rutas.arranque,
        builder: (context, state) =>
            PantallaArranque(siguiente: state.uri.queryParameters['siguiente']),
      ),
      GoRoute(
        path: Rutas.bienvenida,
        builder: (context, state) => const PantallaBienvenida(),
      ),
      GoRoute(
        path: Rutas.registro,
        builder: (context, state) => const PantallaRegistro(),
      ),
      GoRoute(
        path: Rutas.cuentaCreada,
        builder: (context, state) => const PantallaCuentaCreada(),
      ),
      GoRoute(
        path: Rutas.iniciarSesion,
        builder: (context, state) => PantallaIniciarSesion(
          correo: state.uri.queryParameters['correo'],
          aviso: AvisoInicioSesion.desde(state.uri.queryParameters['aviso']),
        ),
      ),
      GoRoute(
        path: Rutas.recuperar,
        builder: (context, state) =>
            PantallaRecuperar(correo: state.uri.queryParameters['correo']),
      ),
      GoRoute(
        path: Rutas.enlaceEnviado,
        builder: (context, state) => PantallaEnlaceEnviado(
          correo: state.uri.queryParameters['correo'] ?? '',
        ),
      ),
      GoRoute(
        path: Rutas.nuevaContrasena,
        builder: (context, state) => PantallaNuevaContrasena(
          token: state.uri.queryParameters['token'] ?? '',
          correo: state.uri.queryParameters['correo'],
        ),
      ),
      GoRoute(
        path: '${Rutas.invitacion}/:token',
        builder: (context, state) => PantallaAceptarInvitacion(
          token: state.pathParameters['token']!,
          titular: state.uri.queryParameters['titular'],
          adultoMayor: state.uri.queryParameters['adultoMayor'],
          correo: state.uri.queryParameters['correo'],
        ),
      ),
      GoRoute(
        path: Rutas.terminos,
        builder: (context, state) => const PantallaTerminos(),
      ),
      GoRoute(
        path: Rutas.politica,
        builder: (context, state) => const PantallaPolitica(),
      ),
      GoRoute(
        path: Rutas.documentoConsentimiento,
        builder: (context, state) => const PantallaDocumentoConsentimiento(),
      ),
      GoRoute(
        path: Rutas.instalar,
        builder: (context, state) => const PantallaInstalarApp(),
      ),
      GoRoute(
        path: Rutas.accesoCreado,
        builder: (context, state) => const PantallaAccesoCreado(),
      ),
      GoRoute(
        path: Rutas.enlaceVencido,
        builder: (context, state) => const PantallaEnlaceVencido(),
      ),
      GoRoute(
        path: Rutas.configPersona,
        builder: (context, state) => const PantallaPersonaSetup(),
      ),
      GoRoute(
        path: Rutas.configConsentimiento,
        builder: (context, state) =>
            const PantallaConsentimiento(enConfiguracion: true),
      ),
      GoRoute(
        path: Rutas.configConstancia,
        builder: (context, state) =>
            const PantallaConsentimientoRegistrado(enConfiguracion: true),
      ),
      GoRoute(
        path: Rutas.configCamara,
        builder: (context, state) => const PantallaPcDeLaCasa(),
      ),
      GoRoute(
        path: Rutas.configFamilia,
        builder: (context, state) => const PantallaInvitarSetup(),
      ),
      GoRoute(
        path: Rutas.configAvisos,
        builder: (context, state) => PantallaAvisosSetup(
          invitado: state.uri.queryParameters['invitado'],
        ),
      ),
      GoRoute(
        path: Rutas.configListo,
        builder: (context, state) =>
            PantallaTodoListo(invitado: state.uri.queryParameters['invitado']),
      ),
      // The PC's QR opens `/vincular?codigo=…` (contract §9): the approval screen.
      GoRoute(
        path: Rutas.vincular,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          final config = q['config'] == '1';
          final codigo = q['codigo'];
          if (codigo == null) {
            return PantallaVincularPc(enConfiguracion: config);
          }
          return PantallaAprobarPc(
            codigo: codigo,
            consulta: state.extra is ConsultaPc
                ? state.extra! as ConsultaPc
                : null,
            enConfiguracion: config,
          );
        },
        routes: [
          GoRoute(
            path: 'escanear',
            builder: (context, state) => PantallaEscanear(
              enConfiguracion: state.uri.queryParameters['config'] == '1',
              codigoVencido: state.uri.queryParameters['vencido'] == '1',
            ),
          ),
          GoRoute(
            path: 'codigo',
            builder: (context, state) => PantallaEscribirCodigo(
              enConfiguracion: state.uri.queryParameters['config'] == '1',
            ),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.pcs,
        builder: (context, state) => const PantallaCamaras(),
      ),
      GoRoute(
        path: Rutas.ordenarCamaras,
        builder: (context, state) => const PantallaOrdenarCamaras(),
      ),
      GoRoute(
        path: '/pcs/:id',
        builder: (context, state) =>
            PantallaPc(pcId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pcs/:id/vinculada',
        builder: (context, state) =>
            PantallaPcVinculada(pcId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pcs/:id/camaras',
        builder: (context, state) => PantallaElegirCamaras(
          pcId: state.pathParameters['id']!,
          enConfiguracion: state.uri.queryParameters['config'] == '1',
        ),
      ),
      GoRoute(
        path: Rutas.consentimiento,
        builder: (context, state) => const PantallaConsentimiento(),
      ),
      GoRoute(
        path: Rutas.constancia,
        builder: (context, state) => const PantallaConsentimientoRegistrado(),
      ),
      GoRoute(
        path: Rutas.personaCuidada,
        builder: (context, state) => const PantallaPersonaCuidada(),
      ),
      GoRoute(
        path: Rutas.tuPerfil,
        builder: (context, state) => const PantallaTuPerfil(),
      ),
      GoRoute(
        path: Rutas.cambiarContrasena,
        builder: (context, state) => const PantallaCambiarContrasena(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacion) => ShellPestanas(
          navegacion: navegacion,
          encima: const [
            BarraSinInternet(),
            FranjaAlertaActiva(),
            EnvioReportesPendientes(),
            BarraActualizacion(),
            RenovacionFotos(),
          ],
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.inicio,
                builder: (context, state) => const PantallaInicio(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.historial,
                builder: (context, state) => const PantallaHistorial(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.familia,
                builder: (context, state) => const PantallaFamilia(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.ajustes,
                builder: (context, state) => const PantallaAjustes(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/alerta/:id',
        builder: (context, state) =>
            PantallaAlerta(alertaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/alertas/:id',
        builder: (context, state) =>
            PantallaDetalleAlerta(alertaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Rutas.privacidad,
        builder: (context, state) => const PantallaPrivacidad(),
      ),
      GoRoute(
        path: Rutas.movimientos,
        builder: (context, state) => const PantallaGuardarMovimientos(),
      ),
      GoRoute(
        path: Rutas.documentoMovimientos,
        builder: (context, state) => const PantallaDocumentoMovimientos(),
      ),
      GoRoute(
        path: Rutas.movimientosBorrados,
        builder: (context, state) => const PantallaBorrandoMovimientos(),
      ),
      GoRoute(
        path: Rutas.nube,
        builder: (context, state) => const PantallaMovimientosNube(),
      ),
      GoRoute(
        path: '/familiares/:id',
        builder: (context, state) =>
            PantallaFamiliar(usuarioId: state.pathParameters['id']!),
      ),
      ...rutasActualizaciones,
      GoRoute(
        path: Rutas.actividad,
        builder: (context, state) => const PantallaActividad(),
      ),
      GoRoute(
        path: Rutas.reporteCaida,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return PantallaReporteCaida(
            habitacion: q['habitacion'],
            cuando: DateTime.tryParse(q['cuando'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: '${Rutas.reporteCaida}/enviado',
        builder: (context, state) => PantallaReporteEnviado(
          guardado: state.uri.queryParameters['guardado'] == '1',
        ),
      ),
      GoRoute(
        path: Rutas.revocado,
        builder: (context, state) => const PantallaRevocado(),
      ),
      GoRoute(
        path: Rutas.ordenAviso,
        builder: (context, state) => const PantallaOrdenAviso(),
      ),
      GoRoute(
        path: Rutas.invitar,
        builder: (context, state) => const PantallaInvitar(),
      ),
      GoRoute(
        path: Rutas.notificaciones,
        builder: (context, state) => const PantallaNotificaciones(),
      ),
      GoRoute(
        path: Rutas.preferencias,
        builder: (context, state) => const PantallaPreferencias(),
      ),
      GoRoute(
        path: Rutas.accesos,
        builder: (context, state) => const PantallaAccesos(),
      ),
      GoRoute(
        path: Rutas.verTodas,
        builder: (context, state) => const PantallaMosaico(),
      ),
      GoRoute(
        path: Rutas.vivo,
        builder: (context, state) => PantallaVivo(
          camaraId: state.uri.queryParameters['camara'],
          alertaId: state.uri.queryParameters['alerta'],
          mosaicoId: state.uri.queryParameters['mosaico'],
        ),
      ),
      GoRoute(
        path: '/camara/:id',
        builder: (context, state) => PantallaCamara(
          camaraId: state.pathParameters['id']!,
          momento: DateTime.tryParse(
            state.uri.queryParameters['momento'] ?? '',
          ),
        ),
        routes: [
          GoRoute(
            path: 'nombre',
            builder: (context, state) => PantallaNombreHabitacion(
              camaraId: state.pathParameters['id']!,
              nombreActual: state.uri.queryParameters['actual'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    sesion.dispose();
  });
  return router;
});
