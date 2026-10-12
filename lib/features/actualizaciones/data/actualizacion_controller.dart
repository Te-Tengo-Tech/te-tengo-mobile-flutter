import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';
import '../../../core/cache/interceptor_cache.dart';
import '../../../core/dispositivo/conectividad.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../domain/estado_actualizacion.dart';
import '../domain/versiones.dart';
import 'descarga_apk.dart';
import 'interrupcion.dart';
import 'plataforma.dart';
import 'versiones_repositorio.dart';

/// The version this phone had when the family chose «Actualizar»: the next start with a newer
/// version shows «Te Tengo se actualizó». A device key, kept on sign-out.
const claveActualizacionPedida = 'dispositivo|actualizacion-desde';

/// This app's update (US-43): asks `GET /api/versiones`, and runs the channel's path when the
/// family chooses «Actualizar»: reload (PWA), download, check and install (APK), Google Play's
/// in-app update, or the store page (iPhone).
class ActualizacionController extends Notifier<EstadoActualizacion> {
  CancelToken? _cancelacion;
  DateTime? _ultimaBusqueda;
  bool _buscando = false;

  @override
  EstadoActualizacion build() {
    ref.onDispose(() => _cancelacion?.cancel());
    return const EstadoActualizacion();
  }

  DateTime get _ahora => ref.read(relojProvider)();

  /// Looks for a new version, when [PlanBusqueda] says so. Without an answer nothing changes:
  /// only «Buscar actualizaciones» shows «No pudimos buscar.».
  Future<void> buscar(MotivoBusqueda motivo) async {
    if (_buscando) return;
    if (!PlanBusqueda.debeBuscar(motivo, _ahora, _ultimaBusqueda)) return;
    _buscando = true;
    final manual = motivo == MotivoBusqueda.manual;
    try {
      final info = await ref.read(infoAppProvider.future);
      if (info == null) return;
      state = state.copiar(info: info);
      if (manual) {
        if (!await ref.read(conectividadProvider).conectado()) {
          state = state.copiar(
            error: () => ErrorActualizacion.sinInternetAlBuscar,
          );
          return;
        }
        state = state.copiar(
          fase: state.enCurso ? null : FaseActualizacion.buscando,
          error: _sinErrorDeBusqueda,
        );
      }
      try {
        final versiones = await ref.read(versionesRepositorioProvider).leer();
        _ultimaBusqueda = _ahora;
        state = state.copiar(
          versiones: () => versiones,
          revisadoEn: _ahora,
          error: _sinErrorDeBusqueda,
        );
      } on ProblemaApi catch (e) {
        if (manual && e.codigo == ProblemaApi.sinConexion) {
          state = state.copiar(
            error: () => ErrorActualizacion.sinInternetAlBuscar,
          );
        }
      }
    } finally {
      _buscando = false;
      if (state.fase == FaseActualizacion.buscando) {
        state = state.copiar(fase: FaseActualizacion.quieta);
      }
    }
  }

  ErrorActualizacion? Function() get _sinErrorDeBusqueda {
    final actual = state.error;
    return () =>
        actual == ErrorActualizacion.sinInternetAlBuscar ? null : actual;
  }

  /// At start: «Te Tengo se actualizó · Versión 0.6.0.» when this app is newer than the one that
  /// chose «Actualizar», and the downloads of earlier updates are deleted.
  Future<void> alAbrir() async {
    final info = await ref.read(infoAppProvider.future);
    if (info == null) return;
    final cache = ref.read(cacheLocalProvider);
    try {
      final desde = await cache.leer(claveActualizacionPedida);
      if (desde != null &&
          desde.isNotEmpty &&
          esAnterior(desde, info.version)) {
        await cache.guardar(claveActualizacionPedida, '');
        ref
            .read(avisoFlotanteProvider.notifier)
            .mostrar(
              AvisoFlotante(
                titulo: 'Te Tengo se actualizó',
                texto: 'Versión ${info.version}.',
              ),
            );
      }
    } on Object {
      // An unreadable cache only loses the notice.
    }
    if (info.canal == Canal.apk) unawaited(_borrarDescargas());
  }

