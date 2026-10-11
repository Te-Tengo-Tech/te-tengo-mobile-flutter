import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/historial/data/resumen_repositorio.dart';
import 'package:te_tengo/features/movimientos/data/movimientos_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/presentation/escaner_qr.dart';
import 'package:te_tengo/features/historial/domain/resumen_semanal.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';

import '../apoyo/app_de_prueba.dart';
import '../apoyo/clip_falso.dart';
import '../apoyo/datos.dart';
import '../features/alertas/alertas_falso.dart';
import '../features/camaras/repositorio_falso.dart';
import '../features/familia/familia_falso.dart';
import '../features/hogar/hogar_falso.dart';
import '../features/movimientos/movimientos_falso.dart';
import '../features/pcs/escaner_falso.dart';
import '../features/pcs/pcs_falso.dart';
import '../features/vivo/vivo_falso.dart';

/// A main screen of the app, opened with every fake in place.
class Pantalla {
  const Pantalla(
    this.nombre,
    this.ubicacion, {
    this.sesion = sesionTitular,
    this.inestable = false,
  });

  final String nombre;
  final String ubicacion;
  final Sesion? sesion;

  /// The active alert `a-1` is an unstable movement instead of a fall.
  final bool inestable;
}

/// Screens checked in dark mode and with the system text at 200 %: the main ones plus every setup
/// step, the unstable alert and the legal pages.
final pantallasOscurasYGrandes = [
  ...pantallasPrincipales,
  Pantalla(
    'alerta de movimiento inestable',
    Rutas.alerta('a-1'),
    inestable: true,
  ),
  const Pantalla('paso 1 persona', Rutas.configPersona),
  const Pantalla('paso 2 consentimiento', Rutas.configConsentimiento),
  const Pantalla('paso 3 cámara', Rutas.configCamara),
  const Pantalla('paso 4 familia', Rutas.configFamilia),
  const Pantalla('paso 5 avisos', Rutas.configAvisos),
  const Pantalla('todo listo', Rutas.configListo),
  const Pantalla('términos de uso', Rutas.terminos),
  const Pantalla('política de privacidad', Rutas.politica),
  const Pantalla('documento de consentimiento', Rutas.documentoConsentimiento),
  ...pantallasNuevas,
];

/// Screens of the change request «PCs, cámaras y datos de movimiento» (US-28 to US-40), checked for
/// accessibility, dark mode and large text, without golden screenshots (the prototype's own dark and
/// large-text versions are screens 237 to 249 and 280 to 302).
final pantallasNuevas = [
  const Pantalla('agregar PC', Rutas.vincular),
  const Pantalla('escanear el código QR', Rutas.escanear),
  const Pantalla('escribir el código', Rutas.escribirCodigo),
  Pantalla('aprobar la PC', Rutas.aprobarPc('KQWT-MXHD')),
  Pantalla(
    'aprobar la PC (invitado)',
    Rutas.aprobarPc('KQWT-MXHD'),
    sesion: sesionInvitado,
  ),
  Pantalla('PC vinculada', Rutas.pcVinculada('pc-sala')),
  Pantalla('elige las cámaras', Rutas.elegirCamaras('pc-sala', config: true)),
  Pantalla(
    'elige las cámaras (invitado)',
    Rutas.elegirCamaras('pc-sala'),
    sesion: sesionInvitado,
  ),
  Pantalla('nombre de la habitación', Rutas.nombreCamara('c1')),
  const Pantalla('cámaras', Rutas.pcs),
  const Pantalla('cámaras (invitado)', Rutas.pcs, sesion: sesionInvitado),
  Pantalla('detalle de la PC', Rutas.pc('pc-sala')),
  const Pantalla('guardar movimientos', Rutas.movimientos),
  const Pantalla(
    'guardar movimientos (invitado)',
    Rutas.movimientos,
    sesion: sesionInvitado,
  ),
  const Pantalla('documento de movimientos', Rutas.documentoMovimientos),
  const Pantalla('movimientos en la nube', Rutas.nube),
];

