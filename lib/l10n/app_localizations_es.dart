// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get actividadTitulo => 'Actividad';

  @override
  String get actividadHoy => 'Hoy';

  @override
  String get actividadAyer => 'Ayer';

  @override
  String actividadUltimoCambioHoy(String hora) {
    return 'Último cambio: hoy $hora';
  }

  @override
  String actividadUltimoCambioAyer(String hora) {
    return 'Último cambio: ayer $hora';
  }

  @override
  String actividadUltimoCambioFecha(String fecha, String hora) {
    return 'Último cambio: el $fecha $hora';
  }

  @override
  String get actividadSinActividad => 'Aún no hay actividad';

  @override
  String get actividadAyudaRegistro =>
      'Nadie puede borrar ni cambiar este registro.';

  @override
  String get actividadAyudaTema => 'registro de actividad';

  @override
  String get actividadFiltrarPorPc => 'Filtrar por PC';

  @override
  String get actividadTodas => 'Todas';

  @override
  String get actividadVacioTitulo => 'Aún no hay actividad registrada';

  @override
  String get actividadVacioTexto =>
      'Aquí verás cada cambio en PCs, cámaras y datos.';

  @override
  String get actividadReintentar => 'Volver a intentarlo';

  @override
  String get actividadDatoQuien => 'Quién';

  @override
  String get actividadDatoDesde => 'Desde';

  @override
  String get actividadDatoMomento => 'Momento';

  @override
  String get actividadDatoDuracion => 'Duración';

  @override
  String get actividadDatoAntes => 'Antes';

  @override
  String get actividadDatoDespues => 'Después';

  @override
  String get actividadDatoFechaYHora => 'Fecha y hora';

  @override
  String get actividadCerrar => 'Cerrar';

  @override
  String get actividadCargando => 'Cargando actividad';

  @override
  String actividadFraseFamiliar(String quien, String accion) {
    return '$quien $accion';
  }

  @override
  String actividadFraseDesdePc(String pc, String accion) {
    return 'Desde la PC $pc: $accion';
  }

  @override
  String actividadVinculoPc(String pc) {
    return 'vinculó la PC $pc';
  }

  @override
  String actividadRenombroPc(String antes, String despues) {
    return 'renombró la PC $antes a $despues';
  }

  @override
  String actividadQuitoPc(String pc) {
    return 'quitó la PC $pc';
  }

  @override
  String actividadPcRestablecida(String pc) {
    return 'La PC $pc se restableció';
  }

  @override
  String actividadPcDesinstalada(String pc) {
    return 'La PC $pc se desinstaló';
  }

  @override
  String get actividadPcSeDesvinculo => 'se desvinculó esta PC';

  @override
  String actividadPcVencida(String pc) {
    return 'Se desvinculó la PC $pc: no se conectó en 90 días';
  }

  @override
  String actividadPcPorSeguridad(String pc) {
    return 'Se desvinculó la PC $pc por seguridad';
  }

  @override
  String actividadCamaraPasoA(String camara, String habitacion) {
    return 'la cámara $camara pasó a $habitacion';
  }

  @override
  String actividadEligioCamara(
    String camara,
    String conArticulo,
    String habitacion,
  ) {
    return 'eligió la cámara $camara para $conArticulo';
  }

  @override
  String actividadPasoCamara(
    String camara,
    String deAntes,
    String aDespues,
    String antes,
    String despues,
  ) {
    return 'pasó la cámara $camara $deAntes $aDespues';
  }

  @override
  String actividadSeDejoDeUsarCamara(String camara) {
    return 'se dejó de usar la cámara $camara';
  }

  @override
  String actividadDejoDeUsarCamara(String camara) {
    return 'dejó de usar la cámara $camara';
  }

  @override
  String actividadRenombroHabitacion(
    String deAntes,
    String despues,
    String antes,
  ) {
    return 'cambió el nombre de la habitación $deAntes a $despues';
  }

  @override
  String actividadPausoCamara(String deHabitacion, String habitacion) {
    return 'pausó la cámara $deHabitacion';
  }

  @override
  String actividadPausoCamaraHasta(
    String deHabitacion,
    String hasta,
    String habitacion,
  ) {
    return 'pausó la cámara $deHabitacion hasta $hasta';
  }

  @override
  String actividadHastaHora(String hora) {
    return 'las $hora';
  }

  @override
  String actividadHastaDia(String dia, String hora) {
    return 'el $dia a las $hora';
  }

  @override
  String actividadTerminoPausa(String deHabitacion, String habitacion) {
    return 'Terminó la pausa $deHabitacion';
  }

  @override
  String actividadReanudoCamara(String deHabitacion, String habitacion) {
    return 'reanudó la cámara $deHabitacion';
  }

  @override
  String actividadCambioFoto(String nombre) {
    return 'cambió la foto de $nombre';
  }

  @override
  String actividadQuitoFoto(String nombre) {
    return 'quitó la foto de $nombre';
  }

  @override
  String get actividadRegistroConsentimiento =>
      'registró el consentimiento de monitoreo';

  @override
  String get actividadRevocoConsentimiento =>
      'revocó el consentimiento de monitoreo';

  @override
  String actividadRegistroPermisoMovimientos(String nombre) {
    return 'registró el permiso de $nombre para guardar movimientos';
  }

  @override
  String actividadMovimientosRevocados(String nombre) {
    return 'Se dejaron de guardar los movimientos de $nombre al revocar el consentimiento';
  }

  @override
  String actividadDejoDeGuardarMovimientos(String nombre) {
    return 'dejó de guardar los movimientos de $nombre';
  }

  @override
  String actividadCambioRetencion(String de, String a) {
    return 'cambió los movimientos en la nube de $de a $a';
  }

  @override
  String get actividadNoGuardar => 'No guardar';

  @override
  String get actividadModoAvanzadoActivado => 'se activó el modo avanzado';

  @override
  String get actividadModoAvanzadoDesactivado =>
      'se desactivó el modo avanzado';

  @override
  String get actividadGuardadoEnPc => 'el guardado en la PC';

  @override
  String actividadGuardadoCambio(String que, String antes, String despues) {
    return '$que pasó de $antes a $despues';
  }

  @override
  String get actividadNo => 'No';

  @override
  String get actividadBorroDatos => 'se borraron los datos guardados en la PC';

  @override
  String get actividadVioQuePaso => 'se vio qué pasó';

  @override
  String actividadVioQuePasoEn(String enHabitacion, String habitacion) {
    return 'se vio qué pasó $enHabitacion';
  }

  @override
  String actividadConDetalle(String frase, String detalle) {
    return '$frase ($detalle)';
  }

  @override
  String actividadMomento(String dia, String desde, String hasta) {
    return '$dia $desde–$hasta';
  }

  @override
  String actividadDiaMes(String dd, String mm) {
    return '$dd/$mm';
  }

  @override
  String actividadPcActualizada(String pc, String version) {
    return '$pc se actualizó a $version';
  }

  @override
  String get actividadActualizacionAutomaticaActivada =>
      'se activó la actualización automática';

  @override
  String get actividadActualizacionAutomaticaDesactivada =>
      'se desactivó la actualización automática';

  @override
  String get actividadCambioFamiliar => 'hizo un cambio en la configuración';

  @override
  String get actividadCambioPc => 'hubo un cambio en la configuración';

  @override
  String get actividadCambioSistema => 'Hubo un cambio en la configuración';

  @override
  String get actividadVinculada => 'Vinculada';

  @override
  String get actividadDesvinculada => 'Desvinculada';

  @override
  String get actividadSinUsar => 'Sin usar';

  @override
  String get actividadEnLinea => 'En línea';

  @override
  String get actividadEnPausa => 'En pausa';

  @override
  String actividadEnPausaHasta(String hasta) {
    return 'En pausa hasta $hasta';
  }

  @override
  String get actividadNoAutorizado => 'No autorizado';

  @override
  String get actividadVigente => 'Vigente';

  @override
  String get actividadRevocado => 'Revocado';

  @override
  String get actividadDesactivado => 'Desactivado';

  @override
  String get actividadActivado => 'Activado';

  @override
  String get actividadAlguienEnPc => 'Alguien en la PC';

  @override
  String actividadCelularDe(String nombre) {
    return 'Celular de $nombre';
  }

  @override
  String actividadPc(String pc) {
    return 'PC $pc';
  }

  @override
  String get actividadAutomatico => 'Automático';

  @override
  String get ajustesTitulo => 'Ajustes';

  @override
  String ajustesEdad(int edad) {
    return '$edad años';
  }

  @override
  String get ajustesViveSolo => 'Vive solo(a)';

  @override
  String get ajustesViveContigo => 'Vive contigo';

  @override
  String get ajustesViveConCuidador => 'Vive con otro cuidador';

  @override
  String get ajustesInvitadoTitulo => 'Eres familiar invitado';

  @override
  String ajustesInvitadoTexto(String titular) {
    return 'Lo que tiene candado solo lo cambia $titular.';
  }

  @override
  String get ajustesPersonaCuidada => 'Persona cuidada';

  @override
  String get ajustesMonitoreo => 'Monitoreo';

  @override
  String get ajustesCamarasYPcs => 'Cámaras y PCs';

  @override
  String get ajustesOrdenAviso => 'Orden de aviso y espera';

  @override
  String ajustesOrdenSinSecundario(String principal, int espera) {
    return '$principal · sin secundario · $espera min';
  }

  @override
  String ajustesOrdenConSecundario(
    String principal,
    String secundario,
    int espera,
  ) {
    return '$principal → $secundario · $espera min';
  }

  @override
  String get ajustesPrivacidad => 'Privacidad y consentimiento';

  @override
  String ajustesConsentimientoVigente(String fecha) {
    return 'Vigente · $fecha';
  }

  @override
  String get ajustesSinConsentimiento => 'Sin consentimiento';

  @override
  String get ajustesActividad => 'Actividad';

  @override
  String get ajustesEsteCelular => 'Este celular';

  @override
  String get ajustesNotificaciones => 'Notificaciones';

  @override
  String get ajustesActivadas => 'Activadas';

  @override
  String get ajustesDesactivadas => 'Desactivadas';

  @override
  String get ajustesPreferencias => 'Preferencias';

  @override
  String get ajustesAgregarWidget => 'Agregar el widget';

  @override
  String ajustesWidgetResumen(String nombre) {
    return '$nombre y «Ver en vivo» en tu pantalla de inicio';
  }

  @override
  String get ajustesCuenta => 'Cuenta';

  @override
  String get ajustesTuCuentaTitular => 'Tu cuenta · Titular';

  @override
  String get ajustesTuCuentaInvitado => 'Tu cuenta · Familiar invitado';

  @override
  String get ajustesCerrarSesion => 'Cerrar sesión';

  @override
  String ajustesCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras',
      one: '1 cámara',
    );
    return '$_temp0';
  }

  @override
  String ajustesPcs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n PCs',
      one: '1 PC',
    );
    return '$_temp0';
  }

  @override
  String get ajustesSinPc => 'Aún no hay una PC vinculada';

  @override
  String ajustesPcSinConexion(String pc) {
    return '$pc sin conexión';
  }

  @override
  String get preferenciasTitulo => 'Preferencias';

  @override
  String get preferenciasTemaAutomatico => 'Automático';

  @override
  String get preferenciasTemaClaro => 'Claro';

  @override
  String get preferenciasTemaOscuro => 'Oscuro';

  @override
  String get preferenciasLetraEstandar => 'Estándar';

  @override
  String get preferenciasLetraGrande => 'Grande';

  @override
  String get preferenciasResumenTemaAutomatico => 'Tema automático';

  @override
  String get preferenciasResumenTemaClaro => 'Tema claro';

  @override
  String get preferenciasResumenTemaOscuro => 'Tema oscuro';

  @override
  String get preferenciasResumenLetraEstandar => 'letra estándar';

  @override
  String get preferenciasResumenLetraGrande => 'letra grande';

  @override
  String get preferenciasResumenContraste => 'más contraste';

  @override
  String get preferenciasTema => 'Tema';

  @override
  String get preferenciasIgualQueCelular => 'Igual que tu celular';

  @override
  String get preferenciasTamanoLetra => 'Tamaño de letra';

  @override
  String get preferenciasContraste => 'Contraste';

  @override
  String get preferenciasAumentarContraste => 'Aumentar el contraste';

  @override
  String get preferenciasContrasteTexto => 'Texto y bordes más marcados';

  @override
  String get preferenciasAlertasConservanColor =>
      'Las alertas conservan su color.';

  @override
  String get notificacionesTitulo => 'Notificaciones';

  @override
  String get notificacionesDesactivadasTitulo => 'Desactivadas en tu celular';

  @override
  String get notificacionesDesactivadasTexto =>
      'Con la app cerrada no te enterarás de una caída.';

  @override
  String get notificacionesActivar => 'Activar notificaciones';

  @override
  String get notificacionesFamiliaSinAlertas =>
      'Nadie de la familia recibe las alertas';

  @override
  String get notificacionesCelularSinAlertas =>
      'Este celular no recibe las alertas';

  @override
  String get notificacionesSinAlertasTexto =>
      'Sin ellas no sabrás de una caída con la app cerrada.';

  @override
  String get notificacionesActivadas => 'Notificaciones activadas';

  @override
  String get notificacionesAvisosEnCelular => 'Avisos en este celular';

  @override
  String get notificacionesCaidas => 'Caídas';

  @override
  String get notificacionesSiempreActivas => 'Siempre activas';

  @override
  String get notificacionesSonarSubtitulo =>
      'Aunque el celular esté en silencio';

  @override
  String get notificacionesInestables => 'Movimientos inestables';

  @override
  String get notificacionesSeveridadMedia => 'Severidad media';

  @override
  String get notificacionesEstadoCamara => 'Estado de la cámara';

  @override
  String get notificacionesEstadoCamaraTexto =>
      'Desconexión o detección no confiable · siempre activas';

  @override
  String get notificacionesFinPausa => 'Fin de una pausa';

  @override
  String get notificacionesFinPausaTexto => 'Cuando la cámara se reactiva sola';

  @override
  String get notificacionesSiNadieAtiende => 'Si nadie atiende';

  @override
  String notificacionesAvisarSecundario(int espera) {
    return 'Avisar al secundario a los $espera min';
  }

  @override
  String get notificacionesActivadasPermiso => 'Activadas';

  @override
  String get notificacionesSonarEnSilencio => 'Sonar en silencio';

  @override
  String get notificacionesPermitir => 'Permitir';

  @override
  String get acercaDeComoPwa =>
      'Se actualiza con internet. Te avisamos para recargarla.';

  @override
  String get acercaDeComoApk =>
      'Te avisamos cuando hay una versión nueva. Android te pide confirmar.';

  @override
  String get acercaDeComoPlay => 'Google Play la actualiza sola.';

  @override
  String get acercaDeComoIos => 'Se actualiza desde App Store o TestFlight.';

  @override
  String get acercaDeTitulo => 'Acerca de';

  @override
  String get acercaDeFila => 'Acerca de Te Tengo';

  @override
  String acercaDeVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get acercaDeHayUnaNueva => 'hay una nueva';

  @override
  String get acercaDeActualizaciones => 'Actualizaciones';

  @override
  String get acercaDeActualizacionesTema => 'actualizaciones';

  @override
  String get acercaDePcsDeLaCasa => 'PCs de la casa';

  @override
  String get acercaDePcsAyuda =>
      'Cada PC actualiza Te Tengo Captura por su cuenta.';

  @override
  String get acercaDePcsTema => 'las PCs';

  @override
  String acercaDePcsAnteriores(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n PCs con versión anterior',
      one: '1 PC con versión anterior',
    );
    return '$_temp0';
  }

  @override
  String acercaDeTodasAlDia(String version) {
    return 'Todas al día · Te Tengo Captura $version';
  }

  @override
  String acercaDeCaptura(String version) {
    return 'Captura $version';
  }

  @override
  String get acercaDeAlDia => 'al día';

  @override
  String get actualizacionVersionAnterior => 'versión anterior';

  @override
  String get actualizacionBuscando => 'Buscando actualizaciones…';

  @override
  String get actualizacionSinInternet => 'Sin internet';

  @override
  String get actualizacionNoPudimosBuscar => 'No pudimos buscar.';

  @override
  String get actualizacionUltimaVersion => 'Tienes la última versión';

  @override
  String get actualizacionRevisadoAntes => 'Revisado hoy a las ';

  @override
  String get actualizacionRevisadoDespues => '.';

  @override
  String get actualizacionBuscar => 'Buscar actualizaciones';

  @override
  String get actualizacionQueCambio => 'Qué cambió';

  @override
  String actualizacionQueCambioEn(String version) {
    return 'Qué cambió en la $version';
  }

  @override
  String get actualizacionAlCerrarAlerta => 'Al cerrar la alerta.';

  @override
  String get actualizacionAhoraNo => 'Ahora no';

  @override
  String get actualizacionDescarga => 'Descarga';

  @override
  String actualizacionPorcentaje(int p) {
    return '$p %';
  }

  @override
  String actualizacionTamanoMb(String mb) {
    return '$mb MB';
  }

  @override
  String get actualizacionSeparadorDecimal => ',';

  @override
  String get actualizacionDescargaTema => 'la descarga';

  @override
  String actualizacionAbrirTienda(String tienda) {
    return 'Abrir $tienda';
  }

  @override
  String get actualizacionAbrir => 'Abrir';

  @override
  String get actualizacionActualizar => 'Actualizar';

  @override
  String actualizacionDescargando(String version) {
    return 'Descargando $version';
  }

  @override
  String get actualizacionCancelar => 'Cancelar';

  @override
  String get actualizacionComprobando => 'Comprobando la descarga…';

  @override
  String get actualizacionReintentar => 'Reintentar';

  @override
  String get actualizacionNoSePudoDescargarPunto => 'No se pudo descargar.';

  @override
  String get actualizacionNoSePudoDescargar => 'No se pudo descargar';

  @override
  String actualizacionSigues(String version) {
    return 'Sigues con la $version.';
  }

  @override
  String get actualizacionNoSePudoVerificar =>
      'No se pudo verificar la descarga';

  @override
  String actualizacionLaBorramos(String version) {
    return 'La borramos. Sigues con la $version.';
  }

  @override
  String get actualizacionNoCoincide =>
      'No coincide con la versión publicada. Para cuidar tu celular, no se instala.';

  @override
  String get actualizacionNoSeInstalo => 'No se instaló';

  @override
  String get actualizacionCancelaste => 'Cancelaste la instalación.';

  @override
  String get actualizacionFaltaPermiso => 'Falta el permiso de Android';

  @override
  String get actualizacionSinPermiso => 'Sin él no se instala.';

  @override
  String actualizacionHayNuevaVersion(String version) {
    return 'Hay una versión nueva ($version)';
  }

  @override
  String get actualizacionHayNueva => 'Hay una versión nueva';

  @override
  String get actualizacionAplicacionWeb => 'Aplicación web';

  @override
  String get actualizacionSeActualizo => 'Te Tengo se actualizó';

  @override
  String actualizacionVersionPunto(String version) {
    return 'Versión $version.';
  }

  @override
  String get actualizacionObligatoriaTitulo =>
      'Actualiza Te Tengo para seguir recibiendo alertas';

  @override
  String actualizacionObligatoriaTienes(String version) {
    return 'Tienes la $version. Toma un minuto.';
  }

  @override
  String get actualizacionObligatoriaAyuda =>
      'Esta versión ya no recibe las alertas de forma segura. Quienes ya actualizaron las siguen recibiendo.';

  @override
  String get actualizacionObligatoriaTema => 'por qué actualizar';

  @override
  String get actualizacionAbrirLaTienda => 'Abrir la tienda';

  @override
  String actualizacionLlamarA(String nombre) {
    return 'Llamar a $nombre';
  }

  @override
  String actualizacionSeAbre(String tienda) {
    return 'Se abre $tienda.';
  }

  @override
  String get actualizacionActualizando => 'Actualizando…';

  @override
  String get actualizacionCerrar => 'Cerrar';

  @override
  String get actualizacionInstalarTitulo => 'Instalar la actualización';

  @override
  String get actualizacionPermitirFuente => 'Permitir de esta fuente';

  @override
  String get actualizacionPermiteInstalar =>
      'Permite instalar la actualización';

  @override
  String get actualizacionUnaSolaVez => 'Android lo pide una sola vez.';

  @override
  String get actualizacionPermisoAyuda =>
      'Te Tengo no viene de una tienda, así que Android pide permiso para instalar sus versiones nuevas. Solo acepta las firmadas por Te Tengo.';

  @override
  String get actualizacionPermisoTema => 'el permiso de Android';

  @override
  String get actualizacionPasoAbrirAjustes => 'Toca «Abrir ajustes».';

  @override
  String get actualizacionPasoActivar => 'Activa «Permitir de esta fuente».';

  @override
  String get actualizacionPasoVolver => 'Vuelve a Te Tengo.';

  @override
  String get actualizacionAbrirAjustes => 'Abrir ajustes';

  @override
  String actualizacionVersionAnteriorPc(String version) {
    return 'Versión anterior ($version)';
  }

  @override
  String get actualizacionSeActualizaraSola => 'Se actualizará sola.';

  @override
  String get actualizacionPideActualizar =>
      'Pide a quien está en la casa que la actualice. ';

  @override
  String get actualizacionPcAyuda =>
      'En la PC aparece «Hay una versión nueva»: que elijan «Descargar». Se instala sola y la detección sigue.';

  @override
  String get actualizacionPcTema => 'cómo actualizar la PC';

  @override
  String get alertaTipoCaida => 'Caída';

  @override
  String get alertaTipoInestable => 'Movimiento inestable';

  @override
  String alertaTipoEnHabitacion(String tipo, String sala, String habitacion) {
    return '$tipo en $sala';
  }

  @override
  String get alertaEtiquetaInestable => 'Inestable';

  @override
  String get alertaSelloAtendida => 'Atendida';

  @override
  String get alertaSelloFalsaAlarma => 'Falsa alarma';

  @override
  String get alertaSelloActiva => 'Activa';

  @override
  String get alertaCerrarTooltip => 'Cerrar la alerta y volver al inicio';

  @override
  String alertaNoContesta(String nombre) {
    return '¿$nombre no contesta?';
  }

  @override
  String get alertaLlamarSamu => 'Llamar al SAMU · 106';

  @override
  String get alertaClipTitulo => 'Clip del evento';

  @override
  String get alertaClipResumen => '12 s, antes y después';

  @override
  String get alertaClipNoGuardado => 'No se pudo guardar';

  @override
  String get alertaMasDetalles => 'Más detalles';

  @override
  String get alertaMasDetallesResumen =>
      'Dirección, teléfono, aviso y registro';

  @override
  String get alertaMarcar => 'Marcar alerta';

  @override
  String get alertaPorqueInestable =>
      'No es una caída. Si termina en una, te avisamos.';

  @override
  String get alertaPorqueSeLevanto =>
      'Se puso de pie. Confirma cómo está antes de marcarla.';

  @override
  String get alertaPorqueConfirmada =>
      'Lleva más de 30 s en el suelo. Si se levanta, te avisamos.';

  @override
  String get alertaPorqueComprobando =>
      'Si sigue en el suelo 30 s, confirmamos la caída. Si se levanta, te avisamos.';

  @override
  String get alertaDireccion => 'Dirección';

  @override
  String get alertaTelefono => 'Teléfono';

  @override
  String get alertaBomberos => 'Bomberos';

  @override
  String get alertaEmpezoInestableTitulo => 'Empezó como movimiento inestable';

  @override
  String alertaEmpezoInestableTexto(
    String hora,
    String sala,
    String habitacion,
  ) {
    return 'A las $hora en $sala. Terminó en caída.';
  }

  @override
  String get alertaTeTocaTitulo => 'Te toca atenderla';

  @override
  String alertaTeTocaTexto(int espera, String hora) {
    return 'Nadie la marcó en $espera min ($hora).';
  }

  @override
  String alertaAvisamosA(String nombre) {
    return 'Avisamos a $nombre';
  }

  @override
  String alertaAvisamosTexto(String hora) {
    return 'A las $hora. Tú aún puedes atenderla.';
  }

  @override
  String get alertaNoHayAQuienTitulo => 'No hay a quién escalar';

  @override
  String alertaSinRespuestaTuya(int espera) {
    return '$espera min sin respuesta. Sigue siendo tuya.';
  }

  @override
  String alertaSinRespuestaDe(int espera, String nombre) {
    return '$espera min sin respuesta. Sigue siendo de $nombre.';
  }

  @override
  String get alertaAgregarSecundario => 'Agregar contacto secundario';

  @override
  String get alertaSinSecundarioTitulo => 'Sin contacto secundario';

  @override
  String get alertaSinSecundarioTexto =>
      'Si nadie la atiende, no hay a quién más avisar.';

  @override
  String get alertaAgregarContacto => 'Agregar contacto';

  @override
  String alertaLimiteSoySecundario(String principal, String hora) {
    return '$principal es la principal. Si nadie la marca antes de las $hora, te avisamos.';
  }

  @override
  String alertaLimiteSecundario(String hora, String secundario) {
    return 'Si nadie la marca antes de las $hora, avisamos a $secundario (secundario).';
  }

  @override
  String get alertaEtiquetaCaidaUrgente => 'Caída · Urgente';

  @override
  String get alertaEtiquetaInestableMedia => 'Inestable · Severidad media';

  @override
  String get alertaNoTeLlego => 'No te llegó como notificación';

  @override
  String get alertaFalloEnvio => 'Falló el envío; seguimos reintentando.';

  @override
  String alertaTituloInestable(String nombre) {
    return '$nombre tuvo un movimiento inestable';
  }

  @override
  String alertaTituloEnElSuelo(String nombre) {
    return '$nombre se cayó y sigue en el suelo';
  }

  @override
  String alertaTituloPudoCaerse(String nombre) {
    return '$nombre pudo haberse caído';
  }

  @override
  String get alertaHaceAhora => 'ahora';

  @override
  String alertaHaceMinutos(int minutos) {
    return '$minutos min';
  }

  @override
  String alertaLlamarA(String nombre) {
    return 'Llamar a $nombre';
  }

  @override
  String get alertaVerEnVivo => 'Ver en vivo';

  @override
  String get alertaSigueEnSueloConfirmada => 'Sigue en el suelo · confirmada';

  @override
  String get alertaComprobando => 'Comprobando si sigue en el suelo';

  @override
  String alertaSeLevantoALas(String hora) {
    return 'Se levantó a las $hora';
  }

  @override
  String get alertaDatoHabitacion => 'Habitación';

  @override
  String get alertaDatoHora => 'Hora';

  @override
  String get alertaDatoHace => 'Hace';

  @override
  String alertaAvisadoPrincipal(String nombre) {
    return '$nombre (principal)';
  }

  @override
  String get alertaLineaLaFamilia => 'la familia';

  @override
  String get alertaLineaReintentando => 'No se pudo entregar; reintentando';

  @override
  String get alertaLineaNoEntregada => 'No se pudo entregar';

  @override
  String alertaLineaAviso(String avisados, int segundos) {
    return 'Aviso a $avisados · $segundos s';
  }

  @override
  String get alertaLineaConfirmada => 'Sigue en el suelo: confirmada';

  @override
  String alertaLineaSeLevanto(String nombre) {
    return '$nombre se levantó';
  }

  @override
  String alertaLineaEscaladaA(int espera, String nombre) {
    return 'Sin respuesta en $espera min: aviso a $nombre (secundario)';
  }

  @override
  String alertaLineaSinSecundario(int espera) {
    return 'Sin respuesta en $espera min y sin secundario';
  }

  @override
  String alertaLineaAtendidaPor(String nombre) {
    return 'Atendida por $nombre';
  }

  @override
  String alertaLineaAntesDeEscalar(int espera) {
    return 'Atendida antes de $espera min: sin escalar';
  }

  @override
  String alertaLineaFalsaAlarma(String nombre) {
    return 'Falsa alarma, marcada por $nombre';
  }

  @override
  String get alertaMarcadaFalsa => 'Marcada como falsa alarma';

  @override
  String get alertaAtendidaToast => 'Alerta atendida';

  @override
  String alertaToastFamiliaVera(String hora) {
    return 'La familia verá que la marcaste a las $hora.';
  }

  @override
  String get alertaMarcarPregunta => '¿Cómo terminó esta alerta?';

  @override
  String alertaMarcarResumen(
    String tipo,
    String sala,
    String hora,
    String habitacion,
  ) {
    return '$tipo en $sala a las $hora.';
  }

  @override
  String get alertaOpcionAtendida => 'Atendida';

  @override
  String alertaOpcionAtendidaDetalle(String nombre) {
    return '$nombre recibió ayuda o está bien';
  }

  @override
  String get alertaOpcionFalsa => 'Falsa alarma';

  @override
  String get alertaOpcionFalsaCaida => 'No hubo caída.';

  @override
  String get alertaOpcionFalsaInestable => 'No hubo movimiento inestable.';

  @override
  String get alertaEligeOpcion => 'Elige una opción.';

  @override
  String alertaQuedaraRegistrado(String quien, String hora) {
    return 'Quedará registrado: $quien · $hora';
  }

  @override
  String get alertaGuardar => 'Guardar';

  @override
  String get alertaDetalleTitulo => 'Alerta';

  @override
  String alertaDetalleTituloFecha(String fecha) {
    return 'Alerta del $fecha';
  }

  @override
  String get alertaGrabacion => 'Grabación';

  @override
  String get alertaVerQuePaso => 'Ver qué pasó';

  @override
  String get alertaVerQuePasoSinVideo => 'En la cámara, sin video';

  @override
  String get alertaVerQuePasoRequiere => 'Requiere guardar movimientos';

  @override
  String get alertaRegistroEvento => 'Registro del evento';

  @override
  String alertaMomentos(int n) {
    return '$n momentos';
  }

  @override
  String get alertaTerminoEnCaida => '¿Terminó en caída y no avisamos?';

  @override
  String get alertaMarcadaAtendida => 'Marcada como atendida';

  @override
  String alertaMarcadaPor(String nombre, String hora) {
    return 'por $nombre a las $hora';
  }

  @override
  String get alertaGrabacionDescargada => 'Grabación descargada';

  @override
  String alertaGrabacionEnArchivos(String archivo) {
    return '$archivo en Archivos';
  }

  @override
  String get alertaDescargarGrabacion => 'Descargar grabación';

  @override
  String alertaDescargaDetalle(String fecha) {
    return 'MP4 · 12 s · hasta el $fecha';
  }

  @override
  String get clipBorradoTitulo => 'La grabación ya no está disponible';

  @override
  String clipBorradoDetalle(String fecha) {
    return 'Se borró el $fecha (se guardan 30 días).';
  }

  @override
  String get clipNoDisponible => 'Clip no disponible';

  @override
  String get clipSigueValida => 'La alerta sigue siendo válida.';

  @override
  String get clipPantallaCompleta => 'Ver el clip en pantalla completa';

  @override
  String get clipAyuda =>
      'El clip dura 12 s: 6 s antes y 6 s después de la alerta.';

  @override
  String get clipAyudaTema => 'el clip';

  @override
  String get clipSalirPantallaCompleta => 'Salir de pantalla completa';

  @override
  String clipPuntosSinPermiso(String nombre) {
    return 'falta el permiso de $nombre para guardar movimientos';
  }

  @override
  String get clipPuntosNoLosTiene => 'este clip no los tiene';

  @override
  String get clipPuntosNoCargaron => 'no se pudieron cargar';

  @override
  String get clipPuntosTitulo => 'Puntos del cuerpo';

  @override
  String clipPuntosNoDisponibles(String motivo) {
    return 'No disponibles: $motivo.';
  }

  @override
  String get clipPausar => 'Pausar clip';

  @override
  String get clipVolverAVer => 'Volver a ver el clip';

  @override
  String get clipReproducir => 'Reproducir clip';

  @override
  String get clipRetroceder => 'Retroceder 5 segundos';

  @override
  String get clipAdelantar => 'Adelantar 5 segundos';

  @override
  String clipVelocidad(String velocidad) {
    return 'Velocidad $velocidad. Cambiar la velocidad';
  }

  @override
  String get clipAvance => 'Avance del clip';

  @override
  String get clipMomentoEvento => 'Momento del evento';

  @override
  String get repeticionEventoCaida => 'Caída';

  @override
  String get repeticionEventoInestable => 'Inestable';

  @override
  String get repeticionEventoLevanto => 'Se levantó';

  @override
  String get repeticionSinDatos => 'Sin datos';

  @override
  String get repeticionFaseLevanto => 'Se levantó';

  @override
  String get repeticionFaseInestable => 'Movimiento inestable';

  @override
  String get repeticionFasePosibleCaida => 'Posible caída';

  @override
  String get repeticionFaseEnSuelo => 'En el suelo';

  @override
  String get repeticionNoMasEventosDia => 'No hay más eventos este día';

  @override
  String get repeticionNoMasEventos => 'No hay más eventos';

  @override
  String get repeticionNoEventosAntes => 'No hay eventos antes';

  @override
  String get repeticionHoy => 'Hoy';

  @override
  String get repeticionAyer => 'Ayer';

  @override
  String repeticionVerEnVivo(String habitacion) {
    return 'Ver $habitacion en vivo';
  }

  @override
  String get repeticionEnVivo => 'En vivo';

  @override
  String get repeticionCargando => 'Cargando…';

  @override
  String get repeticionSinInternet => 'Sin internet';

  @override
  String repeticionPermisoRetirado(String nombre) {
    return '$nombre retiró el permiso. Se borraron sus movimientos.';
  }

  @override
  String get repeticionSinPersona => 'Sin persona en la imagen';

  @override
  String repeticionIrAEvento(String hora, String evento) {
    return '$hora, $evento. Ir a este momento';
  }

  @override
  String get repeticionMomento => 'Momento de la repetición';

  @override
  String get repeticionEventoAnterior => 'Evento anterior';

  @override
  String get repeticionRetroceder => 'Retroceder 10 segundos';

  @override
  String get repeticionPausar => 'Pausar';

  @override
  String get repeticionReproducir => 'Reproducir';

  @override
  String get repeticionEventoSiguiente => 'Evento siguiente';

  @override
  String get repeticionAdelantar => 'Adelantar 10 segundos';

  @override
  String get repeticionElegirDia => 'Elegir día';

  @override
  String repeticionHayMovimientosDesde(String fecha) {
    return 'Hay movimientos desde el $fecha.';
  }

  @override
  String get repeticionConEventos => 'Con eventos';

  @override
  String repeticionDiaSinMovimientos(String fecha) {
    return '$fecha, sin movimientos';
  }

  @override
  String repeticionDiaConEventos(String fecha) {
    return '$fecha, con eventos';
  }

  @override
  String get reportesEnlace => '¿Hubo una caída y no avisó?';

  @override
  String get reportesNoSe => 'No sé';

  @override
  String get reportesHoraFormato => 'Escribe la hora así: 07:30.';

  @override
  String get reportesHoraFutura => 'Elige una hora que ya pasó.';

  @override
  String get reportesFecha => 'Fecha';

  @override
  String get reportesHoy => 'Hoy';

  @override
  String get reportesAyer => 'Ayer';

  @override
  String get reportesHoraAproximada => 'Hora aproximada';

  @override
  String get reportesTitulo => 'Contarnos qué pasó';

  @override
  String reportesSamuConNombre(String nombre) {
    return 'Si $nombre necesita ayuda ahora, llama al SAMU · 106';
  }

  @override
  String get reportesSamu => 'Si necesita ayuda ahora, llama al SAMU · 106';

  @override
  String get reportesLlamarSamu => 'Llamar al SAMU · 106';

  @override
  String get reportesPregunta => '¿Hubo una caída y no te avisamos?';

  @override
  String get reportesRevisaremos => 'Lo revisaremos para mejorar la detección.';

  @override
  String get reportesHabitacion => 'Habitación';

  @override
  String get reportesEligeHabitacion => 'Elige la habitación o «No sé».';

  @override
  String get reportesQuePaso => '¿Qué pasó? (opcional)';

  @override
  String get reportesNotaEjemplo => 'Ej.: Se resbaló al salir de la cama';

  @override
  String get reportesEnviar => 'Enviar';

  @override
  String get reportesEnviando => 'Enviando…';

  @override
  String get reportesMovimientosHay =>
      'Revisaremos los movimientos de ese momento.';

  @override
  String get reportesMovimientosNo =>
      'Sin movimientos de ese momento; revisaremos tu relato.';

  @override
  String get reportesGuardado => 'Lo guardamos para enviarlo';

  @override
  String get reportesGracias => 'Gracias. Lo revisaremos.';

  @override
  String reportesGraciasNombre(String nombre) {
    return 'Gracias, $nombre. Lo revisaremos.';
  }

  @override
  String get reportesNoPudimosTitulo => 'No pudimos enviarlo';

  @override
  String get reportesNoPudimosTexto =>
      'Lo guardamos y lo enviaremos cuando vuelva la conexión.';

  @override
  String get reportesNoGeneraAlerta =>
      'Esto no genera una alerta ni avisa a la familia.';

  @override
  String get reportesVolverHistorial => 'Volver al historial';

  @override
  String get appTitulo => 'Te Tengo';

  @override
  String get camaraEstadoEnLinea => 'En línea';

  @override
  String get camaraEstadoDesconectada => 'Desconectada';

  @override
  String get camaraEstadoEnPausa => 'En pausa';

  @override
  String get camaraEstadoNoConfiable => 'Detección no confiable';

  @override
  String get camaraEstadoDetenida => 'Detenida';

  @override
  String get camaraEstadoSinConexion => 'Sin conexión';

  @override
  String get camaraPausa30Min => '30 minutos';

  @override
  String get camaraPausa1Hora => '1 hora';

  @override
  String get camaraPausa2Horas => '2 horas';

  @override
  String get camaraPausaHastaManana => 'Hasta mañana';

  @override
  String camaraPausaFinHasta(String hora) {
    return 'hasta las $hora';
  }

  @override
  String camaraPausaFinALas(String hora) {
    return 'a las $hora';
  }

  @override
  String camaraFinDePausaManana(String hora) {
    return '$hora de mañana';
  }

  @override
  String camaraEnHabitacion(String habitacion) {
    return 'en $habitacion';
  }

  @override
  String camaraReactivadaTitulo(String habitacion) {
    return 'Cámara $habitacion reactivada';
  }

  @override
  String get camaraReactivadaTexto =>
      'La detección y la vista en vivo vuelven a estar disponibles.';

  @override
  String camaraEnPausaTitulo(String habitacion) {
    return 'Cámara $habitacion en pausa';
  }

  @override
  String camaraSeReactivaraALas(String hora) {
    return 'Se reactivará sola a las $hora.';
  }

  @override
  String camaraPausarTitulo(String habitacion) {
    return 'Pausar la cámara $habitacion';
  }

  @override
  String get camaraPausarTexto =>
      'Sin detección ni vista en vivo. Se reactiva sola.';

  @override
  String get camaraPausar => 'Pausar';

  @override
  String camaraAvisoDesconectadaTitulo(String habitacion) {
    return 'La cámara $habitacion se desconectó';
  }

  @override
  String get camaraAvisoDesconectadaTexto =>
      'Revisa el cable de la cámara, que la PC esté encendida y el internet de la casa.';

  @override
  String camaraAvisoReconectadaTitulo(String habitacion) {
    return 'La cámara $habitacion volvió a estar en línea';
  }

  @override
  String camaraAvisoReconectadaTexto(String hora) {
    return 'El monitoreo se restableció a las $hora.';
  }

  @override
  String camaraAvisoReactivadaTitulo(String habitacion) {
    return 'La cámara $habitacion se reactivó';
  }

  @override
  String camaraAvisoReactivadaTexto(String hora) {
    return 'Terminó la pausa a las $hora.';
  }

  @override
  String camaraAvisoNoConfiableTitulo(String enHabitacion) {
    return 'La detección no es confiable $enHabitacion';
  }

  @override
  String camaraAvisoNoConfiableTexto(String nombre) {
    return 'Hace más de 5 minutos que la cámara no ve bien a $nombre. Revisa la luz y el encuadre.';
  }

  @override
  String get camaraFavorita => 'Favorita';

  @override
  String camaraFavoritaDe(String habitacion) {
    return 'Favorita: $habitacion';
  }

  @override
  String get camaraUltimaSenalPrefijo => 'última señal ';

  @override
  String get camaraDesdeLasPrefijo => 'desde las ';

  @override
  String camaraHastaLas(String hora) {
    return 'hasta las $hora';
  }

  @override
  String get camaraRevisaLuzEncuadre => 'revisa la luz y el encuadre';

  @override
  String get camaraSinConsentimiento => 'sin consentimiento';

  @override
  String get camaraPcNoResponde => 'la PC no responde';

  @override
  String camaraHaceSegundos(int n) {
    return 'hace $n s';
  }

  @override
  String camaraHaceMinutos(int n) {
    return 'hace $n min';
  }

  @override
  String camaraHaceHoras(int n) {
    return 'hace $n h';
  }

  @override
  String get camarasOrdenar => 'Ordenar';

  @override
  String get camarasListo => 'Listo';

  @override
  String get camarasOrdenarTexto => 'Favoritas primero. Solo en este celular.';

  @override
  String get camarasFavoritas => 'Favoritas';

  @override
  String get camarasTitulo => 'Cámaras';

  @override
  String get camarasLasDemas => 'Las demás';

  @override
  String camarasArrastrar(String habitacion) {
    return 'Arrastrar $habitacion';
  }

  @override
  String camarasSubir(String habitacion) {
    return 'Subir $habitacion';
  }

  @override
  String camarasBajar(String habitacion) {
    return 'Bajar $habitacion';
  }

  @override
  String camaraNombreOcupada(String enHabitacion) {
    return 'Ya hay una cámara $enHabitacion. Por ahora, cada habitación usa una sola cámara.';
  }

  @override
  String get camaraNombreVacio => 'Escribe el nombre de la habitación.';

  @override
  String get camaraNombreBano =>
      'Por privacidad, Te Tengo no admite cámaras en el baño.';

  @override
  String camaraNombreGuardado(String nombre) {
    return 'Nombre guardado: $nombre';
  }

  @override
  String camaraNombreProximasAlertas(String enHabitacion) {
    return 'Las próximas alertas dirán «$enHabitacion».';
  }

  @override
  String get camaraNombreTitulo => 'Nombre de la habitación';

  @override
  String get camaraNombreMarcador => 'Ej.: Sala comedor';

  @override
  String get camaraNombreSugerencias => 'Sugerencias';

  @override
  String get camaraNombreYaTienen =>
      'Las que ya tienen cámara no se pueden elegir.';

  @override
  String get camaraNombreAsiSeVera => 'Así se verá en las próximas alertas';

  @override
  String get camaraNombrePosibleCaidaVacia => 'Posible caída …';

  @override
  String camaraNombrePosibleCaida(String enHabitacion) {
    return 'Posible caída $enHabitacion';
  }

  @override
  String get camaraNombreAnteriores => 'Las alertas anteriores no cambian.';

  @override
  String get camaraNombreGuardar => 'Guardar nombre';

  @override
  String get camaraTitulo => 'Cámara';

  @override
  String get camaraAjustes => 'Ajustes de la cámara';

  @override
  String camaraRepeticionAcceso(String habitacion, String duracion) {
    return 'Repetición $habitacion · $duracion';
  }

  @override
  String get camaraPcNoRespondeMotivo => 'La PC no responde';

  @override
  String get camaraDesconectadaMotivo => 'Cámara desconectada';

  @override
  String get camaraActivar => 'Activar';

  @override
  String camaraSoloTitularActiva(String nombre) {
    return 'Solo $nombre puede activarlo';
  }

  @override
  String get camaraDetenidaSinConsentimiento =>
      'Detenida: falta el consentimiento';

  @override
  String get camaraRegistrarConsentimiento => 'Registrar consentimiento';

  @override
  String get camaraSinInternet => 'Sin internet';

  @override
  String get camaraActivaGuardarMovimientos =>
      'Para ver lo que pasó, activa Guardar movimientos';

  @override
  String get camaraActivaNube =>
      'Para ver lo que pasó, activa Movimientos en la nube';

  @override
  String camaraNoHayMovimientos(String dia, String desde) {
    return 'No hay movimientos del $dia. Hay desde el $desde.';
  }

  @override
  String get camaraVerLoUltimo => 'Ver lo último';

  @override
  String get camaraCargando => 'Cargando…';

  @override
  String get camaraAyudaPrivacidad =>
      'Solo puntos del cuerpo, nunca video. Cada repetición queda en el registro de accesos.';

  @override
  String get camaraAjustesResumen => 'Pausa, nombre, registro';

  @override
  String get camaraRevisarCable => 'El cable USB de la cámara';

  @override
  String get camaraRevisarPc => 'La PC encendida';

  @override
  String get camaraRevisarPcDetalle => 'Con Te Tengo Captura abierto';

  @override
  String get camaraRevisarInternet => 'El internet de la casa';

  @override
  String get camaraRevisarLuz => 'La luz';

  @override
  String get camaraRevisarLuzDetalle => 'De noche, una lámpara pequeña';

  @override
  String get camaraRevisarEncuadre => 'El encuadre';

  @override
  String camaraRevisarEncuadreDetalle(String nombre) {
    return 'Que se vea a $nombre de cuerpo entero';
  }

  @override
  String get camaraQueRevisar => 'Qué revisar';

  @override
  String get camaraHoy => 'Hoy';

  @override
  String get camaraAyer => 'Ayer';

  @override
  String get camaraElegirDia => 'Elegir día…';

  @override
  String get camara10Min => '10 min';

  @override
  String get camara1Hora => '1 hora';

  @override
  String get camaraSoloEventos => 'Solo eventos';

  @override
  String camaraEventosDe(String dia) {
    return 'Eventos · $dia';
  }

  @override
  String get camaraSinEventosHoy => 'Sin eventos hoy';

  @override
  String get camaraSinEventosAyer => 'Sin eventos ayer';

  @override
  String camaraSinEventosEl(String dia) {
    return 'Sin eventos el $dia';
  }

  @override
  String get camaraUltimosEventos => 'Últimos eventos';

  @override
  String get camaraCaida => 'Caída';

  @override
  String get camaraInestable => 'Inestable';

  @override
  String get camaraReanudarAhora => 'Reanudar ahora';

  @override
  String camaraEnPausaHastaLas(String hora) {
    return 'En pausa hasta las $hora';
  }

  @override
  String get camaraSinDeteccionNiVivo => 'Sin detección ni vista en vivo';

  @override
  String camaraNombreDe(String habitacion) {
    return 'Nombre: $habitacion';
  }

  @override
  String camaraPcNombre(String nombre) {
    return 'PC $nombre';
  }

  @override
  String get camaraPcDeLaCasa => 'PC de la casa';

  @override
  String camaraDesdeElFecha(String fecha) {
    return 'desde el $fecha';
  }

  @override
  String get camaraHuboCaida => '¿Hubo una caída y no avisó?';

  @override
  String get camaraDejarDeUsar => 'Dejar de usar esta cámara';

  @override
  String camaraDispositivoDeHabitacion(String habitacion) {
    return 'de la $habitacion';
  }

  @override
  String camaraDesconectadaDesde(String hora) {
    return 'Desconectada desde las $hora';
  }

  @override
  String camaraSinConexionDesde(String hora) {
    return 'Sin conexión desde las $hora';
  }

  @override
  String get accesosTitulo => 'Registro de accesos';

  @override
  String get accesosRegistrado => 'Acceso registrado';

  @override
  String get accesosIntro =>
      'Quién miró, cuándo y cuánto. Toda la familia lo ve.';

  @override
  String get accesosVacio => 'Aún no hay accesos registrados';

  @override
  String get accesosTodo => 'Todo';

  @override
  String get accesosVistaEnVivo => 'Vista en vivo';

  @override
  String get accesosRepeticiones => 'Repeticiones';

  @override
  String accesosNombreTu(String nombre) {
    return '$nombre (tú)';
  }

  @override
  String accesosVio(String quien, String habitaciones) {
    return '$quien vio $habitaciones';
  }

  @override
  String get accesosVariasCamaras => 'Varias cámaras';

  @override
  String accesosVistaEnVivoDe(String habitacion) {
    return 'Vista en vivo · $habitacion';
  }

  @override
  String get accesosVistaPrevia => 'Vista previa al elegir cámaras';

  @override
  String accesosVistaPreviaDe(String dispositivo) {
    return 'Vista previa al elegir cámaras · $dispositivo';
  }

  @override
  String accesosRepeticion(String habitacion, String dia, String hora) {
    return 'Repetición · $habitacion, $dia $hora';
  }

  @override
  String get accesosDesdeAlerta => 'Desde una alerta';

  @override
  String get accesosAbrirDeNuevo => 'Abrir de nuevo';

  @override
  String get accesosSinAccesos => 'Sin accesos';

  @override
  String get accesosTu => 'Tú';

  @override
  String get accesosHoyMinuscula => 'hoy';

  @override
  String accesosResumen(String quien, String dia, String hora) {
    return '$quien · $dia $hora';
  }

  @override
  String vivoViste(String habitacion, String duracion) {
    return 'Viste $habitacion en vivo durante $duracion.';
  }

  @override
  String get vivoVolverAlerta => 'Volver a la alerta';

  @override
  String get vivoVolverATodas => 'Volver a todas';

  @override
  String get vivoCerrar => 'Cerrar la vista en vivo';

  @override
  String get vivoTitulo => 'En vivo';

  @override
  String vivoTituloDe(String habitacion) {
    return 'En vivo · $habitacion';
  }

  @override
  String get vivoVerEnVivo => 'Ver en vivo';

  @override
  String vivoLlamarA(String nombre) {
    return 'Llamar a $nombre';
  }

  @override
  String get vivoReanudarCamara => 'Reanudar la cámara ahora';

  @override
  String get vivoPrivacidad =>
      'No se graba. Tu acceso queda en el registro que ve toda la familia: quién, cuándo y cuánto.';

  @override
  String get vivoEtiqueta => 'EN VIVO';

  @override
  String vivoNoDisponibleTitulo(String habitacion) {
    return 'La cámara $habitacion no está disponible';
  }

  @override
  String get vivoSinConexionDesdePrefijo => 'Sin conexión desde las ';

  @override
  String vivoLlamaOPide(String nombre) {
    return 'Llama a $nombre o pide a alguien cercano que vaya a verla.';
  }

  @override
  String get vivoRevisaCable =>
      'Revisa el cable, la PC y el internet de la casa.';

  @override
  String get vivoNoDisponible => 'Vista en vivo no disponible';

  @override
  String get vivoEnPausaHastaPrefijo => 'En pausa hasta las ';

  @override
  String vivoCamaraEnPausa(String habitacion) {
    return 'La cámara $habitacion está en pausa.';
  }

  @override
  String get vivoDetenidaTitulo => 'La cámara está detenida';

  @override
  String vivoSinConsentimiento(String nombre) {
    return 'Sin el consentimiento de $nombre no hay video.';
  }

  @override
  String vivoSinConexionPc(String pc) {
    return 'Sin conexión · la PC $pc no responde';
  }

  @override
  String get vivoDesdeLasPrefijo => ' desde las ';

  @override
  String get vivoDetenidaSinConsentimiento => 'Detenida · sin consentimiento';

  @override
  String get vivoQueHabitacion => '¿Qué habitación quieres ver?';

  @override
  String get vivoVerTodasALaVez => 'Ver todas a la vez';

  @override
  String get vivoHasta4PorPagina => 'Hasta 4 por página';

  @override
  String get vivoDisponibleAhora => 'Disponible ahora';

  @override
  String get vivoQueSeVe => 'Qué se ve';

  @override
  String get vivoModoVideo => 'Video';

  @override
  String get vivoModoEsqueleto => 'Esqueleto';

  @override
  String get mosaicoPrivacidad =>
      'No se graba. Al cerrar queda un solo acceso en el registro, con las habitaciones vistas y la duración.';

  @override
  String mosaicoHastaLas(String hora) {
    return 'Hasta las $hora';
  }

  @override
  String mosaicoDesdeLas(String hora) {
    return 'Desde las $hora';
  }

  @override
  String get mosaicoPcNoResponde => 'La PC no responde';

  @override
  String get mosaicoSinConsentimiento => 'Sin consentimiento';

  @override
  String mosaicoSeMovio(String habitacion) {
    return '$habitacion se movió';
  }

  @override
  String get mosaicoMismoOrden => 'Mismo orden en Cámaras y Ver en vivo.';

  @override
  String get mosaicoFavoritasPrimero => 'Las favoritas van primero';

  @override
  String get mosaicoCambiaEstrella =>
      'Cambia la estrella para pasarla al otro grupo.';

  @override
  String mosaicoViste(String habitaciones, String duracion) {
    return 'Viste $habitaciones · $duracion.';
  }

  @override
  String get mosaicoTodas => 'Todas en vivo';

  @override
  String mosaicoTodasPagina(int pagina, int total) {
    return 'Todas en vivo, página $pagina de $total';
  }

  @override
  String get mosaicoEligeCamara => 'Elige una cámara para moverla';

  @override
  String get mosaicoArrastraOMuevePrefijo => 'Arrastra o mueve ';

  @override
  String get mosaicoMoverAntes => 'Mover antes';

  @override
  String get mosaicoMoverDespues => 'Mover después';

  @override
  String get mosaicoCerrar => 'Cerrar';

  @override
  String get mosaicoVertical => 'Vertical';

  @override
  String get mosaicoOrdenarCamaras => 'Ordenar las cámaras';

  @override
  String get mosaicoControles => 'Controles de Ver todas';

  @override
  String get mosaicoReanudar => 'Reanudar';

  @override
  String get mosaicoCerrarVerTodas => 'Cerrar Ver todas';

  @override
  String get mosaicoVerHorizontal => 'Ver en horizontal';

  @override
  String get mosaicoPaginaAnterior => 'Página anterior';

  @override
  String get mosaicoPaginaSiguiente => 'Página siguiente';

  @override
  String mosaicoPagina(int pagina, int total) {
    return 'Página $pagina de $total';
  }

  @override
  String get mosaicoEnVivoMinuscula => 'en vivo';

  @override
  String mosaicoCeldaEtiqueta(String habitacion, String estado, String accion) {
    return '$habitacion, $estado. $accion';
  }

  @override
  String get mosaicoElegirParaMover => 'Elegir para mover';

  @override
  String get mosaicoAbrirCompleta => 'Abrir en pantalla completa';

  @override
  String get mosaicoPistaOrdenando =>
      'Arrástrala o usa Mover antes y Mover después';

  @override
  String get mosaicoPistaMantener => 'Mantén presionado para moverla';

  @override
  String get mosaicoQuitarFavorita => 'Quitar de favoritas';

  @override
  String get mosaicoMarcarFavorita => 'Marcar como favorita';

  @override
  String get mosaicoVerCompleta => 'Ver en pantalla completa';

  @override
  String familiaNombreTu(String nombre) {
    return '$nombre (tú)';
  }

  @override
  String get familiaPapelPrincipal => 'Principal';

  @override
  String get familiaPapelSecundario => 'Secundario';

  @override
  String get familiaPapelFamiliar => 'Recibe alertas';

  @override
  String familiaResumenParentescoTitular(String parentesco) {
    return '$parentesco · titular';
  }

  @override
  String get familiaResumenTitular => 'titular de la cuenta';

  @override
  String get familiaTitularCuenta => 'Titular de la cuenta';

  @override
  String get familiaTitulo => 'Familia';

  @override
  String familiaReciben(String nombre) {
    return 'Reciben las alertas de $nombre.';
  }

  @override
  String get familiaOrdenFila => 'Orden de aviso y tiempo de espera';

  @override
  String familiaOrdenSinSecundario(String principal) {
    return '$principal · sin contacto secundario';
  }

  @override
  String familiaOrdenResumen(String principal, String secundario, int minutos) {
    return '$principal → $secundario · $minutos min de espera';
  }

  @override
  String get familiaSinSecundarioTitulo => 'No hay contacto secundario';

  @override
  String familiaSinSecundarioTexto(String principal) {
    return 'Si $principal no atiende a tiempo, nadie más será avisado.';
  }

  @override
  String get familiaInvitar => 'Invitar a un familiar';

  @override
  String get familiaSoloLecturaInvitar =>
      'invitar o retirar familiares y cambiar el orden de aviso';

  @override
  String get familiaFamiliarTitulo => 'Familiar';

  @override
  String get familiaTuPerfilTitulo => 'Tu perfil en la familia';

  @override
  String get familiaHacerPrincipal => 'Hacer contacto principal';

  @override
  String get familiaHacerPrincipalDetalle => 'Recibirá cada alerta primero';

  @override
  String get familiaHacerSecundario => 'Hacer contacto secundario';

  @override
  String familiaHacerSecundarioDetalle(int minutos) {
    return 'Recibe la alerta si nadie atiende en $minutos min';
  }

  @override
  String get familiaRetirarAcceso => 'Retirar acceso';

  @override
  String get familiaContacto => 'Contacto';

  @override
  String get familiaTelefono => 'Teléfono';

  @override
  String get familiaLlamar => 'Llamar';

  @override
  String get familiaCorreo => 'Correo';

  @override
  String get familiaEnLasAlertas => 'En las alertas';

  @override
  String get familiaPapelPrincipalDetalle => 'Recibe cada alerta primero';

  @override
  String familiaPapelSecundarioDetalle(int minutos) {
    return 'Le avisamos si nadie atiende en $minutos min';
  }

  @override
  String get familiaPapelFamiliarDetalle =>
      'Se entera de todo, sin escalamiento';

  @override
  String get familiaActividad => 'Actividad';

  @override
  String familiaAlertasMarcadas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n alertas marcadas',
      one: '1 alerta marcada',
    );
    return '$_temp0';
  }

  @override
  String familiaUltimaMarcada(
    String tipo,
    String habitacion,
    String habitacionConArticulo,
    String fecha,
  ) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'caida': 'Caída',
      'other': 'Inestable',
    });
    return 'Última: $_temp0 en $habitacionConArticulo · $fecha · ';
  }

  @override
  String get familiaSinMarcadas => 'Aún no marcó alertas';

  @override
  String familiaAccesosCamara(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n accesos a la cámara',
      one: '1 acceso a la cámara',
    );
    return '$_temp0';
  }

  @override
  String familiaUltimoAcceso(String cuando) {
    return 'Último: $cuando ';
  }

  @override
  String get familiaHoy => 'hoy';

  @override
  String get familiaSinAccesos => 'Aún no abrió la vista en vivo';

  @override
  String get familiaAvisoDejarPrincipal =>
      'Para dejar de ser principal, elige a otro contacto.';

  @override
  String get familiaAvisoRetirarPrincipal =>
      'Para retirar su acceso, primero elige a otro contacto principal.';

  @override
  String get familiaOpciones => 'Opciones';

  @override
  String get familiaSoloLecturaPapel =>
      'cambiar el papel de un familiar o retirar su acceso';

  @override
  String familiaAhoraEsContacto(String nombre, String papel) {
    String _temp0 = intl.Intl.selectLogic(papel, {
      'principal': 'principal',
      'other': 'secundario',
    });
    return '$nombre ahora es contacto $_temp0';
  }

  @override
  String get familiaOrdenActualizado => 'El orden de aviso se actualizó.';

  @override
  String familiaRetirarTitulo(String nombre) {
    return '¿Retirar el acceso de $nombre?';
  }

  @override
  String get familiaRetirarTexto =>
      'Dejará de recibir alertas y de ver el historial.';

  @override
  String get familiaRetirarTextoSecundario =>
      'Dejará de recibir alertas y de ver el historial. Te quedarás sin contacto secundario.';

  @override
  String get familiaCancelar => 'Cancelar';

  @override
  String familiaYaNoRecibe(String nombre) {
    return '$nombre ya no recibe alertas';
  }

  @override
  String get familiaQuedasteSinSecundario =>
      'Te quedaste sin contacto secundario.';

  @override
  String get familiaOrdenTitulo => 'Orden de aviso';

  @override
  String get familiaSoloLecturaOrden =>
      'cambiar el orden de aviso y el tiempo de espera';

  @override
  String get familiaOrdenExplicacion =>
      'Si el principal no marca la alerta a tiempo, avisamos al secundario.';

  @override
  String get familiaQuienResponde => 'Quién responde';

  @override
  String get familiaContactoPrincipal => 'Contacto principal';

  @override
  String get familiaSinSecundario => 'Sin contacto secundario';

  @override
  String get familiaNadieMasRecibe => 'Nadie más recibe el aviso.';

  @override
  String familiaContactoSecundarioA(int minutos) {
    return 'Contacto secundario · a los $minutos min';
  }

  @override
  String get familiaTiempoEspera => 'Tiempo de espera';

  @override
  String get familiaAntesDeAvisar => 'Antes de avisar al secundario.';

  @override
  String familiaMinutos(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: '$minutos minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get familiaPredeterminado => 'Predeterminado';

  @override
  String familiaEsperaToast(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: 'Tiempo de espera: $minutos minutos',
      one: 'Tiempo de espera: 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get familiaEsperaToastTexto => 'Se aplicará en las próximas alertas.';

  @override
  String familiaEjemploEspera(String inicio, String nombre, String fin) {
    return 'Ej.: alerta a las $inicio sin atender → $nombre a las $fin.';
  }

  @override
  String get familiaUsaConSecundario =>
      'Se usa cuando haya un contacto secundario.';

  @override
  String familiaCambiarContacto(String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'principal',
      'other': 'secundario',
    });
    return 'Cambiar contacto $_temp0';
  }

  @override
  String get familiaCambiar => 'Cambiar';

  @override
  String get familiaPrimeroOtroPrincipal => 'Primero elige otro principal';

  @override
  String familiaYaEsPrincipal(String nombre) {
    return '$nombre ya es el contacto principal.';
  }

  @override
  String familiaEsContacto(String nombre, String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'principal',
      'other': 'secundario',
    });
    return '$nombre es contacto $_temp0';
  }

  @override
  String get familiaUsaremosOrden =>
      'Usaremos este orden en las próximas alertas.';

  @override
  String familiaQuienSera(String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'principal',
      'other': 'secundario',
    });
    return '¿Quién será el contacto $_temp0?';
  }

  @override
  String get familiaAtiendePrimero => 'Atiende cada alerta primero.';

  @override
  String familiaLeAvisamos(int minutos) {
    return 'Le avisamos si nadie la marca en $minutos min.';
  }

  @override
  String familiaOrdenAhora(String papel) {
    return 'ahora: $papel';
  }

  @override
  String get familiaQuitarSecundario => 'Quitar contacto secundario';

  @override
  String get familiaNadieMasSeraAvisado =>
      'Nadie más será avisado si no se atiende una alerta.';

  @override
  String get invitarCorreoVacio => 'Escribe su correo electrónico.';

  @override
  String get invitarPropioCorreo =>
      'Ese es tu propio correo. Invita a otra persona.';

  @override
  String invitarYaEnFamilia(String nombre) {
    return 'Esa persona ya está en la familia de $nombre.';
  }

  @override
  String get invitarEnviada => 'Invitación enviada';

  @override
  String invitarEnviadaTexto(String correo) {
    return 'Le enviamos un enlace a $correo.';
  }

  @override
  String get invitarQuePodra => 'Qué podrá hacer';

  @override
  String get invitarPuntoVer => 'Ver alertas, historial y la cámara en vivo';

  @override
  String get invitarPuntoMarcar => 'Marcar alertas y pausar la cámara';

  @override
  String get invitarPuntoNoCambia =>
      'No cambia datos, consentimiento, cámaras ni familia';

  @override
  String get invitarEnviar => 'Enviar invitación';

  @override
  String invitarTeInvito(String titular, String adulto) {
    return '$titular te invitó a cuidar a $adulto';
  }

  @override
  String get invitarCrearAcceso => 'Crear mi acceso';

  @override
  String get invitarCreaTuAcceso => 'Crea tu acceso para recibir sus alertas.';

  @override
  String get invitarCampoClave => 'Crea una contraseña';

  @override
  String invitarListo(String yo, String adulto) {
    return 'Listo, $yo. Ya recibes las alertas de $adulto.';
  }

  @override
  String get invitarPuedes => 'Puedes';

  @override
  String get invitarPuedesDetalle =>
      'Ver alertas, clips y la cámara en vivo; marcar alertas y pausar.';

  @override
  String invitarSoloPuede(String titular) {
    return 'Solo $titular puede';
  }

  @override
  String get invitarSoloPuedeDetalle =>
      'Cambiar datos, consentimiento, cámaras y familia.';

  @override
  String get invitarIrInicio => 'Ir al inicio';

  @override
  String get perfilErrorSubir =>
      'No se pudo subir la foto. Vuelve a intentarlo.';

  @override
  String get perfilTitulo => 'Tu perfil';

  @override
  String get perfilCampoNombre => 'Nombre y apellido';

  @override
  String get perfilCorreoAyuda => 'Con él inicias sesión.';

  @override
  String get perfilErrorTelefono => 'Revisa el teléfono: solo números.';

  @override
  String get perfilCambiosGuardados => 'Cambios guardados';

  @override
  String get perfilNombreNuevo => 'Tu familia verá tu nombre nuevo.';

  @override
  String get perfilCampoTelefono => 'Teléfono';

  @override
  String get perfilParentesco => 'Parentesco';

  @override
  String perfilParentescoCon(String nombre) {
    return 'Parentesco con $nombre';
  }

  @override
  String get perfilParentescoMarcador => 'Ej.: Hija, sobrino, vecina';

  @override
  String get perfilGuardarCambios => 'Guardar cambios';

  @override
  String get perfilCambiarContrasena => 'Cambiar contraseña';

  @override
  String get perfilQuitandoFoto => 'Quitando la foto';

  @override
  String get perfilSubiendoFoto => 'Subiendo la foto';

  @override
  String perfilPorcentaje(int n) {
    return '$n %';
  }

  @override
  String get perfilCambiarFoto => 'Cambiar foto';

  @override
  String get perfilQuitando => 'Quitando…';

  @override
  String get perfilSubiendo => 'Subiendo…';

  @override
  String perfilSubiendoPorcentaje(int n) {
    return 'Subiendo… $n %';
  }

  @override
  String get perfilNoSeCambioFoto => 'No se pudo cambiar la foto';

  @override
  String get perfilVolverIntentar => 'Volver a intentarlo';

  @override
  String get perfilFotoQuitada => 'Foto quitada';

  @override
  String get perfilSeVeranIniciales => 'Se verán las iniciales.';

  @override
  String get perfilNoPudimosAbrir => 'No pudimos abrir esa foto';

  @override
  String get perfilEligeOtra => 'Elige otra.';

  @override
  String get perfilNoPudimosAbrirEligeOtra =>
      'No pudimos abrir esa foto. Elige otra.';

  @override
  String get perfilFotoActualizada => 'Foto actualizada';

  @override
  String get perfilLaVeraFamilia => 'La verá toda la familia.';

  @override
  String get perfilSinPermisoCamara => 'Sin permiso para usar la cámara';

  @override
  String get perfilSinPermisoFotos => 'Sin permiso para ver tus fotos';

  @override
  String get perfilOtraOpcion => 'Puedes elegir otra opción.';

  @override
  String get perfilCamaraBloqueada => 'La cámara del celular está bloqueada';

  @override
  String get perfilFotosBloqueadas =>
      'Tus fotos están bloqueadas para Te Tengo';

  @override
  String get perfilPermitelo =>
      'Permítelo en los ajustes del celular y vuelve a intentarlo.';

  @override
  String get perfilAbrirAjustes => 'Abrir los ajustes del celular';

  @override
  String get perfilAhoraNo => 'Ahora no';

  @override
  String perfilFotoDe(String nombre) {
    return 'Foto de $nombre';
  }

  @override
  String get perfilLaVeFamilia => 'La ve toda la familia.';

  @override
  String get perfilTomarFoto => 'Tomar una foto';

  @override
  String get perfilElegirGaleria => 'Elegir de la galería';

  @override
  String get perfilQuitarFoto => 'Quitar la foto';

  @override
  String get perfilErrorActualVacia => 'Escribe tu contraseña actual.';

  @override
  String get perfilActualIncorrecta => 'No coincide con tu contraseña actual.';

  @override
  String get perfilContrasenaActual => 'Contraseña actual';

  @override
  String get perfilRepiteNueva => 'Repite la nueva contraseña';

  @override
  String get perfilAjustaFoto => 'Ajusta la foto';

  @override
  String get perfilMueveAcerca =>
      'Mueve y acerca la foto para centrar la cara.';

  @override
  String get perfilUsarFoto => 'Usar esta foto';

  @override
  String get sesionErrorNombre => 'Escribe tu nombre y apellido.';

  @override
  String get sesionErrorCorreoVacio => 'Escribe tu correo electrónico.';

  @override
  String get sesionErrorCorreoIncompleto =>
      'Revisa el correo: parece incompleto.';

  @override
  String get sesionErrorClaveVacia => 'Crea una contraseña.';

  @override
  String get sesionErrorClaveCorta => 'Usa al menos 8 caracteres y un número.';

  @override
  String get sesionErrorNoCoinciden => 'Las contraseñas no coinciden.';

  @override
  String get sesionAyudaContrasena => '8 caracteres o más, con un número.';

  @override
  String get sesionCampoNombre => 'Tu nombre y apellido';

  @override
  String get sesionCampoCorreo => 'Correo electrónico';

  @override
  String get sesionCampoContrasena => 'Contraseña';

  @override
  String get sesionNuevaContrasena => 'Nueva contraseña';

  @override
  String get sesionGuardarContrasena => 'Guardar contraseña';

  @override
  String get sesionContrasenaActualizada => 'Contraseña actualizada';

  @override
  String get sesionCerrarTitulo => '¿Cerrar sesión?';

  @override
  String get sesionCerrarTexto =>
      'Dejarás de recibir las alertas en este celular.';

  @override
  String get sesionCerrarTextoSus =>
      'Dejarás de recibir sus alertas en este celular.';

  @override
  String get sesionCerrar => 'Cerrar sesión';

  @override
  String get sesionCancelar => 'Cancelar';

  @override
  String get sesionBienvenidaTitulo =>
      'Cuida a tu familiar aunque no estés en casa.';

  @override
  String get sesionBienvenidaTexto => 'Detecta caídas y te avisa al instante.';

  @override
  String get sesionVinetaSinPulseras => 'Sin pulseras ni botones';

  @override
  String get sesionVinetaEnVivo => 'En vivo, con su permiso';

  @override
  String get sesionVinetaPostura => 'Solo postura, nunca rostros';

  @override
  String get sesionCrearCuenta => 'Crear cuenta';

  @override
  String get sesionYaTengoCuenta => 'Ya tengo una cuenta';

  @override
  String get sesionFotoDescripcion => 'Una hija abraza a su madre';

  @override
  String get sesionCerradaTitulo => 'Sesión cerrada';

  @override
  String get sesionCerradaTexto =>
      'Inicia sesión para volver a recibir alertas.';

  @override
  String get sesionClaveActualizadaTexto =>
      'Ya puedes iniciar sesión con ella.';

  @override
  String get sesionErrorCorreo => 'Escribe tu correo.';

  @override
  String get sesionErrorContrasena => 'Escribe tu contraseña.';

  @override
  String get sesionIniciaSesion => 'Inicia sesión';

  @override
  String get sesionBloqueadoTitulo => 'Bloqueado por 15 minutos';

  @override
  String sesionBloqueadoTexto(String hora) {
    return 'Vuelve a intentarlo a las $hora.';
  }

  @override
  String get sesionIncorrectos => 'Correo o contraseña incorrectos';

  @override
  String sesionIntentosRestantes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Te quedan $n intentos antes de un bloqueo de 15 min.',
      one: 'Te queda 1 intento antes de un bloqueo de 15 min.',
    );
    return '$_temp0';
  }

  @override
  String get sesionFaltanDatos => 'Escribe tu correo y tu contraseña';

  @override
  String get sesionOlvidaste => '¿Olvidaste tu contraseña?';

  @override
  String get sesionIniciarSesion => 'Iniciar sesión';

  @override
  String get sesionSinCuenta => '¿Aún no tienes cuenta?';

  @override
  String get sesionCreaUna => 'Crea una';

  @override
  String get registroCorreoRegistrado => 'Este correo ya está registrado.';

  @override
  String get registroCorreoConCuenta => 'Ese correo ya tiene una cuenta';

  @override
  String get registroIniciarConCorreo => 'Iniciar sesión con este correo';

  @override
  String get registroRecuperarMiContrasena => 'Recuperar mi contraseña';

  @override
  String get registroCompletaCampos => 'Completa los campos marcados';

  @override
  String get registroAceptasLos => 'Aceptas los';

  @override
  String get registroTerminos => 'Términos';

  @override
  String get registroYLa => 'y la';

  @override
  String get registroPrivacidad => 'Privacidad';

  @override
  String get registroYaTienesCuenta => '¿Ya tienes cuenta?';

  @override
  String registroCuentaLista(String nombre) {
    return 'Tu cuenta está lista, $nombre.';
  }

  @override
  String get registroDosPasos => '2 pasos más:';

  @override
  String get registroPasoDatos => 'Datos de la persona';

  @override
  String get registroPasoConsentimiento => 'Consentimiento informado';

  @override
  String get registroEmpezar => 'Empezar';

  @override
  String get recuperarContrasena => 'Recuperar contraseña';

  @override
  String get recuperarTeEnviaremos => 'Te enviaremos un enlace.';

  @override
  String get recuperarEnviarEnlace => 'Enviar enlace';

  @override
  String get recuperarRevisaCorreo => 'Revisa tu correo';

  @override
  String recuperarSiTieneCuenta(String correo) {
    return 'Si $correo tiene cuenta, te llegará un enlace. Vence en 30 minutos.';
  }

  @override
  String get recuperarSpam => 'Revisa también el spam.';

  @override
  String get recuperarVolverIniciar => 'Volver a iniciar sesión';

  @override
  String recuperarReenviarEn(String tiempo) {
    return 'Reenviar enlace en $tiempo';
  }

  @override
  String get recuperarReenviar => 'Reenviar enlace';

  @override
  String recuperarParaCuenta(String correo) {
    return 'Para la cuenta $correo.';
  }

  @override
  String get recuperarRepite => 'Repite la contraseña';

  @override
  String get recuperarVencido => 'Este enlace ya venció';

  @override
  String get recuperarDura => 'Dura 30 minutos y sirve una sola vez.';

  @override
  String get recuperarPedirNuevo => 'Pedir un enlace nuevo';

  @override
  String get recuperarCerrar => 'Cerrar';

  @override
  String get consentimientoSeccionVivoTitulo =>
      'Vista en vivo en cualquier momento';

  @override
  String get consentimientoSeccionVivoResumen => 'Cuando la familia quiera';

  @override
  String get consentimientoSeccionVivoTexto =>
      'La familia vinculada puede verla en vivo cuando quiera, no solo en una alerta. Cada acceso queda registrado: quién, cuándo y cuánto.';

  @override
  String get consentimientoSeccionHacemosTitulo => 'Qué hacemos';

  @override
  String get consentimientoSeccionHacemosResumen => 'Caídas por la postura';

  @override
  String get consentimientoSeccionHacemosTexto =>
      'La PC de la casa analiza la postura para detectar caídas y movimientos inestables. El video continuo nunca sale de la casa. Solo salen el aviso y el clip de cada alerta, y la vista en vivo mientras alguien de la familia la mira.';

  @override
  String get consentimientoSeccionNoHacemosTitulo => 'Qué no hacemos';

  @override
  String get consentimientoSeccionNoHacemosResumen =>
      'Ni rostros ni grabación continua';

  @override
  String get consentimientoSeccionNoHacemosTexto =>
      'Sin reconocimiento facial ni grabación continua. La vista en vivo no se guarda.';

  @override
  String get consentimientoSeccionGuardamosTitulo => 'Qué guardamos';

  @override
  String get consentimientoSeccionGuardamosResumen =>
      'Clip de cada alerta, 30 días';

  @override
  String get consentimientoSeccionGuardamosTexto =>
      'Solo el clip de cada alerta, 30 días; luego se borra. Se guarda en Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú: es un flujo transfronterizo de datos personales. Sus movimientos (puntos del cuerpo, sin imagen) solo se guardan con un permiso aparte.';

  @override
  String get consentimientoSeccionDerechosTitulo => 'Sus derechos';

  @override
  String get consentimientoSeccionDerechosResumen =>
      'Ley N.° 29733 · revocable';

  @override
  String get consentimientoSeccionDerechosTexto =>
      'Por la Ley N.° 29733, puede ver, corregir o borrar sus datos, oponerse a su uso y revocar este consentimiento.';

  @override
  String get consentimientoRegistroTitulo => 'Cómo se registra';

  @override
  String get consentimientoRegistroTexto =>
      'Guardamos quién lo otorgó, quién lo registró, fecha y hora (Ley N.° 29733).';

  @override
  String get legalTerminosQueEsTitulo => 'Qué es Te Tengo';

  @override
  String get legalTerminosQueEsTexto =>
      'Avisa a tu familia si la cámara de la casa detecta una posible caída o un movimiento inestable. No es una cámara de seguridad.';

  @override
  String get legalTerminosCuentaTitulo => 'Tu cuenta';

  @override
  String get legalTerminosCuentaTexto1 =>
      'Solo el titular (quien la crea) cambia los datos de la persona cuidada, el consentimiento, las habitaciones, la familia y el orden de aviso.';

  @override
  String get legalTerminosCuentaTexto2 =>
      'Cada cuenta cuida a una sola persona. Contraseña de 8 caracteres o más, con un número; 5 intentos fallidos bloquean el acceso 15 minutos.';

  @override
  String get legalTerminosInvitadosTitulo => 'Familiares invitados';

  @override
  String get legalTerminosInvitadosTexto =>
      'Ven alertas, clips, historial y vista en vivo; marcan alertas y pausan la cámara. El titular puede retirar el acceso.';

  @override
  String get legalTerminosConsentimientoTitulo => 'Consentimiento';

  @override
  String get legalTerminosConsentimientoTexto1 =>
      'Sin el consentimiento de la persona cuidada o de su representante legal, la cámara no envía video. Revocarlo detiene la captura y borra las grabaciones.';

  @override
  String get legalTerminosConsentimientoTexto2 =>
      'Guardar sus movimientos necesita un permiso aparte y opcional; las alertas funcionan igual sin él.';

  @override
  String get legalTerminosAlertasTitulo => 'Alertas';

  @override
  String get legalTerminosAlertasTexto =>
      'Las reciben todos los familiares vinculados. Si el principal no marca una en el tiempo de espera (3, 5 o 10 minutos), avisamos al secundario.';

  @override
  String get legalTerminosLimitesTitulo => 'Límites del servicio';

  @override
  String get legalTerminosLimitesTexto1 =>
      'Sin detección con la PC de la casa apagada, la cámara desconectada, en pausa o sin consentimiento; no es confiable si no ve bien a la persona.';

  @override
  String get legalTerminosLimitesTexto2 =>
      'Con la app cerrada, las alertas llegan solo con las notificaciones activadas.';

  @override
  String get legalPoliticaDatosTitulo => 'Qué datos guardamos';

  @override
  String get legalPoliticaDatosTexto1 => 'Cuenta: nombre, correo y contraseña.';

  @override
  String get legalPoliticaDatosTexto2 =>
      'Persona cuidada: nombre, edad, dirección y con quién vive.';

  @override
  String get legalPoliticaDatosTexto3 =>
      'Alertas: tipo, habitación, fecha, hora y quién atendió.';

  @override
  String get legalPoliticaVideoTitulo => 'Video';

  @override
  String get legalPoliticaVideoTexto1 =>
      'Se analiza en la PC de la casa. Sin reconocimiento facial ni video en la nube.';

  @override
  String get legalPoliticaVideoTexto2 =>
      'Solo salen de la casa el aviso y el clip de cada alerta, y la vista en vivo mientras alguien de la familia la mira con el consentimiento vigente.';

  @override
  String get legalPoliticaVideoTexto3 =>
      'Solo el clip de cada alerta (6 s antes y 6 s después), 30 días. La vista en vivo no se graba.';

  @override
  String get legalPoliticaMovimientosTitulo => 'Movimientos';

  @override
  String get legalPoliticaMovimientosTexto1 =>
      'Solo con un permiso aparte y opcional: puntos del cuerpo (hombros, caderas, rodillas…), sin imagen ni video.';

  @override
  String get legalPoliticaMovimientosTexto2 =>
      'En la PC de la casa y, si el titular lo elige, en la nube, de 7 días a 1 año. Retirar el permiso borra los de la nube; la PC pregunta si también los borra.';

  @override
  String get legalPoliticaDondeTitulo => 'Dónde se guardan';

  @override
  String get legalPoliticaDondeTexto =>
      'Los clips y los movimientos de la nube se guardan en Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú: es un flujo transfronterizo de datos personales.';

  @override
  String get legalPoliticaQuienTitulo => 'Quién ve los datos';

  @override
  String get legalPoliticaQuienTexto =>
      'Solo la familia vinculada. Cada acceso en vivo y cada repetición quedan en un registro que ven todos: quién, cuándo y cuánto.';

  @override
  String get legalPoliticaRevocarTitulo => 'Revocar el consentimiento';

  @override
  String get legalPoliticaRevocarTexto =>
      'Detiene la captura y la vista en vivo y borra las grabaciones; te enviamos la constancia.';

  @override
  String get legalPoliticaDerechosTitulo => 'Tus derechos';

  @override
  String get legalPoliticaDerechosTexto =>
      'Ver, corregir o borrar tus datos, u oponerte a su uso (Ley N.° 29733): privacidad@tetengo.pe.';

  @override
  String get legalTerminosTitulo => 'Términos de uso';

  @override
  String get legalVerPolitica => 'Ver la política de privacidad';

  @override
  String get legalPoliticaTitulo => 'Política de privacidad';

  @override
  String get consentimientoTitulo => 'Consentimiento';

  @override
  String get consentimientoPersonaGenerica => 'la persona cuidada';

  @override
  String consentimientoDocumentoIntro(String nombre) {
    return 'Lo acepta $nombre o su representante legal antes de que la cámara envíe video.';
  }

  @override
  String get consentimientoConstancia => 'Constancia';

  @override
  String get consentimientoOtorgadoPor => 'Otorgado por';

  @override
  String get consentimientoRegistradoPor => 'Registrado por';

  @override
  String get consentimientoFecha => 'Fecha';

  @override
  String get consentimientoHora => 'Hora';

  @override
  String consentimientoIntro(String nombre) {
    return 'Lo acepta $nombre o su representante. Sin él, no detectamos caídas.';
  }

  @override
  String get consentimientoQuienOtorga => '¿Quién otorga el consentimiento?';

  @override
  String consentimientoDirectamente(String nombre) {
    return '$nombre, directamente';
  }

  @override
  String get consentimientoRepresentante => 'Su representante legal';

  @override
  String consentimientoCasillaAcepta(String nombre) {
    return '$nombre fue informada y acepta la cámara para detectar caídas y que su familia la vea en vivo cuando quiera.';
  }

  @override
  String get consentimientoCasillaLeyo =>
      'Leí el resumen y el documento completo.';

  @override
  String get consentimientoFaltanCasillas => 'Marca las dos casillas.';

  @override
  String get consentimientoGuardamosFecha =>
      'Guardamos fecha y hora como constancia (Ley N.° 29733).';

  @override
  String get consentimientoRegistrar => 'Registrar consentimiento';

  @override
  String get consentimientoAhoraNo => 'Ahora no';

  @override
  String get consentimientoLeerDocumento => 'Leer el documento completo';

  @override
  String get consentimientoRegistradoTitulo => 'Consentimiento registrado';

  @override
  String get consentimientoCamarasDetectan => 'Las cámaras ya detectan caídas.';

  @override
  String get consentimientoDetectaranAlVincular =>
      'Detectarán caídas al vincular la PC.';

  @override
  String get consentimientoVolverInicio => 'Volver al inicio';

  @override
  String get consentimientoCamaraActivada => 'Cámara activada';

  @override
  String consentimientoCamaraDetectaDesde(
    String deHabitacion,
    String habitacion,
    String hora,
  ) {
    return 'La cámara $deHabitacion detecta caídas desde las $hora.';
  }

  @override
  String get consentimientoConstanciaTitulo => 'Constancia de consentimiento';

  @override
  String get consentimientoVerConstancia => 'Ver la constancia completa';

  @override
  String get consentimientoConstanciaLey =>
      'Constancia exigida por la Ley N.° 29733.';

  @override
  String get privacidadTitulo => 'Privacidad';

  @override
  String get privacidadVerDocumento => 'Ver el documento aceptado';

  @override
  String get privacidadSinConsentimiento => 'Sin consentimiento';

  @override
  String get privacidadRevocadoEliminadas =>
      'Revocado. Grabaciones eliminadas.';

  @override
  String get privacidadAunNoRegistra =>
      'Aún no se registra. La cámara no envía video.';

  @override
  String get privacidadMovimientos => 'Movimientos';

  @override
  String get privacidadGuardarMovimientos => 'Guardar movimientos';

  @override
  String privacidadVigenteDesde(String fecha) {
    return 'Vigente desde el $fecha';
  }

  @override
  String get privacidadNoAutorizado => 'No autorizado';

  @override
  String get privacidadMovimientosNube => 'Movimientos en la nube';

  @override
  String get privacidadNubeDesactivada => 'Desactivado · falta el permiso';

  @override
  String get privacidadSusDatos => 'Sus datos';

  @override
  String get privacidadComoCuidamos => 'Cómo los cuidamos';

  @override
  String get privacidadComoCuidamosResumen =>
      'Sin video en la nube · clips 30 días';

  @override
  String get privacidadDatoVideo => 'Video';

  @override
  String get privacidadDatoVideoValor => 'En la PC, nunca en la nube';

  @override
  String get privacidadDatoClips => 'Clips';

  @override
  String get privacidadDatoClipsValor => '30 días';

  @override
  String get privacidadDatoEnVivo => 'En vivo';

  @override
  String get privacidadDatoEnVivoValor => 'No se graba';

  @override
  String get privacidadDatoRostros => 'Rostros';

  @override
  String get privacidadDatoRostrosValor => 'No se reconocen';

  @override
  String get privacidadRegistroAccesos => 'Registro de accesos';

  @override
  String get privacidadRegistroAccesosSub => 'Quién miró, cuándo y cuánto';

  @override
  String get privacidadDerechos => 'Derechos (Ley N.° 29733): ';

  @override
  String get privacidadRevocar => 'Revocar';

  @override
  String get privacidadRevocarTexto =>
      'Detiene la cámara y borra las grabaciones.';

  @override
  String get privacidadRevocarBoton => 'Revocar consentimiento';

  @override
  String get privacidadSoloLecturaRevocar => 'revocar el consentimiento';

  @override
  String get privacidadRevocarDialogoTitulo => '¿Revocar el consentimiento?';

  @override
  String get privacidadRevocarDialogoTexto =>
      'Se detiene la captura, no habrá más alertas y se borran las grabaciones. No se puede deshacer.';

  @override
  String get privacidadRevocarDialogoAceptar => 'Sí, revocar y eliminar';

  @override
  String get privacidadRevocarDialogoCancelar => 'Cancelar, mantenerlo';

  @override
  String get privacidadSigueVigente => 'Tu consentimiento sigue vigente';

  @override
  String get privacidadSigueDetectando => 'La cámara sigue detectando caídas.';

  @override
  String get privacidadRevocadoTitulo => 'Consentimiento revocado';

  @override
  String get privacidadRevocandoTitulo => 'Revocando el consentimiento';

  @override
  String privacidadConstanciaEnviada(String correo) {
    return 'Te enviamos la constancia a $correo.';
  }

  @override
  String get privacidadNoCierres => 'No cierres la app.';

  @override
  String get privacidadCapturaDetenida => 'Captura detenida';

  @override
  String privacidadALasHora(String hora) {
    return 'A las $hora';
  }

  @override
  String get privacidadGrabacionesEliminadas => 'Grabaciones eliminadas';

  @override
  String get privacidadEliminandoGrabaciones => 'Eliminando las grabaciones…';

  @override
  String privacidadClips(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n clips',
      one: '1 clip',
    );
    return '$_temp0';
  }

  @override
  String privacidadClipsHora(String clips, String hora) {
    return '$clips · $hora';
  }

  @override
  String get privacidadConstanciaCorreo => 'Constancia por correo';

  @override
  String get privacidadEnviada => 'Enviada';

  @override
  String get privacidadPendiente => 'Pendiente';

  @override
  String get hogarConvivenciaSolo => 'Vive solo(a)';

  @override
  String get hogarConvivenciaConFamiliar => 'Vive conmigo';

  @override
  String get hogarConvivenciaConCuidador => 'Vive con otro cuidador';

  @override
  String get hogarErrorNombre => 'Escribe su nombre y apellido.';

  @override
  String get hogarErrorEdadVacia => 'Escribe su edad.';

  @override
  String get hogarErrorEdadInvalida => 'Escribe una edad válida, en años.';

  @override
  String get hogarErrorDireccion => 'Escribe la dirección de la vivienda.';

  @override
  String get hogarErrorConvivencia => 'Elige una opción.';

  @override
  String get hogarErrorTelefono => 'Revisa el teléfono: solo números.';

  @override
  String get hogarCampoNombre => 'Nombre y apellido';

  @override
  String get hogarCampoNombreEjemplo => 'Ej.: Rosa Huamán';

  @override
  String get hogarCampoEdad => 'Edad';

  @override
  String hogarCampoTelefono(String nombre) {
    return 'Teléfono de $nombre';
  }

  @override
  String hogarCampoTelefonoAyuda(String nombre) {
    return 'Lo usa «Llamar a $nombre».';
  }

  @override
  String get hogarCampoDireccion => 'Dirección de la vivienda';

  @override
  String get hogarCampoDireccionEjemplo => 'Calle, número y distrito';

  @override
  String get hogarConQuienVive => '¿Con quién vive?';

  @override
  String get hogarPersonaCuidadaTitulo => 'Persona cuidada';

  @override
  String get hogarCambiosGuardados => 'Cambios guardados';

  @override
  String hogarSoloLecturaCambiarDatos(String nombre) {
    return 'cambiar los datos de $nombre';
  }

  @override
  String get hogarGuardarCambios => 'Guardar cambios';

  @override
  String get hogarUnaSolaPersonaTitulo =>
      'Cada cuenta cuida a una sola persona';

  @override
  String get hogarUnaSolaPersonaTexto =>
      'Para cuidar a alguien más, crea otra cuenta.';

  @override
  String get hogarAQuienCuidar => '¿A quién vas a cuidar?';

  @override
  String get hogarCompletaCampos => 'Completa los campos marcados';

  @override
  String get hogarGuardarYContinuar => 'Guardar y continuar';

  @override
  String onboardingTodoListo(String nombre) {
    return 'Todo listo. Ya estás cerca de $nombre.';
  }

  @override
  String get onboardingQueNoSePase => 'Que no se te pase ninguna caída';

  @override
  String get onboardingAunqueCerrada =>
      'Aunque la app esté cerrada o el celular en silencio.';

  @override
  String get onboardingNotificaciones => 'Notificaciones';

  @override
  String get onboardingParaRecibir => 'Para recibir las alertas';

  @override
  String get onboardingPermitir => 'Permitir';

  @override
  String get onboardingSuenanIgual => 'Las caídas suenan igual';

  @override
  String get onboardingFaltaConsentimiento => 'Falta el consentimiento';

  @override
  String get onboardingRegistraloInicio => 'Regístralo desde Inicio';

  @override
  String onboardingPcVinculada(String nombre) {
    return 'PC $nombre vinculada';
  }

  @override
  String get onboardingFaltaElegirCamaras => 'Falta elegir las cámaras';

  @override
  String onboardingPcCamaras(int n, String lista) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras: $lista',
      one: '1 cámara: $lista',
    );
    return '$_temp0';
  }

  @override
  String onboardingSinDetectar(String camaras) {
    return '$camaras · sin detectar';
  }

  @override
  String get onboardingSinPc => 'Sin PC vinculada';

  @override
  String get onboardingAgregaPc => 'Agrégala desde Ajustes › Cámaras y PCs';

  @override
  String get onboardingSinSecundario => 'Sin contacto secundario';

  @override
  String get onboardingInvitaloFamilia => 'Invítalo desde Familia';

  @override
  String get onboardingIrInicio => 'Ir al inicio';

  @override
  String get movimientosSecParaQueTitulo => 'Para qué';

  @override
  String get movimientosSecParaQueResumen =>
      'Ver qué pasó y mejorar la detección';

  @override
  String get movimientosSecParaQueTexto =>
      'Ver qué pasó antes y después de un aviso, y mejorar la detección.';

  @override
  String get movimientosSecQueTitulo => 'Qué guardamos';

  @override
  String get movimientosSecQueResumen => 'Puntos del cuerpo, sin imagen';

  @override
  String get movimientosSecQueTexto =>
      'Solo puntos del cuerpo (hombros, caderas, rodillas…), sin imagen ni video.';

  @override
  String get movimientosSecDondeTitulo => 'Dónde';

  @override
  String get movimientosSecDondeResumen => 'PC y, si quieres, nube';

  @override
  String get movimientosSecDondeTextoV1 =>
      'En la PC de la casa y, si lo eliges, en la nube (servidores fuera del Perú).';

  @override
  String get movimientosSecDondeTextoV2 =>
      'En la PC de la casa y, si lo eliges, en la nube: Cloudflare R2, con servidores fuera del Perú. Guardarlos ahí es un flujo transfronterizo de datos personales.';

  @override
  String get movimientosSecDondeTextoV3 =>
      'En la PC de la casa y, si lo eliges, en la nube: Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú. Guardarlos ahí es un flujo transfronterizo de datos personales.';

  @override
  String get movimientosSecCuantoTitulo => 'Cuánto tiempo';

  @override
  String get movimientosSecCuantoResumen => 'Tú eliges el plazo';

  @override
  String get movimientosSecCuantoTexto =>
      'Nube: de 7 días a 1 año. PC: también sin borrar.';

  @override
  String get movimientosSecQuienTitulo => 'Quién puede verlos';

  @override
  String get movimientosSecQuienResumen => 'La familia, con registro';

  @override
  String get movimientosSecQuienTexto =>
      'Solo la familia vinculada; cada repetición queda registrada.';

  @override
  String get movimientosSecDerechosTitulo => 'Sus derechos';

  @override
  String get movimientosSecDerechosResumen => 'Ley N.° 29733';

  @override
  String movimientosSecDerechosTexto(String nombre) {
    return '$nombre puede ver, corregir o borrar sus datos, u oponerse a su uso: privacidad@tetengo.pe (Ley N.° 29733).';
  }

  @override
  String get movimientosTitulo => 'Guardar movimientos';

  @override
  String get movimientosErrorRepresentante =>
      'Escribe el nombre del representante.';

  @override
  String get movimientosRegistradoTitulo => 'Permiso registrado';

  @override
  String get movimientosRegistradoTexto =>
      'Ahora puedes elegir si se guardan en la nube.';

  @override
  String movimientosDejarTitulo(String nombre) {
    return '¿Dejar de guardar los movimientos de $nombre?';
  }

  @override
  String get movimientosDejarTexto =>
      'Borraremos los de la nube; la PC preguntará si también los borra. Las alertas siguen igual.';

  @override
  String get movimientosDejarAceptar => 'Dejar de guardar';

  @override
  String get movimientosCancelar => 'Cancelar';

  @override
  String get movimientosSinInternetTitulo => 'Sin internet';

  @override
  String get movimientosSinInternetTexto =>
      'Revisa tu conexión y vuelve a intentarlo.';

  @override
  String movimientosPregunta(String nombre) {
    return '¿Guardamos los movimientos de $nombre?';
  }

  @override
  String get movimientosOpcional => 'Es opcional: las alertas funcionan igual.';

  @override
  String get movimientosQuienDa => '¿Quién da el permiso?';

  @override
  String movimientosEnPersona(String nombre) {
    return '$nombre, en persona';
  }

  @override
  String get movimientosSuRepresentante => 'Su representante';

  @override
  String get movimientosNombreRepresentante => 'Nombre del representante';

  @override
  String get movimientosNombreMarcador => 'Nombre y apellido';

  @override
  String movimientosAcepto(String nombre) {
    return '$nombre aceptó que se guarden sus movimientos para estos fines.';
  }

  @override
  String get movimientosErrorRedTitulo => 'No pudimos registrar el permiso';

  @override
  String get movimientosErrorRedTexto => 'Nada se guardó.';

  @override
  String get movimientosRegistrar => 'Registrar el permiso';

  @override
  String get movimientosAhoraNo => 'Ahora no';

  @override
  String get movimientosAccionRegistrar => 'registrar este permiso';

  @override
  String get movimientosLeerDocumento => 'Leer el documento completo';

  @override
  String get movimientosFaltaConsentimientoTitulo => 'Falta el consentimiento';

  @override
  String get movimientosFaltaConsentimientoTexto =>
      'Sin él no detectamos caídas.';

  @override
  String get movimientosRegistrarConsentimiento => 'Registrar consentimiento';

  @override
  String get movimientosEnLaNube => 'Movimientos en la nube';

  @override
  String get movimientosDejarBoton => 'Dejar de guardar movimientos';

  @override
  String get movimientosAccionRetirar => 'retirar este permiso';

  @override
  String get movimientosConstanciaTitulo => 'Permiso para guardar movimientos';

  @override
  String get movimientosConstanciaOtorgadoPor => 'Otorgado por';

  @override
  String movimientosConstanciaRepresentante(String nombre) {
    return '$nombre (representante)';
  }

  @override
  String get movimientosConstanciaRegistradoPor => 'Registrado por';

  @override
  String get movimientosConstanciaFecha => 'Fecha';

  @override
  String get movimientosConstanciaVersion => 'Versión del texto';

  @override
  String get movimientosConstanciaLey =>
      'Constancia exigida por la Ley N.° 29733 para datos sensibles.';

  @override
  String get movimientosLeerAceptado => 'Leer el documento aceptado';

  @override
  String get movimientosPersonaCuidada => 'la persona cuidada';

  @override
  String movimientosDocIntroduccion(String nombre) {
    return 'Permiso aparte y opcional. Lo acepta $nombre o su representante.';
  }

  @override
  String get movimientosDocRegistraTitulo => 'Cómo se registra';

  @override
  String get movimientosDocRegistraTexto =>
      'Guardamos quién lo otorgó, quién lo registró, fecha, hora y versión del texto (Ley N.° 29733).';

  @override
  String get movimientosDocRetirarTitulo => 'Cómo retirarlo';

  @override
  String get movimientosDocRetirarTexto =>
      'El titular lo retira en Ajustes › Privacidad. Borramos los de la nube; la PC pregunta si también los borra.';

  @override
  String movimientosDocVersion(String version) {
    return 'Versión del texto: $version.';
  }

  @override
  String movimientosBorradoListo(String nombre) {
    return 'Listo. Ya no guardamos los movimientos de $nombre.';
  }

  @override
  String get movimientosBorrandoNube => 'Borrando los movimientos de la nube…';

  @override
  String get movimientosAlertasIgual => 'Las alertas siguen igual.';

  @override
  String get movimientosNoCierres => 'No cierres la app.';

  @override
  String get movimientosYaNoGuardamos => 'Ya no guardamos movimientos';

  @override
  String movimientosDesdeLas(String hora) {
    return 'Desde las $hora';
  }

  @override
  String get movimientosBorradosNube => 'Movimientos borrados de la nube';

  @override
  String get movimientosEnLaPc => 'En la PC de la casa';

  @override
  String get movimientosPcPreguntara => 'Preguntará si también se borran ahí.';

  @override
  String get movimientosVolverPrivacidad => 'Volver a Privacidad';

  @override
  String nubePlazoDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
    );
    return '$_temp0';
  }

  @override
  String get nubePlazoAnio => '1 año';

  @override
  String get nubeDesactivado => 'Desactivado';

  @override
  String nubeSeGuardan(String plazo) {
    return 'Se guardan $plazo';
  }

  @override
  String get nubeApagarTitulo => '¿Dejar de guardar en la nube?';

  @override
  String nubeAcortarTitulo(String plazo) {
    return '¿Guardar solo $plazo?';
  }

  @override
  String get nubeApagarTexto =>
      'Borraremos todos los movimientos de la nube. No se pueden recuperar.';

  @override
  String nubeAcortarTexto(String fecha) {
    return 'Borraremos los movimientos anteriores al $fecha. No se pueden recuperar.';
  }

  @override
  String get nubeNoGuardar => 'No guardar en la nube';

  @override
  String nubeGuardarPlazo(String plazo) {
    return 'Guardar $plazo';
  }

  @override
  String get nubeToastApagado => 'Movimientos en la nube: no guardar';

  @override
  String nubeToastPlazo(String plazo) {
    return 'Movimientos en la nube: $plazo';
  }

  @override
  String get nubeBorramos => 'Borramos los movimientos de la nube.';

  @override
  String get nubeSeBorranSolos => 'Se borran solos al cumplirse el plazo.';

  @override
  String nubeFaltaPermiso(String nombre) {
    return 'Falta el permiso de $nombre para guardar movimientos';
  }

  @override
  String get nubeVerPermiso => 'Ver el permiso';

  @override
  String get nubeAccionCambiarPlazo => 'cambiar el plazo';

  @override
  String get nubeErrorRed => 'No pudimos guardar el cambio';

  @override
  String get nubePlazoEtiqueta => 'Plazo en la nube';

  @override
  String get nubeMaximoRecomendado => 'Máximo recomendado';

  @override
  String get nubeEspacio => 'Espacio aproximado';

  @override
  String nubeEspacioValor(int minimo, int maximo) {
    return '$minimo a $maximo MB por cámara al día (estimado)';
  }

  @override
  String get nubeDatosDesde => 'Hay movimientos desde';

  @override
  String get nubeCamaras => 'Cámaras';

  @override
  String nubePcSubira(String pc) {
    return 'La PC $pc subirá sus movimientos al reconectarse.';
  }

  @override
  String get nubeNuncaVideo => 'Nunca guardamos video en la nube.';

  @override
  String get historialTitulo => 'Historial';

  @override
  String get historialAlertas => 'Alertas';

  @override
  String get historialResumenSemanal => 'Resumen semanal';

  @override
  String get historialRangoSiete => 'Últimos 7 días';

  @override
  String get historialRangoTreinta => 'Últimos 30 días';

  @override
  String get historialRangoTodo => 'Todo';

  @override
  String get historialChipCaidas => 'Caídas';

  @override
  String get historialChipInestables => 'Movimientos inestables';

  @override
  String get historialChipActivas => 'Activas';

  @override
  String get historialChipAtendidas => 'Atendidas';

  @override
  String get historialChipFalsas => 'Falsas alarmas';

  @override
  String get historialFiltrarTitulo => 'Filtrar alertas';

  @override
  String get historialFiltroFecha => 'Fecha';

  @override
  String get historialFiltroTipo => 'Tipo';

  @override
  String get historialFiltroEstado => 'Estado';

  @override
  String get historialFiltroTodas => 'Todas';

  @override
  String get historialFiltroCaida => 'Caída';

  @override
  String get historialFiltroInestable => 'Movimiento inestable';

  @override
  String get historialFiltroTodos => 'Todos';

  @override
  String get historialFiltroActiva => 'Activa';

  @override
  String get historialFiltroAtendida => 'Atendida';

  @override
  String get historialFiltroFalsa => 'Falsa alarma';

  @override
  String get historialLimpiar => 'Limpiar';

  @override
  String get historialVerAlertas => 'Ver alertas';

  @override
  String historialVerConteo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ver $n alertas',
      one: 'Ver $n alerta',
    );
    return '$_temp0';
  }

  @override
  String get historialVacio => 'Sin eventos registrados';

  @override
  String get historialNingunaCoincide => 'Ninguna alerta coincide';

  @override
  String get historialQuitarFiltros => 'Quitar filtros';

  @override
  String get historialHoy => 'Hoy';

  @override
  String get historialAyer => 'Ayer';

  @override
  String get historialFiltrar => 'Filtrar';

  @override
  String historialFiltrarConteo(int n) {
    return 'Filtrar ($n)';
  }

  @override
  String historialQuitarFiltro(String filtro) {
    return 'Quitar filtro $filtro';
  }

  @override
  String get historialSinMarcar => 'Sin marcar';

  @override
  String historialMarcadaPor(String nombre) {
    return 'por $nombre';
  }

  @override
  String get historialFilaCaida => 'Caída';

  @override
  String get historialFilaInestable => 'Inestable';

  @override
  String get historialCargando => 'Cargando historial';

  @override
  String get resumenSemanaAnterior => 'Semana anterior';

  @override
  String get resumenSemanaSiguiente => 'Semana siguiente';

  @override
  String get resumenEstaSemana => 'Esta semana';

  @override
  String get resumenSemanaPasada => 'Semana pasada';

  @override
  String resumenHaceSemanas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Hace $n semanas',
    );
    return '$_temp0';
  }

  @override
  String resumenRangoHastaHoy(String rango) {
    return '$rango · hasta hoy';
  }

  @override
  String resumenRangoAnio(String rango, String anio) {
    return '$rango $anio';
  }

  @override
  String get resumenSinEventos => 'Semana sin eventos';

  @override
  String get resumenPorTipo => 'Por tipo';

  @override
  String resumenVs(String rango) {
    return 'vs. $rango';
  }

  @override
  String get resumenCaidas => 'Caídas';

  @override
  String get resumenInestables => 'Movimientos inestables';

  @override
  String get resumenFalsas => 'Falsas alarmas';

  @override
  String get resumenFalsasNoSuman => 'Las falsas alarmas no suman.';

  @override
  String get resumenEventosPorDia => 'Eventos por día';

  @override
  String get resumenInicialesDias => 'LMMJVSD';

  @override
  String resumenIgual(int anterior) {
    return 'Igual ($anterior)';
  }

  @override
  String resumenSubio(int anterior, int actual) {
    return 'Subió de $anterior a $actual';
  }

  @override
  String resumenBajo(int anterior, int actual) {
    return 'Bajó de $anterior a $actual';
  }

  @override
  String get resumenVerResumen => 'Ver resumen';

  @override
  String resumenInicioCaidas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'caídas',
      one: 'caída',
    );
    return '$_temp0';
  }

  @override
  String resumenInicioInestables(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'inestables',
      one: 'inestable',
    );
    return '$_temp0';
  }

  @override
  String resumenInicioFalsas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'falsas',
      one: 'falsa',
    );
    return '$_temp0';
  }

  @override
  String get comunCerrarAviso => 'Cerrar aviso';

  @override
  String get comunSoloVer => 'Solo ver';

  @override
  String comunSoloTitularPuede(String titular, String accion) {
    return 'Solo $titular (titular) puede $accion.';
  }

  @override
  String comunPasoDe(int paso, int pasos) {
    return 'Paso $paso de $pasos';
  }

  @override
  String get comunMostrarContrasena => 'Mostrar contraseña';

  @override
  String get comunOcultarContrasena => 'Ocultar contraseña';

  @override
  String get comunUnMomento => 'Un momento…';

  @override
  String comunMasInformacion(String tema) {
    return 'Más información: $tema';
  }

  @override
  String get comunErrorGenerico => 'Ocurrió un error.';

  @override
  String get redSinConexion =>
      'No hay conexión con Te Tengo. Revisa tu internet.';

  @override
  String get navInicio => 'Inicio';

  @override
  String get navHistorial => 'Historial';

  @override
  String get navFamilia => 'Familia';

  @override
  String get navAjustes => 'Ajustes';

  @override
  String navAlertasActivas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n alertas activas',
      one: '1 alerta activa',
    );
    return '$_temp0';
  }

  @override
  String nucleoEnHabitacion(String lugar, String habitacion) {
    return 'en $lugar';
  }

  @override
  String get nucleoSinInternetTitulo => 'Tu celular no tiene internet';

  @override
  String get nucleoSinInternetTexto =>
      'Las alertas llegarán cuando vuelvas a conectarte. Si no atiendes una a tiempo, avisamos a tu contacto secundario.';

  @override
  String nucleoAlertaTitulo(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'inestable': 'Movimiento inestable',
      'confirmada': 'Caída confirmada',
      'other': 'Posible caída',
    });
    return '$_temp0';
  }

  @override
  String get nucleoAlertaActivaDesde => 'Alerta activa desde las ';

  @override
  String pushSigueEnElSueloTitulo(String nombre) {
    return '$nombre sigue en el suelo';
  }

  @override
  String pushCaidaConfirmadaTexto(String hora) {
    return 'Caída confirmada a las $hora. La alerta sigue activa.';
  }

  @override
  String pushSeLevantoTitulo(String nombre) {
    return '$nombre se levantó';
  }

  @override
  String pushSeLevantoTexto(String hora) {
    return '$hora · Se puso de pie. Confirma cómo está.';
  }

  @override
  String pushSeLevantoTextoEn(String hora, String lugar) {
    return '$hora · Se puso de pie $lugar. Confirma cómo está.';
  }

  @override
  String pushMovimientosBorradosTitulo(String nombre) {
    return 'Listo. Ya no guardamos los movimientos de $nombre.';
  }

  @override
  String get pushMovimientosBorradosTexto => 'Los borramos de la nube.';

  @override
  String get pushPcDesvinculadaTitulo => 'Una PC se desvinculó de la casa';

  @override
  String pushPcDesvinculadaNombre(String pc) {
    return 'La PC $pc se desvinculó';
  }

  @override
  String get pushPcDesvinculadaSinCamaras =>
      'Sus cámaras ya no detectan caídas. Revisa Cámaras y PCs.';

  @override
  String pushPcDesvinculadaHabitaciones(String habitaciones) {
    return 'Ya no detecta caídas en $habitaciones.';
  }

  @override
  String get pushEscaladaMiaTitulo => 'Nadie atendió la alerta: te toca';

  @override
  String pushEscaladaMiaTexto(int espera) {
    return 'Pasaron $espera min sin respuesta. Eres el contacto secundario.';
  }

  @override
  String pushEscaladaTitulo(String nombre) {
    return 'Alerta escalada a $nombre';
  }

  @override
  String get pushTuContactoSecundario => 'tu contacto secundario';

  @override
  String pushEscaladaTexto(int espera) {
    return 'Nadie la marcó en $espera min. Tú todavía puedes atenderla.';
  }

  @override
  String get pushSinSecundarioTitulo => 'No hay contacto secundario';

  @override
  String pushSinSecundarioTexto(int espera) {
    return 'Pasaron $espera min sin respuesta. La alerta sigue siendo tuya.';
  }

  @override
  String pushFalsaAlarmaTitulo(String quien) {
    return '$quien la marcó como falsa alarma';
  }

  @override
  String pushAtendidaTitulo(String quien) {
    return '$quien atendió la alerta';
  }

  @override
  String pushAtendidaTexto(String hora, String tipo, String lugar) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'caida': 'Caída',
      'other': 'Movimiento inestable',
    });
    return '$hora · $_temp0 $lugar.';
  }

  @override
  String inicioHola(String nombre) {
    return 'Hola, $nombre';
  }

  @override
  String get inicioNadieRecibeAlertas =>
      'Nadie de la familia recibe las alertas';

  @override
  String get inicioActivaNotificaciones => 'Activa las notificaciones';

  @override
  String get inicioEsteCelularNoRecibe => 'Este celular no recibe las alertas';

  @override
  String get inicioSinNotificacionesTexto =>
      'Sin ellas no sabrás de una caída con la app cerrada.';

  @override
  String get inicioActivarNotificaciones => 'Activar notificaciones';

  @override
  String get inicioVerAlerta => 'Ver la alerta';

  @override
  String get inicioRegistrarConsentimiento => 'Registrar consentimiento';

  @override
  String get inicioElegirCamaras => 'Elegir las cámaras';

  @override
  String get inicioAgregarPc => 'Agregar PC';

  @override
  String get inicioVerQueRevisar => 'Ver qué revisar';

  @override
  String get inicioVerEnVivo => 'Ver en vivo';

  @override
  String get inicioNoDisponibleAhora => 'No disponible ahora';

  @override
  String get inicioTemaPrivacidad => 'privacidad';

  @override
  String get inicioNotificacionesActivadas => 'Notificaciones activadas';

  @override
  String get inicioNotificacionesActivadasTexto =>
      'Te llegarán las alertas aunque la app esté cerrada.';

  @override
  String inicioAlertaTitulo(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'inestable': 'Movimiento inestable activo',
      'confirmada': 'Caída confirmada',
      'other': 'Alerta de caída activa',
    });
    return '$_temp0';
  }

  @override
  String inicioAlertaTexto(String tipo, String lugar, String hora) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'caida': 'Caída',
      'other': 'Movimiento inestable',
    });
    return '$_temp0 $lugar a las $hora. Nadie la marcó aún.';
  }

  @override
  String get inicioDeteccionDetenida => 'Detección detenida';

  @override
  String get inicioRevocasteConsentimiento => 'Revocaste el consentimiento.';

  @override
  String inicioFaltaConsentimiento(String nombre) {
    return 'Falta el consentimiento de $nombre.';
  }

  @override
  String get inicioSinCamaras => 'Sin cámaras';

  @override
  String get inicioFaltaElegirCamaras => 'Falta elegir las cámaras.';

  @override
  String get inicioVinculaPc =>
      'Vincula la PC de la casa para detectar caídas.';

  @override
  String inicioUnaCamaraNoResponde(String habitacion) {
    return '1 cámara no responde · $habitacion';
  }

  @override
  String inicioCamarasNoResponden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras no responden',
      one: '1 cámara no responde',
    );
    return '$_temp0';
  }

  @override
  String inicioNoDetectamosEn(String lugares) {
    return 'No detectamos caídas $lugares. Las demás siguen.';
  }

  @override
  String get inicioCamaraDesconectada => 'La cámara está desconectada';

  @override
  String inicioSinEllaNoDetectamos(String lugar) {
    return 'Sin ella no detectamos caídas $lugar.';
  }

  @override
  String get inicioNoConfiable => 'La detección no es confiable';

  @override
  String inicioNoVeBien(String nombre) {
    return 'Hace más de 5 min que no ve bien a $nombre.';
  }

  @override
  String get inicioTranquiloConPausa => 'Todo tranquilo, con una pausa';

  @override
  String inicioEnPausaHasta(String habitacion, String hora) {
    return '$habitacion en pausa hasta las $hora.';
  }

  @override
  String get inicioTodoTranquilo => 'Todo tranquilo';

  @override
  String inicioSinEventosHoy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras cuidando. Sin eventos hoy.',
      one: 'Sin eventos hoy.',
      zero: 'Sin eventos hoy.',
    );
    return '$_temp0';
  }

  @override
  String inicioNombreEdad(String nombre, int edad) {
    return '$nombre, $edad años';
  }

  @override
  String get inicioCamaras => 'Cámaras';

  @override
  String get inicioFamilia => 'Familia';

  @override
  String inicioPersonas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String inicioCamarasNecesitanAtencion(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras necesitan atención',
      one: '1 cámara necesita atención',
    );
    return '$_temp0';
  }

  @override
  String get arranqueLema => 'Cerca de los tuyos, aunque estés lejos.';

  @override
  String get instalarAvisoTitulo => 'Agrega Te Tengo a tu pantalla de inicio';

  @override
  String get instalarAvisoTexto =>
      'En el iPhone, las alertas solo llegan si abres Te Tengo desde su ícono.';

  @override
  String get instalarVerComo => 'Ver cómo';

  @override
  String get instalarTitulo => 'Agregar a la pantalla de inicio';

  @override
  String get instalarEncabezado => 'Instala Te Tengo en tu iPhone';

  @override
  String get instalarIntro =>
      'Así te llegarán las alertas de caída aunque tengas la app cerrada. Necesitas iOS 16.4 o posterior.';

  @override
  String get instalarPaso1 => 'Abre esta página en Safari';

  @override
  String get instalarPaso2 => 'Toca Compartir';

  @override
  String get instalarPaso2Detalle =>
      'El cuadrado con una flecha hacia arriba, en la barra de Safari o dentro del menú «···».';

  @override
  String get instalarPaso3 => 'Elige «Agregar a inicio»';

  @override
  String get instalarPaso3Detalle =>
      'Si no lo ves, toca «Ver más» y desliza la lista hacia arriba.';

  @override
  String get instalarPaso4 => 'Toca «Agregar»';

  @override
  String get instalarPaso5 => 'Abre Te Tengo desde su ícono';

  @override
  String get instalarPaso5Detalle =>
      'Inicia sesión otra vez y toca «Activar notificaciones».';

  @override
  String get widgetAbreLaApp => 'Abre la app para ver el estado.';

  @override
  String widgetTituloAlerta(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'confirmada': 'Caída confirmada',
      'caida': 'Posible caída',
      'other': 'Movimiento inestable',
    });
    return '$_temp0';
  }

  @override
  String get widgetSinCamaras => 'Sin cámaras';

  @override
  String get widgetAbreTeTengo => 'Abre Te Tengo';

  @override
  String get widgetDeteccionDetenida => 'Detección detenida';

  @override
  String get widgetFaltaConsentimiento => 'Falta el consentimiento';

  @override
  String widgetCamarasNoResponden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras no responden',
      one: '1 cámara no responde',
    );
    return '$_temp0';
  }

  @override
  String get widgetTodoTranquilo => 'Todo tranquilo';

  @override
  String widgetCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras',
      one: '1 cámara',
    );
    return '$_temp0';
  }

  @override
  String get widgetPaso1 =>
      'Mantén presionado un espacio libre de la pantalla de inicio.';

  @override
  String get widgetPaso2 => 'Toca «Widgets» y busca Te Tengo.';

  @override
  String get widgetPaso3 => 'Elige el tamaño y suéltalo.';

  @override
  String get widgetPrivacidad =>
      'Muestra el estado, nunca imágenes de la casa.';

  @override
  String get pcsSinInternet => 'Sin internet';

  @override
  String get pcsRevisaConexion => 'Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get pcsSinInternetReintenta => 'Sin internet. Vuelve a intentarlo.';

  @override
  String get pcsAgregarPc => 'Agregar PC';

  @override
  String get pcsEscanearQr => 'Escanear el código QR';

  @override
  String get pcsEscribirCodigo => 'Escribir el código';

  @override
  String get pcsBuscandoPc => 'Buscando la PC…';

  @override
  String get pcsCodigoVencidoTitulo => 'Este código ya venció o ya se usó';

  @override
  String get pcsCodigoVencidoTexto =>
      'La PC ya muestra uno nuevo: escríbelo o escanéalo.';

  @override
  String get pcsDemasiadosIntentos => 'Demasiados intentos';

  @override
  String get pcsYaVinculadaTitulo => 'Esta PC ya está vinculada';

  @override
  String get pcsYaVinculadaTexto => 'La encuentras en Cámaras y PCs.';

  @override
  String get pcsCancelar => 'Cancelar';

  @override
  String get pcsCerrar => 'Cerrar';

  @override
  String get pcsListo => 'Listo';

  @override
  String get pcsFaltaElegirCamaras => 'Falta elegir las cámaras';

  @override
  String get pcsElegirCamaras => 'Elegir las cámaras';

  @override
  String get pcsSistema => 'Sistema';

  @override
  String get pcsPrograma => 'Programa';

  @override
  String get pcsRegistrarConsentimiento => 'Registrar consentimiento';

  @override
  String pcsFaltaConsentimientoDe(String nombre) {
    return 'Falta el consentimiento de $nombre';
  }

  @override
  String get pcsQueRevisar => 'Qué revisar';

  @override
  String get pcsSinConexion => 'Sin conexión';

  @override
  String get pcsEnLinea => 'En línea';

  @override
  String pcsSinConexionDesdeLas(String hora) {
    return 'Sin conexión desde las $hora.';
  }

  @override
  String pcsPcNoResponde(String nombre) {
    return 'La PC $nombre no responde';
  }

  @override
  String pcsPcNoRespondeDesde(String nombre, String hora) {
    return 'La PC $nombre no responde desde las $hora';
  }

  @override
  String pcsPcNombre(String nombre) {
    return 'PC $nombre';
  }

  @override
  String get pcsDejarDeUsar => 'Dejar de usar';

  @override
  String get pcsVistaPreviaTema => 'vista previa';

  @override
  String pcsNCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras',
      one: '1 cámara',
    );
    return '$_temp0';
  }

  @override
  String pcsNCamarasSinUsar(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras sin usar',
      one: '1 cámara sin usar',
    );
    return '$_temp0';
  }

  @override
  String get pcsUnaPorHabitacion => 'Una cámara por habitación.';

  @override
  String get pcsBuscarDeNuevo => 'Buscar de nuevo';

  @override
  String pcsEstadoSinConexionDesde(String hora) {
    return 'Sin conexión desde las $hora';
  }

  @override
  String pcsEstadoEnLineaSenal(String hace) {
    return 'En línea · última señal $hace';
  }

  @override
  String get pcsRevisarEncendida => 'Que la PC esté encendida';

  @override
  String get pcsRevisarEncendidaDetalle => 'Sin suspender';

  @override
  String get pcsRevisarInternet => 'Que tenga internet';

  @override
  String get pcsRevisarInternetDetalle => 'Con la luz del módem encendida';

  @override
  String get pcsRevisarCaptura => 'Que Te Tengo Captura esté abierto';

  @override
  String get pcsRevisarCapturaDetalle => 'Junto al reloj de Windows';

  @override
  String pcsChipOcupada(String habitacion) {
    return '$habitacion, ya tiene cámara';
  }

  @override
  String pcsDejarDeUsarTitulo(String dispositivo) {
    return '¿Dejar de usar la cámara $dispositivo?';
  }

  @override
  String pcsDejarDeUsarTexto(String enHabitacion) {
    return 'No detectaremos caídas $enHabitacion. Puedes volver a elegirla.';
  }

  @override
  String pcsDejamosDeUsar(String dispositivo) {
    return 'Dejamos de usar la cámara $dispositivo';
  }

  @override
  String pcsYaNoDetectamos(String enHabitacion) {
    return 'Ya no detectamos caídas $enHabitacion.';
  }

  @override
  String get pcsCodigoNoExiste =>
      'Ese código no existe. Revísalo letra por letra.';

  @override
  String get pcsCodigoFormato =>
      'El código tiene 8 letras, solo consonantes y sin números.';

  @override
  String get pcsCodigoVencido =>
      'Este código venció o ya se usó. La PC ya muestra uno nuevo.';

  @override
  String get pcsBloqueoQuinceMinutos =>
      'Podrás volver a intentarlo en 15 minutos.';

  @override
  String pcsBloqueoHasta(String hora) {
    return 'Podrás volver a intentarlo a las $hora.';
  }

  @override
  String get pcsCampoCodigoEtiqueta => 'Código de la PC, 8 letras';

  @override
  String get pcsEscribeElCodigo => 'Escribe el código de la PC';

  @override
  String get pcsCodigoDe8Letras => 'Código de 8 letras';

  @override
  String get pcsSoloConsonantes =>
      'El código solo lleva consonantes, sin números';

  @override
  String get pcsCodigoDondeEsta => 'Está debajo del QR, en Te Tengo Captura.';

  @override
  String get pcsContinuar => 'Continuar';

  @override
  String get pcsQrAjenoTitulo => 'Ese código no es de Te Tengo Captura';

  @override
  String get pcsQrAjenoTexto => 'Apunta al código QR que muestra la PC.';

  @override
  String get pcsVolver => 'Volver';

  @override
  String get pcsCamaraDelCelular => 'Cámara del celular';

  @override
  String get pcsApuntaAlQr => 'Apunta al QR de la PC';

  @override
  String get pcsLinterna => 'Linterna';

  @override
  String get pcsExplicarCamara => 'Te Tengo usará la cámara para leer el QR.';

  @override
  String get pcsNoGuardaImagenes => 'No guarda imágenes.';

  @override
  String get pcsPermitir => 'Permitir';

  @override
  String get pcsCamaraBloqueada => 'La cámara del celular está bloqueada';

  @override
  String get pcsAbrirAjustesCelular => 'Abrir los ajustes del celular';

  @override
  String get pcsNoPuedesEscanear => '¿No puedes escanearlo?';

  @override
  String get pcsNoVinculamosTitulo => 'No vinculamos la PC';

  @override
  String get pcsNoVinculamosTexto =>
      'La PC no tendrá acceso. No escanees códigos ajenos.';

  @override
  String get pcsEntendido => 'Entendido';

  @override
  String get pcsAprobarLaPc => 'Aprobar la PC';

  @override
  String get pcsVolverAIntentarlo => 'Volver a intentarlo';

  @override
  String pcsVinculamosPregunta(String nombre) {
    return '¿Vinculamos esta PC a la casa de $nombre?';
  }

  @override
  String get pcsNoPudimosVincular => 'No pudimos vincular la PC';

  @override
  String get pcsNombreDeLaPc => 'Nombre de la PC';

  @override
  String get pcsCodigo => 'Código';

  @override
  String get pcsSiLaApruebas => 'Si la apruebas, esta PC podrá:';

  @override
  String get pcsPermisoDetectar => 'Detectar caídas con sus cámaras';

  @override
  String get pcsPermisoAvisos => 'Enviar avisos y clips de 12 s';

  @override
  String get pcsPermisoVivo => 'Mostrar la vista en vivo';

  @override
  String pcsApruebalaSolo(String nombre) {
    return 'Apruébala solo si estás frente a la PC de $nombre o tú la instalaste.';
  }

  @override
  String get pcsAccionVincularPc =>
      'vincular una PC. Pídele que escanee el código';

  @override
  String get pcsAprobar => 'Aprobar';

  @override
  String get pcsVinculando => 'Vinculando…';

  @override
  String get pcsNoReconozco => 'No reconozco esta PC';

  @override
  String get pcsVinculaTitulo => 'Vincula la PC de la casa';

  @override
  String get pcsAccionAgregarPc => 'agregar una PC';

  @override
  String get pcsPasoInstalar => 'Instala Te Tengo Captura en la PC';

  @override
  String pcsPasoInstalarDesde(String pagina) {
    return 'Desde $pagina';
  }

  @override
  String get pcsPasoAbrir => 'Ábrelo: muestra un código QR';

  @override
  String get pcsPasoEscanear => 'Escanea el QR con este celular';

  @override
  String pcsEstaVinculada(String nombre) {
    return 'La PC $nombre está vinculada';
  }

  @override
  String get pcsCamarasYaElegidas => 'Sus cámaras ya están elegidas.';

  @override
  String get pcsAhoraElige => 'Ahora elige sus cámaras desde aquí.';

  @override
  String get pcsSinElNoEnvian => 'Sin él, las cámaras no envían nada.';

  @override
  String get pcsCompletarConsentimiento => 'Completar el consentimiento';

  @override
  String get pcsHacerloDespues => 'Hacerlo después';

  @override
  String get pcsSinCamarasNoDetectamos =>
      'Sin cámaras elegidas no detectamos caídas.';

  @override
  String get pcsPc => 'PC';

  @override
  String get pcsVinculada => 'Vinculada';

  @override
  String pcsVinculadaPor(String fecha, String nombre) {
    return '$fecha por $nombre';
  }

  @override
  String get pcsUltimaSenal => 'Última señal';

  @override
  String get pcsCamarasDeEstaPc => 'Cámaras de esta PC';

  @override
  String get pcsUsaOtraCamara => 'Usa otra cámara o deja de usar una';

  @override
  String get pcsQuitar => 'Quitar';

  @override
  String get pcsQuitarExplicacion => 'Deja de detectar caídas con esta PC.';

  @override
  String get pcsQuitarEstaPc => 'Quitar esta PC';

  @override
  String get pcsAccionElegirOQuitar => 'elegir las cámaras o quitar esta PC';

  @override
  String pcsQuitarPregunta(String nombre) {
    return '¿Quitar la PC $nombre?';
  }

  @override
  String pcsQuitarTextoHabitaciones(String habitaciones) {
    return 'Dejaremos de detectar caídas en $habitaciones. La PC volverá a mostrar su QR.';
  }

  @override
  String get pcsQuitarTexto => 'La PC volverá a mostrar su QR.';

  @override
  String get pcsQuitarLaPc => 'Quitar la PC';

  @override
  String pcsQuitamos(String nombre) {
    return 'Quitamos la PC $nombre';
  }

  @override
  String get pcsDejaraDeCapturar => 'Dejará de capturar en cuanto se conecte.';

  @override
  String get pcsCamaras => 'Cámaras';

  @override
  String get pcsFaltaConsentimiento => 'Falta el consentimiento';

  @override
  String get pcsSinElNoDetectamos => 'Sin él no detectamos caídas.';

  @override
  String get pcsVerTodas => 'Ver todas';

  @override
  String get pcsOrdenar => 'Ordenar';

  @override
  String get pcsFiltroSemantica => 'Ver las cámaras de';

  @override
  String get pcsTodas => 'Todas';

  @override
  String get pcsNecesitanAtencion => 'Necesitan atención';

  @override
  String get pcsFuncionando => 'Funcionando';

  @override
  String get pcsDetenidas => 'Detenidas';

  @override
  String get pcsPcsDeLaCasa => 'PCs de la casa';

  @override
  String get pcsAccionAgregarOQuitar => 'agregar o quitar PCs';

  @override
  String pcsAtencionPcSinConexion(String nombre) {
    return 'PC $nombre sin conexión';
  }

  @override
  String pcsAtencionSinConexion(String habitacion) {
    return '$habitacion sin conexión';
  }

  @override
  String pcsAtencionEnPc(String nombre) {
    return 'En la PC $nombre';
  }

  @override
  String pcsAtencionEnPcElige(String nombre) {
    return 'En la PC $nombre · elige en qué habitación está';
  }

  @override
  String get pcsReanudarAhora => 'Reanudar ahora';

  @override
  String pcsAtencionDesconectada(String habitacion) {
    return '$habitacion: cámara desconectada';
  }

  @override
  String pcsDesdeLas(String hora) {
    return 'Desde las $hora';
  }

  @override
  String pcsAtencionEnPausa(String habitacion) {
    return '$habitacion en pausa';
  }

  @override
  String pcsAtencionHastaLas(String hora) {
    return 'Hasta las $hora · se reactiva sola';
  }

  @override
  String pcsAtencionNoConfiable(String habitacion) {
    return 'Detección no confiable · $habitacion';
  }

  @override
  String get pcsAtencionRevisaLuz => 'Revisa la luz y el encuadre';

  @override
  String get pcsAunNoHayPc => 'Aún no hay una PC vinculada';

  @override
  String get pcsLineaSinCamaras => 'Sin cámaras';

  @override
  String pcsLineaFunciona(String habitacion) {
    return 'Funciona · $habitacion';
  }

  @override
  String pcsLineaFuncionan(int ok, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      ok,
      locale: localeName,
      other: '$ok de $n funcionan',
      one: '$ok de $n funciona',
    );
    return '$_temp0';
  }

  @override
  String get pcsResumenSinCamaras => 'Aún no hay cámaras elegidas';

  @override
  String get pcsResumenDetenidas => 'detenidas';

  @override
  String get pcsResumenFuncionaBien => 'funciona bien';

  @override
  String get pcsResumenTodasBien => 'todas funcionan bien';

  @override
  String get pcsResumenNoFunciona => 'no funciona ahora';

  @override
  String get pcsResumenNingunaFunciona => 'ninguna funciona ahora';

  @override
  String pcsResumenAlgunasBien(int ok) {
    String _temp0 = intl.Intl.pluralLogic(
      ok,
      locale: localeName,
      other: '$ok funcionan bien',
      one: '1 funciona bien',
    );
    return '$_temp0';
  }

  @override
  String get pcsEscribeNombreHabitacion =>
      'Escribe el nombre de la habitación.';

  @override
  String get pcsSinBano =>
      'Por privacidad, Te Tengo no admite cámaras en el baño.';

  @override
  String pcsOcupada(String enHabitacion) {
    return 'Ya hay una cámara $enHabitacion. Por ahora, cada habitación usa una sola cámara.';
  }

  @override
  String pcsOcupadaConPc(String enHabitacion, String pc) {
    return 'Ya hay una cámara $enHabitacion (PC $pc). Por ahora, cada habitación usa una sola cámara.';
  }

  @override
  String pcsCuidaAhora(String dispositivo, String laHabitacion) {
    return 'La cámara $dispositivo cuida ahora $laHabitacion';
  }

  @override
  String pcsProximasAlertas(String enHabitacion) {
    return 'Las próximas alertas dirán «$enHabitacion».';
  }

  @override
  String get pcsDetectaraConConsentimiento =>
      'Detectará caídas cuando registres el consentimiento.';

  @override
  String get pcsEligeLasCamaras => 'Elige las cámaras';

  @override
  String pcsCamarasEnLaPc(int n, String pc) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cámaras en la PC $pc. Una por habitación.',
      one: '1 cámara en la PC $pc. Una por habitación.',
    );
    return '$_temp0';
  }

  @override
  String get pcsSinElNoHayVistaPrevia =>
      'Sin él no hay vista previa ni detección.';

  @override
  String get pcsAccionElegirCamaras => 'elegir las cámaras';

  @override
  String get pcsQueRevisarEnCasa => 'Qué revisar en la casa';

  @override
  String get pcsDeteccionLenta =>
      'Si la detección va lenta, pasa cámaras a otra PC.';

  @override
  String get pcsFaltaUna => '¿Falta una? Que la conecten por USB.';

  @override
  String get pcsVerVistaPrevia => 'Ver vista previa';

  @override
  String get pcsAyudaVistaPrevia =>
      'Muestra lo que ve la cámara durante 15 s. No se graba y queda en el registro de accesos.';

  @override
  String pcsRevisaCableConserva(String habitacion) {
    return 'Revisa el cable USB. $habitacion conserva esta cámara.';
  }

  @override
  String get pcsPideConectarUsb => 'Pide que la conecten por USB.';

  @override
  String get pcsEnQueHabitacion => '¿En qué habitación está?';

  @override
  String get pcsHabitacionesTema => 'habitaciones';

  @override
  String get pcsOtra => 'Otra…';

  @override
  String get pcsYaTienenCamara =>
      'Las que ya tienen cámara no se pueden elegir.';

  @override
  String get pcsNombreHabitacion => 'Nombre de la habitación';

  @override
  String get pcsNombreHabitacionEjemplo => 'Ej.: Estudio';

  @override
  String get pcsUsarEstaCamara => 'Usar esta cámara';

  @override
  String pcsBuscandoCamaras(String pc) {
    return 'Buscando cámaras en la PC $pc…';
  }

  @override
  String pcsNoEncontramosCamaras(String pc) {
    return 'No encontramos cámaras en la PC $pc';
  }

  @override
  String get pcsConectenWebcam => 'Que conecten una webcam por USB.';

  @override
  String pcsWebcamDesconectadaEn(String habitacion) {
    return 'Desconectada · $habitacion';
  }

  @override
  String pcsWebcamEnUsoPausa(String habitacion) {
    return 'En uso · $habitacion · en pausa';
  }

  @override
  String pcsWebcamEnUso(String habitacion) {
    return 'En uso · $habitacion';
  }

  @override
  String get pcsWebcamDesconectada => 'Desconectada';

  @override
  String get pcsWebcamSinUsar => 'Sin usar';

  @override
  String get pcsCamaraDesconectada => 'La cámara está desconectada';

  @override
  String get pcsRevisenCable => 'Que revisen el cable USB.';

  @override
  String get pcsSinElNoHayVideo => 'Sin él no hay video.';

  @override
  String get pcsCamaraEnPausa => 'La cámara está en pausa';

  @override
  String pcsHastaLas(String hora) {
    return 'Hasta las $hora.';
  }

  @override
  String get pcsAccesoRegistrado => 'Acceso registrado';

  @override
  String pcsVisteVistaPrevia(String dispositivo, String duracion) {
    return 'Viste la vista previa de $dispositivo durante $duracion.';
  }

  @override
  String pcsVistaPreviaDe(String dispositivo) {
    return 'Vista previa · $dispositivo';
  }

  @override
  String pcsAyudaVistaPreviaCierre(int segundos) {
    return 'No se graba y queda en el registro de accesos. Se cierra sola a los $segundos s.';
  }

  @override
  String pcsVistaPreviaCuenta(String tiempo) {
    return 'VISTA PREVIA · $tiempo';
  }
}