  Future<void> _borrarDescargas() async {
    try {
      final carpeta = await ref.read(carpetaActualizacionesProvider.future);
      if (carpeta.existsSync()) await carpeta.delete(recursive: true);
    } on Object {
      // A file left behind is deleted on the next start.
    }
  }

  /// «Actualizar» (or «Abrir», «Abrir la tienda», «Reintentar»): the channel's path. Never during
  /// an alert or a live view (CA-43.9).
  Future<void> actualizar() async {
    final info = state.info;
    final publicada = state.publicada;
    if (info == null || publicada == null || state.enCurso) return;
    if (state.nueva == null && !state.obligatoria) return;
    if (ref.read(interrupcionActivaProvider)) return;
    unawaited(_recordarPedido(info.version));
    switch (info.canal) {
      case Canal.pwa:
        state = state.copiar(
          fase: FaseActualizacion.recargando,
          error: () => null,
        );
        await ref.read(recargarAppProvider)();
      case Canal.ios:
        await _abrirTienda(publicada);
      case Canal.play:
        await _play(publicada);
      case Canal.apk:
        await _apk(publicada);
    }
  }

  Future<void> _recordarPedido(String version) async {
    try {
      await ref
          .read(cacheLocalProvider)
          .guardar(claveActualizacionPedida, version);
    } on Object {
      // Only the «se actualizó» notice is lost.
    }
  }

  Future<void> _abrirTienda(VersionPublicada v) async {
    final url = Uri.tryParse(v.url ?? '');
    if (url == null || !url.hasScheme) return;
    await ref.read(abrirEnlaceProvider)(url);
  }

  /// Google Play's in-app update: flexible for a new version, immediate below the minimum. If Play
  /// cannot (the app is not on Play yet, or it has not got the version), nothing happens, except
  /// that the minimum-version screen opens the store page.
  Future<void> _play(VersionPublicada v) async {
    final play = ref.read(actualizacionPlayProvider);
    if (state.obligatoria) {
      if (!await play.inmediata()) await _abrirTienda(v);
      return;
    }
    state = state.copiar(
      fase: FaseActualizacion.descargando,
      progreso: () => null,
      error: () => null,
    );
    await play.flexible();
    state = state.copiar(fase: FaseActualizacion.quieta);
  }

  Future<void> _apk(VersionPublicada v) async {
    final verificado = state.apkVerificado;
    if (verificado != null && File(verificado).existsSync()) {
      return _instalar(verificado);
    }
    final url = Uri.tryParse(v.url ?? '');
    final suma = v.sha256;
    // Without a checksum nothing can be checked, so nothing is installed.
    if (url == null || !url.hasScheme || suma == null || suma.isEmpty) {
      state = state.copiar(error: () => ErrorActualizacion.descarga);
      return;
    }
    if (!await ref.read(conectividadProvider).conectado()) {
      state = state.copiar(error: () => ErrorActualizacion.sinInternet);
      return;
    }
    final carpeta = await ref.read(carpetaActualizacionesProvider.future);
    final destino = File('${carpeta.path}/te-tengo-${v.version}.apk');
    final cancelacion = _cancelacion = CancelToken();
    state = state.copiar(
      fase: FaseActualizacion.descargando,
      progreso: () => 0,
      error: () => null,
      apkVerificado: () => null,
    );
    final File archivo;
    try {
      archivo = await ref
          .read(descargaApkProvider)
          .descargar(
            url,
            destino,
            cancelar: cancelacion,
            alAvanzar: (p) {
              if (state.fase == FaseActualizacion.descargando) {
                state = state.copiar(progreso: () => p);
              }
            },
          );
    } on DioException catch (e) {
      state = state.copiar(
        fase: FaseActualizacion.quieta,
        progreso: () => null,
        // «Cancelar»: the new-version notice stays.
        error: () => CancelToken.isCancel(e)
            ? null
            : InterceptorCache.sinConexion(e)
            ? ErrorActualizacion.sinInternet
            : ErrorActualizacion.descarga,
      );
      return;
    } on Object {
      state = state.copiar(
        fase: FaseActualizacion.quieta,
        progreso: () => null,
        error: () => ErrorActualizacion.descarga,
      );
      return;
    } finally {
      _cancelacion = null;
    }
    state = state.copiar(
      fase: FaseActualizacion.comprobando,
      progreso: () => null,
    );
    var coincide = false;
    try {
      coincide = await DescargaApk.coincide(archivo, suma);
    } on Object {
      coincide = false;
    }
    if (!coincide) {
      try {
        if (archivo.existsSync()) await archivo.delete();
      } on Object {
        // Deleted at the next start.
      }
      state = state.copiar(
        fase: FaseActualizacion.quieta,
        error: () => ErrorActualizacion.verificacion,
      );
      return;
    }
    state = state.copiar(apkVerificado: () => archivo.path);
    await _instalar(archivo.path);
  }