final pantallasPrincipales = [
  const Pantalla('bienvenida', Rutas.bienvenida, sesion: null),
  const Pantalla('iniciar sesión', Rutas.iniciarSesion, sesion: null),
  const Pantalla('registro', Rutas.registro, sesion: null),
  const Pantalla('inicio', Rutas.inicio),
  Pantalla('alerta de caída', Rutas.alerta('a-1')),
  Pantalla('detalle de alerta', Rutas.detalleAlerta('h1')),
  const Pantalla('historial', Rutas.historial),
  Pantalla('cámara', Rutas.camara('c1')),
  const Pantalla('vista en vivo', '/vivo?camara=c1'),
  const Pantalla('registro de accesos', Rutas.accesos),
  const Pantalla('familia', Rutas.familia),
  const Pantalla('orden de aviso', Rutas.ordenAviso),
  const Pantalla('invitar', Rutas.invitar),
  const Pantalla('ajustes', Rutas.ajustes),
  const Pantalla('ajustes del invitado', Rutas.ajustes, sesion: sesionInvitado),
  const Pantalla('notificaciones', Rutas.notificaciones),
  const Pantalla('persona cuidada', Rutas.personaCuidada),
  const Pantalla('privacidad', Rutas.privacidad),
];

class _ResumenFalso implements ResumenRepositorio {
  @override
  Future<ResumenSemanal> obtener(String semana) async => ResumenSemanal(
    semana: semana,
    conteos: const Conteos(movimientosInestables: 1),
    semanaAnterior: const Conteos(caidas: 1),
    tendenciaCaidas: Tendencia.disminucion,
    tendenciaInestables: Tendencia.aumento,
  );
}

Future<void> abrirPantalla(WidgetTester tester, Pantalla p) async {
  usarTelefono(tester);
  final alertas = AlertasRepositorioFalso([
    if (p.ubicacion == Rutas.alerta('a-1'))
      caidaSala(
        tipo: p.inestable ? TipoAlerta.movimientoInestable : TipoAlerta.caida,
      ),
    caidaSala(
      id: 'h1',
      tipo: TipoAlerta.movimientoInestable,
      estado: EstadoAlerta.atendida,
      atendidaPor: 'Carmen Huamán',
      atendidaPorId: 'u-carmen',
      atendidaEn: DateTime(2026, 9, 21, 12, 9),
      ocurridaEn: DateTime(2026, 9, 21, 12, 5),
    ),
  ]);
  final vivo = VistaEnVivoRepositorioFalso()
    ..lista = [
      AccesoVivo(
        usuarioId: 'u-luis',
        nombre: 'Luis Huamán',
        inicio: DateTime(2026, 9, 23, 8, 15),
        duracionSegundos: 125,
      ),
    ];
  await tester.pumpWidget(
    appDePrueba(
      ubicacion: p.ubicacion,
      sesion: p.sesion,
      overrides: [
        hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
        pcsRepositorioProvider.overrideWithValue(
          PcsRepositorioFalso(
            webcams: [
              webcam('c1', 'Webcam USB HD', habitacion: 'Sala'),
              webcam('w2', 'Logitech C920'),
              webcam(
                'w3',
                'USB2.0 PC Camera',
                habitacion: 'Pasillo',
                conectada: false,
              ),
            ],
            habitaciones: [
              ambiente('Sala', camara: 'c1'),
              ambiente('Pasillo', camara: 'w3'),
            ],
          ),
        ),
        fabricaEscanerQrProvider.overrideWithValue(EscanerFalso.new),
        movimientosRepositorioProvider.overrideWithValue(
          MovimientosRepositorioFalso(vigente: true, retencion: 30),
        ),
        camarasRepositorioProvider.overrideWithValue(CamarasRepositorioFalso()),
        familiaRepositorioProvider.overrideWithValue(FamiliaRepositorioFalso()),
        alertasRepositorioProvider.overrideWithValue(alertas),
        resumenRepositorioProvider.overrideWithValue(_ResumenFalso()),
        vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
        fabricaReproductorVivoProvider.overrideWithValue(
          FabricaReproductorFalsa().crear,
        ),
        fabricaClipProvider.overrideWithValue(ClipFalso.new),
        llamarProvider.overrideWithValue((_) async {}),
        relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42, 6)),
      ],
    ),
  );
  await tester.pumpAndSettle();
}
