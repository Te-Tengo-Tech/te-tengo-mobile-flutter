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
import 'package:te_tengo/features/historial/domain/resumen_semanal.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';

import '../apoyo/app_de_prueba.dart';
import '../apoyo/clip_falso.dart';
import '../apoyo/datos.dart';
import '../features/alertas/alertas_falso.dart';
import '../features/camaras/repositorio_falso.dart';
import '../features/familia/familia_falso.dart';
import '../features/hogar/hogar_falso.dart';
import '../features/vivo/vivo_falso.dart';

/// A main screen of the app, opened with every fake in place.
class Pantalla {
  const Pantalla(this.nombre, this.ubicacion, {this.sesion = sesionTitular});

  final String nombre;
  final String ubicacion;
  final Sesion? sesion;
}

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
    if (p.ubicacion == Rutas.alerta('a-1')) caidaSala(),
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
        camarasRepositorioProvider.overrideWithValue(CamarasRepositorioFalso()),
        familiaRepositorioProvider.overrideWithValue(FamiliaRepositorioFalso()),
        alertasRepositorioProvider.overrideWithValue(alertas),
        resumenRepositorioProvider.overrideWithValue(_ResumenFalso()),
        vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
        transmisionProvider.overrideWithValue(TransmisionFalsa().abrir),
        fabricaClipProvider.overrideWithValue(ClipFalso.new),
        llamarProvider.overrideWithValue((_) async {}),
        relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42, 6)),
      ],
    ),
  );
  await tester.pumpAndSettle();
}
