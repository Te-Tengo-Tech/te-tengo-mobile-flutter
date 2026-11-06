// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get actividadTitulo => 'Activity';

  @override
  String get actividadHoy => 'Today';

  @override
  String get actividadAyer => 'Yesterday';

  @override
  String actividadUltimoCambioHoy(String hora) {
    return 'Last change: today $hora';
  }

  @override
  String actividadUltimoCambioAyer(String hora) {
    return 'Last change: yesterday $hora';
  }

  @override
  String actividadUltimoCambioFecha(String fecha, String hora) {
    return 'Last change: $fecha $hora';
  }

  @override
  String get actividadSinActividad => 'No activity yet';

  @override
  String get actividadAyudaRegistro => 'No one can delete or change this log.';

  @override
  String get actividadAyudaTema => 'activity log';

  @override
  String get actividadFiltrarPorPc => 'Filter by PC';

  @override
  String get actividadTodas => 'All';

  @override
  String get actividadVacioTitulo => 'No activity recorded yet';

  @override
  String get actividadVacioTexto =>
      'Here you\'ll see every change to PCs, cameras and data.';

  @override
  String get actividadReintentar => 'Try again';

  @override
  String get actividadDatoQuien => 'Who';

  @override
  String get actividadDatoDesde => 'From';

  @override
  String get actividadDatoMomento => 'Moment';

  @override
  String get actividadDatoDuracion => 'Duration';

  @override
  String get actividadDatoAntes => 'Before';

  @override
  String get actividadDatoDespues => 'After';

  @override
  String get actividadDatoFechaYHora => 'Date and time';

  @override
  String get actividadCerrar => 'Close';

  @override
  String get actividadCargando => 'Loading activity';

  @override
  String actividadFraseFamiliar(String quien, String accion) {
    return '$quien $accion';
  }

  @override
  String actividadFraseDesdePc(String pc, String accion) {
    return 'From PC $pc: $accion';
  }

  @override
  String actividadVinculoPc(String pc) {
    return 'linked PC $pc';
  }

  @override
  String actividadRenombroPc(String antes, String despues) {
    return 'renamed PC $antes to $despues';
  }

  @override
  String actividadQuitoPc(String pc) {
    return 'removed PC $pc';
  }

  @override
  String actividadPcRestablecida(String pc) {
    return 'PC $pc was reset';
  }

  @override
  String actividadPcDesinstalada(String pc) {
    return 'PC $pc was uninstalled';
  }

  @override
  String get actividadPcSeDesvinculo => 'this PC was unlinked';

  @override
  String actividadPcVencida(String pc) {
    return 'PC $pc was unlinked: it didn\'t connect for 90 days';
  }

  @override
  String actividadPcPorSeguridad(String pc) {
    return 'PC $pc was unlinked for security';
  }

  @override
  String actividadCamaraPasoA(String camara, String habitacion) {
    return 'camera $camara moved to $habitacion';
  }

  @override
  String actividadEligioCamara(
    String camara,
    String conArticulo,
    String habitacion,
  ) {
    return 'chose camera $camara for $habitacion';
  }

  @override
  String actividadPasoCamara(
    String camara,
    String deAntes,
    String aDespues,
    String antes,
    String despues,
  ) {
    return 'moved camera $camara from $antes to $despues';
  }

  @override
  String actividadSeDejoDeUsarCamara(String camara) {
    return 'camera $camara is no longer used';
  }

  @override
  String actividadDejoDeUsarCamara(String camara) {
    return 'stopped using camera $camara';
  }

  @override
  String actividadRenombroHabitacion(
    String deAntes,
    String despues,
    String antes,
  ) {
    return 'renamed the room $antes to $despues';
  }

  @override
  String actividadPausoCamara(String deHabitacion, String habitacion) {
    return 'paused the $habitacion camera';
  }

  @override
  String actividadPausoCamaraHasta(
    String deHabitacion,
    String hasta,
    String habitacion,
  ) {
    return 'paused the $habitacion camera until $hasta';
  }

  @override
  String actividadHastaHora(String hora) {
    return '$hora';
  }

  @override
  String actividadHastaDia(String dia, String hora) {
    return '$dia at $hora';
  }

  @override
  String actividadTerminoPausa(String deHabitacion, String habitacion) {
    return 'The $habitacion camera pause ended';
  }

  @override
  String actividadReanudoCamara(String deHabitacion, String habitacion) {
    return 'resumed the $habitacion camera';
  }

  @override
  String actividadCambioFoto(String nombre) {
    return 'changed $nombre\'s photo';
  }

  @override
  String actividadQuitoFoto(String nombre) {
    return 'removed $nombre\'s photo';
  }

  @override
  String get actividadRegistroConsentimiento =>
      'recorded the monitoring consent';

  @override
  String get actividadRevocoConsentimiento => 'revoked the monitoring consent';

  @override
  String actividadRegistroPermisoMovimientos(String nombre) {
    return 'recorded $nombre\'s permission to save movements';
  }

  @override
  String actividadMovimientosRevocados(String nombre) {
    return '$nombre\'s movements stopped being saved when consent was revoked';
  }

  @override
  String actividadDejoDeGuardarMovimientos(String nombre) {
    return 'stopped saving $nombre\'s movements';
  }

  @override
  String actividadCambioRetencion(String de, String a) {
    return 'changed cloud movements from $de to $a';
  }

  @override
  String get actividadNoGuardar => 'Don\'t save';

  @override
  String get actividadModoAvanzadoActivado => 'turned on advanced mode';

  @override
  String get actividadModoAvanzadoDesactivado => 'turned off advanced mode';

  @override
  String get actividadGuardadoEnPc => 'saving on the PC';

  @override
  String actividadGuardadoCambio(String que, String antes, String despues) {
    return '$que changed from $antes to $despues';
  }

  @override
  String get actividadNo => 'No';

  @override
  String get actividadBorroDatos => 'deleted the data saved on the PC';

  @override
  String get actividadVioQuePaso => 'watched what happened';

  @override
  String actividadVioQuePasoEn(String enHabitacion, String habitacion) {
    return 'watched what happened in $habitacion';
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
    return '$mm/$dd';
  }

  @override
  String actividadPcActualizada(String pc, String version) {
    return '$pc updated to $version';
  }

  @override
  String get actividadActualizacionAutomaticaActivada =>
      'turned on automatic updates';

  @override
  String get actividadActualizacionAutomaticaDesactivada =>
      'turned off automatic updates';

  @override
  String get actividadCambioFamiliar => 'changed a setting';

  @override
  String get actividadCambioPc => 'a setting changed';

  @override
  String get actividadCambioSistema => 'A setting changed';

  @override
  String get actividadVinculada => 'Linked';

  @override
  String get actividadDesvinculada => 'Unlinked';

  @override
  String get actividadSinUsar => 'Not in use';

  @override
  String get actividadEnLinea => 'Online';

  @override
  String get actividadEnPausa => 'Paused';

  @override
  String actividadEnPausaHasta(String hasta) {
    return 'Paused until $hasta';
  }

  @override
  String get actividadNoAutorizado => 'Not authorized';

  @override
  String get actividadVigente => 'Active';

  @override
  String get actividadRevocado => 'Revoked';

  @override
  String get actividadDesactivado => 'Off';

  @override
  String get actividadActivado => 'On';

  @override
  String get actividadAlguienEnPc => 'Someone at the PC';

  @override
  String actividadCelularDe(String nombre) {
    return '$nombre\'s phone';
  }

  @override
  String actividadPc(String pc) {
    return 'PC $pc';
  }

  @override
  String get actividadAutomatico => 'Automatic';

  @override
  String get ajustesTitulo => 'Settings';

  @override
  String ajustesEdad(int edad) {
    return '$edad years old';
  }

  @override
  String get ajustesViveSolo => 'Lives alone';

  @override
  String get ajustesViveContigo => 'Lives with you';

  @override
  String get ajustesViveConCuidador => 'Lives with another caregiver';

  @override
  String get ajustesInvitadoTitulo => 'You\'re an invited member';

  @override
  String ajustesInvitadoTexto(String titular) {
    return 'Only $titular can change what has a lock.';
  }

  @override
  String get ajustesPersonaCuidada => 'Cared-for person';

  @override
  String get ajustesMonitoreo => 'Monitoring';

  @override
  String get ajustesCamarasYPcs => 'Cameras and PCs';

  @override
  String get ajustesOrdenAviso => 'Alert order and wait';

  @override
  String ajustesOrdenSinSecundario(String principal, int espera) {
    return '$principal · no backup · $espera min';
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
  String get ajustesPrivacidad => 'Privacy and consent';

  @override
  String ajustesConsentimientoVigente(String fecha) {
    return 'Active · $fecha';
  }

  @override
  String get ajustesSinConsentimiento => 'No consent';

  @override
  String get ajustesActividad => 'Activity';

  @override
  String get ajustesEsteCelular => 'This phone';

  @override
  String get ajustesNotificaciones => 'Notifications';

  @override
  String get ajustesActivadas => 'On';

  @override
  String get ajustesDesactivadas => 'Off';

  @override
  String get ajustesPreferencias => 'Preferences';

  @override
  String get ajustesAgregarWidget => 'Add the widget';

  @override
  String ajustesWidgetResumen(String nombre) {
    return '$nombre and “Watch live” on your home screen';
  }

  @override
  String get ajustesCuenta => 'Account';

  @override
  String get ajustesTuCuentaTitular => 'Your account · Owner';

  @override
  String get ajustesTuCuentaInvitado => 'Your account · Invited member';

  @override
  String get ajustesCerrarSesion => 'Sign out';

  @override
  String ajustesCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras',
      one: '1 camera',
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
  String get ajustesSinPc => 'No PC linked yet';

  @override
  String ajustesPcSinConexion(String pc) {
    return '$pc offline';
  }

  @override
  String get preferenciasTitulo => 'Preferences';

  @override
  String get preferenciasTemaAutomatico => 'Automatic';

  @override
  String get preferenciasTemaClaro => 'Light';

  @override
  String get preferenciasTemaOscuro => 'Dark';

  @override
  String get preferenciasLetraEstandar => 'Standard';

  @override
  String get preferenciasLetraGrande => 'Large';

  @override
  String get preferenciasResumenTemaAutomatico => 'Automatic theme';

  @override
  String get preferenciasResumenTemaClaro => 'Light theme';

  @override
  String get preferenciasResumenTemaOscuro => 'Dark theme';

  @override
  String get preferenciasResumenLetraEstandar => 'standard text';

  @override
  String get preferenciasResumenLetraGrande => 'large text';

  @override
  String get preferenciasResumenContraste => 'more contrast';

  @override
  String get preferenciasTema => 'Theme';

  @override
  String get preferenciasIgualQueCelular => 'Same as your phone';

  @override
  String get preferenciasTamanoLetra => 'Text size';

  @override
  String get preferenciasContraste => 'Contrast';

  @override
  String get preferenciasAumentarContraste => 'Increase contrast';

  @override
  String get preferenciasContrasteTexto => 'Bolder text and borders';

  @override
  String get preferenciasAlertasConservanColor => 'Alerts keep their colors.';

  @override
  String get notificacionesTitulo => 'Notifications';

  @override
  String get notificacionesDesactivadasTitulo => 'Off on your phone';

  @override
  String get notificacionesDesactivadasTexto =>
      'With the app closed, you won\'t hear about a fall.';

  @override
  String get notificacionesActivar => 'Turn on notifications';

  @override
  String get notificacionesFamiliaSinAlertas =>
      'No one in the family gets alerts';

  @override
  String get notificacionesCelularSinAlertas =>
      'This phone doesn\'t get alerts';

  @override
  String get notificacionesSinAlertasTexto =>
      'Without them, you won\'t know about a fall while the app is closed.';

  @override
  String get notificacionesActivadas => 'Notifications on';

  @override
  String get notificacionesAvisosEnCelular => 'Alerts on this phone';

  @override
  String get notificacionesCaidas => 'Falls';

  @override
  String get notificacionesSiempreActivas => 'Always on';

  @override
  String get notificacionesSonarSubtitulo => 'Even when the phone is on silent';

  @override
  String get notificacionesInestables => 'Unstable movements';

  @override
  String get notificacionesSeveridadMedia => 'Medium severity';

  @override
  String get notificacionesEstadoCamara => 'Camera status';

  @override
  String get notificacionesEstadoCamaraTexto =>
      'Disconnected or unreliable detection · always on';

  @override
  String get notificacionesFinPausa => 'End of a pause';

  @override
  String get notificacionesFinPausaTexto =>
      'When the camera turns back on by itself';

  @override
  String get notificacionesSiNadieAtiende => 'If no one responds';

  @override
  String notificacionesAvisarSecundario(int espera) {
    return 'Alert the backup after $espera min';
  }

  @override
  String get notificacionesActivadasPermiso => 'On';

  @override
  String get notificacionesSonarEnSilencio => 'Ring on silent';

  @override
  String get notificacionesPermitir => 'Allow';

  @override
  String get acercaDeComoPwa =>
      'It updates over the internet. We\'ll tell you when to reload it.';

  @override
  String get acercaDeComoApk =>
      'We\'ll tell you when there\'s a new version. Android asks you to confirm.';

  @override
  String get acercaDeComoPlay => 'Google Play updates it by itself.';

  @override
  String get acercaDeComoIos => 'It updates from the App Store or TestFlight.';

  @override
  String get acercaDeTitulo => 'About';

  @override
  String get acercaDeFila => 'About Te Tengo';

  @override
  String acercaDeVersion(String version) {
    return 'Version $version';
  }

  @override
  String get acercaDeHayUnaNueva => 'update available';

  @override
  String get acercaDeActualizaciones => 'Updates';

  @override
  String get acercaDeActualizacionesTema => 'updates';

  @override
  String get acercaDePcsDeLaCasa => 'PCs at home';

  @override
  String get acercaDePcsAyuda => 'Each PC updates Te Tengo Captura on its own.';

  @override
  String get acercaDePcsTema => 'the PCs';

  @override
  String acercaDePcsAnteriores(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n PCs on an older version',
      one: '1 PC on an older version',
    );
    return '$_temp0';
  }

  @override
  String acercaDeTodasAlDia(String version) {
    return 'All up to date · Te Tengo Captura $version';
  }

  @override
  String acercaDeCaptura(String version) {
    return 'Captura $version';
  }

  @override
  String get acercaDeAlDia => 'up to date';

  @override
  String get actualizacionVersionAnterior => 'older version';

  @override
  String get actualizacionBuscando => 'Checking for updates…';

  @override
  String get actualizacionSinInternet => 'No internet';

  @override
  String get actualizacionNoPudimosBuscar => 'We couldn\'t check.';

  @override
  String get actualizacionUltimaVersion => 'You have the latest version';

  @override
  String get actualizacionRevisadoAntes => 'Checked today at ';

  @override
  String get actualizacionRevisadoDespues => '.';

  @override
  String get actualizacionBuscar => 'Check for updates';

  @override
  String get actualizacionQueCambio => 'What\'s new';

  @override
  String actualizacionQueCambioEn(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get actualizacionAlCerrarAlerta => 'Once the alert is closed.';

  @override
  String get actualizacionAhoraNo => 'Not now';

  @override
  String get actualizacionDescarga => 'Download';

  @override
  String actualizacionPorcentaje(int p) {
    return '$p%';
  }

  @override
  String actualizacionTamanoMb(String mb) {
    return '$mb MB';
  }

  @override
  String get actualizacionSeparadorDecimal => '.';

  @override
  String get actualizacionDescargaTema => 'the download';

  @override
  String actualizacionAbrirTienda(String tienda) {
    return 'Open $tienda';
  }

  @override
  String get actualizacionAbrir => 'Open';

  @override
  String get actualizacionActualizar => 'Update';

  @override
  String actualizacionDescargando(String version) {
    return 'Downloading $version';
  }

  @override
  String get actualizacionCancelar => 'Cancel';

  @override
  String get actualizacionComprobando => 'Checking the download…';

  @override
  String get actualizacionReintentar => 'Retry';

  @override
  String get actualizacionNoSePudoDescargarPunto => 'Couldn\'t download.';

  @override
  String get actualizacionNoSePudoDescargar => 'Couldn\'t download';

  @override
  String actualizacionSigues(String version) {
    return 'You\'re still on $version.';
  }

  @override
  String get actualizacionNoSePudoVerificar => 'Couldn\'t verify the download';

  @override
  String actualizacionLaBorramos(String version) {
    return 'We deleted it. You\'re still on $version.';
  }

  @override
  String get actualizacionNoCoincide =>
      'It doesn\'t match the published version. To protect your phone, it won\'t be installed.';

  @override
  String get actualizacionNoSeInstalo => 'Not installed';

  @override
  String get actualizacionCancelaste => 'You canceled the installation.';

  @override
  String get actualizacionFaltaPermiso => 'Android permission needed';

  @override
  String get actualizacionSinPermiso => 'Without it, it won\'t install.';

  @override
  String actualizacionHayNuevaVersion(String version) {
    return 'New version available ($version)';
  }

  @override
  String get actualizacionHayNueva => 'New version available';

  @override
  String get actualizacionAplicacionWeb => 'Web app';

  @override
  String get actualizacionSeActualizo => 'Te Tengo was updated';

  @override
  String actualizacionVersionPunto(String version) {
    return 'Version $version.';
  }

  @override
  String get actualizacionObligatoriaTitulo =>
      'Update Te Tengo to keep getting alerts';

  @override
  String actualizacionObligatoriaTienes(String version) {
    return 'You have $version. It takes a minute.';
  }

  @override
  String get actualizacionObligatoriaAyuda =>
      'This version no longer gets alerts safely. Those who updated keep getting them.';

  @override
  String get actualizacionObligatoriaTema => 'why update';

  @override
  String get actualizacionAbrirLaTienda => 'Open the store';

  @override
  String actualizacionLlamarA(String nombre) {
    return 'Call $nombre';
  }

  @override
  String actualizacionSeAbre(String tienda) {
    return '$tienda will open.';
  }

  @override
  String get actualizacionActualizando => 'Updating…';

  @override
  String get actualizacionCerrar => 'Close';

  @override
  String get actualizacionInstalarTitulo => 'Install the update';

  @override
  String get actualizacionPermitirFuente => 'Allow from this source';

  @override
  String get actualizacionPermiteInstalar => 'Allow installing the update';

  @override
  String get actualizacionUnaSolaVez => 'Android asks only once.';

  @override
  String get actualizacionPermisoAyuda =>
      'Te Tengo doesn\'t come from a store, so Android asks for permission to install its new versions. It only accepts the ones signed by Te Tengo.';

  @override
  String get actualizacionPermisoTema => 'the Android permission';

  @override
  String get actualizacionPasoAbrirAjustes => 'Tap “Open settings”.';

  @override
  String get actualizacionPasoActivar => 'Turn on “Allow from this source”.';

  @override
  String get actualizacionPasoVolver => 'Go back to Te Tengo.';

  @override
  String get actualizacionAbrirAjustes => 'Open settings';

  @override
  String actualizacionVersionAnteriorPc(String version) {
    return 'Older version ($version)';
  }

  @override
  String get actualizacionSeActualizaraSola => 'It will update by itself.';

  @override
  String get actualizacionPideActualizar =>
      'Ask someone at home to update it. ';

  @override
  String get actualizacionPcAyuda =>
      'The PC shows «Hay una versión nueva»: they should choose «Descargar». It installs by itself and detection keeps running.';

  @override
  String get actualizacionPcTema => 'how to update the PC';

  @override
  String get alertaTipoCaida => 'Fall';

  @override
  String get alertaTipoInestable => 'Unstable movement';

  @override
  String alertaTipoEnHabitacion(String tipo, String sala, String habitacion) {
    return '$tipo in $habitacion';
  }

  @override
  String get alertaEtiquetaInestable => 'Unstable';

  @override
  String get alertaSelloAtendida => 'Handled';

  @override
  String get alertaSelloFalsaAlarma => 'False alarm';

  @override
  String get alertaSelloActiva => 'Active';

  @override
  String get alertaCerrarTooltip => 'Close the alert and go home';

  @override
  String alertaNoContesta(String nombre) {
    return '$nombre isn\'t answering?';
  }

  @override
  String get alertaLlamarSamu => 'Call SAMU · 106';

  @override
  String get alertaClipTitulo => 'Event clip';

  @override
  String get alertaClipResumen => '12 s, before and after';

  @override
  String get alertaClipNoGuardado => 'Couldn\'t be saved';

  @override
  String get alertaMasDetalles => 'More details';

  @override
  String get alertaMasDetallesResumen => 'Address, phone, alerts and log';

  @override
  String get alertaMarcar => 'Mark alert';

  @override
  String get alertaPorqueInestable =>
      'It isn\'t a fall. If it turns into one, we\'ll let you know.';

  @override
  String get alertaPorqueSeLevanto =>
      'Back on their feet. Check how they\'re doing before marking it.';

  @override
  String get alertaPorqueConfirmada =>
      'On the floor for over 30 s. If they get up, we\'ll let you know.';

  @override
  String get alertaPorqueComprobando =>
      'If still on the floor after 30 s, we confirm the fall. If they get up, we\'ll let you know.';

  @override
  String get alertaDireccion => 'Address';

  @override
  String get alertaTelefono => 'Phone';

  @override
  String get alertaBomberos => 'Firefighters';

  @override
  String get alertaEmpezoInestableTitulo => 'Started as unstable movement';

  @override
  String alertaEmpezoInestableTexto(
    String hora,
    String sala,
    String habitacion,
  ) {
    return 'At $hora in $habitacion. It ended in a fall.';
  }

  @override
  String get alertaTeTocaTitulo => 'It\'s your turn to handle it';

  @override
  String alertaTeTocaTexto(int espera, String hora) {
    return 'No one marked it in $espera min ($hora).';
  }

  @override
  String alertaAvisamosA(String nombre) {
    return 'We told $nombre';
  }

  @override
  String alertaAvisamosTexto(String hora) {
    return 'At $hora. You can still handle it.';
  }

  @override
  String get alertaNoHayAQuienTitulo => 'No one to escalate to';

  @override
  String alertaSinRespuestaTuya(int espera) {
    return 'No answer in $espera min. It\'s still yours.';
  }

  @override
  String alertaSinRespuestaDe(int espera, String nombre) {
    return 'No answer in $espera min. It\'s still $nombre\'s.';
  }

  @override
  String get alertaAgregarSecundario => 'Add secondary contact';

  @override
  String get alertaSinSecundarioTitulo => 'No secondary contact';

  @override
  String get alertaSinSecundarioTexto =>
      'If no one handles it, there\'s no one else to tell.';

  @override
  String get alertaAgregarContacto => 'Add contact';

  @override
  String alertaLimiteSoySecundario(String principal, String hora) {
    return '$principal is the main contact. If no one marks it by $hora, we\'ll tell you.';
  }

  @override
  String alertaLimiteSecundario(String hora, String secundario) {
    return 'If no one marks it by $hora, we\'ll tell $secundario (secondary).';
  }

  @override
  String get alertaEtiquetaCaidaUrgente => 'Fall · Urgent';

  @override
  String get alertaEtiquetaInestableMedia => 'Unstable · Medium severity';

  @override
  String get alertaNoTeLlego => 'It didn\'t reach you as a notification';

  @override
  String get alertaFalloEnvio => 'Sending failed; we keep retrying.';

  @override
  String alertaTituloInestable(String nombre) {
    return '$nombre had an unstable movement';
  }

  @override
  String alertaTituloEnElSuelo(String nombre) {
    return '$nombre fell and is still on the floor';
  }

  @override
  String alertaTituloPudoCaerse(String nombre) {
    return '$nombre may have fallen';
  }

  @override
  String get alertaHaceAhora => 'Just now';

  @override
  String alertaHaceMinutos(int minutos) {
    return '$minutos min ago';
  }

  @override
  String alertaLlamarA(String nombre) {
    return 'Call $nombre';
  }

  @override
  String get alertaVerEnVivo => 'Watch live';

  @override
  String get alertaSigueEnSueloConfirmada => 'Still on the floor · confirmed';

  @override
  String get alertaComprobando => 'Checking if still on the floor';

  @override
  String alertaSeLevantoALas(String hora) {
    return 'Got up at $hora';
  }

  @override
  String get alertaDatoHabitacion => 'Room';

  @override
  String get alertaDatoHora => 'Time';

  @override
  String get alertaDatoHace => 'When';

  @override
  String alertaAvisadoPrincipal(String nombre) {
    return '$nombre (main)';
  }

  @override
  String get alertaLineaLaFamilia => 'the family';

  @override
  String get alertaLineaReintentando => 'Couldn\'t deliver; retrying';

  @override
  String get alertaLineaNoEntregada => 'Couldn\'t deliver';

  @override
  String alertaLineaAviso(String avisados, int segundos) {
    return 'Alert sent to $avisados · $segundos s';
  }

  @override
  String get alertaLineaConfirmada => 'Still on the floor: confirmed';

  @override
  String alertaLineaSeLevanto(String nombre) {
    return '$nombre got up';
  }

  @override
  String alertaLineaEscaladaA(int espera, String nombre) {
    return 'No answer in $espera min: alert sent to $nombre (secondary)';
  }

  @override
  String alertaLineaSinSecundario(int espera) {
    return 'No answer in $espera min and no secondary contact';
  }

  @override
  String alertaLineaAtendidaPor(String nombre) {
    return 'Handled by $nombre';
  }

  @override
  String alertaLineaAntesDeEscalar(int espera) {
    return 'Handled within $espera min: not escalated';
  }

  @override
  String alertaLineaFalsaAlarma(String nombre) {
    return 'False alarm, marked by $nombre';
  }

  @override
  String get alertaMarcadaFalsa => 'Marked as a false alarm';

  @override
  String get alertaAtendidaToast => 'Alert handled';

  @override
  String alertaToastFamiliaVera(String hora) {
    return 'The family will see you marked it at $hora.';
  }

  @override
  String get alertaMarcarPregunta => 'How did this alert end?';

  @override
  String alertaMarcarResumen(
    String tipo,
    String sala,
    String hora,
    String habitacion,
  ) {
    return '$tipo in $habitacion at $hora.';
  }

  @override
  String get alertaOpcionAtendida => 'Handled';

  @override
  String alertaOpcionAtendidaDetalle(String nombre) {
    return '$nombre got help or is OK';
  }

  @override
  String get alertaOpcionFalsa => 'False alarm';

  @override
  String get alertaOpcionFalsaCaida => 'There was no fall.';

  @override
  String get alertaOpcionFalsaInestable => 'There was no unstable movement.';

  @override
  String get alertaEligeOpcion => 'Choose an option.';

  @override
  String alertaQuedaraRegistrado(String quien, String hora) {
    return 'It will be logged: $quien · $hora';
  }

  @override
  String get alertaGuardar => 'Save';

  @override
  String get alertaDetalleTitulo => 'Alert';

  @override
  String alertaDetalleTituloFecha(String fecha) {
    return 'Alert from $fecha';
  }

  @override
  String get alertaGrabacion => 'Recording';

  @override
  String get alertaVerQuePaso => 'See what happened';

  @override
  String get alertaVerQuePasoSinVideo => 'On the camera, no video';

  @override
  String get alertaVerQuePasoRequiere => 'Requires storing movements';

  @override
  String get alertaRegistroEvento => 'Event log';

  @override
  String alertaMomentos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n moments',
      one: '1 moment',
    );
    return '$_temp0';
  }

  @override
  String get alertaTerminoEnCaida => 'Did it end in a fall we missed?';

  @override
  String get alertaMarcadaAtendida => 'Marked as handled';

  @override
  String alertaMarcadaPor(String nombre, String hora) {
    return 'by $nombre at $hora';
  }

  @override
  String get alertaGrabacionDescargada => 'Recording downloaded';

  @override
  String alertaGrabacionEnArchivos(String archivo) {
    return '$archivo in Files';
  }

  @override
  String get alertaDescargarGrabacion => 'Download recording';

  @override
  String alertaDescargaDetalle(String fecha) {
    return 'MP4 · 12 s · until $fecha';
  }

  @override
  String get clipBorradoTitulo => 'The recording is no longer available';

  @override
  String clipBorradoDetalle(String fecha) {
    return 'Deleted on $fecha (kept for 30 days).';
  }

  @override
  String get clipNoDisponible => 'Clip not available';

  @override
  String get clipSigueValida => 'The alert is still valid.';

  @override
  String get clipPantallaCompleta => 'Watch the clip full screen';

  @override
  String get clipAyuda =>
      'The clip is 12 s long: 6 s before and 6 s after the alert.';

  @override
  String get clipAyudaTema => 'the clip';

  @override
  String get clipSalirPantallaCompleta => 'Exit full screen';

  @override
  String clipPuntosSinPermiso(String nombre) {
    return '$nombre hasn\'t given permission to store movements';
  }

  @override
  String get clipPuntosNoLosTiene => 'this clip doesn\'t have them';

  @override
  String get clipPuntosNoCargaron => 'they couldn\'t be loaded';

  @override
  String get clipPuntosTitulo => 'Body points';

  @override
  String clipPuntosNoDisponibles(String motivo) {
    return 'Not available: $motivo.';
  }

  @override
  String get clipPausar => 'Pause clip';

  @override
  String get clipVolverAVer => 'Watch the clip again';

  @override
  String get clipReproducir => 'Play clip';

  @override
  String get clipRetroceder => 'Back 5 seconds';

  @override
  String get clipAdelantar => 'Forward 5 seconds';

  @override
  String clipVelocidad(String velocidad) {
    return 'Speed $velocidad. Change the speed';
  }

  @override
  String get clipAvance => 'Clip progress';

  @override
  String get clipMomentoEvento => 'Moment of the event';

  @override
  String get repeticionEventoCaida => 'Fall';

  @override
  String get repeticionEventoInestable => 'Unstable';

  @override
  String get repeticionEventoLevanto => 'Got up';

  @override
  String get repeticionSinDatos => 'No data';

  @override
  String get repeticionFaseLevanto => 'Got up';

  @override
  String get repeticionFaseInestable => 'Unstable movement';

  @override
  String get repeticionFasePosibleCaida => 'Possible fall';

  @override
  String get repeticionFaseEnSuelo => 'On the floor';

  @override
  String get repeticionNoMasEventosDia => 'No more events this day';

  @override
  String get repeticionNoMasEventos => 'No more events';

  @override
  String get repeticionNoEventosAntes => 'No earlier events';

  @override
  String get repeticionHoy => 'Today';

  @override
  String get repeticionAyer => 'Yesterday';

  @override
  String repeticionVerEnVivo(String habitacion) {
    return 'Watch $habitacion live';
  }

  @override
  String get repeticionEnVivo => 'Live';

  @override
  String get repeticionCargando => 'Loading…';

  @override
  String get repeticionSinInternet => 'No internet';

  @override
  String repeticionPermisoRetirado(String nombre) {
    return '$nombre withdrew permission. Their movements were deleted.';
  }

  @override
  String get repeticionSinPersona => 'No one in the picture';

  @override
  String repeticionIrAEvento(String hora, String evento) {
    return '$hora, $evento. Go to this moment';
  }

  @override
  String get repeticionMomento => 'Replay position';

  @override
  String get repeticionEventoAnterior => 'Previous event';

  @override
  String get repeticionRetroceder => 'Back 10 seconds';

  @override
  String get repeticionPausar => 'Pause';

  @override
  String get repeticionReproducir => 'Play';

  @override
  String get repeticionEventoSiguiente => 'Next event';

  @override
  String get repeticionAdelantar => 'Forward 10 seconds';

  @override
  String get repeticionElegirDia => 'Choose a day';

  @override
  String repeticionHayMovimientosDesde(String fecha) {
    return 'Movements available since $fecha.';
  }

  @override
  String get repeticionConEventos => 'With events';

  @override
  String repeticionDiaSinMovimientos(String fecha) {
    return '$fecha, no movements';
  }

  @override
  String repeticionDiaConEventos(String fecha) {
    return '$fecha, with events';
  }

  @override
  String get reportesEnlace => 'Was there a fall we missed?';

  @override
  String get reportesNoSe => 'Don\'t know';

  @override
  String get reportesHoraFormato => 'Write the time like this: 07:30.';

  @override
  String get reportesHoraFutura => 'Choose a time that has already passed.';

  @override
  String get reportesFecha => 'Date';

  @override
  String get reportesHoy => 'Today';

  @override
  String get reportesAyer => 'Yesterday';

  @override
  String get reportesHoraAproximada => 'Approximate time';

  @override
  String get reportesTitulo => 'Tell us what happened';

  @override
  String reportesSamuConNombre(String nombre) {
    return 'If $nombre needs help now, call SAMU · 106';
  }

  @override
  String get reportesSamu => 'If help is needed now, call SAMU · 106';

  @override
  String get reportesLlamarSamu => 'Call SAMU · 106';

  @override
  String get reportesPregunta => 'Was there a fall we didn\'t alert you to?';

  @override
  String get reportesRevisaremos => 'We\'ll review it to improve detection.';

  @override
  String get reportesHabitacion => 'Room';

  @override
  String get reportesEligeHabitacion => 'Choose the room or “Don\'t know”.';

  @override
  String get reportesQuePaso => 'What happened? (optional)';

  @override
  String get reportesNotaEjemplo => 'E.g.: Slipped getting out of bed';

  @override
  String get reportesEnviar => 'Send';

  @override
  String get reportesEnviando => 'Sending…';

  @override
  String get reportesMovimientosHay =>
      'We\'ll review the movements from that moment.';

  @override
  String get reportesMovimientosNo =>
      'No movements from that moment; we\'ll review your account.';

  @override
  String get reportesGuardado => 'We saved it to send later';

  @override
  String get reportesGracias => 'Thank you. We\'ll review it.';

  @override
  String reportesGraciasNombre(String nombre) {
    return 'Thank you, $nombre. We\'ll review it.';
  }

  @override
  String get reportesNoPudimosTitulo => 'We couldn\'t send it';

  @override
  String get reportesNoPudimosTexto =>
      'We saved it and will send it when the connection is back.';

  @override
  String get reportesNoGeneraAlerta =>
      'This doesn\'t create an alert or notify the family.';

  @override
  String get reportesVolverHistorial => 'Back to history';

  @override
  String get appTitulo => 'Te Tengo';

  @override
  String get camaraEstadoEnLinea => 'Online';

  @override
  String get camaraEstadoDesconectada => 'Disconnected';

  @override
  String get camaraEstadoEnPausa => 'Paused';

  @override
  String get camaraEstadoNoConfiable => 'Detection unreliable';

  @override
  String get camaraEstadoDetenida => 'Stopped';

  @override
  String get camaraEstadoSinConexion => 'Offline';

  @override
  String get camaraPausa30Min => '30 minutes';

  @override
  String get camaraPausa1Hora => '1 hour';

  @override
  String get camaraPausa2Horas => '2 hours';

  @override
  String get camaraPausaHastaManana => 'Until tomorrow';

  @override
  String camaraPausaFinHasta(String hora) {
    return 'until $hora';
  }

  @override
  String camaraPausaFinALas(String hora) {
    return 'at $hora';
  }

  @override
  String camaraFinDePausaManana(String hora) {
    return '$hora tomorrow';
  }

  @override
  String camaraEnHabitacion(String habitacion) {
    return 'in $habitacion';
  }

  @override
  String camaraReactivadaTitulo(String habitacion) {
    return '$habitacion camera is back on';
  }

  @override
  String get camaraReactivadaTexto =>
      'Detection and live view are available again.';

  @override
  String camaraEnPausaTitulo(String habitacion) {
    return '$habitacion camera paused';
  }

  @override
  String camaraSeReactivaraALas(String hora) {
    return 'It will turn back on by itself at $hora.';
  }

  @override
  String camaraPausarTitulo(String habitacion) {
    return 'Pause the $habitacion camera';
  }

  @override
  String get camaraPausarTexto =>
      'No detection or live view. It turns back on by itself.';

  @override
  String get camaraPausar => 'Pause';

  @override
  String camaraAvisoDesconectadaTitulo(String habitacion) {
    return 'The $habitacion camera disconnected';
  }

  @override
  String get camaraAvisoDesconectadaTexto =>
      'Check the camera cable, that the PC is on, and the home internet.';

  @override
  String camaraAvisoReconectadaTitulo(String habitacion) {
    return 'The $habitacion camera is back online';
  }

  @override
  String camaraAvisoReconectadaTexto(String hora) {
    return 'Monitoring resumed at $hora.';
  }

  @override
  String camaraAvisoReactivadaTitulo(String habitacion) {
    return 'The $habitacion camera is back on';
  }

  @override
  String camaraAvisoReactivadaTexto(String hora) {
    return 'The pause ended at $hora.';
  }

  @override
  String camaraAvisoNoConfiableTitulo(String enHabitacion) {
    return 'Detection is unreliable $enHabitacion';
  }

  @override
  String camaraAvisoNoConfiableTexto(String nombre) {
    return 'For over 5 minutes the camera hasn\'t seen $nombre clearly. Check the lighting and framing.';
  }

  @override
  String get camaraFavorita => 'Favorite';

  @override
  String camaraFavoritaDe(String habitacion) {
    return 'Favorite: $habitacion';
  }

  @override
  String get camaraUltimaSenalPrefijo => 'last signal ';

  @override
  String get camaraDesdeLasPrefijo => 'since ';

  @override
  String camaraHastaLas(String hora) {
    return 'until $hora';
  }

  @override
  String get camaraRevisaLuzEncuadre => 'check the lighting and framing';

  @override
  String get camaraSinConsentimiento => 'no consent';

  @override
  String get camaraPcNoResponde => 'the PC isn\'t responding';

  @override
  String camaraHaceSegundos(int n) {
    return '$n s ago';
  }

  @override
  String camaraHaceMinutos(int n) {
    return '$n min ago';
  }

  @override
  String camaraHaceHoras(int n) {
    return '$n h ago';
  }

  @override
  String get camarasOrdenar => 'Reorder';

  @override
  String get camarasListo => 'Done';

  @override
  String get camarasOrdenarTexto => 'Favorites first. Only on this phone.';

  @override
  String get camarasFavoritas => 'Favorites';

  @override
  String get camarasTitulo => 'Cameras';

  @override
  String get camarasLasDemas => 'The rest';

  @override
  String camarasArrastrar(String habitacion) {
    return 'Drag $habitacion';
  }

  @override
  String camarasSubir(String habitacion) {
    return 'Move $habitacion up';
  }

  @override
  String camarasBajar(String habitacion) {
    return 'Move $habitacion down';
  }

  @override
  String camaraNombreOcupada(String enHabitacion) {
    return 'There\'s already a camera $enHabitacion. For now, each room uses just one camera.';
  }

  @override
  String get camaraNombreVacio => 'Type the room\'s name.';

  @override
  String get camaraNombreBano =>
      'For privacy, Te Tengo doesn\'t allow cameras in the bathroom.';

  @override
  String camaraNombreGuardado(String nombre) {
    return 'Name saved: $nombre';
  }

  @override
  String camaraNombreProximasAlertas(String enHabitacion) {
    return 'Upcoming alerts will say “$enHabitacion”.';
  }

  @override
  String get camaraNombreTitulo => 'Room name';

  @override
  String get camaraNombreMarcador => 'E.g. Living room';

  @override
  String get camaraNombreSugerencias => 'Suggestions';

  @override
  String get camaraNombreYaTienen =>
      'Rooms that already have a camera can\'t be chosen.';

  @override
  String get camaraNombreAsiSeVera => 'How upcoming alerts will look';

  @override
  String get camaraNombrePosibleCaidaVacia => 'Possible fall …';

  @override
  String camaraNombrePosibleCaida(String enHabitacion) {
    return 'Possible fall $enHabitacion';
  }

  @override
  String get camaraNombreAnteriores => 'Earlier alerts don\'t change.';

  @override
  String get camaraNombreGuardar => 'Save name';

  @override
  String get camaraTitulo => 'Camera';

  @override
  String get camaraAjustes => 'Camera settings';

  @override
  String camaraRepeticionAcceso(String habitacion, String duracion) {
    return '$habitacion replay · $duracion';
  }

  @override
  String get camaraPcNoRespondeMotivo => 'The PC isn\'t responding';

  @override
  String get camaraDesconectadaMotivo => 'Camera disconnected';

  @override
  String get camaraActivar => 'Turn on';

  @override
  String camaraSoloTitularActiva(String nombre) {
    return 'Only $nombre can turn it on';
  }

  @override
  String get camaraDetenidaSinConsentimiento => 'Stopped: consent missing';

  @override
  String get camaraRegistrarConsentimiento => 'Record consent';

  @override
  String get camaraSinInternet => 'No internet';

  @override
  String get camaraActivaGuardarMovimientos =>
      'To see what happened, turn on Save movements';

  @override
  String get camaraActivaNube =>
      'To see what happened, turn on Movements in the cloud';

  @override
  String camaraNoHayMovimientos(String dia, String desde) {
    return 'No movements on $dia. Available since $desde.';
  }

  @override
  String get camaraVerLoUltimo => 'See latest';

  @override
  String get camaraCargando => 'Loading…';

  @override
  String get camaraAyudaPrivacidad =>
      'Only body points, never video. Every replay goes in the access log.';

  @override
  String get camaraAjustesResumen => 'Pause, name, log';

  @override
  String get camaraRevisarCable => 'The camera\'s USB cable';

  @override
  String get camaraRevisarPc => 'The PC is on';

  @override
  String get camaraRevisarPcDetalle => 'With Te Tengo Captura open';

  @override
  String get camaraRevisarInternet => 'The home internet';

  @override
  String get camaraRevisarLuz => 'Lighting';

  @override
  String get camaraRevisarLuzDetalle => 'At night, a small lamp';

  @override
  String get camaraRevisarEncuadre => 'Framing';

  @override
  String camaraRevisarEncuadreDetalle(String nombre) {
    return '$nombre\'s whole body should be in view';
  }

  @override
  String get camaraQueRevisar => 'What to check';

  @override
  String get camaraHoy => 'Today';

  @override
  String get camaraAyer => 'Yesterday';

  @override
  String get camaraElegirDia => 'Pick a day…';

  @override
  String get camara10Min => '10 min';

  @override
  String get camara1Hora => '1 hour';

  @override
  String get camaraSoloEventos => 'Events only';

  @override
  String camaraEventosDe(String dia) {
    return 'Events · $dia';
  }

  @override
  String get camaraSinEventosHoy => 'No events today';

  @override
  String get camaraSinEventosAyer => 'No events yesterday';

  @override
  String camaraSinEventosEl(String dia) {
    return 'No events on $dia';
  }

  @override
  String get camaraUltimosEventos => 'Latest events';

  @override
  String get camaraCaida => 'Fall';

  @override
  String get camaraInestable => 'Unstable';

  @override
  String get camaraReanudarAhora => 'Resume now';

  @override
  String camaraEnPausaHastaLas(String hora) {
    return 'Paused until $hora';
  }

  @override
  String get camaraSinDeteccionNiVivo => 'No detection or live view';

  @override
  String camaraNombreDe(String habitacion) {
    return 'Name: $habitacion';
  }

  @override
  String camaraPcNombre(String nombre) {
    return 'PC $nombre';
  }

  @override
  String get camaraPcDeLaCasa => 'Home PC';

  @override
  String camaraDesdeElFecha(String fecha) {
    return 'since $fecha';
  }

  @override
  String get camaraHuboCaida => 'Was there a fall it missed?';

  @override
  String get camaraDejarDeUsar => 'Stop using this camera';

  @override
  String camaraDispositivoDeHabitacion(String habitacion) {
    return '$habitacion';
  }

  @override
  String camaraDesconectadaDesde(String hora) {
    return 'Disconnected since $hora';
  }

  @override
  String camaraSinConexionDesde(String hora) {
    return 'Offline since $hora';
  }

  @override
  String get accesosTitulo => 'Access log';

  @override
  String get accesosRegistrado => 'Access recorded';

  @override
  String get accesosIntro =>
      'Who watched, when and for how long. The whole family sees it.';

  @override
  String get accesosVacio => 'No access recorded yet';

  @override
  String get accesosTodo => 'All';

  @override
  String get accesosVistaEnVivo => 'Live view';

  @override
  String get accesosRepeticiones => 'Replays';

  @override
  String accesosNombreTu(String nombre) {
    return '$nombre (you)';
  }

  @override
  String accesosVio(String quien, String habitaciones) {
    return '$quien watched $habitaciones';
  }

  @override
  String get accesosVariasCamaras => 'Several cameras';

  @override
  String accesosVistaEnVivoDe(String habitacion) {
    return 'Live view · $habitacion';
  }

  @override
  String get accesosVistaPrevia => 'Preview while choosing cameras';

  @override
  String accesosVistaPreviaDe(String dispositivo) {
    return 'Preview while choosing cameras · $dispositivo';
  }

  @override
  String accesosRepeticion(String habitacion, String dia, String hora) {
    return 'Replay · $habitacion, $dia $hora';
  }

  @override
  String get accesosDesdeAlerta => 'From an alert';

  @override
  String get accesosAbrirDeNuevo => 'Open again';

  @override
  String get accesosSinAccesos => 'No access yet';

  @override
  String get accesosTu => 'You';

  @override
  String get accesosHoyMinuscula => 'today';

  @override
  String accesosResumen(String quien, String dia, String hora) {
    return '$quien · $dia $hora';
  }

  @override
  String vivoViste(String habitacion, String duracion) {
    return 'You watched $habitacion live for $duracion.';
  }

  @override
  String get vivoVolverAlerta => 'Back to the alert';

  @override
  String get vivoVolverATodas => 'Back to all';

  @override
  String get vivoCerrar => 'Close live view';

  @override
  String get vivoTitulo => 'Live';

  @override
  String vivoTituloDe(String habitacion) {
    return 'Live · $habitacion';
  }

  @override
  String get vivoVerEnVivo => 'Watch live';

  @override
  String vivoLlamarA(String nombre) {
    return 'Call $nombre';
  }

  @override
  String get vivoReanudarCamara => 'Resume the camera now';

  @override
  String get vivoPrivacidad =>
      'Nothing is recorded. Your access goes in the log the whole family sees: who, when and for how long.';

  @override
  String get vivoEtiqueta => 'LIVE';

  @override
  String vivoNoDisponibleTitulo(String habitacion) {
    return 'The $habitacion camera isn\'t available';
  }

  @override
  String get vivoSinConexionDesdePrefijo => 'Offline since ';

  @override
  String vivoLlamaOPide(String nombre) {
    return 'Call $nombre or ask someone nearby to go check on her.';
  }

  @override
  String get vivoRevisaCable =>
      'Check the cable, the PC and the home internet.';

  @override
  String get vivoNoDisponible => 'Live view unavailable';

  @override
  String get vivoEnPausaHastaPrefijo => 'Paused until ';

  @override
  String vivoCamaraEnPausa(String habitacion) {
    return 'The $habitacion camera is paused.';
  }

  @override
  String get vivoDetenidaTitulo => 'The camera is stopped';

  @override
  String vivoSinConsentimiento(String nombre) {
    return 'Without $nombre\'s consent there\'s no video.';
  }

  @override
  String vivoSinConexionPc(String pc) {
    return 'Offline · PC $pc isn\'t responding';
  }

  @override
  String get vivoDesdeLasPrefijo => ' since ';

  @override
  String get vivoDetenidaSinConsentimiento => 'Stopped · no consent';

  @override
  String get vivoQueHabitacion => 'Which room do you want to see?';

  @override
  String get vivoVerTodasALaVez => 'See all at once';

  @override
  String get vivoHasta4PorPagina => 'Up to 4 per page';

  @override
  String get vivoDisponibleAhora => 'Available now';

  @override
  String get vivoQueSeVe => 'What\'s shown';

  @override
  String get vivoModoVideo => 'Video';

  @override
  String get vivoModoEsqueleto => 'Skeleton';

  @override
  String get mosaicoPrivacidad =>
      'Nothing is recorded. When you close, one access goes in the log, with the rooms seen and how long.';

  @override
  String mosaicoHastaLas(String hora) {
    return 'Until $hora';
  }

  @override
  String mosaicoDesdeLas(String hora) {
    return 'Since $hora';
  }

  @override
  String get mosaicoPcNoResponde => 'PC not responding';

  @override
  String get mosaicoSinConsentimiento => 'No consent';

  @override
  String mosaicoSeMovio(String habitacion) {
    return '$habitacion moved';
  }

  @override
  String get mosaicoMismoOrden => 'Same order in Cameras and Watch live.';

  @override
  String get mosaicoFavoritasPrimero => 'Favorites go first';

  @override
  String get mosaicoCambiaEstrella =>
      'Change the star to move it to the other group.';

  @override
  String mosaicoViste(String habitaciones, String duracion) {
    return 'You watched $habitaciones · $duracion.';
  }

  @override
  String get mosaicoTodas => 'All live';

  @override
  String mosaicoTodasPagina(int pagina, int total) {
    return 'All live, page $pagina of $total';
  }

  @override
  String get mosaicoEligeCamara => 'Pick a camera to move';

  @override
  String get mosaicoArrastraOMuevePrefijo => 'Drag or move ';

  @override
  String get mosaicoMoverAntes => 'Move earlier';

  @override
  String get mosaicoMoverDespues => 'Move later';

  @override
  String get mosaicoCerrar => 'Close';

  @override
  String get mosaicoVertical => 'Portrait';

  @override
  String get mosaicoOrdenarCamaras => 'Reorder cameras';

  @override
  String get mosaicoControles => 'See all controls';

  @override
  String get mosaicoReanudar => 'Resume';

  @override
  String get mosaicoCerrarVerTodas => 'Close See all';

  @override
  String get mosaicoVerHorizontal => 'View in landscape';

  @override
  String get mosaicoPaginaAnterior => 'Previous page';

  @override
  String get mosaicoPaginaSiguiente => 'Next page';

  @override
  String mosaicoPagina(int pagina, int total) {
    return 'Page $pagina of $total';
  }

  @override
  String get mosaicoEnVivoMinuscula => 'live';

  @override
  String mosaicoCeldaEtiqueta(String habitacion, String estado, String accion) {
    return '$habitacion, $estado. $accion';
  }

  @override
  String get mosaicoElegirParaMover => 'Choose to move';

  @override
  String get mosaicoAbrirCompleta => 'Open full screen';

  @override
  String get mosaicoPistaOrdenando =>
      'Drag it or use Move earlier and Move later';

  @override
  String get mosaicoPistaMantener => 'Press and hold to move it';

  @override
  String get mosaicoQuitarFavorita => 'Remove from favorites';

  @override
  String get mosaicoMarcarFavorita => 'Mark as favorite';

  @override
  String get mosaicoVerCompleta => 'View full screen';

  @override
  String familiaNombreTu(String nombre) {
    return '$nombre (you)';
  }

  @override
  String get familiaPapelPrincipal => 'Primary';

  @override
  String get familiaPapelSecundario => 'Secondary';

  @override
  String get familiaPapelFamiliar => 'Gets alerts';

  @override
  String familiaResumenParentescoTitular(String parentesco) {
    return '$parentesco · owner';
  }

  @override
  String get familiaResumenTitular => 'account owner';

  @override
  String get familiaTitularCuenta => 'Account owner';

  @override
  String get familiaTitulo => 'Family';

  @override
  String familiaReciben(String nombre) {
    return 'They get $nombre\'s alerts.';
  }

  @override
  String get familiaOrdenFila => 'Alert order and wait time';

  @override
  String familiaOrdenSinSecundario(String principal) {
    return '$principal · no secondary contact';
  }

  @override
  String familiaOrdenResumen(String principal, String secundario, int minutos) {
    return '$principal → $secundario · $minutos min wait';
  }

  @override
  String get familiaSinSecundarioTitulo => 'No secondary contact';

  @override
  String familiaSinSecundarioTexto(String principal) {
    return 'If $principal doesn\'t respond in time, no one else will be alerted.';
  }

  @override
  String get familiaInvitar => 'Invite a family member';

  @override
  String get familiaSoloLecturaInvitar =>
      'invite or remove family members and change the alert order';

  @override
  String get familiaFamiliarTitulo => 'Family member';

  @override
  String get familiaTuPerfilTitulo => 'Your family profile';

  @override
  String get familiaHacerPrincipal => 'Make primary contact';

  @override
  String get familiaHacerPrincipalDetalle => 'Will get every alert first';

  @override
  String get familiaHacerSecundario => 'Make secondary contact';

  @override
  String familiaHacerSecundarioDetalle(int minutos) {
    return 'Gets the alert if no one responds in $minutos min';
  }

  @override
  String get familiaRetirarAcceso => 'Remove access';

  @override
  String get familiaContacto => 'Contact';

  @override
  String get familiaTelefono => 'Phone';

  @override
  String get familiaLlamar => 'Call';

  @override
  String get familiaCorreo => 'Email';

  @override
  String get familiaEnLasAlertas => 'In alerts';

  @override
  String get familiaPapelPrincipalDetalle => 'Gets every alert first';

  @override
  String familiaPapelSecundarioDetalle(int minutos) {
    return 'We alert them if no one responds in $minutos min';
  }

  @override
  String get familiaPapelFamiliarDetalle => 'Sees everything, no escalation';

  @override
  String get familiaActividad => 'Activity';

  @override
  String familiaAlertasMarcadas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n alerts marked',
      one: '1 alert marked',
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
      'caida': 'Fall',
      'other': 'Unstable',
    });
    return 'Last: $_temp0 in $habitacion · $fecha · ';
  }

  @override
  String get familiaSinMarcadas => 'Hasn\'t marked any alerts yet';

  @override
  String familiaAccesosCamara(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n camera views',
      one: '1 camera view',
    );
    return '$_temp0';
  }

  @override
  String familiaUltimoAcceso(String cuando) {
    return 'Last: $cuando ';
  }

  @override
  String get familiaHoy => 'today';

  @override
  String get familiaSinAccesos => 'Hasn\'t opened the live view yet';

  @override
  String get familiaAvisoDejarPrincipal =>
      'To stop being primary, choose another contact.';

  @override
  String get familiaAvisoRetirarPrincipal =>
      'To remove their access, first choose another primary contact.';

  @override
  String get familiaOpciones => 'Options';

  @override
  String get familiaSoloLecturaPapel =>
      'change a family member\'s role or remove their access';

  @override
  String familiaAhoraEsContacto(String nombre, String papel) {
    String _temp0 = intl.Intl.selectLogic(papel, {
      'principal': 'primary',
      'other': 'secondary',
    });
    return '$nombre is now the $_temp0 contact';
  }

  @override
  String get familiaOrdenActualizado => 'The alert order was updated.';

  @override
  String familiaRetirarTitulo(String nombre) {
    return 'Remove $nombre\'s access?';
  }

  @override
  String get familiaRetirarTexto =>
      'They\'ll stop getting alerts and seeing the history.';

  @override
  String get familiaRetirarTextoSecundario =>
      'They\'ll stop getting alerts and seeing the history. You\'ll have no secondary contact.';

  @override
  String get familiaCancelar => 'Cancel';

  @override
  String familiaYaNoRecibe(String nombre) {
    return '$nombre no longer gets alerts';
  }

  @override
  String get familiaQuedasteSinSecundario =>
      'You no longer have a secondary contact.';

  @override
  String get familiaOrdenTitulo => 'Alert order';

  @override
  String get familiaSoloLecturaOrden => 'change the alert order and wait time';

  @override
  String get familiaOrdenExplicacion =>
      'If the primary doesn\'t mark the alert in time, we alert the secondary.';

  @override
  String get familiaQuienResponde => 'Who responds';

  @override
  String get familiaContactoPrincipal => 'Primary contact';

  @override
  String get familiaSinSecundario => 'No secondary contact';

  @override
  String get familiaNadieMasRecibe => 'No one else gets the alert.';

  @override
  String familiaContactoSecundarioA(int minutos) {
    return 'Secondary contact · after $minutos min';
  }

  @override
  String get familiaTiempoEspera => 'Wait time';

  @override
  String get familiaAntesDeAvisar => 'Before alerting the secondary.';

  @override
  String familiaMinutos(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: '$minutos minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get familiaPredeterminado => 'Default';

  @override
  String familiaEsperaToast(int minutos) {
    String _temp0 = intl.Intl.pluralLogic(
      minutos,
      locale: localeName,
      other: 'Wait time: $minutos minutes',
      one: 'Wait time: 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get familiaEsperaToastTexto => 'It will apply to upcoming alerts.';

  @override
  String familiaEjemploEspera(String inicio, String nombre, String fin) {
    return 'E.g.: alert at $inicio, no response → $nombre at $fin.';
  }

  @override
  String get familiaUsaConSecundario =>
      'Used once there is a secondary contact.';

  @override
  String familiaCambiarContacto(String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'primary',
      'other': 'secondary',
    });
    return 'Change $_temp0 contact';
  }

  @override
  String get familiaCambiar => 'Change';

  @override
  String get familiaPrimeroOtroPrincipal => 'First choose another primary';

  @override
  String familiaYaEsPrincipal(String nombre) {
    return '$nombre is already the primary contact.';
  }

  @override
  String familiaEsContacto(String nombre, String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'primary',
      'other': 'secondary',
    });
    return '$nombre is the $_temp0 contact';
  }

  @override
  String get familiaUsaremosOrden =>
      'We\'ll use this order for upcoming alerts.';

  @override
  String familiaQuienSera(String puesto) {
    String _temp0 = intl.Intl.selectLogic(puesto, {
      'principal': 'primary',
      'other': 'secondary',
    });
    return 'Who will be the $_temp0 contact?';
  }

  @override
  String get familiaAtiendePrimero => 'Handles every alert first.';

  @override
  String familiaLeAvisamos(int minutos) {
    return 'We alert them if no one marks it in $minutos min.';
  }

  @override
  String familiaOrdenAhora(String papel) {
    return 'now: $papel';
  }

  @override
  String get familiaQuitarSecundario => 'Remove secondary contact';

  @override
  String get familiaNadieMasSeraAvisado =>
      'No one else will be alerted if an alert isn\'t handled.';

  @override
  String get invitarCorreoVacio => 'Enter their email.';

  @override
  String get invitarPropioCorreo =>
      'That\'s your own email. Invite someone else.';

  @override
  String invitarYaEnFamilia(String nombre) {
    return 'That person is already in $nombre\'s family.';
  }

  @override
  String get invitarEnviada => 'Invitation sent';

  @override
  String invitarEnviadaTexto(String correo) {
    return 'We sent a link to $correo.';
  }

  @override
  String get invitarQuePodra => 'What they can do';

  @override
  String get invitarPuntoVer => 'See alerts, history and the live camera';

  @override
  String get invitarPuntoMarcar => 'Mark alerts and pause the camera';

  @override
  String get invitarPuntoNoCambia =>
      'Can\'t change details, consent, cameras or family';

  @override
  String get invitarEnviar => 'Send invitation';

  @override
  String invitarTeInvito(String titular, String adulto) {
    return '$titular invited you to look after $adulto';
  }

  @override
  String get invitarCrearAcceso => 'Create my access';

  @override
  String get invitarCreaTuAcceso => 'Create your access to get their alerts.';

  @override
  String get invitarCampoClave => 'Create a password';

  @override
  String invitarListo(String yo, String adulto) {
    return 'All set, $yo. You now get $adulto\'s alerts.';
  }

  @override
  String get invitarPuedes => 'You can';

  @override
  String get invitarPuedesDetalle =>
      'See alerts, clips and the live camera; mark alerts and pause.';

  @override
  String invitarSoloPuede(String titular) {
    return 'Only $titular can';
  }

  @override
  String get invitarSoloPuedeDetalle =>
      'Change details, consent, cameras and family.';

  @override
  String get invitarIrInicio => 'Go to Home';

  @override
  String get perfilErrorSubir =>
      'Couldn\'t upload the photo. Please try again.';

  @override
  String get perfilTitulo => 'Your profile';

  @override
  String get perfilCampoNombre => 'Full name';

  @override
  String get perfilCorreoAyuda => 'You sign in with it.';

  @override
  String get perfilErrorTelefono => 'Check the phone: numbers only.';

  @override
  String get perfilCambiosGuardados => 'Changes saved';

  @override
  String get perfilNombreNuevo => 'Your family will see your new name.';

  @override
  String get perfilCampoTelefono => 'Phone';

  @override
  String get perfilParentesco => 'Relationship';

  @override
  String perfilParentescoCon(String nombre) {
    return 'Relationship to $nombre';
  }

  @override
  String get perfilParentescoMarcador => 'E.g.: Daughter, nephew, neighbor';

  @override
  String get perfilGuardarCambios => 'Save changes';

  @override
  String get perfilCambiarContrasena => 'Change password';

  @override
  String get perfilQuitandoFoto => 'Removing the photo';

  @override
  String get perfilSubiendoFoto => 'Uploading the photo';

  @override
  String perfilPorcentaje(int n) {
    return '$n%';
  }

  @override
  String get perfilCambiarFoto => 'Change photo';

  @override
  String get perfilQuitando => 'Removing…';

  @override
  String get perfilSubiendo => 'Uploading…';

  @override
  String perfilSubiendoPorcentaje(int n) {
    return 'Uploading… $n%';
  }

  @override
  String get perfilNoSeCambioFoto => 'Couldn\'t change the photo';

  @override
  String get perfilVolverIntentar => 'Try again';

  @override
  String get perfilFotoQuitada => 'Photo removed';

  @override
  String get perfilSeVeranIniciales => 'Initials will show instead.';

  @override
  String get perfilNoPudimosAbrir => 'We couldn\'t open that photo';

  @override
  String get perfilEligeOtra => 'Choose another one.';

  @override
  String get perfilNoPudimosAbrirEligeOtra =>
      'We couldn\'t open that photo. Choose another one.';

  @override
  String get perfilFotoActualizada => 'Photo updated';

  @override
  String get perfilLaVeraFamilia => 'The whole family will see it.';

  @override
  String get perfilSinPermisoCamara => 'No permission to use the camera';

  @override
  String get perfilSinPermisoFotos => 'No permission to see your photos';

  @override
  String get perfilOtraOpcion => 'You can choose another option.';

  @override
  String get perfilCamaraBloqueada => 'The phone\'s camera is blocked';

  @override
  String get perfilFotosBloqueadas => 'Your photos are blocked for Te Tengo';

  @override
  String get perfilPermitelo =>
      'Allow it in the phone\'s settings and try again.';

  @override
  String get perfilAbrirAjustes => 'Open phone settings';

  @override
  String get perfilAhoraNo => 'Not now';

  @override
  String perfilFotoDe(String nombre) {
    return '$nombre\'s photo';
  }

  @override
  String get perfilLaVeFamilia => 'The whole family sees it.';

  @override
  String get perfilTomarFoto => 'Take a photo';

  @override
  String get perfilElegirGaleria => 'Choose from gallery';

  @override
  String get perfilQuitarFoto => 'Remove photo';

  @override
  String get perfilErrorActualVacia => 'Enter your current password.';

  @override
  String get perfilActualIncorrecta =>
      'It doesn\'t match your current password.';

  @override
  String get perfilContrasenaActual => 'Current password';

  @override
  String get perfilRepiteNueva => 'Repeat the new password';

  @override
  String get perfilAjustaFoto => 'Adjust the photo';

  @override
  String get perfilMueveAcerca => 'Move and zoom the photo to center the face.';

  @override
  String get perfilUsarFoto => 'Use this photo';

  @override
  String get sesionErrorNombre => 'Enter your full name.';

  @override
  String get sesionErrorCorreoVacio => 'Enter your email.';

  @override
  String get sesionErrorCorreoIncompleto =>
      'Check the email: it looks incomplete.';

  @override
  String get sesionErrorClaveVacia => 'Create a password.';

  @override
  String get sesionErrorClaveCorta => 'Use at least 8 characters and a number.';

  @override
  String get sesionErrorNoCoinciden => 'The passwords don\'t match.';

  @override
  String get sesionAyudaContrasena => '8 or more characters, with a number.';

  @override
  String get sesionCampoNombre => 'Your full name';

  @override
  String get sesionCampoCorreo => 'Email';

  @override
  String get sesionCampoContrasena => 'Password';

  @override
  String get sesionNuevaContrasena => 'New password';

  @override
  String get sesionGuardarContrasena => 'Save password';

  @override
  String get sesionContrasenaActualizada => 'Password updated';

  @override
  String get sesionCerrarTitulo => 'Sign out?';

  @override
  String get sesionCerrarTexto => 'You\'ll stop getting alerts on this phone.';

  @override
  String get sesionCerrarTextoSus =>
      'You\'ll stop getting their alerts on this phone.';

  @override
  String get sesionCerrar => 'Sign out';

  @override
  String get sesionCancelar => 'Cancel';

  @override
  String get sesionBienvenidaTitulo =>
      'Look after your loved one, even when you\'re away.';

  @override
  String get sesionBienvenidaTexto =>
      'Detects falls and alerts you right away.';

  @override
  String get sesionVinetaSinPulseras => 'No wristbands or buttons';

  @override
  String get sesionVinetaEnVivo => 'Live, with their permission';

  @override
  String get sesionVinetaPostura => 'Posture only, never faces';

  @override
  String get sesionCrearCuenta => 'Create account';

  @override
  String get sesionYaTengoCuenta => 'I have an account';

  @override
  String get sesionFotoDescripcion => 'A daughter hugs her mother';

  @override
  String get sesionCerradaTitulo => 'Signed out';

  @override
  String get sesionCerradaTexto => 'Sign in to get alerts again.';

  @override
  String get sesionClaveActualizadaTexto => 'You can now sign in with it.';

  @override
  String get sesionErrorCorreo => 'Enter your email.';

  @override
  String get sesionErrorContrasena => 'Enter your password.';

  @override
  String get sesionIniciaSesion => 'Sign in';

  @override
  String get sesionBloqueadoTitulo => 'Locked for 15 minutes';

  @override
  String sesionBloqueadoTexto(String hora) {
    return 'Try again at $hora.';
  }

  @override
  String get sesionIncorrectos => 'Wrong email or password';

  @override
  String sesionIntentosRestantes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n attempts left before a 15-min lock.',
      one: '1 attempt left before a 15-min lock.',
    );
    return '$_temp0';
  }

  @override
  String get sesionFaltanDatos => 'Enter your email and password';

  @override
  String get sesionOlvidaste => 'Forgot your password?';

  @override
  String get sesionIniciarSesion => 'Sign in';

  @override
  String get sesionSinCuenta => 'No account yet?';

  @override
  String get sesionCreaUna => 'Create one';

  @override
  String get registroCorreoRegistrado => 'This email is already registered.';

  @override
  String get registroCorreoConCuenta => 'That email already has an account';

  @override
  String get registroIniciarConCorreo => 'Sign in with this email';

  @override
  String get registroRecuperarMiContrasena => 'Reset my password';

  @override
  String get registroCompletaCampos => 'Fill in the marked fields';

  @override
  String get registroAceptasLos => 'You accept the';

  @override
  String get registroTerminos => 'Terms';

  @override
  String get registroYLa => 'and';

  @override
  String get registroPrivacidad => 'Privacy';

  @override
  String get registroYaTienesCuenta => 'Already have an account?';

  @override
  String registroCuentaLista(String nombre) {
    return 'Your account is ready, $nombre.';
  }

  @override
  String get registroDosPasos => '2 more steps:';

  @override
  String get registroPasoDatos => 'The person\'s details';

  @override
  String get registroPasoConsentimiento => 'Informed consent';

  @override
  String get registroEmpezar => 'Start';

  @override
  String get recuperarContrasena => 'Reset password';

  @override
  String get recuperarTeEnviaremos => 'We\'ll send you a link.';

  @override
  String get recuperarEnviarEnlace => 'Send link';

  @override
  String get recuperarRevisaCorreo => 'Check your email';

  @override
  String recuperarSiTieneCuenta(String correo) {
    return 'If $correo has an account, you\'ll get a link. It expires in 30 minutes.';
  }

  @override
  String get recuperarSpam => 'Check your spam folder too.';

  @override
  String get recuperarVolverIniciar => 'Back to sign in';

  @override
  String recuperarReenviarEn(String tiempo) {
    return 'Resend link in $tiempo';
  }

  @override
  String get recuperarReenviar => 'Resend link';

  @override
  String recuperarParaCuenta(String correo) {
    return 'For the account $correo.';
  }

  @override
  String get recuperarRepite => 'Repeat the password';

  @override
  String get recuperarVencido => 'This link has expired';

  @override
  String get recuperarDura => 'It lasts 30 minutes and works only once.';

  @override
  String get recuperarPedirNuevo => 'Request a new link';

  @override
  String get recuperarCerrar => 'Close';

  @override
  String get consentimientoSeccionVivoTitulo => 'Live view at any time';

  @override
  String get consentimientoSeccionVivoResumen => 'Whenever the family wants';

  @override
  String get consentimientoSeccionVivoTexto =>
      'The linked family can watch the person live whenever they want, not only during an alert. Every access is logged: who, when and for how long.';

  @override
  String get consentimientoSeccionHacemosTitulo => 'What we do';

  @override
  String get consentimientoSeccionHacemosResumen =>
      'Falls detected from posture';

  @override
  String get consentimientoSeccionHacemosTexto =>
      'The home PC analyzes posture to detect falls and unstable movements. The continuous video never leaves the home. Only the notice and the clip of each alert leave it, plus the live view while someone in the family is watching it.';

  @override
  String get consentimientoSeccionNoHacemosTitulo => 'What we don\'t do';

  @override
  String get consentimientoSeccionNoHacemosResumen =>
      'No faces, no continuous recording';

  @override
  String get consentimientoSeccionNoHacemosTexto =>
      'No facial recognition and no continuous recording. The live view is not saved.';

  @override
  String get consentimientoSeccionGuardamosTitulo => 'What we store';

  @override
  String get consentimientoSeccionGuardamosResumen =>
      'Clip of each alert, 30 days';

  @override
  String get consentimientoSeccionGuardamosTexto =>
      'Only the clip of each alert, for 30 days; then it is deleted. It is stored in Microsoft Azure (Azure Blob Storage, Chile Central region), on servers outside Peru: this is a cross-border flow of personal data. Their movements (body points, no image) are stored only with a separate permission.';

  @override
  String get consentimientoSeccionDerechosTitulo => 'Their rights';

  @override
  String get consentimientoSeccionDerechosResumen =>
      'Law No. 29733 · revocable';

  @override
  String get consentimientoSeccionDerechosTexto =>
      'Under Law No. 29733, they can view, correct or delete their data, object to its use and revoke this consent.';

  @override
  String get consentimientoRegistroTitulo => 'How it is recorded';

  @override
  String get consentimientoRegistroTexto =>
      'We store who gave it, who recorded it, and the date and time (Law No. 29733).';

  @override
  String get legalTerminosQueEsTitulo => 'What Te Tengo is';

  @override
  String get legalTerminosQueEsTexto =>
      'It alerts your family if the home camera detects a possible fall or an unstable movement. It is not a security camera.';

  @override
  String get legalTerminosCuentaTitulo => 'Your account';

  @override
  String get legalTerminosCuentaTexto1 =>
      'Only the owner (who creates it) changes the cared-for person\'s details, the consent, the rooms, the family and the alert order.';

  @override
  String get legalTerminosCuentaTexto2 =>
      'Each account cares for a single person. Password of 8 characters or more, with a number; 5 failed attempts lock access for 15 minutes.';

  @override
  String get legalTerminosInvitadosTitulo => 'Invited family members';

  @override
  String get legalTerminosInvitadosTexto =>
      'They see alerts, clips, history and the live view; they mark alerts and pause the camera. The owner can remove their access.';

  @override
  String get legalTerminosConsentimientoTitulo => 'Consent';

  @override
  String get legalTerminosConsentimientoTexto1 =>
      'Without the consent of the cared-for person or their legal representative, the camera sends no video. Revoking it stops capture and deletes the recordings.';

  @override
  String get legalTerminosConsentimientoTexto2 =>
      'Storing their movements needs a separate, optional permission; alerts work the same without it.';

  @override
  String get legalTerminosAlertasTitulo => 'Alerts';

  @override
  String get legalTerminosAlertasTexto =>
      'All linked family members receive them. If the primary contact does not mark one within the waiting time (3, 5 or 10 minutes), we notify the secondary contact.';

  @override
  String get legalTerminosLimitesTitulo => 'Service limits';

  @override
  String get legalTerminosLimitesTexto1 =>
      'No detection while the home PC is off or the camera is disconnected, paused or without consent; it is not reliable if it cannot see the person well.';

  @override
  String get legalTerminosLimitesTexto2 =>
      'With the app closed, alerts arrive only if notifications are turned on.';

  @override
  String get legalPoliticaDatosTitulo => 'What data we store';

  @override
  String get legalPoliticaDatosTexto1 => 'Account: name, email and password.';

  @override
  String get legalPoliticaDatosTexto2 =>
      'Cared-for person: name, age, address and who they live with.';

  @override
  String get legalPoliticaDatosTexto3 =>
      'Alerts: type, room, date, time and who responded.';

  @override
  String get legalPoliticaVideoTitulo => 'Video';

  @override
  String get legalPoliticaVideoTexto1 =>
      'It is analyzed on the home PC. No facial recognition and no video in the cloud.';

  @override
  String get legalPoliticaVideoTexto2 =>
      'Only the notice and the clip of each alert leave the home, plus the live view while someone in the family watches it with consent in effect.';

  @override
  String get legalPoliticaVideoTexto3 =>
      'Only the clip of each alert (6 s before and 6 s after), for 30 days. The live view is not recorded.';

  @override
  String get legalPoliticaMovimientosTitulo => 'Movements';

  @override
  String get legalPoliticaMovimientosTexto1 =>
      'Only with a separate, optional permission: body points (shoulders, hips, knees…), with no image or video.';

  @override
  String get legalPoliticaMovimientosTexto2 =>
      'On the home PC and, if the owner chooses, in the cloud, from 7 days to 1 year. Withdrawing the permission deletes the ones in the cloud; the PC asks whether to delete its own too.';

  @override
  String get legalPoliticaDondeTitulo => 'Where it is stored';

  @override
  String get legalPoliticaDondeTexto =>
      'Clips and movements in the cloud are stored in Microsoft Azure (Azure Blob Storage, Chile Central region), on servers outside Peru: this is a cross-border flow of personal data.';

  @override
  String get legalPoliticaQuienTitulo => 'Who sees the data';

  @override
  String get legalPoliticaQuienTexto =>
      'Only the linked family. Every live access and every replay is kept in a log that everyone sees: who, when and for how long.';

  @override
  String get legalPoliticaRevocarTitulo => 'Revoking consent';

  @override
  String get legalPoliticaRevocarTexto =>
      'It stops capture and the live view and deletes the recordings; we send you the record.';

  @override
  String get legalPoliticaDerechosTitulo => 'Your rights';

  @override
  String get legalPoliticaDerechosTexto =>
      'View, correct or delete your data, or object to its use (Law No. 29733): privacidad@tetengo.pe.';

  @override
  String get legalTerminosTitulo => 'Terms of use';

  @override
  String get legalVerPolitica => 'View the privacy policy';

  @override
  String get legalPoliticaTitulo => 'Privacy policy';

  @override
  String get consentimientoTitulo => 'Consent';

  @override
  String get consentimientoPersonaGenerica => 'the cared-for person';

  @override
  String consentimientoDocumentoIntro(String nombre) {
    return 'Accepted by $nombre or their legal representative before the camera sends video.';
  }

  @override
  String get consentimientoConstancia => 'Record';

  @override
  String get consentimientoOtorgadoPor => 'Given by';

  @override
  String get consentimientoRegistradoPor => 'Recorded by';

  @override
  String get consentimientoFecha => 'Date';

  @override
  String get consentimientoHora => 'Time';

  @override
  String consentimientoIntro(String nombre) {
    return 'Accepted by $nombre or their representative. Without it, we don\'t detect falls.';
  }

  @override
  String get consentimientoQuienOtorga => 'Who gives consent?';

  @override
  String consentimientoDirectamente(String nombre) {
    return '$nombre, directly';
  }

  @override
  String get consentimientoRepresentante => 'Their legal representative';

  @override
  String consentimientoCasillaAcepta(String nombre) {
    return '$nombre was informed and accepts the camera to detect falls and that their family may watch them live at any time.';
  }

  @override
  String get consentimientoCasillaLeyo =>
      'I read the summary and the full document.';

  @override
  String get consentimientoFaltanCasillas => 'Check both boxes.';

  @override
  String get consentimientoGuardamosFecha =>
      'We store the date and time as a record (Law No. 29733).';

  @override
  String get consentimientoRegistrar => 'Record consent';

  @override
  String get consentimientoAhoraNo => 'Not now';

  @override
  String get consentimientoLeerDocumento => 'Read the full document';

  @override
  String get consentimientoRegistradoTitulo => 'Consent recorded';

  @override
  String get consentimientoCamarasDetectan =>
      'The cameras are now detecting falls.';

  @override
  String get consentimientoDetectaranAlVincular =>
      'They will detect falls once the PC is linked.';

  @override
  String get consentimientoVolverInicio => 'Back to Home';

  @override
  String get consentimientoCamaraActivada => 'Camera on';

  @override
  String consentimientoCamaraDetectaDesde(
    String deHabitacion,
    String habitacion,
    String hora,
  ) {
    return 'The $habitacion camera is detecting falls as of $hora.';
  }

  @override
  String get consentimientoConstanciaTitulo => 'Consent record';

  @override
  String get consentimientoVerConstancia => 'View the full record';

  @override
  String get consentimientoConstanciaLey => 'Record required by Law No. 29733.';

  @override
  String get privacidadTitulo => 'Privacy';

  @override
  String get privacidadVerDocumento => 'View the accepted document';

  @override
  String get privacidadSinConsentimiento => 'No consent';

  @override
  String get privacidadRevocadoEliminadas => 'Revoked. Recordings deleted.';

  @override
  String get privacidadAunNoRegistra =>
      'Not recorded yet. The camera sends no video.';

  @override
  String get privacidadMovimientos => 'Movements';

  @override
  String get privacidadGuardarMovimientos => 'Save movements';

  @override
  String privacidadVigenteDesde(String fecha) {
    return 'In effect since $fecha';
  }

  @override
  String get privacidadNoAutorizado => 'Not authorized';

  @override
  String get privacidadMovimientosNube => 'Movements in the cloud';

  @override
  String get privacidadNubeDesactivada => 'Off · permission missing';

  @override
  String get privacidadSusDatos => 'Their data';

  @override
  String get privacidadComoCuidamos => 'How we protect it';

  @override
  String get privacidadComoCuidamosResumen =>
      'No video in the cloud · clips 30 days';

  @override
  String get privacidadDatoVideo => 'Video';

  @override
  String get privacidadDatoVideoValor => 'On the PC, never in the cloud';

  @override
  String get privacidadDatoClips => 'Clips';

  @override
  String get privacidadDatoClipsValor => '30 days';

  @override
  String get privacidadDatoEnVivo => 'Live';

  @override
  String get privacidadDatoEnVivoValor => 'Not recorded';

  @override
  String get privacidadDatoRostros => 'Faces';

  @override
  String get privacidadDatoRostrosValor => 'Not recognized';

  @override
  String get privacidadRegistroAccesos => 'Access log';

  @override
  String get privacidadRegistroAccesosSub =>
      'Who watched, when and for how long';

  @override
  String get privacidadDerechos => 'Rights (Law No. 29733): ';

  @override
  String get privacidadRevocar => 'Revoke';

  @override
  String get privacidadRevocarTexto =>
      'Stops the camera and deletes the recordings.';

  @override
  String get privacidadRevocarBoton => 'Revoke consent';

  @override
  String get privacidadSoloLecturaRevocar => 'revoke consent';

  @override
  String get privacidadRevocarDialogoTitulo => 'Revoke consent?';

  @override
  String get privacidadRevocarDialogoTexto =>
      'Capture stops, there will be no more alerts and the recordings are deleted. This can\'t be undone.';

  @override
  String get privacidadRevocarDialogoAceptar => 'Yes, revoke and delete';

  @override
  String get privacidadRevocarDialogoCancelar => 'Cancel, keep it';

  @override
  String get privacidadSigueVigente => 'Your consent remains in effect';

  @override
  String get privacidadSigueDetectando => 'The camera keeps detecting falls.';

  @override
  String get privacidadRevocadoTitulo => 'Consent revoked';

  @override
  String get privacidadRevocandoTitulo => 'Revoking consent';

  @override
  String privacidadConstanciaEnviada(String correo) {
    return 'We sent the record to $correo.';
  }

  @override
  String get privacidadNoCierres => 'Don\'t close the app.';

  @override
  String get privacidadCapturaDetenida => 'Capture stopped';

  @override
  String privacidadALasHora(String hora) {
    return 'At $hora';
  }

  @override
  String get privacidadGrabacionesEliminadas => 'Recordings deleted';

  @override
  String get privacidadEliminandoGrabaciones => 'Deleting the recordings…';

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
  String get privacidadConstanciaCorreo => 'Record by email';

  @override
  String get privacidadEnviada => 'Sent';

  @override
  String get privacidadPendiente => 'Pending';

  @override
  String get hogarConvivenciaSolo => 'Lives alone';

  @override
  String get hogarConvivenciaConFamiliar => 'Lives with me';

  @override
  String get hogarConvivenciaConCuidador => 'Lives with another caregiver';

  @override
  String get hogarErrorNombre => 'Enter their full name.';

  @override
  String get hogarErrorEdadVacia => 'Enter their age.';

  @override
  String get hogarErrorEdadInvalida => 'Enter a valid age, in years.';

  @override
  String get hogarErrorDireccion => 'Enter the home address.';

  @override
  String get hogarErrorConvivencia => 'Choose an option.';

  @override
  String get hogarErrorTelefono => 'Check the phone number: digits only.';

  @override
  String get hogarCampoNombre => 'Full name';

  @override
  String get hogarCampoNombreEjemplo => 'E.g., Rosa Huamán';

  @override
  String get hogarCampoEdad => 'Age';

  @override
  String hogarCampoTelefono(String nombre) {
    return '$nombre\'s phone';
  }

  @override
  String hogarCampoTelefonoAyuda(String nombre) {
    return 'Used by “Call $nombre”.';
  }

  @override
  String get hogarCampoDireccion => 'Home address';

  @override
  String get hogarCampoDireccionEjemplo => 'Street, number and district';

  @override
  String get hogarConQuienVive => 'Who do they live with?';

  @override
  String get hogarPersonaCuidadaTitulo => 'Cared-for person';

  @override
  String get hogarCambiosGuardados => 'Changes saved';

  @override
  String hogarSoloLecturaCambiarDatos(String nombre) {
    return 'change $nombre\'s details';
  }

  @override
  String get hogarGuardarCambios => 'Save changes';

  @override
  String get hogarUnaSolaPersonaTitulo => 'Each account cares for one person';

  @override
  String get hogarUnaSolaPersonaTexto =>
      'To care for someone else, create another account.';

  @override
  String get hogarAQuienCuidar => 'Who will you care for?';

  @override
  String get hogarCompletaCampos => 'Fill in the marked fields';

  @override
  String get hogarGuardarYContinuar => 'Save and continue';

  @override
  String onboardingTodoListo(String nombre) {
    return 'All set. You\'re close to $nombre now.';
  }

  @override
  String get onboardingQueNoSePase => 'Don\'t miss a single fall';

  @override
  String get onboardingAunqueCerrada =>
      'Even with the app closed or the phone on silent.';

  @override
  String get onboardingNotificaciones => 'Notifications';

  @override
  String get onboardingParaRecibir => 'To get the alerts';

  @override
  String get onboardingPermitir => 'Allow';

  @override
  String get onboardingSuenanIgual => 'Falls still ring';

  @override
  String get onboardingFaltaConsentimiento => 'Consent missing';

  @override
  String get onboardingRegistraloInicio => 'Record it from Home';

  @override
  String onboardingPcVinculada(String nombre) {
    return 'PC $nombre linked';
  }

  @override
  String get onboardingFaltaElegirCamaras => 'Cameras not chosen yet';

  @override
  String onboardingPcCamaras(int n, String lista) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras: $lista',
      one: '1 camera: $lista',
    );
    return '$_temp0';
  }

  @override
  String onboardingSinDetectar(String camaras) {
    return '$camaras · not detecting';
  }

  @override
  String get onboardingSinPc => 'No PC linked';

  @override
  String get onboardingAgregaPc => 'Add it from Settings › Cameras and PCs';

  @override
  String get onboardingSinSecundario => 'No secondary contact';

  @override
  String get onboardingInvitaloFamilia => 'Invite them from Family';

  @override
  String get onboardingIrInicio => 'Go to Home';

  @override
  String get movimientosSecParaQueTitulo => 'Purpose';

  @override
  String get movimientosSecParaQueResumen =>
      'See what happened and improve detection';

  @override
  String get movimientosSecParaQueTexto =>
      'To see what happened before and after an alert, and to improve detection.';

  @override
  String get movimientosSecQueTitulo => 'What we store';

  @override
  String get movimientosSecQueResumen => 'Body points, no images';

  @override
  String get movimientosSecQueTexto =>
      'Only body points (shoulders, hips, knees…), with no images or video.';

  @override
  String get movimientosSecDondeTitulo => 'Where';

  @override
  String get movimientosSecDondeResumen => 'PC and, if you want, the cloud';

  @override
  String get movimientosSecDondeTextoV1 =>
      'On the home PC and, if you choose, in the cloud (servers outside Peru).';

  @override
  String get movimientosSecDondeTextoV2 =>
      'On the home PC and, if you choose, in the cloud: Cloudflare R2, with servers outside Peru. Storing them there is a cross-border flow of personal data.';

  @override
  String get movimientosSecDondeTextoV3 =>
      'On the home PC and, if you choose, in the cloud: Microsoft Azure (Azure Blob Storage, Chile Central region), with servers outside Peru. Storing them there is a cross-border flow of personal data.';

  @override
  String get movimientosSecCuantoTitulo => 'How long';

  @override
  String get movimientosSecCuantoResumen => 'You choose how long';

  @override
  String get movimientosSecCuantoTexto =>
      'Cloud: from 7 days to 1 year. PC: also with no deletion.';

  @override
  String get movimientosSecQuienTitulo => 'Who can see them';

  @override
  String get movimientosSecQuienResumen => 'The family, with a record';

  @override
  String get movimientosSecQuienTexto =>
      'Only the linked family; every replay is recorded.';

  @override
  String get movimientosSecDerechosTitulo => 'Their rights';

  @override
  String get movimientosSecDerechosResumen => 'Law No. 29733';

  @override
  String movimientosSecDerechosTexto(String nombre) {
    return '$nombre can see, correct or delete their data, or object to its use: privacidad@tetengo.pe (Law No. 29733).';
  }

  @override
  String get movimientosTitulo => 'Save movements';

  @override
  String get movimientosErrorRepresentante =>
      'Enter the representative\'s name.';

  @override
  String get movimientosRegistradoTitulo => 'Permission recorded';

  @override
  String get movimientosRegistradoTexto =>
      'Now you can choose whether they\'re saved in the cloud.';

  @override
  String movimientosDejarTitulo(String nombre) {
    return 'Stop saving $nombre\'s movements?';
  }

  @override
  String get movimientosDejarTexto =>
      'We\'ll delete the ones in the cloud; the PC will ask whether to delete them too. Alerts stay the same.';

  @override
  String get movimientosDejarAceptar => 'Stop saving';

  @override
  String get movimientosCancelar => 'Cancel';

  @override
  String get movimientosSinInternetTitulo => 'No internet';

  @override
  String get movimientosSinInternetTexto =>
      'Check your connection and try again.';

  @override
  String movimientosPregunta(String nombre) {
    return 'Should we save $nombre\'s movements?';
  }

  @override
  String get movimientosOpcional => 'It\'s optional: alerts work the same.';

  @override
  String get movimientosQuienDa => 'Who gives permission?';

  @override
  String movimientosEnPersona(String nombre) {
    return '$nombre, in person';
  }

  @override
  String get movimientosSuRepresentante => 'Their representative';

  @override
  String get movimientosNombreRepresentante => 'Representative\'s name';

  @override
  String get movimientosNombreMarcador => 'First and last name';

  @override
  String movimientosAcepto(String nombre) {
    return '$nombre agreed to have their movements saved for these purposes.';
  }

  @override
  String get movimientosErrorRedTitulo => 'We couldn\'t record the permission';

  @override
  String get movimientosErrorRedTexto => 'Nothing was saved.';

  @override
  String get movimientosRegistrar => 'Record permission';

  @override
  String get movimientosAhoraNo => 'Not now';

  @override
  String get movimientosAccionRegistrar => 'record this permission';

  @override
  String get movimientosLeerDocumento => 'Read the full document';

  @override
  String get movimientosFaltaConsentimientoTitulo => 'Consent is missing';

  @override
  String get movimientosFaltaConsentimientoTexto =>
      'Without it we can\'t detect falls.';

  @override
  String get movimientosRegistrarConsentimiento => 'Record consent';

  @override
  String get movimientosEnLaNube => 'Movements in the cloud';

  @override
  String get movimientosDejarBoton => 'Stop saving movements';

  @override
  String get movimientosAccionRetirar => 'withdraw this permission';

  @override
  String get movimientosConstanciaTitulo => 'Permission to save movements';

  @override
  String get movimientosConstanciaOtorgadoPor => 'Given by';

  @override
  String movimientosConstanciaRepresentante(String nombre) {
    return '$nombre (representative)';
  }

  @override
  String get movimientosConstanciaRegistradoPor => 'Recorded by';

  @override
  String get movimientosConstanciaFecha => 'Date';

  @override
  String get movimientosConstanciaVersion => 'Text version';

  @override
  String get movimientosConstanciaLey =>
      'Record required by Law No. 29733 for sensitive data.';

  @override
  String get movimientosLeerAceptado => 'Read the accepted document';

  @override
  String get movimientosPersonaCuidada => 'the cared-for person';

  @override
  String movimientosDocIntroduccion(String nombre) {
    return 'A separate, optional permission. $nombre or their representative accepts it.';
  }

  @override
  String get movimientosDocRegistraTitulo => 'How it\'s recorded';

  @override
  String get movimientosDocRegistraTexto =>
      'We store who gave it, who recorded it, the date, time and text version (Law No. 29733).';

  @override
  String get movimientosDocRetirarTitulo => 'How to withdraw it';

  @override
  String get movimientosDocRetirarTexto =>
      'The owner withdraws it in Settings › Privacy. We delete the ones in the cloud; the PC asks whether to delete them too.';

  @override
  String movimientosDocVersion(String version) {
    return 'Text version: $version.';
  }

  @override
  String movimientosBorradoListo(String nombre) {
    return 'Done. We no longer save $nombre\'s movements.';
  }

  @override
  String get movimientosBorrandoNube => 'Deleting movements from the cloud…';

  @override
  String get movimientosAlertasIgual => 'Alerts stay the same.';

  @override
  String get movimientosNoCierres => 'Don\'t close the app.';

  @override
  String get movimientosYaNoGuardamos => 'We no longer save movements';

  @override
  String movimientosDesdeLas(String hora) {
    return 'Since $hora';
  }

  @override
  String get movimientosBorradosNube => 'Movements deleted from the cloud';

  @override
  String get movimientosEnLaPc => 'On the home PC';

  @override
  String get movimientosPcPreguntara =>
      'It will ask whether to delete them there too.';

  @override
  String get movimientosVolverPrivacidad => 'Back to Privacy';

  @override
  String nubePlazoDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get nubePlazoAnio => '1 year';

  @override
  String get nubeDesactivado => 'Off';

  @override
  String nubeSeGuardan(String plazo) {
    return 'Kept for $plazo';
  }

  @override
  String get nubeApagarTitulo => 'Stop saving in the cloud?';

  @override
  String nubeAcortarTitulo(String plazo) {
    return 'Keep only $plazo?';
  }

  @override
  String get nubeApagarTexto =>
      'We\'ll delete all movements from the cloud. They can\'t be recovered.';

  @override
  String nubeAcortarTexto(String fecha) {
    return 'We\'ll delete movements from before $fecha. They can\'t be recovered.';
  }

  @override
  String get nubeNoGuardar => 'Don\'t save in the cloud';

  @override
  String nubeGuardarPlazo(String plazo) {
    return 'Keep $plazo';
  }

  @override
  String get nubeToastApagado => 'Movements in the cloud: don\'t save';

  @override
  String nubeToastPlazo(String plazo) {
    return 'Movements in the cloud: $plazo';
  }

  @override
  String get nubeBorramos => 'We deleted the movements from the cloud.';

  @override
  String get nubeSeBorranSolos =>
      'They\'re deleted automatically when the time is up.';

  @override
  String nubeFaltaPermiso(String nombre) {
    return '$nombre\'s permission to save movements is missing';
  }

  @override
  String get nubeVerPermiso => 'See permission';

  @override
  String get nubeAccionCambiarPlazo => 'change how long they\'re kept';

  @override
  String get nubeErrorRed => 'We couldn\'t save the change';

  @override
  String get nubePlazoEtiqueta => 'Time kept in the cloud';

  @override
  String get nubeMaximoRecomendado => 'Recommended maximum';

  @override
  String get nubeEspacio => 'Approximate space';

  @override
  String nubeEspacioValor(int minimo, int maximo) {
    return '$minimo to $maximo MB per camera per day (estimated)';
  }

  @override
  String get nubeDatosDesde => 'Movements since';

  @override
  String get nubeCamaras => 'Cameras';

  @override
  String nubePcSubira(String pc) {
    return 'The PC $pc will upload its movements when it reconnects.';
  }

  @override
  String get nubeNuncaVideo => 'We never save video in the cloud.';

  @override
  String get historialTitulo => 'History';

  @override
  String get historialAlertas => 'Alerts';

  @override
  String get historialResumenSemanal => 'Weekly summary';

  @override
  String get historialRangoSiete => 'Last 7 days';

  @override
  String get historialRangoTreinta => 'Last 30 days';

  @override
  String get historialRangoTodo => 'All';

  @override
  String get historialChipCaidas => 'Falls';

  @override
  String get historialChipInestables => 'Unstable movements';

  @override
  String get historialChipActivas => 'Active';

  @override
  String get historialChipAtendidas => 'Handled';

  @override
  String get historialChipFalsas => 'False alarms';

  @override
  String get historialFiltrarTitulo => 'Filter alerts';

  @override
  String get historialFiltroFecha => 'Date';

  @override
  String get historialFiltroTipo => 'Type';

  @override
  String get historialFiltroEstado => 'Status';

  @override
  String get historialFiltroTodas => 'All';

  @override
  String get historialFiltroCaida => 'Fall';

  @override
  String get historialFiltroInestable => 'Unstable movement';

  @override
  String get historialFiltroTodos => 'All';

  @override
  String get historialFiltroActiva => 'Active';

  @override
  String get historialFiltroAtendida => 'Handled';

  @override
  String get historialFiltroFalsa => 'False alarm';

  @override
  String get historialLimpiar => 'Clear';

  @override
  String get historialVerAlertas => 'See alerts';

  @override
  String historialVerConteo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'See $n alerts',
      one: 'See $n alert',
    );
    return '$_temp0';
  }

  @override
  String get historialVacio => 'No events recorded';

  @override
  String get historialNingunaCoincide => 'No alerts match';

  @override
  String get historialQuitarFiltros => 'Clear filters';

  @override
  String get historialHoy => 'Today';

  @override
  String get historialAyer => 'Yesterday';

  @override
  String get historialFiltrar => 'Filter';

  @override
  String historialFiltrarConteo(int n) {
    return 'Filter ($n)';
  }

  @override
  String historialQuitarFiltro(String filtro) {
    return 'Remove filter $filtro';
  }

  @override
  String get historialSinMarcar => 'Not marked';

  @override
  String historialMarcadaPor(String nombre) {
    return 'by $nombre';
  }

  @override
  String get historialFilaCaida => 'Fall';

  @override
  String get historialFilaInestable => 'Unstable';

  @override
  String get historialCargando => 'Loading history';

  @override
  String get resumenSemanaAnterior => 'Previous week';

  @override
  String get resumenSemanaSiguiente => 'Next week';

  @override
  String get resumenEstaSemana => 'This week';

  @override
  String get resumenSemanaPasada => 'Last week';

  @override
  String resumenHaceSemanas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String resumenRangoHastaHoy(String rango) {
    return '$rango · up to today';
  }

  @override
  String resumenRangoAnio(String rango, String anio) {
    return '$rango, $anio';
  }

  @override
  String get resumenSinEventos => 'A week with no events';

  @override
  String get resumenPorTipo => 'By type';

  @override
  String resumenVs(String rango) {
    return 'vs. $rango';
  }

  @override
  String get resumenCaidas => 'Falls';

  @override
  String get resumenInestables => 'Unstable movements';

  @override
  String get resumenFalsas => 'False alarms';

  @override
  String get resumenFalsasNoSuman => 'False alarms don\'t count.';

  @override
  String get resumenEventosPorDia => 'Events by day';

  @override
  String get resumenInicialesDias => 'MTWTFSS';

  @override
  String resumenIgual(int anterior) {
    return 'Same ($anterior)';
  }

  @override
  String resumenSubio(int anterior, int actual) {
    return 'Up from $anterior to $actual';
  }

  @override
  String resumenBajo(int anterior, int actual) {
    return 'Down from $anterior to $actual';
  }

  @override
  String get resumenVerResumen => 'See summary';

  @override
  String resumenInicioCaidas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'falls',
      one: 'fall',
    );
    return '$_temp0';
  }

  @override
  String resumenInicioInestables(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'unstable',
    );
    return '$_temp0';
  }

  @override
  String resumenInicioFalsas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'false alarms',
      one: 'false alarm',
    );
    return '$_temp0';
  }

  @override
  String get comunCerrarAviso => 'Dismiss notice';

  @override
  String get comunSoloVer => 'View only';

  @override
  String comunSoloTitularPuede(String titular, String accion) {
    return 'Only $titular (owner) can $accion.';
  }

  @override
  String comunPasoDe(int paso, int pasos) {
    return 'Step $paso of $pasos';
  }

  @override
  String get comunMostrarContrasena => 'Show password';

  @override
  String get comunOcultarContrasena => 'Hide password';

  @override
  String get comunUnMomento => 'One moment…';

  @override
  String comunMasInformacion(String tema) {
    return 'More info: $tema';
  }

  @override
  String get comunErrorGenerico => 'Something went wrong.';

  @override
  String get redSinConexion =>
      'Can\'t reach Te Tengo. Check your internet connection.';

  @override
  String get navInicio => 'Home';

  @override
  String get navHistorial => 'History';

  @override
  String get navFamilia => 'Family';

  @override
  String get navAjustes => 'Settings';

  @override
  String navAlertasActivas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n active alerts',
      one: '1 active alert',
    );
    return '$_temp0';
  }

  @override
  String nucleoEnHabitacion(String lugar, String habitacion) {
    return 'in the $habitacion';
  }

  @override
  String get nucleoSinInternetTitulo => 'Your phone is offline';

  @override
  String get nucleoSinInternetTexto =>
      'Alerts will arrive when you\'re back online. If you don\'t respond to one in time, we\'ll notify your backup contact.';

  @override
  String nucleoAlertaTitulo(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'inestable': 'Unstable movement',
      'confirmada': 'Fall confirmed',
      'other': 'Possible fall',
    });
    return '$_temp0';
  }

  @override
  String get nucleoAlertaActivaDesde => 'Alert active since ';

  @override
  String pushSigueEnElSueloTitulo(String nombre) {
    return '$nombre is still on the floor';
  }

  @override
  String pushCaidaConfirmadaTexto(String hora) {
    return 'Fall confirmed at $hora. The alert is still active.';
  }

  @override
  String pushSeLevantoTitulo(String nombre) {
    return '$nombre got up';
  }

  @override
  String pushSeLevantoTexto(String hora) {
    return '$hora · Stood up. Check how they\'re doing.';
  }

  @override
  String pushSeLevantoTextoEn(String hora, String lugar) {
    return '$hora · Stood up $lugar. Check how they\'re doing.';
  }

  @override
  String pushMovimientosBorradosTitulo(String nombre) {
    return 'Done. We no longer save $nombre\'s movements.';
  }

  @override
  String get pushMovimientosBorradosTexto => 'We deleted them from the cloud.';

  @override
  String get pushPcDesvinculadaTitulo => 'A PC was unlinked from the home';

  @override
  String pushPcDesvinculadaNombre(String pc) {
    return 'The PC $pc was unlinked';
  }

  @override
  String get pushPcDesvinculadaSinCamaras =>
      'Its cameras no longer detect falls. Check Cameras and PCs.';

  @override
  String pushPcDesvinculadaHabitaciones(String habitaciones) {
    return 'It no longer detects falls in $habitaciones.';
  }

  @override
  String get pushEscaladaMiaTitulo =>
      'No one handled the alert: it\'s your turn';

  @override
  String pushEscaladaMiaTexto(int espera) {
    return '$espera min went by with no response. You\'re the backup contact.';
  }

  @override
  String pushEscaladaTitulo(String nombre) {
    return 'Alert escalated to $nombre';
  }

  @override
  String get pushTuContactoSecundario => 'your backup contact';

  @override
  String pushEscaladaTexto(int espera) {
    return 'No one marked it in $espera min. You can still handle it.';
  }

  @override
  String get pushSinSecundarioTitulo => 'There\'s no backup contact';

  @override
  String pushSinSecundarioTexto(int espera) {
    return '$espera min went by with no response. The alert is still yours.';
  }

  @override
  String pushFalsaAlarmaTitulo(String quien) {
    return '$quien marked it as a false alarm';
  }

  @override
  String pushAtendidaTitulo(String quien) {
    return '$quien handled the alert';
  }

  @override
  String pushAtendidaTexto(String hora, String tipo, String lugar) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'caida': 'Fall',
      'other': 'Unstable movement',
    });
    return '$hora · $_temp0 $lugar.';
  }

  @override
  String inicioHola(String nombre) {
    return 'Hi, $nombre';
  }

  @override
  String get inicioNadieRecibeAlertas => 'No one in the family gets the alerts';

  @override
  String get inicioActivaNotificaciones => 'Turn on notifications';

  @override
  String get inicioEsteCelularNoRecibe =>
      'This phone isn\'t getting the alerts';

  @override
  String get inicioSinNotificacionesTexto =>
      'Without them, you won\'t hear about a fall while the app is closed.';

  @override
  String get inicioActivarNotificaciones => 'Turn on notifications';

  @override
  String get inicioVerAlerta => 'See the alert';

  @override
  String get inicioRegistrarConsentimiento => 'Record consent';

  @override
  String get inicioElegirCamaras => 'Choose the cameras';

  @override
  String get inicioAgregarPc => 'Add PC';

  @override
  String get inicioVerQueRevisar => 'See what to check';

  @override
  String get inicioVerEnVivo => 'Watch live';

  @override
  String get inicioNoDisponibleAhora => 'Not available now';

  @override
  String get inicioTemaPrivacidad => 'privacy';

  @override
  String get inicioNotificacionesActivadas => 'Notifications on';

  @override
  String get inicioNotificacionesActivadasTexto =>
      'You\'ll get the alerts even when the app is closed.';

  @override
  String inicioAlertaTitulo(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'inestable': 'Unstable movement active',
      'confirmada': 'Fall confirmed',
      'other': 'Fall alert active',
    });
    return '$_temp0';
  }

  @override
  String inicioAlertaTexto(String tipo, String lugar, String hora) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'caida': 'Fall',
      'other': 'Unstable movement',
    });
    return '$_temp0 $lugar at $hora. No one has marked it yet.';
  }

  @override
  String get inicioDeteccionDetenida => 'Detection stopped';

  @override
  String get inicioRevocasteConsentimiento => 'You revoked consent.';

  @override
  String inicioFaltaConsentimiento(String nombre) {
    return '$nombre\'s consent is missing.';
  }

  @override
  String get inicioSinCamaras => 'No cameras';

  @override
  String get inicioFaltaElegirCamaras => 'The cameras still need to be chosen.';

  @override
  String get inicioVinculaPc => 'Link the home\'s PC to detect falls.';

  @override
  String inicioUnaCamaraNoResponde(String habitacion) {
    return '1 camera not responding · $habitacion';
  }

  @override
  String inicioCamarasNoResponden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras not responding',
      one: '1 camera not responding',
    );
    return '$_temp0';
  }

  @override
  String inicioNoDetectamosEn(String lugares) {
    return 'We can\'t detect falls $lugares. The others keep watching.';
  }

  @override
  String get inicioCamaraDesconectada => 'The camera is disconnected';

  @override
  String inicioSinEllaNoDetectamos(String lugar) {
    return 'Without it, we can\'t detect falls $lugar.';
  }

  @override
  String get inicioNoConfiable => 'Detection isn\'t reliable';

  @override
  String inicioNoVeBien(String nombre) {
    return 'It hasn\'t seen $nombre clearly for over 5 min.';
  }

  @override
  String get inicioTranquiloConPausa => 'All calm, with a pause';

  @override
  String inicioEnPausaHasta(String habitacion, String hora) {
    return '$habitacion paused until $hora.';
  }

  @override
  String get inicioTodoTranquilo => 'All calm';

  @override
  String inicioSinEventosHoy(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras watching. No events today.',
      one: 'No events today.',
      zero: 'No events today.',
    );
    return '$_temp0';
  }

  @override
  String inicioNombreEdad(String nombre, int edad) {
    return '$nombre, $edad';
  }

  @override
  String get inicioCamaras => 'Cameras';

  @override
  String get inicioFamilia => 'Family';

  @override
  String inicioPersonas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String inicioCamarasNecesitanAtencion(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras need attention',
      one: '1 camera needs attention',
    );
    return '$_temp0';
  }

  @override
  String get arranqueLema => 'Close to your loved ones, even from afar.';

  @override
  String get instalarAvisoTitulo => 'Add Te Tengo to your Home Screen';

  @override
  String get instalarAvisoTexto =>
      'On iPhone, alerts only arrive if you open Te Tengo from its icon.';

  @override
  String get instalarVerComo => 'Show me how';

  @override
  String get instalarTitulo => 'Add to Home Screen';

  @override
  String get instalarEncabezado => 'Install Te Tengo on your iPhone';

  @override
  String get instalarIntro =>
      'That way you\'ll get fall alerts even when the app is closed. You need iOS 16.4 or later.';

  @override
  String get instalarPaso1 => 'Open this page in Safari';

  @override
  String get instalarPaso2 => 'Tap Share';

  @override
  String get instalarPaso2Detalle =>
      'The square with an arrow pointing up, in the Safari toolbar or in the “···” menu.';

  @override
  String get instalarPaso3 => 'Choose “Add to Home Screen”';

  @override
  String get instalarPaso3Detalle =>
      'If you don\'t see it, tap “View More” and swipe the list up.';

  @override
  String get instalarPaso4 => 'Tap “Add”';

  @override
  String get instalarPaso5 => 'Open Te Tengo from its icon';

  @override
  String get instalarPaso5Detalle =>
      'Sign in again and tap “Turn on notifications”.';

  @override
  String get widgetAbreLaApp => 'Open the app to see the status.';

  @override
  String widgetTituloAlerta(String tipo) {
    String _temp0 = intl.Intl.selectLogic(tipo, {
      'confirmada': 'Fall confirmed',
      'caida': 'Possible fall',
      'other': 'Unstable movement',
    });
    return '$_temp0';
  }

  @override
  String get widgetSinCamaras => 'No cameras';

  @override
  String get widgetAbreTeTengo => 'Open Te Tengo';

  @override
  String get widgetDeteccionDetenida => 'Detection stopped';

  @override
  String get widgetFaltaConsentimiento => 'Consent missing';

  @override
  String widgetCamarasNoResponden(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras not responding',
      one: '1 camera not responding',
    );
    return '$_temp0';
  }

  @override
  String get widgetTodoTranquilo => 'All calm';

  @override
  String widgetCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras',
      one: '1 camera',
    );
    return '$_temp0';
  }

  @override
  String get widgetPaso1 => 'Touch and hold an empty spot on the Home Screen.';

  @override
  String get widgetPaso2 => 'Tap “Widgets” and find Te Tengo.';

  @override
  String get widgetPaso3 => 'Choose the size and drop it in place.';

  @override
  String get widgetPrivacidad => 'Shows the status, never images of the home.';

  @override
  String get pcsSinInternet => 'No internet';

  @override
  String get pcsRevisaConexion => 'Check your connection and try again.';

  @override
  String get pcsSinInternetReintenta => 'No internet. Try again.';

  @override
  String get pcsAgregarPc => 'Add PC';

  @override
  String get pcsEscanearQr => 'Scan the QR code';

  @override
  String get pcsEscribirCodigo => 'Type the code';

  @override
  String get pcsBuscandoPc => 'Looking for the PC…';

  @override
  String get pcsCodigoVencidoTitulo => 'This code expired or was already used';

  @override
  String get pcsCodigoVencidoTexto =>
      'The PC already shows a new one: type it or scan it.';

  @override
  String get pcsDemasiadosIntentos => 'Too many attempts';

  @override
  String get pcsYaVinculadaTitulo => 'This PC is already linked';

  @override
  String get pcsYaVinculadaTexto => 'You’ll find it in Cameras and PCs.';

  @override
  String get pcsCancelar => 'Cancel';

  @override
  String get pcsCerrar => 'Close';

  @override
  String get pcsListo => 'Done';

  @override
  String get pcsFaltaElegirCamaras => 'Cameras not chosen yet';

  @override
  String get pcsElegirCamaras => 'Choose cameras';

  @override
  String get pcsSistema => 'System';

  @override
  String get pcsPrograma => 'Program';

  @override
  String get pcsRegistrarConsentimiento => 'Record consent';

  @override
  String pcsFaltaConsentimientoDe(String nombre) {
    return '$nombre’s consent is missing';
  }

  @override
  String get pcsQueRevisar => 'What to check';

  @override
  String get pcsSinConexion => 'Offline';

  @override
  String get pcsEnLinea => 'Online';

  @override
  String pcsSinConexionDesdeLas(String hora) {
    return 'Offline since $hora.';
  }

  @override
  String pcsPcNoResponde(String nombre) {
    return 'PC $nombre isn’t responding';
  }

  @override
  String pcsPcNoRespondeDesde(String nombre, String hora) {
    return 'PC $nombre hasn’t responded since $hora';
  }

  @override
  String pcsPcNombre(String nombre) {
    return 'PC $nombre';
  }

  @override
  String get pcsDejarDeUsar => 'Stop using';

  @override
  String get pcsVistaPreviaTema => 'preview';

  @override
  String pcsNCamaras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras',
      one: '1 camera',
    );
    return '$_temp0';
  }

  @override
  String pcsNCamarasSinUsar(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unused cameras',
      one: '1 unused camera',
    );
    return '$_temp0';
  }

  @override
  String get pcsUnaPorHabitacion => 'One camera per room.';

  @override
  String get pcsBuscarDeNuevo => 'Search again';

  @override
  String pcsEstadoSinConexionDesde(String hora) {
    return 'Offline since $hora';
  }

  @override
  String pcsEstadoEnLineaSenal(String hace) {
    return 'Online · last signal $hace';
  }

  @override
  String get pcsRevisarEncendida => 'The PC is on';

  @override
  String get pcsRevisarEncendidaDetalle => 'Not asleep';

  @override
  String get pcsRevisarInternet => 'It has internet';

  @override
  String get pcsRevisarInternetDetalle => 'With the modem light on';

  @override
  String get pcsRevisarCaptura => 'Te Tengo Captura is open';

  @override
  String get pcsRevisarCapturaDetalle => 'Next to the Windows clock';

  @override
  String pcsChipOcupada(String habitacion) {
    return '$habitacion, already has a camera';
  }

  @override
  String pcsDejarDeUsarTitulo(String dispositivo) {
    return 'Stop using the $dispositivo camera?';
  }

  @override
  String pcsDejarDeUsarTexto(String enHabitacion) {
    return 'We won’t detect falls $enHabitacion. You can choose it again.';
  }

  @override
  String pcsDejamosDeUsar(String dispositivo) {
    return 'We stopped using the $dispositivo camera';
  }

  @override
  String pcsYaNoDetectamos(String enHabitacion) {
    return 'We no longer detect falls $enHabitacion.';
  }

  @override
  String get pcsCodigoNoExiste =>
      'That code doesn’t exist. Check it letter by letter.';

  @override
  String get pcsCodigoFormato =>
      'The code has 8 letters, only consonants, no numbers.';

  @override
  String get pcsCodigoVencido =>
      'This code expired or was already used. The PC already shows a new one.';

  @override
  String get pcsBloqueoQuinceMinutos => 'You can try again in 15 minutes.';

  @override
  String pcsBloqueoHasta(String hora) {
    return 'You can try again at $hora.';
  }

  @override
  String get pcsCampoCodigoEtiqueta => 'PC code, 8 letters';

  @override
  String get pcsEscribeElCodigo => 'Type the PC’s code';

  @override
  String get pcsCodigoDe8Letras => '8-letter code';

  @override
  String get pcsSoloConsonantes => 'The code has only consonants, no numbers';

  @override
  String get pcsCodigoDondeEsta => 'It’s below the QR, in Te Tengo Captura.';

  @override
  String get pcsContinuar => 'Continue';

  @override
  String get pcsQrAjenoTitulo => 'That code isn’t from Te Tengo Captura';

  @override
  String get pcsQrAjenoTexto => 'Point at the QR code the PC shows.';

  @override
  String get pcsVolver => 'Back';

  @override
  String get pcsCamaraDelCelular => 'Phone camera';

  @override
  String get pcsApuntaAlQr => 'Point at the PC’s QR';

  @override
  String get pcsLinterna => 'Flashlight';

  @override
  String get pcsExplicarCamara =>
      'Te Tengo will use the camera to read the QR.';

  @override
  String get pcsNoGuardaImagenes => 'It doesn’t save images.';

  @override
  String get pcsPermitir => 'Allow';

  @override
  String get pcsCamaraBloqueada => 'The phone’s camera is blocked';

  @override
  String get pcsAbrirAjustesCelular => 'Open phone settings';

  @override
  String get pcsNoPuedesEscanear => 'Can’t scan it?';

  @override
  String get pcsNoVinculamosTitulo => 'We didn’t link the PC';

  @override
  String get pcsNoVinculamosTexto =>
      'The PC won’t have access. Don’t scan codes you don’t know.';

  @override
  String get pcsEntendido => 'Got it';

  @override
  String get pcsAprobarLaPc => 'Approve the PC';

  @override
  String get pcsVolverAIntentarlo => 'Try again';

  @override
  String pcsVinculamosPregunta(String nombre) {
    return 'Link this PC to $nombre’s home?';
  }

  @override
  String get pcsNoPudimosVincular => 'We couldn’t link the PC';

  @override
  String get pcsNombreDeLaPc => 'PC name';

  @override
  String get pcsCodigo => 'Code';

  @override
  String get pcsSiLaApruebas => 'If you approve it, this PC will be able to:';

  @override
  String get pcsPermisoDetectar => 'Detect falls with its cameras';

  @override
  String get pcsPermisoAvisos => 'Send alerts and 12 s clips';

  @override
  String get pcsPermisoVivo => 'Show the live view';

  @override
  String pcsApruebalaSolo(String nombre) {
    return 'Approve it only if you’re in front of $nombre’s PC or you installed it.';
  }

  @override
  String get pcsAccionVincularPc => 'link a PC. Ask them to scan the code';

  @override
  String get pcsAprobar => 'Approve';

  @override
  String get pcsVinculando => 'Linking…';

  @override
  String get pcsNoReconozco => 'I don’t recognize this PC';

  @override
  String get pcsVinculaTitulo => 'Link the home’s PC';

  @override
  String get pcsAccionAgregarPc => 'add a PC';

  @override
  String get pcsPasoInstalar => 'Install Te Tengo Captura on the PC';

  @override
  String pcsPasoInstalarDesde(String pagina) {
    return 'From $pagina';
  }

  @override
  String get pcsPasoAbrir => 'Open it: it shows a QR code';

  @override
  String get pcsPasoEscanear => 'Scan the QR with this phone';

  @override
  String pcsEstaVinculada(String nombre) {
    return 'PC $nombre is linked';
  }

  @override
  String get pcsCamarasYaElegidas => 'Its cameras are already chosen.';

  @override
  String get pcsAhoraElige => 'Now choose its cameras from here.';

  @override
  String get pcsSinElNoEnvian => 'Without it, the cameras send nothing.';

  @override
  String get pcsCompletarConsentimiento => 'Complete the consent';

  @override
  String get pcsHacerloDespues => 'Do it later';

  @override
  String get pcsSinCamarasNoDetectamos =>
      'Without chosen cameras we can’t detect falls.';

  @override
  String get pcsPc => 'PC';

  @override
  String get pcsVinculada => 'Linked';

  @override
  String pcsVinculadaPor(String fecha, String nombre) {
    return '$fecha by $nombre';
  }

  @override
  String get pcsUltimaSenal => 'Last signal';

  @override
  String get pcsCamarasDeEstaPc => 'This PC’s cameras';

  @override
  String get pcsUsaOtraCamara => 'Use another camera or stop using one';

  @override
  String get pcsQuitar => 'Remove';

  @override
  String get pcsQuitarExplicacion => 'Stop detecting falls with this PC.';

  @override
  String get pcsQuitarEstaPc => 'Remove this PC';

  @override
  String get pcsAccionElegirOQuitar => 'choose the cameras or remove this PC';

  @override
  String pcsQuitarPregunta(String nombre) {
    return 'Remove PC $nombre?';
  }

  @override
  String pcsQuitarTextoHabitaciones(String habitaciones) {
    return 'We’ll stop detecting falls in $habitaciones. The PC will show its QR again.';
  }

  @override
  String get pcsQuitarTexto => 'The PC will show its QR again.';

  @override
  String get pcsQuitarLaPc => 'Remove PC';

  @override
  String pcsQuitamos(String nombre) {
    return 'We removed PC $nombre';
  }

  @override
  String get pcsDejaraDeCapturar =>
      'It will stop capturing as soon as it connects.';

  @override
  String get pcsCamaras => 'Cameras';

  @override
  String get pcsFaltaConsentimiento => 'Consent is missing';

  @override
  String get pcsSinElNoDetectamos => 'Without it we can’t detect falls.';

  @override
  String get pcsVerTodas => 'See all';

  @override
  String get pcsOrdenar => 'Reorder';

  @override
  String get pcsFiltroSemantica => 'Show cameras of';

  @override
  String get pcsTodas => 'All';

  @override
  String get pcsNecesitanAtencion => 'Need attention';

  @override
  String get pcsFuncionando => 'Working';

  @override
  String get pcsDetenidas => 'Stopped';

  @override
  String get pcsPcsDeLaCasa => 'Home PCs';

  @override
  String get pcsAccionAgregarOQuitar => 'add or remove PCs';

  @override
  String pcsAtencionPcSinConexion(String nombre) {
    return 'PC $nombre offline';
  }

  @override
  String pcsAtencionSinConexion(String habitacion) {
    return '$habitacion offline';
  }

  @override
  String pcsAtencionEnPc(String nombre) {
    return 'On PC $nombre';
  }

  @override
  String pcsAtencionEnPcElige(String nombre) {
    return 'On PC $nombre · choose its room';
  }

  @override
  String get pcsReanudarAhora => 'Resume now';

  @override
  String pcsAtencionDesconectada(String habitacion) {
    return '$habitacion: camera disconnected';
  }

  @override
  String pcsDesdeLas(String hora) {
    return 'Since $hora';
  }

  @override
  String pcsAtencionEnPausa(String habitacion) {
    return '$habitacion paused';
  }

  @override
  String pcsAtencionHastaLas(String hora) {
    return 'Until $hora · resumes on its own';
  }

  @override
  String pcsAtencionNoConfiable(String habitacion) {
    return 'Unreliable detection · $habitacion';
  }

  @override
  String get pcsAtencionRevisaLuz => 'Check the lighting and framing';

  @override
  String get pcsAunNoHayPc => 'No PC linked yet';

  @override
  String get pcsLineaSinCamaras => 'No cameras';

  @override
  String pcsLineaFunciona(String habitacion) {
    return 'Working · $habitacion';
  }

  @override
  String pcsLineaFuncionan(int ok, int n) {
    return '$ok of $n working';
  }

  @override
  String get pcsResumenSinCamaras => 'No cameras chosen yet';

  @override
  String get pcsResumenDetenidas => 'stopped';

  @override
  String get pcsResumenFuncionaBien => 'working well';

  @override
  String get pcsResumenTodasBien => 'all working well';

  @override
  String get pcsResumenNoFunciona => 'not working now';

  @override
  String get pcsResumenNingunaFunciona => 'none working now';

  @override
  String pcsResumenAlgunasBien(int ok) {
    return '$ok working well';
  }

  @override
  String get pcsEscribeNombreHabitacion => 'Type the room’s name.';

  @override
  String get pcsSinBano =>
      'For privacy, Te Tengo doesn’t allow cameras in the bathroom.';

  @override
  String pcsOcupada(String enHabitacion) {
    return 'There’s already a camera $enHabitacion. For now, each room uses just one camera.';
  }

  @override
  String pcsOcupadaConPc(String enHabitacion, String pc) {
    return 'There’s already a camera $enHabitacion (PC $pc). For now, each room uses just one camera.';
  }

  @override
  String pcsCuidaAhora(String dispositivo, String laHabitacion) {
    return 'The $dispositivo camera now watches $laHabitacion';
  }

  @override
  String pcsProximasAlertas(String enHabitacion) {
    return 'Upcoming alerts will say “$enHabitacion”.';
  }

  @override
  String get pcsDetectaraConConsentimiento =>
      'It will detect falls once you record consent.';

  @override
  String get pcsEligeLasCamaras => 'Choose the cameras';

  @override
  String pcsCamarasEnLaPc(int n, String pc) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cameras on PC $pc. One per room.',
      one: '1 camera on PC $pc. One per room.',
    );
    return '$_temp0';
  }

  @override
  String get pcsSinElNoHayVistaPrevia =>
      'Without it there’s no preview or detection.';

  @override
  String get pcsAccionElegirCamaras => 'choose the cameras';

  @override
  String get pcsQueRevisarEnCasa => 'What to check at home';

  @override
  String get pcsDeteccionLenta =>
      'If detection is slow, move cameras to another PC.';

  @override
  String get pcsFaltaUna => 'Missing one? Have someone plug it in by USB.';

  @override
  String get pcsVerVistaPrevia => 'See preview';

  @override
  String get pcsAyudaVistaPrevia =>
      'Shows what the camera sees for 15 s. It isn’t recorded and is kept in the access log.';

  @override
  String pcsRevisaCableConserva(String habitacion) {
    return 'Check the USB cable. $habitacion keeps this camera.';
  }

  @override
  String get pcsPideConectarUsb => 'Ask someone to plug it in by USB.';

  @override
  String get pcsEnQueHabitacion => 'Which room is it in?';

  @override
  String get pcsHabitacionesTema => 'rooms';

  @override
  String get pcsOtra => 'Other…';

  @override
  String get pcsYaTienenCamara =>
      'Rooms that already have a camera can’t be chosen.';

  @override
  String get pcsNombreHabitacion => 'Room name';

  @override
  String get pcsNombreHabitacionEjemplo => 'E.g.: Study';

  @override
  String get pcsUsarEstaCamara => 'Use this camera';

  @override
  String pcsBuscandoCamaras(String pc) {
    return 'Looking for cameras on PC $pc…';
  }

  @override
  String pcsNoEncontramosCamaras(String pc) {
    return 'We found no cameras on PC $pc';
  }

  @override
  String get pcsConectenWebcam => 'Have someone plug in a webcam by USB.';

  @override
  String pcsWebcamDesconectadaEn(String habitacion) {
    return 'Disconnected · $habitacion';
  }

  @override
  String pcsWebcamEnUsoPausa(String habitacion) {
    return 'In use · $habitacion · paused';
  }

  @override
  String pcsWebcamEnUso(String habitacion) {
    return 'In use · $habitacion';
  }

  @override
  String get pcsWebcamDesconectada => 'Disconnected';

  @override
  String get pcsWebcamSinUsar => 'Unused';

  @override
  String get pcsCamaraDesconectada => 'The camera is disconnected';

  @override
  String get pcsRevisenCable => 'Have someone check the USB cable.';

  @override
  String get pcsSinElNoHayVideo => 'Without it there’s no video.';

  @override
  String get pcsCamaraEnPausa => 'The camera is paused';

  @override
  String pcsHastaLas(String hora) {
    return 'Until $hora.';
  }

  @override
  String get pcsAccesoRegistrado => 'Access logged';

  @override
  String pcsVisteVistaPrevia(String dispositivo, String duracion) {
    return 'You watched the $dispositivo preview for $duracion.';
  }

  @override
  String pcsVistaPreviaDe(String dispositivo) {
    return 'Preview · $dispositivo';
  }

  @override
  String pcsAyudaVistaPreviaCierre(int segundos) {
    return 'It isn’t recorded and is kept in the access log. It closes on its own after $segundos s.';
  }

  @override
  String pcsVistaPreviaCuenta(String tiempo) {
    return 'PREVIEW · $tiempo';
  }
}