  Future<void> _instalar(String ruta) async {
    if (ref.read(interrupcionActivaProvider)) {
      state = state.copiar(
        fase: FaseActualizacion.esperando,
        error: () => null,
      );
      return;
    }
    final instalador = ref.read(instaladorApkProvider);
    if (!await instalador.puedeInstalar()) {
      state = state.copiar(
        fase: FaseActualizacion.quieta,
        error: () => null,
        pedirPermiso: true,
      );
      return;
    }
    state = state.copiar(
      fase: FaseActualizacion.instalando,
      error: () => null,
      pedirPermiso: false,
    );
    final resultado = await instalador.instalar(ruta);
    state = state.copiar(
      fase: FaseActualizacion.quieta,
      error: () => switch (resultado) {
        ResultadoInstalador.instalada => null,
        ResultadoInstalador.cancelada => ErrorActualizacion.cancelada,
        ResultadoInstalador.fallo => ErrorActualizacion.instalacion,
      },
    );
  }

  /// The alert or the live view closed: the verified APK goes to the installer now (CA-43.9).
  Future<void> continuar() async {
    final ruta = state.apkVerificado;
    if (state.fase != FaseActualizacion.esperando || ruta == null) return;
    state = state.copiar(fase: FaseActualizacion.quieta);
    await _instalar(ruta);
  }

  /// «Cancelar» during the download.
  void cancelarDescarga() => _cancelacion?.cancel();

  /// «Permite instalar la actualización» is on screen.
  void permisoMostrado() => state = state.copiar(pedirPermiso: false);

  /// «Abrir ajustes».
  Future<void> abrirAjustesPermiso() =>
      ref.read(instaladorApkProvider).abrirAjustesPermiso();

  /// Back from Android's settings: with the permission, the installer opens. True when it did.
  Future<bool> alVolverDeAjustes() async {
    final ruta = state.apkVerificado;
    if (ruta == null) return false;
    if (!await ref.read(instaladorApkProvider).puedeInstalar()) return false;
    await _instalar(ruta);
    return true;
  }

  /// «Ahora no»: «Falta el permiso de Android»; the verified APK is kept for «Actualizar».
  void permisoAhoraNo() => state = state.copiar(
    pedirPermiso: false,
    error: () => ErrorActualizacion.sinPermiso,
  );
}

final actualizacionProvider =
    NotifierProvider<ActualizacionController, EstadoActualizacion>(
      ActualizacionController.new,
    );

/// The last published versions, for the PCs' Te Tengo Captura (CA-43.7).
final versionesPublicadasProvider = Provider<Versiones?>(
  (ref) => ref.watch(actualizacionProvider.select((e) => e.versiones)),
);
