import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @actividadTitulo.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get actividadTitulo;

  /// No description provided for @actividadHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get actividadHoy;

  /// No description provided for @actividadAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get actividadAyer;

  /// No description provided for @actividadUltimoCambioHoy.
  ///
  /// In es, this message translates to:
  /// **'Último cambio: hoy {hora}'**
  String actividadUltimoCambioHoy(String hora);

  /// No description provided for @actividadUltimoCambioAyer.
  ///
  /// In es, this message translates to:
  /// **'Último cambio: ayer {hora}'**
  String actividadUltimoCambioAyer(String hora);

  /// No description provided for @actividadUltimoCambioFecha.
  ///
  /// In es, this message translates to:
  /// **'Último cambio: el {fecha} {hora}'**
  String actividadUltimoCambioFecha(String fecha, String hora);

  /// No description provided for @actividadSinActividad.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay actividad'**
  String get actividadSinActividad;

  /// No description provided for @actividadAyudaRegistro.
  ///
  /// In es, this message translates to:
  /// **'Nadie puede borrar ni cambiar este registro.'**
  String get actividadAyudaRegistro;

  /// Topic of the «?» button: «Más información: registro de actividad».
  ///
  /// In es, this message translates to:
  /// **'registro de actividad'**
  String get actividadAyudaTema;

  /// No description provided for @actividadFiltrarPorPc.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por PC'**
  String get actividadFiltrarPorPc;

  /// Chip: all PCs.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get actividadTodas;

  /// No description provided for @actividadVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay actividad registrada'**
  String get actividadVacioTitulo;

  /// No description provided for @actividadVacioTexto.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás cada cambio en PCs, cámaras y datos.'**
  String get actividadVacioTexto;

  /// No description provided for @actividadReintentar.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentarlo'**
  String get actividadReintentar;

  /// No description provided for @actividadDatoQuien.
  ///
  /// In es, this message translates to:
  /// **'Quién'**
  String get actividadDatoQuien;

  /// No description provided for @actividadDatoDesde.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get actividadDatoDesde;

  /// No description provided for @actividadDatoMomento.
  ///
  /// In es, this message translates to:
  /// **'Momento'**
  String get actividadDatoMomento;

  /// No description provided for @actividadDatoDuracion.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get actividadDatoDuracion;

  /// No description provided for @actividadDatoAntes.
  ///
  /// In es, this message translates to:
  /// **'Antes'**
  String get actividadDatoAntes;

  /// No description provided for @actividadDatoDespues.
  ///
  /// In es, this message translates to:
  /// **'Después'**
  String get actividadDatoDespues;

  /// No description provided for @actividadDatoFechaYHora.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get actividadDatoFechaYHora;

  /// No description provided for @actividadCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get actividadCerrar;

  /// No description provided for @actividadCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando actividad'**
  String get actividadCargando;

  /// A family member did [accion]: «Carmen vinculó la PC Cocina-Rosa».
  ///
  /// In es, this message translates to:
  /// **'{quien} {accion}'**
  String actividadFraseFamiliar(String quien, String accion);

  /// No description provided for @actividadFraseDesdePc.
  ///
  /// In es, this message translates to:
  /// **'Desde la PC {pc}: {accion}'**
  String actividadFraseDesdePc(String pc, String accion);

  /// Action in lower case; the system ones are capitalized.
  ///
  /// In es, this message translates to:
  /// **'vinculó la PC {pc}'**
  String actividadVinculoPc(String pc);

  /// No description provided for @actividadRenombroPc.
  ///
  /// In es, this message translates to:
  /// **'renombró la PC {antes} a {despues}'**
  String actividadRenombroPc(String antes, String despues);

  /// No description provided for @actividadQuitoPc.
  ///
  /// In es, this message translates to:
  /// **'quitó la PC {pc}'**
  String actividadQuitoPc(String pc);

  /// No description provided for @actividadPcRestablecida.
  ///
  /// In es, this message translates to:
  /// **'La PC {pc} se restableció'**
  String actividadPcRestablecida(String pc);

  /// No description provided for @actividadPcDesinstalada.
  ///
  /// In es, this message translates to:
  /// **'La PC {pc} se desinstaló'**
  String actividadPcDesinstalada(String pc);

  /// No description provided for @actividadPcSeDesvinculo.
  ///
  /// In es, this message translates to:
  /// **'se desvinculó esta PC'**
  String get actividadPcSeDesvinculo;

  /// No description provided for @actividadPcVencida.
  ///
  /// In es, this message translates to:
  /// **'Se desvinculó la PC {pc}: no se conectó en 90 días'**
  String actividadPcVencida(String pc);

  /// No description provided for @actividadPcPorSeguridad.
  ///
  /// In es, this message translates to:
  /// **'Se desvinculó la PC {pc} por seguridad'**
  String actividadPcPorSeguridad(String pc);

  /// No description provided for @actividadCamaraPasoA.
  ///
  /// In es, this message translates to:
  /// **'la cámara {camara} pasó a {habitacion}'**
  String actividadCamaraPasoA(String camara, String habitacion);

  /// [conArticulo] is the Spanish room with its article («el Dormitorio»); [habitacion] the bare room name.
  ///
  /// In es, this message translates to:
  /// **'eligió la cámara {camara} para {conArticulo}'**
  String actividadEligioCamara(
    String camara,
    String conArticulo,
    String habitacion,
  );

  /// [deAntes] «de la Sala», [aDespues] «al Dormitorio» (Spanish forms); [antes] and [despues] the bare room names.
  ///
  /// In es, this message translates to:
  /// **'pasó la cámara {camara} {deAntes} {aDespues}'**
  String actividadPasoCamara(
    String camara,
    String deAntes,
    String aDespues,
    String antes,
    String despues,
  );

  /// No description provided for @actividadSeDejoDeUsarCamara.
  ///
  /// In es, this message translates to:
  /// **'se dejó de usar la cámara {camara}'**
  String actividadSeDejoDeUsarCamara(String camara);

  /// No description provided for @actividadDejoDeUsarCamara.
  ///
  /// In es, this message translates to:
  /// **'dejó de usar la cámara {camara}'**
  String actividadDejoDeUsarCamara(String camara);

  /// [deAntes] «de la Sala» (Spanish form); [antes] the bare room name.
  ///
  /// In es, this message translates to:
  /// **'cambió el nombre de la habitación {deAntes} a {despues}'**
  String actividadRenombroHabitacion(
    String deAntes,
    String despues,
    String antes,
  );

  /// [deHabitacion] «del Dormitorio» (Spanish form); [habitacion] the bare room name.
  ///
  /// In es, this message translates to:
  /// **'pausó la cámara {deHabitacion}'**
  String actividadPausoCamara(String deHabitacion, String habitacion);

  /// [hasta] is actividadHastaHora or actividadHastaDia.
  ///
  /// In es, this message translates to:
  /// **'pausó la cámara {deHabitacion} hasta {hasta}'**
  String actividadPausoCamaraHasta(
    String deHabitacion,
    String hasta,
    String habitacion,
  );

  /// No description provided for @actividadHastaHora.
  ///
  /// In es, this message translates to:
  /// **'las {hora}'**
  String actividadHastaHora(String hora);

  /// No description provided for @actividadHastaDia.
  ///
  /// In es, this message translates to:
  /// **'el {dia} a las {hora}'**
  String actividadHastaDia(String dia, String hora);

  /// No description provided for @actividadTerminoPausa.
  ///
  /// In es, this message translates to:
  /// **'Terminó la pausa {deHabitacion}'**
  String actividadTerminoPausa(String deHabitacion, String habitacion);

  /// No description provided for @actividadReanudoCamara.
  ///
  /// In es, this message translates to:
  /// **'reanudó la cámara {deHabitacion}'**
  String actividadReanudoCamara(String deHabitacion, String habitacion);

  /// No description provided for @actividadCambioFoto.
  ///
  /// In es, this message translates to:
  /// **'cambió la foto de {nombre}'**
  String actividadCambioFoto(String nombre);

  /// No description provided for @actividadQuitoFoto.
  ///
  /// In es, this message translates to:
  /// **'quitó la foto de {nombre}'**
  String actividadQuitoFoto(String nombre);

  /// No description provided for @actividadRegistroConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'registró el consentimiento de monitoreo'**
  String get actividadRegistroConsentimiento;

  /// No description provided for @actividadRevocoConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'revocó el consentimiento de monitoreo'**
  String get actividadRevocoConsentimiento;

  /// No description provided for @actividadRegistroPermisoMovimientos.
  ///
  /// In es, this message translates to:
  /// **'registró el permiso de {nombre} para guardar movimientos'**
  String actividadRegistroPermisoMovimientos(String nombre);

  /// No description provided for @actividadMovimientosRevocados.
  ///
  /// In es, this message translates to:
  /// **'Se dejaron de guardar los movimientos de {nombre} al revocar el consentimiento'**
  String actividadMovimientosRevocados(String nombre);

  /// No description provided for @actividadDejoDeGuardarMovimientos.
  ///
  /// In es, this message translates to:
  /// **'dejó de guardar los movimientos de {nombre}'**
  String actividadDejoDeGuardarMovimientos(String nombre);

  /// No description provided for @actividadCambioRetencion.
  ///
  /// In es, this message translates to:
  /// **'cambió los movimientos en la nube de {de} a {a}'**
  String actividadCambioRetencion(String de, String a);

  /// No description provided for @actividadNoGuardar.
  ///
  /// In es, this message translates to:
  /// **'No guardar'**
  String get actividadNoGuardar;

  /// No description provided for @actividadModoAvanzadoActivado.
  ///
  /// In es, this message translates to:
  /// **'se activó el modo avanzado'**
  String get actividadModoAvanzadoActivado;

  /// No description provided for @actividadModoAvanzadoDesactivado.
  ///
  /// In es, this message translates to:
  /// **'se desactivó el modo avanzado'**
  String get actividadModoAvanzadoDesactivado;

  /// No description provided for @actividadGuardadoEnPc.
  ///
  /// In es, this message translates to:
  /// **'el guardado en la PC'**
  String get actividadGuardadoEnPc;

  /// No description provided for @actividadGuardadoCambio.
  ///
  /// In es, this message translates to:
  /// **'{que} pasó de {antes} a {despues}'**
  String actividadGuardadoCambio(String que, String antes, String despues);

  /// No description provided for @actividadNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get actividadNo;

  /// No description provided for @actividadBorroDatos.
  ///
  /// In es, this message translates to:
  /// **'se borraron los datos guardados en la PC'**
  String get actividadBorroDatos;

  /// No description provided for @actividadVioQuePaso.
  ///
  /// In es, this message translates to:
  /// **'se vio qué pasó'**
  String get actividadVioQuePaso;

  /// [enHabitacion] «en la Sala» (Spanish form); [habitacion] the bare room name.
  ///
  /// In es, this message translates to:
  /// **'se vio qué pasó {enHabitacion}'**
  String actividadVioQuePasoEn(String enHabitacion, String habitacion);

  /// No description provided for @actividadConDetalle.
  ///
  /// In es, this message translates to:
  /// **'{frase} ({detalle})'**
  String actividadConDetalle(String frase, String detalle);

  /// «23/09 10:36–10:46».
  ///
  /// In es, this message translates to:
  /// **'{dia} {desde}–{hasta}'**
  String actividadMomento(String dia, String desde, String hasta);

  /// Day and month as two digits each.
  ///
  /// In es, this message translates to:
  /// **'{dd}/{mm}'**
  String actividadDiaMes(String dd, String mm);

  /// No description provided for @actividadPcActualizada.
  ///
  /// In es, this message translates to:
  /// **'{pc} se actualizó a {version}'**
  String actividadPcActualizada(String pc, String version);

  /// No description provided for @actividadActualizacionAutomaticaActivada.
  ///
  /// In es, this message translates to:
  /// **'se activó la actualización automática'**
  String get actividadActualizacionAutomaticaActivada;

  /// No description provided for @actividadActualizacionAutomaticaDesactivada.
  ///
  /// In es, this message translates to:
  /// **'se desactivó la actualización automática'**
  String get actividadActualizacionAutomaticaDesactivada;

  /// No description provided for @actividadCambioFamiliar.
  ///
  /// In es, this message translates to:
  /// **'hizo un cambio en la configuración'**
  String get actividadCambioFamiliar;

  /// No description provided for @actividadCambioPc.
  ///
  /// In es, this message translates to:
  /// **'hubo un cambio en la configuración'**
  String get actividadCambioPc;

  /// No description provided for @actividadCambioSistema.
  ///
  /// In es, this message translates to:
  /// **'Hubo un cambio en la configuración'**
  String get actividadCambioSistema;

  /// No description provided for @actividadVinculada.
  ///
  /// In es, this message translates to:
  /// **'Vinculada'**
  String get actividadVinculada;

  /// No description provided for @actividadDesvinculada.
  ///
  /// In es, this message translates to:
  /// **'Desvinculada'**
  String get actividadDesvinculada;

  /// No description provided for @actividadSinUsar.
  ///
  /// In es, this message translates to:
  /// **'Sin usar'**
  String get actividadSinUsar;

  /// No description provided for @actividadEnLinea.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get actividadEnLinea;

  /// No description provided for @actividadEnPausa.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get actividadEnPausa;

  /// No description provided for @actividadEnPausaHasta.
  ///
  /// In es, this message translates to:
  /// **'En pausa hasta {hasta}'**
  String actividadEnPausaHasta(String hasta);

  /// No description provided for @actividadNoAutorizado.
  ///
  /// In es, this message translates to:
  /// **'No autorizado'**
  String get actividadNoAutorizado;

  /// No description provided for @actividadVigente.
  ///
  /// In es, this message translates to:
  /// **'Vigente'**
  String get actividadVigente;

  /// No description provided for @actividadRevocado.
  ///
  /// In es, this message translates to:
  /// **'Revocado'**
  String get actividadRevocado;

  /// No description provided for @actividadDesactivado.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get actividadDesactivado;

  /// No description provided for @actividadActivado.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get actividadActivado;

  /// No description provided for @actividadAlguienEnPc.
  ///
  /// In es, this message translates to:
  /// **'Alguien en la PC'**
  String get actividadAlguienEnPc;

  /// No description provided for @actividadCelularDe.
  ///
  /// In es, this message translates to:
  /// **'Celular de {nombre}'**
  String actividadCelularDe(String nombre);

  /// No description provided for @actividadPc.
  ///
  /// In es, this message translates to:
  /// **'PC {pc}'**
  String actividadPc(String pc);

  /// No description provided for @actividadAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get actividadAutomatico;

  /// No description provided for @ajustesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustesTitulo;

  /// No description provided for @ajustesEdad.
  ///
  /// In es, this message translates to:
  /// **'{edad} años'**
  String ajustesEdad(int edad);

  /// No description provided for @ajustesViveSolo.
  ///
  /// In es, this message translates to:
  /// **'Vive solo(a)'**
  String get ajustesViveSolo;

  /// No description provided for @ajustesViveContigo.
  ///
  /// In es, this message translates to:
  /// **'Vive contigo'**
  String get ajustesViveContigo;

  /// No description provided for @ajustesViveConCuidador.
  ///
  /// In es, this message translates to:
  /// **'Vive con otro cuidador'**
  String get ajustesViveConCuidador;

  /// No description provided for @ajustesInvitadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Eres familiar invitado'**
  String get ajustesInvitadoTitulo;

  /// No description provided for @ajustesInvitadoTexto.
  ///
  /// In es, this message translates to:
  /// **'Lo que tiene candado solo lo cambia {titular}.'**
  String ajustesInvitadoTexto(String titular);

  /// No description provided for @ajustesPersonaCuidada.
  ///
  /// In es, this message translates to:
  /// **'Persona cuidada'**
  String get ajustesPersonaCuidada;

  /// No description provided for @ajustesMonitoreo.
  ///
  /// In es, this message translates to:
  /// **'Monitoreo'**
  String get ajustesMonitoreo;

  /// No description provided for @ajustesCamarasYPcs.
  ///
  /// In es, this message translates to:
  /// **'Cámaras y PCs'**
  String get ajustesCamarasYPcs;

  /// No description provided for @ajustesOrdenAviso.
  ///
  /// In es, this message translates to:
  /// **'Orden de aviso y espera'**
  String get ajustesOrdenAviso;

  /// No description provided for @ajustesOrdenSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'{principal} · sin secundario · {espera} min'**
  String ajustesOrdenSinSecundario(String principal, int espera);

  /// No description provided for @ajustesOrdenConSecundario.
  ///
  /// In es, this message translates to:
  /// **'{principal} → {secundario} · {espera} min'**
  String ajustesOrdenConSecundario(
    String principal,
    String secundario,
    int espera,
  );

  /// No description provided for @ajustesPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y consentimiento'**
  String get ajustesPrivacidad;

  /// No description provided for @ajustesConsentimientoVigente.
  ///
  /// In es, this message translates to:
  /// **'Vigente · {fecha}'**
  String ajustesConsentimientoVigente(String fecha);

  /// No description provided for @ajustesSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin consentimiento'**
  String get ajustesSinConsentimiento;

  /// No description provided for @ajustesActividad.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get ajustesActividad;

  /// No description provided for @ajustesEsteCelular.
  ///
  /// In es, this message translates to:
  /// **'Este celular'**
  String get ajustesEsteCelular;

  /// No description provided for @ajustesNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get ajustesNotificaciones;

  /// Notifications are on.
  ///
  /// In es, this message translates to:
  /// **'Activadas'**
  String get ajustesActivadas;

  /// Notifications are off.
  ///
  /// In es, this message translates to:
  /// **'Desactivadas'**
  String get ajustesDesactivadas;

  /// No description provided for @ajustesPreferencias.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get ajustesPreferencias;

  /// No description provided for @ajustesAgregarWidget.
  ///
  /// In es, this message translates to:
  /// **'Agregar el widget'**
  String get ajustesAgregarWidget;

  /// No description provided for @ajustesWidgetResumen.
  ///
  /// In es, this message translates to:
  /// **'{nombre} y «Ver en vivo» en tu pantalla de inicio'**
  String ajustesWidgetResumen(String nombre);

  /// No description provided for @ajustesCuenta.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get ajustesCuenta;

  /// No description provided for @ajustesTuCuentaTitular.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta · Titular'**
  String get ajustesTuCuentaTitular;

  /// No description provided for @ajustesTuCuentaInvitado.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta · Familiar invitado'**
  String get ajustesTuCuentaInvitado;

  /// No description provided for @ajustesCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get ajustesCerrarSesion;

  /// No description provided for @ajustesCamaras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara} other{{n} cámaras}}'**
  String ajustesCamaras(int n);

  /// No description provided for @ajustesPcs.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 PC} other{{n} PCs}}'**
  String ajustesPcs(int n);

  /// No description provided for @ajustesSinPc.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay una PC vinculada'**
  String get ajustesSinPc;

  /// No description provided for @ajustesPcSinConexion.
  ///
  /// In es, this message translates to:
  /// **'{pc} sin conexión'**
  String ajustesPcSinConexion(String pc);

  /// No description provided for @preferenciasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferenciasTitulo;

  /// No description provided for @preferenciasTemaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get preferenciasTemaAutomatico;

  /// No description provided for @preferenciasTemaClaro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get preferenciasTemaClaro;

  /// No description provided for @preferenciasTemaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get preferenciasTemaOscuro;

  /// No description provided for @preferenciasLetraEstandar.
  ///
  /// In es, this message translates to:
  /// **'Estándar'**
  String get preferenciasLetraEstandar;

  /// No description provided for @preferenciasLetraGrande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get preferenciasLetraGrande;

  /// No description provided for @preferenciasResumenTemaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Tema automático'**
  String get preferenciasResumenTemaAutomatico;

  /// No description provided for @preferenciasResumenTemaClaro.
  ///
  /// In es, this message translates to:
  /// **'Tema claro'**
  String get preferenciasResumenTemaClaro;

  /// No description provided for @preferenciasResumenTemaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro'**
  String get preferenciasResumenTemaOscuro;

  /// No description provided for @preferenciasResumenLetraEstandar.
  ///
  /// In es, this message translates to:
  /// **'letra estándar'**
  String get preferenciasResumenLetraEstandar;

  /// No description provided for @preferenciasResumenLetraGrande.
  ///
  /// In es, this message translates to:
  /// **'letra grande'**
  String get preferenciasResumenLetraGrande;

  /// No description provided for @preferenciasResumenContraste.
  ///
  /// In es, this message translates to:
  /// **'más contraste'**
  String get preferenciasResumenContraste;

  /// No description provided for @preferenciasTema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get preferenciasTema;

  /// No description provided for @preferenciasIgualQueCelular.
  ///
  /// In es, this message translates to:
  /// **'Igual que tu celular'**
  String get preferenciasIgualQueCelular;

  /// No description provided for @preferenciasTamanoLetra.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de letra'**
  String get preferenciasTamanoLetra;

  /// No description provided for @preferenciasContraste.
  ///
  /// In es, this message translates to:
  /// **'Contraste'**
  String get preferenciasContraste;

  /// No description provided for @preferenciasAumentarContraste.
  ///
  /// In es, this message translates to:
  /// **'Aumentar el contraste'**
  String get preferenciasAumentarContraste;

  /// No description provided for @preferenciasContrasteTexto.
  ///
  /// In es, this message translates to:
  /// **'Texto y bordes más marcados'**
  String get preferenciasContrasteTexto;

  /// No description provided for @preferenciasAlertasConservanColor.
  ///
  /// In es, this message translates to:
  /// **'Las alertas conservan su color.'**
  String get preferenciasAlertasConservanColor;

  /// No description provided for @notificacionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificacionesTitulo;

  /// No description provided for @notificacionesDesactivadasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Desactivadas en tu celular'**
  String get notificacionesDesactivadasTitulo;

  /// No description provided for @notificacionesDesactivadasTexto.
  ///
  /// In es, this message translates to:
  /// **'Con la app cerrada no te enterarás de una caída.'**
  String get notificacionesDesactivadasTexto;

  /// No description provided for @notificacionesActivar.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get notificacionesActivar;

  /// No description provided for @notificacionesFamiliaSinAlertas.
  ///
  /// In es, this message translates to:
  /// **'Nadie de la familia recibe las alertas'**
  String get notificacionesFamiliaSinAlertas;

  /// No description provided for @notificacionesCelularSinAlertas.
  ///
  /// In es, this message translates to:
  /// **'Este celular no recibe las alertas'**
  String get notificacionesCelularSinAlertas;

  /// No description provided for @notificacionesSinAlertasTexto.
  ///
  /// In es, this message translates to:
  /// **'Sin ellas no sabrás de una caída con la app cerrada.'**
  String get notificacionesSinAlertasTexto;

  /// No description provided for @notificacionesActivadas.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get notificacionesActivadas;

  /// No description provided for @notificacionesAvisosEnCelular.
  ///
  /// In es, this message translates to:
  /// **'Avisos en este celular'**
  String get notificacionesAvisosEnCelular;

  /// No description provided for @notificacionesCaidas.
  ///
  /// In es, this message translates to:
  /// **'Caídas'**
  String get notificacionesCaidas;

  /// No description provided for @notificacionesSiempreActivas.
  ///
  /// In es, this message translates to:
  /// **'Siempre activas'**
  String get notificacionesSiempreActivas;

  /// No description provided for @notificacionesSonarSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Aunque el celular esté en silencio'**
  String get notificacionesSonarSubtitulo;

  /// No description provided for @notificacionesInestables.
  ///
  /// In es, this message translates to:
  /// **'Movimientos inestables'**
  String get notificacionesInestables;

  /// No description provided for @notificacionesSeveridadMedia.
  ///
  /// In es, this message translates to:
  /// **'Severidad media'**
  String get notificacionesSeveridadMedia;

  /// No description provided for @notificacionesEstadoCamara.
  ///
  /// In es, this message translates to:
  /// **'Estado de la cámara'**
  String get notificacionesEstadoCamara;

  /// No description provided for @notificacionesEstadoCamaraTexto.
  ///
  /// In es, this message translates to:
  /// **'Desconexión o detección no confiable · siempre activas'**
  String get notificacionesEstadoCamaraTexto;

  /// No description provided for @notificacionesFinPausa.
  ///
  /// In es, this message translates to:
  /// **'Fin de una pausa'**
  String get notificacionesFinPausa;

  /// No description provided for @notificacionesFinPausaTexto.
  ///
  /// In es, this message translates to:
  /// **'Cuando la cámara se reactiva sola'**
  String get notificacionesFinPausaTexto;

  /// No description provided for @notificacionesSiNadieAtiende.
  ///
  /// In es, this message translates to:
  /// **'Si nadie atiende'**
  String get notificacionesSiNadieAtiende;

  /// No description provided for @notificacionesAvisarSecundario.
  ///
  /// In es, this message translates to:
  /// **'Avisar al secundario a los {espera} min'**
  String notificacionesAvisarSecundario(int espera);

  /// «✓ Activadas»: the notification permission is granted.
  ///
  /// In es, this message translates to:
  /// **'Activadas'**
  String get notificacionesActivadasPermiso;

  /// No description provided for @notificacionesSonarEnSilencio.
  ///
  /// In es, this message translates to:
  /// **'Sonar en silencio'**
  String get notificacionesSonarEnSilencio;

  /// No description provided for @notificacionesPermitir.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get notificacionesPermitir;

  /// No description provided for @acercaDeComoPwa.
  ///
  /// In es, this message translates to:
  /// **'Se actualiza con internet. Te avisamos para recargarla.'**
  String get acercaDeComoPwa;

  /// No description provided for @acercaDeComoApk.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cuando hay una versión nueva. Android te pide confirmar.'**
  String get acercaDeComoApk;

  /// No description provided for @acercaDeComoPlay.
  ///
  /// In es, this message translates to:
  /// **'Google Play la actualiza sola.'**
  String get acercaDeComoPlay;

  /// No description provided for @acercaDeComoIos.
  ///
  /// In es, this message translates to:
  /// **'Se actualiza desde App Store o TestFlight.'**
  String get acercaDeComoIos;

  /// No description provided for @acercaDeTitulo.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get acercaDeTitulo;

  /// No description provided for @acercaDeFila.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Te Tengo'**
  String get acercaDeFila;

  /// No description provided for @acercaDeVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String acercaDeVersion(String version);

  /// No description provided for @acercaDeHayUnaNueva.
  ///
  /// In es, this message translates to:
  /// **'hay una nueva'**
  String get acercaDeHayUnaNueva;

  /// No description provided for @acercaDeActualizaciones.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get acercaDeActualizaciones;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'actualizaciones'**
  String get acercaDeActualizacionesTema;

  /// No description provided for @acercaDePcsDeLaCasa.
  ///
  /// In es, this message translates to:
  /// **'PCs de la casa'**
  String get acercaDePcsDeLaCasa;

  /// No description provided for @acercaDePcsAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cada PC actualiza Te Tengo Captura por su cuenta.'**
  String get acercaDePcsAyuda;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'las PCs'**
  String get acercaDePcsTema;

  /// No description provided for @acercaDePcsAnteriores.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 PC con versión anterior} other{{n} PCs con versión anterior}}'**
  String acercaDePcsAnteriores(int n);

  /// No description provided for @acercaDeTodasAlDia.
  ///
  /// In es, this message translates to:
  /// **'Todas al día · Te Tengo Captura {version}'**
  String acercaDeTodasAlDia(String version);

  /// Te Tengo Captura (the PC program, a brand) and its version.
  ///
  /// In es, this message translates to:
  /// **'Captura {version}'**
  String acercaDeCaptura(String version);

  /// No description provided for @acercaDeAlDia.
  ///
  /// In es, this message translates to:
  /// **'al día'**
  String get acercaDeAlDia;

  /// No description provided for @actualizacionVersionAnterior.
  ///
  /// In es, this message translates to:
  /// **'versión anterior'**
  String get actualizacionVersionAnterior;

  /// No description provided for @actualizacionBuscando.
  ///
  /// In es, this message translates to:
  /// **'Buscando actualizaciones…'**
  String get actualizacionBuscando;

  /// No description provided for @actualizacionSinInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get actualizacionSinInternet;

  /// No description provided for @actualizacionNoPudimosBuscar.
  ///
  /// In es, this message translates to:
  /// **'No pudimos buscar.'**
  String get actualizacionNoPudimosBuscar;

  /// No description provided for @actualizacionUltimaVersion.
  ///
  /// In es, this message translates to:
  /// **'Tienes la última versión'**
  String get actualizacionUltimaVersion;

  /// Text before the time of «Revisado hoy a las 10:42.».
  ///
  /// In es, this message translates to:
  /// **'Revisado hoy a las '**
  String get actualizacionRevisadoAntes;

  /// Text after the time of «Revisado hoy a las 10:42.».
  ///
  /// In es, this message translates to:
  /// **'.'**
  String get actualizacionRevisadoDespues;

  /// No description provided for @actualizacionBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualizaciones'**
  String get actualizacionBuscar;

  /// No description provided for @actualizacionQueCambio.
  ///
  /// In es, this message translates to:
  /// **'Qué cambió'**
  String get actualizacionQueCambio;

  /// No description provided for @actualizacionQueCambioEn.
  ///
  /// In es, this message translates to:
  /// **'Qué cambió en la {version}'**
  String actualizacionQueCambioEn(String version);

  /// No description provided for @actualizacionAlCerrarAlerta.
  ///
  /// In es, this message translates to:
  /// **'Al cerrar la alerta.'**
  String get actualizacionAlCerrarAlerta;

  /// No description provided for @actualizacionAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get actualizacionAhoraNo;

  /// No description provided for @actualizacionDescarga.
  ///
  /// In es, this message translates to:
  /// **'Descarga'**
  String get actualizacionDescarga;

  /// No description provided for @actualizacionPorcentaje.
  ///
  /// In es, this message translates to:
  /// **'{p} %'**
  String actualizacionPorcentaje(int p);

  /// [mb] already has the decimal separator of the language.
  ///
  /// In es, this message translates to:
  /// **'{mb} MB'**
  String actualizacionTamanoMb(String mb);

  /// Decimal separator of the download size («8,4 MB»).
  ///
  /// In es, this message translates to:
  /// **','**
  String get actualizacionSeparadorDecimal;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'la descarga'**
  String get actualizacionDescargaTema;

  /// No description provided for @actualizacionAbrirTienda.
  ///
  /// In es, this message translates to:
  /// **'Abrir {tienda}'**
  String actualizacionAbrirTienda(String tienda);

  /// No description provided for @actualizacionAbrir.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get actualizacionAbrir;

  /// No description provided for @actualizacionActualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizacionActualizar;

  /// No description provided for @actualizacionDescargando.
  ///
  /// In es, this message translates to:
  /// **'Descargando {version}'**
  String actualizacionDescargando(String version);

  /// No description provided for @actualizacionCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actualizacionCancelar;

  /// No description provided for @actualizacionComprobando.
  ///
  /// In es, this message translates to:
  /// **'Comprobando la descarga…'**
  String get actualizacionComprobando;

  /// No description provided for @actualizacionReintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actualizacionReintentar;

  /// No description provided for @actualizacionNoSePudoDescargarPunto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar.'**
  String get actualizacionNoSePudoDescargarPunto;

  /// No description provided for @actualizacionNoSePudoDescargar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar'**
  String get actualizacionNoSePudoDescargar;

  /// No description provided for @actualizacionSigues.
  ///
  /// In es, this message translates to:
  /// **'Sigues con la {version}.'**
  String actualizacionSigues(String version);

  /// No description provided for @actualizacionNoSePudoVerificar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar la descarga'**
  String get actualizacionNoSePudoVerificar;

  /// No description provided for @actualizacionLaBorramos.
  ///
  /// In es, this message translates to:
  /// **'La borramos. Sigues con la {version}.'**
  String actualizacionLaBorramos(String version);

  /// No description provided for @actualizacionNoCoincide.
  ///
  /// In es, this message translates to:
  /// **'No coincide con la versión publicada. Para cuidar tu celular, no se instala.'**
  String get actualizacionNoCoincide;

  /// No description provided for @actualizacionNoSeInstalo.
  ///
  /// In es, this message translates to:
  /// **'No se instaló'**
  String get actualizacionNoSeInstalo;

  /// No description provided for @actualizacionCancelaste.
  ///
  /// In es, this message translates to:
  /// **'Cancelaste la instalación.'**
  String get actualizacionCancelaste;

  /// No description provided for @actualizacionFaltaPermiso.
  ///
  /// In es, this message translates to:
  /// **'Falta el permiso de Android'**
  String get actualizacionFaltaPermiso;

  /// No description provided for @actualizacionSinPermiso.
  ///
  /// In es, this message translates to:
  /// **'Sin él no se instala.'**
  String get actualizacionSinPermiso;

  /// No description provided for @actualizacionHayNuevaVersion.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva ({version})'**
  String actualizacionHayNuevaVersion(String version);

  /// No description provided for @actualizacionHayNueva.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva'**
  String get actualizacionHayNueva;

  /// No description provided for @actualizacionAplicacionWeb.
  ///
  /// In es, this message translates to:
  /// **'Aplicación web'**
  String get actualizacionAplicacionWeb;

  /// No description provided for @actualizacionSeActualizo.
  ///
  /// In es, this message translates to:
  /// **'Te Tengo se actualizó'**
  String get actualizacionSeActualizo;

  /// No description provided for @actualizacionVersionPunto.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}.'**
  String actualizacionVersionPunto(String version);

  /// No description provided for @actualizacionObligatoriaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Actualiza Te Tengo para seguir recibiendo alertas'**
  String get actualizacionObligatoriaTitulo;

  /// No description provided for @actualizacionObligatoriaTienes.
  ///
  /// In es, this message translates to:
  /// **'Tienes la {version}. Toma un minuto.'**
  String actualizacionObligatoriaTienes(String version);

  /// No description provided for @actualizacionObligatoriaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Esta versión ya no recibe las alertas de forma segura. Quienes ya actualizaron las siguen recibiendo.'**
  String get actualizacionObligatoriaAyuda;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'por qué actualizar'**
  String get actualizacionObligatoriaTema;

  /// No description provided for @actualizacionAbrirLaTienda.
  ///
  /// In es, this message translates to:
  /// **'Abrir la tienda'**
  String get actualizacionAbrirLaTienda;

  /// No description provided for @actualizacionLlamarA.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {nombre}'**
  String actualizacionLlamarA(String nombre);

  /// No description provided for @actualizacionSeAbre.
  ///
  /// In es, this message translates to:
  /// **'Se abre {tienda}.'**
  String actualizacionSeAbre(String tienda);

  /// No description provided for @actualizacionActualizando.
  ///
  /// In es, this message translates to:
  /// **'Actualizando…'**
  String get actualizacionActualizando;

  /// No description provided for @actualizacionCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get actualizacionCerrar;

  /// No description provided for @actualizacionInstalarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Instalar la actualización'**
  String get actualizacionInstalarTitulo;

  /// Android's own setting label.
  ///
  /// In es, this message translates to:
  /// **'Permitir de esta fuente'**
  String get actualizacionPermitirFuente;

  /// No description provided for @actualizacionPermiteInstalar.
  ///
  /// In es, this message translates to:
  /// **'Permite instalar la actualización'**
  String get actualizacionPermiteInstalar;

  /// No description provided for @actualizacionUnaSolaVez.
  ///
  /// In es, this message translates to:
  /// **'Android lo pide una sola vez.'**
  String get actualizacionUnaSolaVez;

  /// No description provided for @actualizacionPermisoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Te Tengo no viene de una tienda, así que Android pide permiso para instalar sus versiones nuevas. Solo acepta las firmadas por Te Tengo.'**
  String get actualizacionPermisoAyuda;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'el permiso de Android'**
  String get actualizacionPermisoTema;

  /// No description provided for @actualizacionPasoAbrirAjustes.
  ///
  /// In es, this message translates to:
  /// **'Toca «Abrir ajustes».'**
  String get actualizacionPasoAbrirAjustes;

  /// No description provided for @actualizacionPasoActivar.
  ///
  /// In es, this message translates to:
  /// **'Activa «Permitir de esta fuente».'**
  String get actualizacionPasoActivar;

  /// No description provided for @actualizacionPasoVolver.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a Te Tengo.'**
  String get actualizacionPasoVolver;

  /// No description provided for @actualizacionAbrirAjustes.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get actualizacionAbrirAjustes;

  /// No description provided for @actualizacionVersionAnteriorPc.
  ///
  /// In es, this message translates to:
  /// **'Versión anterior ({version})'**
  String actualizacionVersionAnteriorPc(String version);

  /// No description provided for @actualizacionSeActualizaraSola.
  ///
  /// In es, this message translates to:
  /// **'Se actualizará sola.'**
  String get actualizacionSeActualizaraSola;

  /// No description provided for @actualizacionPideActualizar.
  ///
  /// In es, this message translates to:
  /// **'Pide a quien está en la casa que la actualice. '**
  String get actualizacionPideActualizar;

  /// The quoted labels are those of the PC program (Te Tengo Captura), which is in Spanish.
  ///
  /// In es, this message translates to:
  /// **'En la PC aparece «Hay una versión nueva»: que elijan «Descargar». Se instala sola y la detección sigue.'**
  String get actualizacionPcAyuda;

  /// Topic of the «?» button.
  ///
  /// In es, this message translates to:
  /// **'cómo actualizar la PC'**
  String get actualizacionPcTema;

  /// Kind of alert (also the severity tag).
  ///
  /// In es, this message translates to:
  /// **'Caída'**
  String get alertaTipoCaida;

  /// No description provided for @alertaTipoInestable.
  ///
  /// In es, this message translates to:
  /// **'Movimiento inestable'**
  String get alertaTipoInestable;

  /// «Caída en la Sala». sala: the room with its Spanish article; habitacion: the room name as entered.
  ///
  /// In es, this message translates to:
  /// **'{tipo} en {sala}'**
  String alertaTipoEnHabitacion(String tipo, String sala, String habitacion);

  /// Short severity tag.
  ///
  /// In es, this message translates to:
  /// **'Inestable'**
  String get alertaEtiquetaInestable;

  /// State stamp (shown uppercase).
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get alertaSelloAtendida;

  /// No description provided for @alertaSelloFalsaAlarma.
  ///
  /// In es, this message translates to:
  /// **'Falsa alarma'**
  String get alertaSelloFalsaAlarma;

  /// No description provided for @alertaSelloActiva.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get alertaSelloActiva;

  /// No description provided for @alertaCerrarTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar la alerta y volver al inicio'**
  String get alertaCerrarTooltip;

  /// No description provided for @alertaNoContesta.
  ///
  /// In es, this message translates to:
  /// **'¿{nombre} no contesta?'**
  String alertaNoContesta(String nombre);

  /// SAMU · 106 is Peru's emergency service.
  ///
  /// In es, this message translates to:
  /// **'Llamar al SAMU · 106'**
  String get alertaLlamarSamu;

  /// No description provided for @alertaClipTitulo.
  ///
  /// In es, this message translates to:
  /// **'Clip del evento'**
  String get alertaClipTitulo;

  /// No description provided for @alertaClipResumen.
  ///
  /// In es, this message translates to:
  /// **'12 s, antes y después'**
  String get alertaClipResumen;

  /// No description provided for @alertaClipNoGuardado.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar'**
  String get alertaClipNoGuardado;

  /// No description provided for @alertaMasDetalles.
  ///
  /// In es, this message translates to:
  /// **'Más detalles'**
  String get alertaMasDetalles;

  /// No description provided for @alertaMasDetallesResumen.
  ///
  /// In es, this message translates to:
  /// **'Dirección, teléfono, aviso y registro'**
  String get alertaMasDetallesResumen;

  /// No description provided for @alertaMarcar.
  ///
  /// In es, this message translates to:
  /// **'Marcar alerta'**
  String get alertaMarcar;

  /// No description provided for @alertaPorqueInestable.
  ///
  /// In es, this message translates to:
  /// **'No es una caída. Si termina en una, te avisamos.'**
  String get alertaPorqueInestable;

  /// No description provided for @alertaPorqueSeLevanto.
  ///
  /// In es, this message translates to:
  /// **'Se puso de pie. Confirma cómo está antes de marcarla.'**
  String get alertaPorqueSeLevanto;

  /// No description provided for @alertaPorqueConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Lleva más de 30 s en el suelo. Si se levanta, te avisamos.'**
  String get alertaPorqueConfirmada;

  /// No description provided for @alertaPorqueComprobando.
  ///
  /// In es, this message translates to:
  /// **'Si sigue en el suelo 30 s, confirmamos la caída. Si se levanta, te avisamos.'**
  String get alertaPorqueComprobando;

  /// No description provided for @alertaDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get alertaDireccion;

  /// No description provided for @alertaTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get alertaTelefono;

  /// No description provided for @alertaBomberos.
  ///
  /// In es, this message translates to:
  /// **'Bomberos'**
  String get alertaBomberos;

  /// No description provided for @alertaEmpezoInestableTitulo.
  ///
  /// In es, this message translates to:
  /// **'Empezó como movimiento inestable'**
  String get alertaEmpezoInestableTitulo;

  /// hora: formatted time (shown in mono).
  ///
  /// In es, this message translates to:
  /// **'A las {hora} en {sala}. Terminó en caída.'**
  String alertaEmpezoInestableTexto(
    String hora,
    String sala,
    String habitacion,
  );

  /// No description provided for @alertaTeTocaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Te toca atenderla'**
  String get alertaTeTocaTitulo;

  /// No description provided for @alertaTeTocaTexto.
  ///
  /// In es, this message translates to:
  /// **'Nadie la marcó en {espera} min ({hora}).'**
  String alertaTeTocaTexto(int espera, String hora);

  /// No description provided for @alertaAvisamosA.
  ///
  /// In es, this message translates to:
  /// **'Avisamos a {nombre}'**
  String alertaAvisamosA(String nombre);

  /// No description provided for @alertaAvisamosTexto.
  ///
  /// In es, this message translates to:
  /// **'A las {hora}. Tú aún puedes atenderla.'**
  String alertaAvisamosTexto(String hora);

  /// No description provided for @alertaNoHayAQuienTitulo.
  ///
  /// In es, this message translates to:
  /// **'No hay a quién escalar'**
  String get alertaNoHayAQuienTitulo;

  /// No description provided for @alertaSinRespuestaTuya.
  ///
  /// In es, this message translates to:
  /// **'{espera} min sin respuesta. Sigue siendo tuya.'**
  String alertaSinRespuestaTuya(int espera);

  /// No description provided for @alertaSinRespuestaDe.
  ///
  /// In es, this message translates to:
  /// **'{espera} min sin respuesta. Sigue siendo de {nombre}.'**
  String alertaSinRespuestaDe(int espera, String nombre);

  /// No description provided for @alertaAgregarSecundario.
  ///
  /// In es, this message translates to:
  /// **'Agregar contacto secundario'**
  String get alertaAgregarSecundario;

  /// No description provided for @alertaSinSecundarioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin contacto secundario'**
  String get alertaSinSecundarioTitulo;

  /// No description provided for @alertaSinSecundarioTexto.
  ///
  /// In es, this message translates to:
  /// **'Si nadie la atiende, no hay a quién más avisar.'**
  String get alertaSinSecundarioTexto;

  /// No description provided for @alertaAgregarContacto.
  ///
  /// In es, this message translates to:
  /// **'Agregar contacto'**
  String get alertaAgregarContacto;

  /// No description provided for @alertaLimiteSoySecundario.
  ///
  /// In es, this message translates to:
  /// **'{principal} es la principal. Si nadie la marca antes de las {hora}, te avisamos.'**
  String alertaLimiteSoySecundario(String principal, String hora);

  /// No description provided for @alertaLimiteSecundario.
  ///
  /// In es, this message translates to:
  /// **'Si nadie la marca antes de las {hora}, avisamos a {secundario} (secundario).'**
  String alertaLimiteSecundario(String hora, String secundario);

  /// Severity tag, shown uppercase.
  ///
  /// In es, this message translates to:
  /// **'Caída · Urgente'**
  String get alertaEtiquetaCaidaUrgente;

  /// No description provided for @alertaEtiquetaInestableMedia.
  ///
  /// In es, this message translates to:
  /// **'Inestable · Severidad media'**
  String get alertaEtiquetaInestableMedia;

  /// No description provided for @alertaNoTeLlego.
  ///
  /// In es, this message translates to:
  /// **'No te llegó como notificación'**
  String get alertaNoTeLlego;

  /// No description provided for @alertaFalloEnvio.
  ///
  /// In es, this message translates to:
  /// **'Falló el envío; seguimos reintentando.'**
  String get alertaFalloEnvio;

  /// No description provided for @alertaTituloInestable.
  ///
  /// In es, this message translates to:
  /// **'{nombre} tuvo un movimiento inestable'**
  String alertaTituloInestable(String nombre);

  /// No description provided for @alertaTituloEnElSuelo.
  ///
  /// In es, this message translates to:
  /// **'{nombre} se cayó y sigue en el suelo'**
  String alertaTituloEnElSuelo(String nombre);

  /// No description provided for @alertaTituloPudoCaerse.
  ///
  /// In es, this message translates to:
  /// **'{nombre} pudo haberse caído'**
  String alertaTituloPudoCaerse(String nombre);

  /// Elapsed time under «Hace» when under a minute.
  ///
  /// In es, this message translates to:
  /// **'ahora'**
  String get alertaHaceAhora;

  /// No description provided for @alertaHaceMinutos.
  ///
  /// In es, this message translates to:
  /// **'{minutos} min'**
  String alertaHaceMinutos(int minutos);

  /// No description provided for @alertaLlamarA.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {nombre}'**
  String alertaLlamarA(String nombre);

  /// No description provided for @alertaVerEnVivo.
  ///
  /// In es, this message translates to:
  /// **'Ver en vivo'**
  String get alertaVerEnVivo;

  /// No description provided for @alertaSigueEnSueloConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Sigue en el suelo · confirmada'**
  String get alertaSigueEnSueloConfirmada;

  /// No description provided for @alertaComprobando.
  ///
  /// In es, this message translates to:
  /// **'Comprobando si sigue en el suelo'**
  String get alertaComprobando;

  /// No description provided for @alertaSeLevantoALas.
  ///
  /// In es, this message translates to:
  /// **'Se levantó a las {hora}'**
  String alertaSeLevantoALas(String hora);

  /// No description provided for @alertaDatoHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Habitación'**
  String get alertaDatoHabitacion;

  /// No description provided for @alertaDatoHora.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get alertaDatoHora;

  /// Header of the elapsed time.
  ///
  /// In es, this message translates to:
  /// **'Hace'**
  String get alertaDatoHace;

  /// No description provided for @alertaAvisadoPrincipal.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (principal)'**
  String alertaAvisadoPrincipal(String nombre);

  /// No description provided for @alertaLineaLaFamilia.
  ///
  /// In es, this message translates to:
  /// **'la familia'**
  String get alertaLineaLaFamilia;

  /// No description provided for @alertaLineaReintentando.
  ///
  /// In es, this message translates to:
  /// **'No se pudo entregar; reintentando'**
  String get alertaLineaReintentando;

  /// No description provided for @alertaLineaNoEntregada.
  ///
  /// In es, this message translates to:
  /// **'No se pudo entregar'**
  String get alertaLineaNoEntregada;

  /// No description provided for @alertaLineaAviso.
  ///
  /// In es, this message translates to:
  /// **'Aviso a {avisados} · {segundos} s'**
  String alertaLineaAviso(String avisados, int segundos);

  /// No description provided for @alertaLineaConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Sigue en el suelo: confirmada'**
  String get alertaLineaConfirmada;

  /// No description provided for @alertaLineaSeLevanto.
  ///
  /// In es, this message translates to:
  /// **'{nombre} se levantó'**
  String alertaLineaSeLevanto(String nombre);

  /// No description provided for @alertaLineaEscaladaA.
  ///
  /// In es, this message translates to:
  /// **'Sin respuesta en {espera} min: aviso a {nombre} (secundario)'**
  String alertaLineaEscaladaA(int espera, String nombre);

  /// No description provided for @alertaLineaSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'Sin respuesta en {espera} min y sin secundario'**
  String alertaLineaSinSecundario(int espera);

  /// No description provided for @alertaLineaAtendidaPor.
  ///
  /// In es, this message translates to:
  /// **'Atendida por {nombre}'**
  String alertaLineaAtendidaPor(String nombre);

  /// No description provided for @alertaLineaAntesDeEscalar.
  ///
  /// In es, this message translates to:
  /// **'Atendida antes de {espera} min: sin escalar'**
  String alertaLineaAntesDeEscalar(int espera);

  /// No description provided for @alertaLineaFalsaAlarma.
  ///
  /// In es, this message translates to:
  /// **'Falsa alarma, marcada por {nombre}'**
  String alertaLineaFalsaAlarma(String nombre);

  /// No description provided for @alertaMarcadaFalsa.
  ///
  /// In es, this message translates to:
  /// **'Marcada como falsa alarma'**
  String get alertaMarcadaFalsa;

  /// No description provided for @alertaAtendidaToast.
  ///
  /// In es, this message translates to:
  /// **'Alerta atendida'**
  String get alertaAtendidaToast;

  /// No description provided for @alertaToastFamiliaVera.
  ///
  /// In es, this message translates to:
  /// **'La familia verá que la marcaste a las {hora}.'**
  String alertaToastFamiliaVera(String hora);

  /// No description provided for @alertaMarcarPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo terminó esta alerta?'**
  String get alertaMarcarPregunta;

  /// No description provided for @alertaMarcarResumen.
  ///
  /// In es, this message translates to:
  /// **'{tipo} en {sala} a las {hora}.'**
  String alertaMarcarResumen(
    String tipo,
    String sala,
    String hora,
    String habitacion,
  );

  /// No description provided for @alertaOpcionAtendida.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get alertaOpcionAtendida;

  /// No description provided for @alertaOpcionAtendidaDetalle.
  ///
  /// In es, this message translates to:
  /// **'{nombre} recibió ayuda o está bien'**
  String alertaOpcionAtendidaDetalle(String nombre);

  /// No description provided for @alertaOpcionFalsa.
  ///
  /// In es, this message translates to:
  /// **'Falsa alarma'**
  String get alertaOpcionFalsa;

  /// No description provided for @alertaOpcionFalsaCaida.
  ///
  /// In es, this message translates to:
  /// **'No hubo caída.'**
  String get alertaOpcionFalsaCaida;

  /// No description provided for @alertaOpcionFalsaInestable.
  ///
  /// In es, this message translates to:
  /// **'No hubo movimiento inestable.'**
  String get alertaOpcionFalsaInestable;

  /// No description provided for @alertaEligeOpcion.
  ///
  /// In es, this message translates to:
  /// **'Elige una opción.'**
  String get alertaEligeOpcion;

  /// No description provided for @alertaQuedaraRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Quedará registrado: {quien} · {hora}'**
  String alertaQuedaraRegistrado(String quien, String hora);

  /// No description provided for @alertaGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get alertaGuardar;

  /// No description provided for @alertaDetalleTitulo.
  ///
  /// In es, this message translates to:
  /// **'Alerta'**
  String get alertaDetalleTitulo;

  /// No description provided for @alertaDetalleTituloFecha.
  ///
  /// In es, this message translates to:
  /// **'Alerta del {fecha}'**
  String alertaDetalleTituloFecha(String fecha);

  /// No description provided for @alertaGrabacion.
  ///
  /// In es, this message translates to:
  /// **'Grabación'**
  String get alertaGrabacion;

  /// No description provided for @alertaVerQuePaso.
  ///
  /// In es, this message translates to:
  /// **'Ver qué pasó'**
  String get alertaVerQuePaso;

  /// No description provided for @alertaVerQuePasoSinVideo.
  ///
  /// In es, this message translates to:
  /// **'En la cámara, sin video'**
  String get alertaVerQuePasoSinVideo;

  /// No description provided for @alertaVerQuePasoRequiere.
  ///
  /// In es, this message translates to:
  /// **'Requiere guardar movimientos'**
  String get alertaVerQuePasoRequiere;

  /// No description provided for @alertaRegistroEvento.
  ///
  /// In es, this message translates to:
  /// **'Registro del evento'**
  String get alertaRegistroEvento;

  /// No description provided for @alertaMomentos.
  ///
  /// In es, this message translates to:
  /// **'{n} momentos'**
  String alertaMomentos(int n);

  /// No description provided for @alertaTerminoEnCaida.
  ///
  /// In es, this message translates to:
  /// **'¿Terminó en caída y no avisamos?'**
  String get alertaTerminoEnCaida;

  /// No description provided for @alertaMarcadaAtendida.
  ///
  /// In es, this message translates to:
  /// **'Marcada como atendida'**
  String get alertaMarcadaAtendida;

  /// No description provided for @alertaMarcadaPor.
  ///
  /// In es, this message translates to:
  /// **'por {nombre} a las {hora}'**
  String alertaMarcadaPor(String nombre, String hora);

  /// No description provided for @alertaGrabacionDescargada.
  ///
  /// In es, this message translates to:
  /// **'Grabación descargada'**
  String get alertaGrabacionDescargada;

  /// No description provided for @alertaGrabacionEnArchivos.
  ///
  /// In es, this message translates to:
  /// **'{archivo} en Archivos'**
  String alertaGrabacionEnArchivos(String archivo);

  /// No description provided for @alertaDescargarGrabacion.
  ///
  /// In es, this message translates to:
  /// **'Descargar grabación'**
  String get alertaDescargarGrabacion;

  /// No description provided for @alertaDescargaDetalle.
  ///
  /// In es, this message translates to:
  /// **'MP4 · 12 s · hasta el {fecha}'**
  String alertaDescargaDetalle(String fecha);

  /// No description provided for @clipBorradoTitulo.
  ///
  /// In es, this message translates to:
  /// **'La grabación ya no está disponible'**
  String get clipBorradoTitulo;

  /// No description provided for @clipBorradoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Se borró el {fecha} (se guardan 30 días).'**
  String clipBorradoDetalle(String fecha);

  /// No description provided for @clipNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Clip no disponible'**
  String get clipNoDisponible;

  /// No description provided for @clipSigueValida.
  ///
  /// In es, this message translates to:
  /// **'La alerta sigue siendo válida.'**
  String get clipSigueValida;

  /// No description provided for @clipPantallaCompleta.
  ///
  /// In es, this message translates to:
  /// **'Ver el clip en pantalla completa'**
  String get clipPantallaCompleta;

  /// No description provided for @clipAyuda.
  ///
  /// In es, this message translates to:
  /// **'El clip dura 12 s: 6 s antes y 6 s después de la alerta.'**
  String get clipAyuda;

  /// Topic of the «?» help button: «Más información: el clip».
  ///
  /// In es, this message translates to:
  /// **'el clip'**
  String get clipAyudaTema;

  /// No description provided for @clipSalirPantallaCompleta.
  ///
  /// In es, this message translates to:
  /// **'Salir de pantalla completa'**
  String get clipSalirPantallaCompleta;

  /// Reason after «No disponibles:».
  ///
  /// In es, this message translates to:
  /// **'falta el permiso de {nombre} para guardar movimientos'**
  String clipPuntosSinPermiso(String nombre);

  /// No description provided for @clipPuntosNoLosTiene.
  ///
  /// In es, this message translates to:
  /// **'este clip no los tiene'**
  String get clipPuntosNoLosTiene;

  /// No description provided for @clipPuntosNoCargaron.
  ///
  /// In es, this message translates to:
  /// **'no se pudieron cargar'**
  String get clipPuntosNoCargaron;

  /// No description provided for @clipPuntosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Puntos del cuerpo'**
  String get clipPuntosTitulo;

  /// No description provided for @clipPuntosNoDisponibles.
  ///
  /// In es, this message translates to:
  /// **'No disponibles: {motivo}.'**
  String clipPuntosNoDisponibles(String motivo);

  /// No description provided for @clipPausar.
  ///
  /// In es, this message translates to:
  /// **'Pausar clip'**
  String get clipPausar;

  /// No description provided for @clipVolverAVer.
  ///
  /// In es, this message translates to:
  /// **'Volver a ver el clip'**
  String get clipVolverAVer;

  /// No description provided for @clipReproducir.
  ///
  /// In es, this message translates to:
  /// **'Reproducir clip'**
  String get clipReproducir;

  /// No description provided for @clipRetroceder.
  ///
  /// In es, this message translates to:
  /// **'Retroceder 5 segundos'**
  String get clipRetroceder;

  /// No description provided for @clipAdelantar.
  ///
  /// In es, this message translates to:
  /// **'Adelantar 5 segundos'**
  String get clipAdelantar;

  /// No description provided for @clipVelocidad.
  ///
  /// In es, this message translates to:
  /// **'Velocidad {velocidad}. Cambiar la velocidad'**
  String clipVelocidad(String velocidad);

  /// No description provided for @clipAvance.
  ///
  /// In es, this message translates to:
  /// **'Avance del clip'**
  String get clipAvance;

  /// No description provided for @clipMomentoEvento.
  ///
  /// In es, this message translates to:
  /// **'Momento del evento'**
  String get clipMomentoEvento;

  /// No description provided for @repeticionEventoCaida.
  ///
  /// In es, this message translates to:
  /// **'Caída'**
  String get repeticionEventoCaida;

  /// No description provided for @repeticionEventoInestable.
  ///
  /// In es, this message translates to:
  /// **'Inestable'**
  String get repeticionEventoInestable;

  /// No description provided for @repeticionEventoLevanto.
  ///
  /// In es, this message translates to:
  /// **'Se levantó'**
  String get repeticionEventoLevanto;

  /// No description provided for @repeticionSinDatos.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get repeticionSinDatos;

  /// No description provided for @repeticionFaseLevanto.
  ///
  /// In es, this message translates to:
  /// **'Se levantó'**
  String get repeticionFaseLevanto;

  /// No description provided for @repeticionFaseInestable.
  ///
  /// In es, this message translates to:
  /// **'Movimiento inestable'**
  String get repeticionFaseInestable;

  /// No description provided for @repeticionFasePosibleCaida.
  ///
  /// In es, this message translates to:
  /// **'Posible caída'**
  String get repeticionFasePosibleCaida;

  /// No description provided for @repeticionFaseEnSuelo.
  ///
  /// In es, this message translates to:
  /// **'En el suelo'**
  String get repeticionFaseEnSuelo;

  /// No description provided for @repeticionNoMasEventosDia.
  ///
  /// In es, this message translates to:
  /// **'No hay más eventos este día'**
  String get repeticionNoMasEventosDia;

  /// No description provided for @repeticionNoMasEventos.
  ///
  /// In es, this message translates to:
  /// **'No hay más eventos'**
  String get repeticionNoMasEventos;

  /// No description provided for @repeticionNoEventosAntes.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos antes'**
  String get repeticionNoEventosAntes;

  /// No description provided for @repeticionHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get repeticionHoy;

  /// No description provided for @repeticionAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get repeticionAyer;

  /// No description provided for @repeticionVerEnVivo.
  ///
  /// In es, this message translates to:
  /// **'Ver {habitacion} en vivo'**
  String repeticionVerEnVivo(String habitacion);

  /// No description provided for @repeticionEnVivo.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get repeticionEnVivo;

  /// No description provided for @repeticionCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get repeticionCargando;

  /// No description provided for @repeticionSinInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get repeticionSinInternet;

  /// No description provided for @repeticionPermisoRetirado.
  ///
  /// In es, this message translates to:
  /// **'{nombre} retiró el permiso. Se borraron sus movimientos.'**
  String repeticionPermisoRetirado(String nombre);

  /// No description provided for @repeticionSinPersona.
  ///
  /// In es, this message translates to:
  /// **'Sin persona en la imagen'**
  String get repeticionSinPersona;

  /// No description provided for @repeticionIrAEvento.
  ///
  /// In es, this message translates to:
  /// **'{hora}, {evento}. Ir a este momento'**
  String repeticionIrAEvento(String hora, String evento);

  /// No description provided for @repeticionMomento.
  ///
  /// In es, this message translates to:
  /// **'Momento de la repetición'**
  String get repeticionMomento;

  /// No description provided for @repeticionEventoAnterior.
  ///
  /// In es, this message translates to:
  /// **'Evento anterior'**
  String get repeticionEventoAnterior;

  /// No description provided for @repeticionRetroceder.
  ///
  /// In es, this message translates to:
  /// **'Retroceder 10 segundos'**
  String get repeticionRetroceder;

  /// No description provided for @repeticionPausar.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get repeticionPausar;

  /// No description provided for @repeticionReproducir.
  ///
  /// In es, this message translates to:
  /// **'Reproducir'**
  String get repeticionReproducir;

  /// No description provided for @repeticionEventoSiguiente.
  ///
  /// In es, this message translates to:
  /// **'Evento siguiente'**
  String get repeticionEventoSiguiente;

  /// No description provided for @repeticionAdelantar.
  ///
  /// In es, this message translates to:
  /// **'Adelantar 10 segundos'**
  String get repeticionAdelantar;

  /// No description provided for @repeticionElegirDia.
  ///
  /// In es, this message translates to:
  /// **'Elegir día'**
  String get repeticionElegirDia;

  /// No description provided for @repeticionHayMovimientosDesde.
  ///
  /// In es, this message translates to:
  /// **'Hay movimientos desde el {fecha}.'**
  String repeticionHayMovimientosDesde(String fecha);

  /// No description provided for @repeticionConEventos.
  ///
  /// In es, this message translates to:
  /// **'Con eventos'**
  String get repeticionConEventos;

  /// No description provided for @repeticionDiaSinMovimientos.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, sin movimientos'**
  String repeticionDiaSinMovimientos(String fecha);

  /// No description provided for @repeticionDiaConEventos.
  ///
  /// In es, this message translates to:
  /// **'{fecha}, con eventos'**
  String repeticionDiaConEventos(String fecha);

  /// No description provided for @reportesEnlace.
  ///
  /// In es, this message translates to:
  /// **'¿Hubo una caída y no avisó?'**
  String get reportesEnlace;

  /// Room chip when the room is unknown.
  ///
  /// In es, this message translates to:
  /// **'No sé'**
  String get reportesNoSe;

  /// The field takes a 24-hour HH:MM time.
  ///
  /// In es, this message translates to:
  /// **'Escribe la hora así: 07:30.'**
  String get reportesHoraFormato;

  /// No description provided for @reportesHoraFutura.
  ///
  /// In es, this message translates to:
  /// **'Elige una hora que ya pasó.'**
  String get reportesHoraFutura;

  /// No description provided for @reportesFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get reportesFecha;

  /// No description provided for @reportesHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get reportesHoy;

  /// No description provided for @reportesAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get reportesAyer;

  /// No description provided for @reportesHoraAproximada.
  ///
  /// In es, this message translates to:
  /// **'Hora aproximada'**
  String get reportesHoraAproximada;

  /// No description provided for @reportesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Contarnos qué pasó'**
  String get reportesTitulo;

  /// No description provided for @reportesSamuConNombre.
  ///
  /// In es, this message translates to:
  /// **'Si {nombre} necesita ayuda ahora, llama al SAMU · 106'**
  String reportesSamuConNombre(String nombre);

  /// No description provided for @reportesSamu.
  ///
  /// In es, this message translates to:
  /// **'Si necesita ayuda ahora, llama al SAMU · 106'**
  String get reportesSamu;

  /// No description provided for @reportesLlamarSamu.
  ///
  /// In es, this message translates to:
  /// **'Llamar al SAMU · 106'**
  String get reportesLlamarSamu;

  /// No description provided for @reportesPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Hubo una caída y no te avisamos?'**
  String get reportesPregunta;

  /// No description provided for @reportesRevisaremos.
  ///
  /// In es, this message translates to:
  /// **'Lo revisaremos para mejorar la detección.'**
  String get reportesRevisaremos;

  /// No description provided for @reportesHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Habitación'**
  String get reportesHabitacion;

  /// No description provided for @reportesEligeHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Elige la habitación o «No sé».'**
  String get reportesEligeHabitacion;

  /// No description provided for @reportesQuePaso.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasó? (opcional)'**
  String get reportesQuePaso;

  /// No description provided for @reportesNotaEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Se resbaló al salir de la cama'**
  String get reportesNotaEjemplo;

  /// No description provided for @reportesEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get reportesEnviar;

  /// No description provided for @reportesEnviando.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get reportesEnviando;

  /// No description provided for @reportesMovimientosHay.
  ///
  /// In es, this message translates to:
  /// **'Revisaremos los movimientos de ese momento.'**
  String get reportesMovimientosHay;

  /// No description provided for @reportesMovimientosNo.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos de ese momento; revisaremos tu relato.'**
  String get reportesMovimientosNo;

  /// No description provided for @reportesGuardado.
  ///
  /// In es, this message translates to:
  /// **'Lo guardamos para enviarlo'**
  String get reportesGuardado;

  /// No description provided for @reportesGracias.
  ///
  /// In es, this message translates to:
  /// **'Gracias. Lo revisaremos.'**
  String get reportesGracias;

  /// No description provided for @reportesGraciasNombre.
  ///
  /// In es, this message translates to:
  /// **'Gracias, {nombre}. Lo revisaremos.'**
  String reportesGraciasNombre(String nombre);

  /// No description provided for @reportesNoPudimosTitulo.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviarlo'**
  String get reportesNoPudimosTitulo;

  /// No description provided for @reportesNoPudimosTexto.
  ///
  /// In es, this message translates to:
  /// **'Lo guardamos y lo enviaremos cuando vuelva la conexión.'**
  String get reportesNoPudimosTexto;

  /// No description provided for @reportesNoGeneraAlerta.
  ///
  /// In es, this message translates to:
  /// **'Esto no genera una alerta ni avisa a la familia.'**
  String get reportesNoGeneraAlerta;

  /// No description provided for @reportesVolverHistorial.
  ///
  /// In es, this message translates to:
  /// **'Volver al historial'**
  String get reportesVolverHistorial;

  /// App name (brand, never translated).
  ///
  /// In es, this message translates to:
  /// **'Te Tengo'**
  String get appTitulo;

  /// Camera state.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get camaraEstadoEnLinea;

  /// Camera state: the camera is unplugged.
  ///
  /// In es, this message translates to:
  /// **'Desconectada'**
  String get camaraEstadoDesconectada;

  /// Camera state.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get camaraEstadoEnPausa;

  /// Camera state.
  ///
  /// In es, this message translates to:
  /// **'Detección no confiable'**
  String get camaraEstadoNoConfiable;

  /// Camera state: stopped because there is no consent.
  ///
  /// In es, this message translates to:
  /// **'Detenida'**
  String get camaraEstadoDetenida;

  /// Camera state: the camera's PC does not answer.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get camaraEstadoSinConexion;

  /// No description provided for @camaraPausa30Min.
  ///
  /// In es, this message translates to:
  /// **'30 minutos'**
  String get camaraPausa30Min;

  /// No description provided for @camaraPausa1Hora.
  ///
  /// In es, this message translates to:
  /// **'1 hora'**
  String get camaraPausa1Hora;

  /// No description provided for @camaraPausa2Horas.
  ///
  /// In es, this message translates to:
  /// **'2 horas'**
  String get camaraPausa2Horas;

  /// No description provided for @camaraPausaHastaManana.
  ///
  /// In es, this message translates to:
  /// **'Hasta mañana'**
  String get camaraPausaHastaManana;

  /// When a pause ends (lowercase, under the option).
  ///
  /// In es, this message translates to:
  /// **'hasta las {hora}'**
  String camaraPausaFinHasta(String hora);

  /// «Hasta mañana» ends at this time (lowercase).
  ///
  /// In es, this message translates to:
  /// **'a las {hora}'**
  String camaraPausaFinALas(String hora);

  /// A pause that ends tomorrow.
  ///
  /// In es, this message translates to:
  /// **'{hora} de mañana'**
  String camaraFinDePausaManana(String hora);

  /// Spanish gets the room with its article («la Sala»); English gets the bare room name.
  ///
  /// In es, this message translates to:
  /// **'en {habitacion}'**
  String camaraEnHabitacion(String habitacion);

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'Cámara {habitacion} reactivada'**
  String camaraReactivadaTitulo(String habitacion);

  /// No description provided for @camaraReactivadaTexto.
  ///
  /// In es, this message translates to:
  /// **'La detección y la vista en vivo vuelven a estar disponibles.'**
  String get camaraReactivadaTexto;

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'Cámara {habitacion} en pausa'**
  String camaraEnPausaTitulo(String habitacion);

  /// No description provided for @camaraSeReactivaraALas.
  ///
  /// In es, this message translates to:
  /// **'Se reactivará sola a las {hora}.'**
  String camaraSeReactivaraALas(String hora);

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'Pausar la cámara {habitacion}'**
  String camaraPausarTitulo(String habitacion);

  /// No description provided for @camaraPausarTexto.
  ///
  /// In es, this message translates to:
  /// **'Sin detección ni vista en vivo. Se reactiva sola.'**
  String get camaraPausarTexto;

  /// No description provided for @camaraPausar.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get camaraPausar;

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'La cámara {habitacion} se desconectó'**
  String camaraAvisoDesconectadaTitulo(String habitacion);

  /// No description provided for @camaraAvisoDesconectadaTexto.
  ///
  /// In es, this message translates to:
  /// **'Revisa el cable de la cámara, que la PC esté encendida y el internet de la casa.'**
  String get camaraAvisoDesconectadaTexto;

  /// No description provided for @camaraAvisoReconectadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'La cámara {habitacion} volvió a estar en línea'**
  String camaraAvisoReconectadaTitulo(String habitacion);

  /// No description provided for @camaraAvisoReconectadaTexto.
  ///
  /// In es, this message translates to:
  /// **'El monitoreo se restableció a las {hora}.'**
  String camaraAvisoReconectadaTexto(String hora);

  /// No description provided for @camaraAvisoReactivadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'La cámara {habitacion} se reactivó'**
  String camaraAvisoReactivadaTitulo(String habitacion);

  /// No description provided for @camaraAvisoReactivadaTexto.
  ///
  /// In es, this message translates to:
  /// **'Terminó la pausa a las {hora}.'**
  String camaraAvisoReactivadaTexto(String hora);

  /// «en la Sala» / «in Sala».
  ///
  /// In es, this message translates to:
  /// **'La detección no es confiable {enHabitacion}'**
  String camaraAvisoNoConfiableTitulo(String enHabitacion);

  /// No description provided for @camaraAvisoNoConfiableTexto.
  ///
  /// In es, this message translates to:
  /// **'Hace más de 5 minutos que la cámara no ve bien a {nombre}. Revisa la luz y el encuadre.'**
  String camaraAvisoNoConfiableTexto(String nombre);

  /// No description provided for @camaraFavorita.
  ///
  /// In es, this message translates to:
  /// **'Favorita'**
  String get camaraFavorita;

  /// No description provided for @camaraFavoritaDe.
  ///
  /// In es, this message translates to:
  /// **'Favorita: {habitacion}'**
  String camaraFavoritaDe(String habitacion);

  /// Followed by a time in another font.
  ///
  /// In es, this message translates to:
  /// **'última señal '**
  String get camaraUltimaSenalPrefijo;

  /// Followed by a time in another font.
  ///
  /// In es, this message translates to:
  /// **'desde las '**
  String get camaraDesdeLasPrefijo;

  /// No description provided for @camaraHastaLas.
  ///
  /// In es, this message translates to:
  /// **'hasta las {hora}'**
  String camaraHastaLas(String hora);

  /// No description provided for @camaraRevisaLuzEncuadre.
  ///
  /// In es, this message translates to:
  /// **'revisa la luz y el encuadre'**
  String get camaraRevisaLuzEncuadre;

  /// No description provided for @camaraSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'sin consentimiento'**
  String get camaraSinConsentimiento;

  /// No description provided for @camaraPcNoResponde.
  ///
  /// In es, this message translates to:
  /// **'la PC no responde'**
  String get camaraPcNoResponde;

  /// No description provided for @camaraHaceSegundos.
  ///
  /// In es, this message translates to:
  /// **'hace {n} s'**
  String camaraHaceSegundos(int n);

  /// No description provided for @camaraHaceMinutos.
  ///
  /// In es, this message translates to:
  /// **'hace {n} min'**
  String camaraHaceMinutos(int n);

  /// No description provided for @camaraHaceHoras.
  ///
  /// In es, this message translates to:
  /// **'hace {n} h'**
  String camaraHaceHoras(int n);

  /// No description provided for @camarasOrdenar.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get camarasOrdenar;

  /// No description provided for @camarasListo.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get camarasListo;

  /// No description provided for @camarasOrdenarTexto.
  ///
  /// In es, this message translates to:
  /// **'Favoritas primero. Solo en este celular.'**
  String get camarasOrdenarTexto;

  /// No description provided for @camarasFavoritas.
  ///
  /// In es, this message translates to:
  /// **'Favoritas'**
  String get camarasFavoritas;

  /// No description provided for @camarasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cámaras'**
  String get camarasTitulo;

  /// No description provided for @camarasLasDemas.
  ///
  /// In es, this message translates to:
  /// **'Las demás'**
  String get camarasLasDemas;

  /// No description provided for @camarasArrastrar.
  ///
  /// In es, this message translates to:
  /// **'Arrastrar {habitacion}'**
  String camarasArrastrar(String habitacion);

  /// No description provided for @camarasSubir.
  ///
  /// In es, this message translates to:
  /// **'Subir {habitacion}'**
  String camarasSubir(String habitacion);

  /// No description provided for @camarasBajar.
  ///
  /// In es, this message translates to:
  /// **'Bajar {habitacion}'**
  String camarasBajar(String habitacion);

  /// No description provided for @camaraNombreOcupada.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una cámara {enHabitacion}. Por ahora, cada habitación usa una sola cámara.'**
  String camaraNombreOcupada(String enHabitacion);

  /// No description provided for @camaraNombreVacio.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de la habitación.'**
  String get camaraNombreVacio;

  /// No description provided for @camaraNombreBano.
  ///
  /// In es, this message translates to:
  /// **'Por privacidad, Te Tengo no admite cámaras en el baño.'**
  String get camaraNombreBano;

  /// No description provided for @camaraNombreGuardado.
  ///
  /// In es, this message translates to:
  /// **'Nombre guardado: {nombre}'**
  String camaraNombreGuardado(String nombre);

  /// No description provided for @camaraNombreProximasAlertas.
  ///
  /// In es, this message translates to:
  /// **'Las próximas alertas dirán «{enHabitacion}».'**
  String camaraNombreProximasAlertas(String enHabitacion);

  /// No description provided for @camaraNombreTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la habitación'**
  String get camaraNombreTitulo;

  /// No description provided for @camaraNombreMarcador.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Sala comedor'**
  String get camaraNombreMarcador;

  /// No description provided for @camaraNombreSugerencias.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias'**
  String get camaraNombreSugerencias;

  /// No description provided for @camaraNombreYaTienen.
  ///
  /// In es, this message translates to:
  /// **'Las que ya tienen cámara no se pueden elegir.'**
  String get camaraNombreYaTienen;

  /// No description provided for @camaraNombreAsiSeVera.
  ///
  /// In es, this message translates to:
  /// **'Así se verá en las próximas alertas'**
  String get camaraNombreAsiSeVera;

  /// No description provided for @camaraNombrePosibleCaidaVacia.
  ///
  /// In es, this message translates to:
  /// **'Posible caída …'**
  String get camaraNombrePosibleCaidaVacia;

  /// No description provided for @camaraNombrePosibleCaida.
  ///
  /// In es, this message translates to:
  /// **'Posible caída {enHabitacion}'**
  String camaraNombrePosibleCaida(String enHabitacion);

  /// No description provided for @camaraNombreAnteriores.
  ///
  /// In es, this message translates to:
  /// **'Las alertas anteriores no cambian.'**
  String get camaraNombreAnteriores;

  /// No description provided for @camaraNombreGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar nombre'**
  String get camaraNombreGuardar;

  /// No description provided for @camaraTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camaraTitulo;

  /// No description provided for @camaraAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de la cámara'**
  String get camaraAjustes;

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'Repetición {habitacion} · {duracion}'**
  String camaraRepeticionAcceso(String habitacion, String duracion);

  /// No description provided for @camaraPcNoRespondeMotivo.
  ///
  /// In es, this message translates to:
  /// **'La PC no responde'**
  String get camaraPcNoRespondeMotivo;

  /// No description provided for @camaraDesconectadaMotivo.
  ///
  /// In es, this message translates to:
  /// **'Cámara desconectada'**
  String get camaraDesconectadaMotivo;

  /// No description provided for @camaraActivar.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get camaraActivar;

  /// No description provided for @camaraSoloTitularActiva.
  ///
  /// In es, this message translates to:
  /// **'Solo {nombre} puede activarlo'**
  String camaraSoloTitularActiva(String nombre);

  /// No description provided for @camaraDetenidaSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Detenida: falta el consentimiento'**
  String get camaraDetenidaSinConsentimiento;

  /// No description provided for @camaraRegistrarConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Registrar consentimiento'**
  String get camaraRegistrarConsentimiento;

  /// No description provided for @camaraSinInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get camaraSinInternet;

  /// No description provided for @camaraActivaGuardarMovimientos.
  ///
  /// In es, this message translates to:
  /// **'Para ver lo que pasó, activa Guardar movimientos'**
  String get camaraActivaGuardarMovimientos;

  /// No description provided for @camaraActivaNube.
  ///
  /// In es, this message translates to:
  /// **'Para ver lo que pasó, activa Movimientos en la nube'**
  String get camaraActivaNube;

  /// No description provided for @camaraNoHayMovimientos.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos del {dia}. Hay desde el {desde}.'**
  String camaraNoHayMovimientos(String dia, String desde);

  /// No description provided for @camaraVerLoUltimo.
  ///
  /// In es, this message translates to:
  /// **'Ver lo último'**
  String get camaraVerLoUltimo;

  /// No description provided for @camaraCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get camaraCargando;

  /// No description provided for @camaraAyudaPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Solo puntos del cuerpo, nunca video. Cada repetición queda en el registro de accesos.'**
  String get camaraAyudaPrivacidad;

  /// No description provided for @camaraAjustesResumen.
  ///
  /// In es, this message translates to:
  /// **'Pausa, nombre, registro'**
  String get camaraAjustesResumen;

  /// No description provided for @camaraRevisarCable.
  ///
  /// In es, this message translates to:
  /// **'El cable USB de la cámara'**
  String get camaraRevisarCable;

  /// No description provided for @camaraRevisarPc.
  ///
  /// In es, this message translates to:
  /// **'La PC encendida'**
  String get camaraRevisarPc;

  /// No description provided for @camaraRevisarPcDetalle.
  ///
  /// In es, this message translates to:
  /// **'Con Te Tengo Captura abierto'**
  String get camaraRevisarPcDetalle;

  /// No description provided for @camaraRevisarInternet.
  ///
  /// In es, this message translates to:
  /// **'El internet de la casa'**
  String get camaraRevisarInternet;

  /// No description provided for @camaraRevisarLuz.
  ///
  /// In es, this message translates to:
  /// **'La luz'**
  String get camaraRevisarLuz;

  /// No description provided for @camaraRevisarLuzDetalle.
  ///
  /// In es, this message translates to:
  /// **'De noche, una lámpara pequeña'**
  String get camaraRevisarLuzDetalle;

  /// No description provided for @camaraRevisarEncuadre.
  ///
  /// In es, this message translates to:
  /// **'El encuadre'**
  String get camaraRevisarEncuadre;

  /// No description provided for @camaraRevisarEncuadreDetalle.
  ///
  /// In es, this message translates to:
  /// **'Que se vea a {nombre} de cuerpo entero'**
  String camaraRevisarEncuadreDetalle(String nombre);

  /// No description provided for @camaraQueRevisar.
  ///
  /// In es, this message translates to:
  /// **'Qué revisar'**
  String get camaraQueRevisar;

  /// No description provided for @camaraHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get camaraHoy;

  /// No description provided for @camaraAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get camaraAyer;

  /// No description provided for @camaraElegirDia.
  ///
  /// In es, this message translates to:
  /// **'Elegir día…'**
  String get camaraElegirDia;

  /// No description provided for @camara10Min.
  ///
  /// In es, this message translates to:
  /// **'10 min'**
  String get camara10Min;

  /// No description provided for @camara1Hora.
  ///
  /// In es, this message translates to:
  /// **'1 hora'**
  String get camara1Hora;

  /// No description provided for @camaraSoloEventos.
  ///
  /// In es, this message translates to:
  /// **'Solo eventos'**
  String get camaraSoloEventos;

  /// No description provided for @camaraEventosDe.
  ///
  /// In es, this message translates to:
  /// **'Eventos · {dia}'**
  String camaraEventosDe(String dia);

  /// No description provided for @camaraSinEventosHoy.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos hoy'**
  String get camaraSinEventosHoy;

  /// No description provided for @camaraSinEventosAyer.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos ayer'**
  String get camaraSinEventosAyer;

  /// No description provided for @camaraSinEventosEl.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos el {dia}'**
  String camaraSinEventosEl(String dia);

  /// No description provided for @camaraUltimosEventos.
  ///
  /// In es, this message translates to:
  /// **'Últimos eventos'**
  String get camaraUltimosEventos;

  /// No description provided for @camaraCaida.
  ///
  /// In es, this message translates to:
  /// **'Caída'**
  String get camaraCaida;

  /// No description provided for @camaraInestable.
  ///
  /// In es, this message translates to:
  /// **'Inestable'**
  String get camaraInestable;

  /// No description provided for @camaraReanudarAhora.
  ///
  /// In es, this message translates to:
  /// **'Reanudar ahora'**
  String get camaraReanudarAhora;

  /// No description provided for @camaraEnPausaHastaLas.
  ///
  /// In es, this message translates to:
  /// **'En pausa hasta las {hora}'**
  String camaraEnPausaHastaLas(String hora);

  /// No description provided for @camaraSinDeteccionNiVivo.
  ///
  /// In es, this message translates to:
  /// **'Sin detección ni vista en vivo'**
  String get camaraSinDeteccionNiVivo;

  /// No description provided for @camaraNombreDe.
  ///
  /// In es, this message translates to:
  /// **'Nombre: {habitacion}'**
  String camaraNombreDe(String habitacion);

  /// No description provided for @camaraPcNombre.
  ///
  /// In es, this message translates to:
  /// **'PC {nombre}'**
  String camaraPcNombre(String nombre);

  /// No description provided for @camaraPcDeLaCasa.
  ///
  /// In es, this message translates to:
  /// **'PC de la casa'**
  String get camaraPcDeLaCasa;

  /// No description provided for @camaraDesdeElFecha.
  ///
  /// In es, this message translates to:
  /// **'desde el {fecha}'**
  String camaraDesdeElFecha(String fecha);

  /// No description provided for @camaraHuboCaida.
  ///
  /// In es, this message translates to:
  /// **'¿Hubo una caída y no avisó?'**
  String get camaraHuboCaida;

  /// No description provided for @camaraDejarDeUsar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de usar esta cámara'**
  String get camaraDejarDeUsar;

  /// Names a camera without a device name, as in «¿Dejar de usar la cámara de la Sala?».
  ///
  /// In es, this message translates to:
  /// **'de la {habitacion}'**
  String camaraDispositivoDeHabitacion(String habitacion);

  /// No description provided for @camaraDesconectadaDesde.
  ///
  /// In es, this message translates to:
  /// **'Desconectada desde las {hora}'**
  String camaraDesconectadaDesde(String hora);

  /// No description provided for @camaraSinConexionDesde.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión desde las {hora}'**
  String camaraSinConexionDesde(String hora);

  /// No description provided for @accesosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Registro de accesos'**
  String get accesosTitulo;

  /// No description provided for @accesosRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Acceso registrado'**
  String get accesosRegistrado;

  /// No description provided for @accesosIntro.
  ///
  /// In es, this message translates to:
  /// **'Quién miró, cuándo y cuánto. Toda la familia lo ve.'**
  String get accesosIntro;

  /// No description provided for @accesosVacio.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay accesos registrados'**
  String get accesosVacio;

  /// No description provided for @accesosTodo.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get accesosTodo;

  /// No description provided for @accesosVistaEnVivo.
  ///
  /// In es, this message translates to:
  /// **'Vista en vivo'**
  String get accesosVistaEnVivo;

  /// No description provided for @accesosRepeticiones.
  ///
  /// In es, this message translates to:
  /// **'Repeticiones'**
  String get accesosRepeticiones;

  /// No description provided for @accesosNombreTu.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (tú)'**
  String accesosNombreTu(String nombre);

  /// No description provided for @accesosVio.
  ///
  /// In es, this message translates to:
  /// **'{quien} vio {habitaciones}'**
  String accesosVio(String quien, String habitaciones);

  /// No description provided for @accesosVariasCamaras.
  ///
  /// In es, this message translates to:
  /// **'Varias cámaras'**
  String get accesosVariasCamaras;

  /// No description provided for @accesosVistaEnVivoDe.
  ///
  /// In es, this message translates to:
  /// **'Vista en vivo · {habitacion}'**
  String accesosVistaEnVivoDe(String habitacion);

  /// No description provided for @accesosVistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Vista previa al elegir cámaras'**
  String get accesosVistaPrevia;

  /// No description provided for @accesosVistaPreviaDe.
  ///
  /// In es, this message translates to:
  /// **'Vista previa al elegir cámaras · {dispositivo}'**
  String accesosVistaPreviaDe(String dispositivo);

  /// No description provided for @accesosRepeticion.
  ///
  /// In es, this message translates to:
  /// **'Repetición · {habitacion}, {dia} {hora}'**
  String accesosRepeticion(String habitacion, String dia, String hora);

  /// No description provided for @accesosDesdeAlerta.
  ///
  /// In es, this message translates to:
  /// **'Desde una alerta'**
  String get accesosDesdeAlerta;

  /// No description provided for @accesosAbrirDeNuevo.
  ///
  /// In es, this message translates to:
  /// **'Abrir de nuevo'**
  String get accesosAbrirDeNuevo;

  /// No description provided for @accesosSinAccesos.
  ///
  /// In es, this message translates to:
  /// **'Sin accesos'**
  String get accesosSinAccesos;

  /// No description provided for @accesosTu.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get accesosTu;

  /// No description provided for @accesosHoyMinuscula.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get accesosHoyMinuscula;

  /// No description provided for @accesosResumen.
  ///
  /// In es, this message translates to:
  /// **'{quien} · {dia} {hora}'**
  String accesosResumen(String quien, String dia, String hora);

  /// Spanish gets «la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'Viste {habitacion} en vivo durante {duracion}.'**
  String vivoViste(String habitacion, String duracion);

  /// No description provided for @vivoVolverAlerta.
  ///
  /// In es, this message translates to:
  /// **'Volver a la alerta'**
  String get vivoVolverAlerta;

  /// No description provided for @vivoVolverATodas.
  ///
  /// In es, this message translates to:
  /// **'Volver a todas'**
  String get vivoVolverATodas;

  /// No description provided for @vivoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar la vista en vivo'**
  String get vivoCerrar;

  /// No description provided for @vivoTitulo.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get vivoTitulo;

  /// No description provided for @vivoTituloDe.
  ///
  /// In es, this message translates to:
  /// **'En vivo · {habitacion}'**
  String vivoTituloDe(String habitacion);

  /// No description provided for @vivoVerEnVivo.
  ///
  /// In es, this message translates to:
  /// **'Ver en vivo'**
  String get vivoVerEnVivo;

  /// No description provided for @vivoLlamarA.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {nombre}'**
  String vivoLlamarA(String nombre);

  /// No description provided for @vivoReanudarCamara.
  ///
  /// In es, this message translates to:
  /// **'Reanudar la cámara ahora'**
  String get vivoReanudarCamara;

  /// No description provided for @vivoPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'No se graba. Tu acceso queda en el registro que ve toda la familia: quién, cuándo y cuánto.'**
  String get vivoPrivacidad;

  /// Tag over a live image.
  ///
  /// In es, this message translates to:
  /// **'EN VIVO'**
  String get vivoEtiqueta;

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'La cámara {habitacion} no está disponible'**
  String vivoNoDisponibleTitulo(String habitacion);

  /// Followed by a time in another font.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión desde las '**
  String get vivoSinConexionDesdePrefijo;

  /// No description provided for @vivoLlamaOPide.
  ///
  /// In es, this message translates to:
  /// **'Llama a {nombre} o pide a alguien cercano que vaya a verla.'**
  String vivoLlamaOPide(String nombre);

  /// No description provided for @vivoRevisaCable.
  ///
  /// In es, this message translates to:
  /// **'Revisa el cable, la PC y el internet de la casa.'**
  String get vivoRevisaCable;

  /// No description provided for @vivoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Vista en vivo no disponible'**
  String get vivoNoDisponible;

  /// Followed by a time in another font.
  ///
  /// In es, this message translates to:
  /// **'En pausa hasta las '**
  String get vivoEnPausaHastaPrefijo;

  /// Spanish gets «de la Sala»; English the bare room name.
  ///
  /// In es, this message translates to:
  /// **'La cámara {habitacion} está en pausa.'**
  String vivoCamaraEnPausa(String habitacion);

  /// No description provided for @vivoDetenidaTitulo.
  ///
  /// In es, this message translates to:
  /// **'La cámara está detenida'**
  String get vivoDetenidaTitulo;

  /// No description provided for @vivoSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin el consentimiento de {nombre} no hay video.'**
  String vivoSinConsentimiento(String nombre);

  /// No description provided for @vivoSinConexionPc.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · la PC {pc} no responde'**
  String vivoSinConexionPc(String pc);

  /// After «Desconectada», followed by a time in another font.
  ///
  /// In es, this message translates to:
  /// **' desde las '**
  String get vivoDesdeLasPrefijo;

  /// No description provided for @vivoDetenidaSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Detenida · sin consentimiento'**
  String get vivoDetenidaSinConsentimiento;

  /// No description provided for @vivoQueHabitacion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué habitación quieres ver?'**
  String get vivoQueHabitacion;

  /// No description provided for @vivoVerTodasALaVez.
  ///
  /// In es, this message translates to:
  /// **'Ver todas a la vez'**
  String get vivoVerTodasALaVez;

  /// No description provided for @vivoHasta4PorPagina.
  ///
  /// In es, this message translates to:
  /// **'Hasta 4 por página'**
  String get vivoHasta4PorPagina;

  /// No description provided for @vivoDisponibleAhora.
  ///
  /// In es, this message translates to:
  /// **'Disponible ahora'**
  String get vivoDisponibleAhora;

  /// No description provided for @vivoQueSeVe.
  ///
  /// In es, this message translates to:
  /// **'Qué se ve'**
  String get vivoQueSeVe;

  /// No description provided for @vivoModoVideo.
  ///
  /// In es, this message translates to:
  /// **'Video'**
  String get vivoModoVideo;

  /// No description provided for @vivoModoEsqueleto.
  ///
  /// In es, this message translates to:
  /// **'Esqueleto'**
  String get vivoModoEsqueleto;

  /// No description provided for @mosaicoPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'No se graba. Al cerrar queda un solo acceso en el registro, con las habitaciones vistas y la duración.'**
  String get mosaicoPrivacidad;

  /// No description provided for @mosaicoHastaLas.
  ///
  /// In es, this message translates to:
  /// **'Hasta las {hora}'**
  String mosaicoHastaLas(String hora);

  /// No description provided for @mosaicoDesdeLas.
  ///
  /// In es, this message translates to:
  /// **'Desde las {hora}'**
  String mosaicoDesdeLas(String hora);

  /// No description provided for @mosaicoPcNoResponde.
  ///
  /// In es, this message translates to:
  /// **'La PC no responde'**
  String get mosaicoPcNoResponde;

  /// No description provided for @mosaicoSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin consentimiento'**
  String get mosaicoSinConsentimiento;

  /// No description provided for @mosaicoSeMovio.
  ///
  /// In es, this message translates to:
  /// **'{habitacion} se movió'**
  String mosaicoSeMovio(String habitacion);

  /// No description provided for @mosaicoMismoOrden.
  ///
  /// In es, this message translates to:
  /// **'Mismo orden en Cámaras y Ver en vivo.'**
  String get mosaicoMismoOrden;

  /// No description provided for @mosaicoFavoritasPrimero.
  ///
  /// In es, this message translates to:
  /// **'Las favoritas van primero'**
  String get mosaicoFavoritasPrimero;

  /// No description provided for @mosaicoCambiaEstrella.
  ///
  /// In es, this message translates to:
  /// **'Cambia la estrella para pasarla al otro grupo.'**
  String get mosaicoCambiaEstrella;

  /// No description provided for @mosaicoViste.
  ///
  /// In es, this message translates to:
  /// **'Viste {habitaciones} · {duracion}.'**
  String mosaicoViste(String habitaciones, String duracion);

  /// No description provided for @mosaicoTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas en vivo'**
  String get mosaicoTodas;

  /// No description provided for @mosaicoTodasPagina.
  ///
  /// In es, this message translates to:
  /// **'Todas en vivo, página {pagina} de {total}'**
  String mosaicoTodasPagina(int pagina, int total);

  /// No description provided for @mosaicoEligeCamara.
  ///
  /// In es, this message translates to:
  /// **'Elige una cámara para moverla'**
  String get mosaicoEligeCamara;

  /// Followed by the room name in bold.
  ///
  /// In es, this message translates to:
  /// **'Arrastra o mueve '**
  String get mosaicoArrastraOMuevePrefijo;

  /// No description provided for @mosaicoMoverAntes.
  ///
  /// In es, this message translates to:
  /// **'Mover antes'**
  String get mosaicoMoverAntes;

  /// No description provided for @mosaicoMoverDespues.
  ///
  /// In es, this message translates to:
  /// **'Mover después'**
  String get mosaicoMoverDespues;

  /// No description provided for @mosaicoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get mosaicoCerrar;

  /// No description provided for @mosaicoVertical.
  ///
  /// In es, this message translates to:
  /// **'Vertical'**
  String get mosaicoVertical;

  /// No description provided for @mosaicoOrdenarCamaras.
  ///
  /// In es, this message translates to:
  /// **'Ordenar las cámaras'**
  String get mosaicoOrdenarCamaras;

  /// No description provided for @mosaicoControles.
  ///
  /// In es, this message translates to:
  /// **'Controles de Ver todas'**
  String get mosaicoControles;

  /// No description provided for @mosaicoReanudar.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get mosaicoReanudar;

  /// No description provided for @mosaicoCerrarVerTodas.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Ver todas'**
  String get mosaicoCerrarVerTodas;

  /// No description provided for @mosaicoVerHorizontal.
  ///
  /// In es, this message translates to:
  /// **'Ver en horizontal'**
  String get mosaicoVerHorizontal;

  /// No description provided for @mosaicoPaginaAnterior.
  ///
  /// In es, this message translates to:
  /// **'Página anterior'**
  String get mosaicoPaginaAnterior;

  /// No description provided for @mosaicoPaginaSiguiente.
  ///
  /// In es, this message translates to:
  /// **'Página siguiente'**
  String get mosaicoPaginaSiguiente;

  /// No description provided for @mosaicoPagina.
  ///
  /// In es, this message translates to:
  /// **'Página {pagina} de {total}'**
  String mosaicoPagina(int pagina, int total);

  /// No description provided for @mosaicoEnVivoMinuscula.
  ///
  /// In es, this message translates to:
  /// **'en vivo'**
  String get mosaicoEnVivoMinuscula;

  /// No description provided for @mosaicoCeldaEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'{habitacion}, {estado}. {accion}'**
  String mosaicoCeldaEtiqueta(String habitacion, String estado, String accion);

  /// No description provided for @mosaicoElegirParaMover.
  ///
  /// In es, this message translates to:
  /// **'Elegir para mover'**
  String get mosaicoElegirParaMover;

  /// No description provided for @mosaicoAbrirCompleta.
  ///
  /// In es, this message translates to:
  /// **'Abrir en pantalla completa'**
  String get mosaicoAbrirCompleta;

  /// No description provided for @mosaicoPistaOrdenando.
  ///
  /// In es, this message translates to:
  /// **'Arrástrala o usa Mover antes y Mover después'**
  String get mosaicoPistaOrdenando;

  /// No description provided for @mosaicoPistaMantener.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado para moverla'**
  String get mosaicoPistaMantener;

  /// No description provided for @mosaicoQuitarFavorita.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritas'**
  String get mosaicoQuitarFavorita;

  /// No description provided for @mosaicoMarcarFavorita.
  ///
  /// In es, this message translates to:
  /// **'Marcar como favorita'**
  String get mosaicoMarcarFavorita;

  /// No description provided for @mosaicoVerCompleta.
  ///
  /// In es, this message translates to:
  /// **'Ver en pantalla completa'**
  String get mosaicoVerCompleta;

  /// A member's name when it is the signed-in person.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (tú)'**
  String familiaNombreTu(String nombre);

  /// Role tag in the alert order.
  ///
  /// In es, this message translates to:
  /// **'Principal'**
  String get familiaPapelPrincipal;

  /// Role tag in the alert order.
  ///
  /// In es, this message translates to:
  /// **'Secundario'**
  String get familiaPapelSecundario;

  /// Role tag: a member that is neither primary nor secondary.
  ///
  /// In es, this message translates to:
  /// **'Recibe alertas'**
  String get familiaPapelFamiliar;

  /// Relationship written by the member (user data) plus «owner».
  ///
  /// In es, this message translates to:
  /// **'{parentesco} · titular'**
  String familiaResumenParentescoTitular(String parentesco);

  /// No description provided for @familiaResumenTitular.
  ///
  /// In es, this message translates to:
  /// **'titular de la cuenta'**
  String get familiaResumenTitular;

  /// No description provided for @familiaTitularCuenta.
  ///
  /// In es, this message translates to:
  /// **'Titular de la cuenta'**
  String get familiaTitularCuenta;

  /// Family tab heading.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get familiaTitulo;

  /// nombre: the cared-for person.
  ///
  /// In es, this message translates to:
  /// **'Reciben las alertas de {nombre}.'**
  String familiaReciben(String nombre);

  /// No description provided for @familiaOrdenFila.
  ///
  /// In es, this message translates to:
  /// **'Orden de aviso y tiempo de espera'**
  String get familiaOrdenFila;

  /// No description provided for @familiaOrdenSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'{principal} · sin contacto secundario'**
  String familiaOrdenSinSecundario(String principal);

  /// No description provided for @familiaOrdenResumen.
  ///
  /// In es, this message translates to:
  /// **'{principal} → {secundario} · {minutos} min de espera'**
  String familiaOrdenResumen(String principal, String secundario, int minutos);

  /// No description provided for @familiaSinSecundarioTitulo.
  ///
  /// In es, this message translates to:
  /// **'No hay contacto secundario'**
  String get familiaSinSecundarioTitulo;

  /// No description provided for @familiaSinSecundarioTexto.
  ///
  /// In es, this message translates to:
  /// **'Si {principal} no atiende a tiempo, nadie más será avisado.'**
  String familiaSinSecundarioTexto(String principal);

  /// Button and screen title.
  ///
  /// In es, this message translates to:
  /// **'Invitar a un familiar'**
  String get familiaInvitar;

  /// Completes «Only Carmen (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'invitar o retirar familiares y cambiar el orden de aviso'**
  String get familiaSoloLecturaInvitar;

  /// No description provided for @familiaFamiliarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Familiar'**
  String get familiaFamiliarTitulo;

  /// No description provided for @familiaTuPerfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil en la familia'**
  String get familiaTuPerfilTitulo;

  /// No description provided for @familiaHacerPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Hacer contacto principal'**
  String get familiaHacerPrincipal;

  /// No description provided for @familiaHacerPrincipalDetalle.
  ///
  /// In es, this message translates to:
  /// **'Recibirá cada alerta primero'**
  String get familiaHacerPrincipalDetalle;

  /// No description provided for @familiaHacerSecundario.
  ///
  /// In es, this message translates to:
  /// **'Hacer contacto secundario'**
  String get familiaHacerSecundario;

  /// No description provided for @familiaHacerSecundarioDetalle.
  ///
  /// In es, this message translates to:
  /// **'Recibe la alerta si nadie atiende en {minutos} min'**
  String familiaHacerSecundarioDetalle(int minutos);

  /// No description provided for @familiaRetirarAcceso.
  ///
  /// In es, this message translates to:
  /// **'Retirar acceso'**
  String get familiaRetirarAcceso;

  /// No description provided for @familiaContacto.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get familiaContacto;

  /// No description provided for @familiaTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get familiaTelefono;

  /// No description provided for @familiaLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get familiaLlamar;

  /// No description provided for @familiaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get familiaCorreo;

  /// No description provided for @familiaEnLasAlertas.
  ///
  /// In es, this message translates to:
  /// **'En las alertas'**
  String get familiaEnLasAlertas;

  /// No description provided for @familiaPapelPrincipalDetalle.
  ///
  /// In es, this message translates to:
  /// **'Recibe cada alerta primero'**
  String get familiaPapelPrincipalDetalle;

  /// No description provided for @familiaPapelSecundarioDetalle.
  ///
  /// In es, this message translates to:
  /// **'Le avisamos si nadie atiende en {minutos} min'**
  String familiaPapelSecundarioDetalle(int minutos);

  /// No description provided for @familiaPapelFamiliarDetalle.
  ///
  /// In es, this message translates to:
  /// **'Se entera de todo, sin escalamiento'**
  String get familiaPapelFamiliarDetalle;

  /// No description provided for @familiaActividad.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get familiaActividad;

  /// No description provided for @familiaAlertasMarcadas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 alerta marcada} other{{n} alertas marcadas}}'**
  String familiaAlertasMarcadas(int n);

  /// Followed by the time. tipo: caida or inestable. habitacion: room name (user data); habitacionConArticulo: the same with its Spanish article («la Sala»).
  ///
  /// In es, this message translates to:
  /// **'Última: {tipo, select, caida{Caída} other{Inestable}} en {habitacionConArticulo} · {fecha} · '**
  String familiaUltimaMarcada(
    String tipo,
    String habitacion,
    String habitacionConArticulo,
    String fecha,
  );

  /// No description provided for @familiaSinMarcadas.
  ///
  /// In es, this message translates to:
  /// **'Aún no marcó alertas'**
  String get familiaSinMarcadas;

  /// No description provided for @familiaAccesosCamara.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 acceso a la cámara} other{{n} accesos a la cámara}}'**
  String familiaAccesosCamara(int n);

  /// Followed by the time. cuando: «today» or a short date.
  ///
  /// In es, this message translates to:
  /// **'Último: {cuando} '**
  String familiaUltimoAcceso(String cuando);

  /// No description provided for @familiaHoy.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get familiaHoy;

  /// No description provided for @familiaSinAccesos.
  ///
  /// In es, this message translates to:
  /// **'Aún no abrió la vista en vivo'**
  String get familiaSinAccesos;

  /// No description provided for @familiaAvisoDejarPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Para dejar de ser principal, elige a otro contacto.'**
  String get familiaAvisoDejarPrincipal;

  /// No description provided for @familiaAvisoRetirarPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Para retirar su acceso, primero elige a otro contacto principal.'**
  String get familiaAvisoRetirarPrincipal;

  /// No description provided for @familiaOpciones.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get familiaOpciones;

  /// Completes «Only Carmen (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'cambiar el papel de un familiar o retirar su acceso'**
  String get familiaSoloLecturaPapel;

  /// papel: principal or secundario.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ahora es contacto {papel, select, principal{principal} other{secundario}}'**
  String familiaAhoraEsContacto(String nombre, String papel);

  /// No description provided for @familiaOrdenActualizado.
  ///
  /// In es, this message translates to:
  /// **'El orden de aviso se actualizó.'**
  String get familiaOrdenActualizado;

  /// No description provided for @familiaRetirarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Retirar el acceso de {nombre}?'**
  String familiaRetirarTitulo(String nombre);

  /// No description provided for @familiaRetirarTexto.
  ///
  /// In es, this message translates to:
  /// **'Dejará de recibir alertas y de ver el historial.'**
  String get familiaRetirarTexto;

  /// No description provided for @familiaRetirarTextoSecundario.
  ///
  /// In es, this message translates to:
  /// **'Dejará de recibir alertas y de ver el historial. Te quedarás sin contacto secundario.'**
  String get familiaRetirarTextoSecundario;

  /// No description provided for @familiaCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get familiaCancelar;

  /// No description provided for @familiaYaNoRecibe.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ya no recibe alertas'**
  String familiaYaNoRecibe(String nombre);

  /// No description provided for @familiaQuedasteSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'Te quedaste sin contacto secundario.'**
  String get familiaQuedasteSinSecundario;

  /// No description provided for @familiaOrdenTitulo.
  ///
  /// In es, this message translates to:
  /// **'Orden de aviso'**
  String get familiaOrdenTitulo;

  /// Completes «Only Carmen (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'cambiar el orden de aviso y el tiempo de espera'**
  String get familiaSoloLecturaOrden;

  /// No description provided for @familiaOrdenExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Si el principal no marca la alerta a tiempo, avisamos al secundario.'**
  String get familiaOrdenExplicacion;

  /// No description provided for @familiaQuienResponde.
  ///
  /// In es, this message translates to:
  /// **'Quién responde'**
  String get familiaQuienResponde;

  /// No description provided for @familiaContactoPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Contacto principal'**
  String get familiaContactoPrincipal;

  /// No description provided for @familiaSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'Sin contacto secundario'**
  String get familiaSinSecundario;

  /// No description provided for @familiaNadieMasRecibe.
  ///
  /// In es, this message translates to:
  /// **'Nadie más recibe el aviso.'**
  String get familiaNadieMasRecibe;

  /// No description provided for @familiaContactoSecundarioA.
  ///
  /// In es, this message translates to:
  /// **'Contacto secundario · a los {minutos} min'**
  String familiaContactoSecundarioA(int minutos);

  /// No description provided for @familiaTiempoEspera.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de espera'**
  String get familiaTiempoEspera;

  /// No description provided for @familiaAntesDeAvisar.
  ///
  /// In es, this message translates to:
  /// **'Antes de avisar al secundario.'**
  String get familiaAntesDeAvisar;

  /// No description provided for @familiaMinutos.
  ///
  /// In es, this message translates to:
  /// **'{minutos, plural, =1{1 minuto} other{{minutos} minutos}}'**
  String familiaMinutos(int minutos);

  /// No description provided for @familiaPredeterminado.
  ///
  /// In es, this message translates to:
  /// **'Predeterminado'**
  String get familiaPredeterminado;

  /// No description provided for @familiaEsperaToast.
  ///
  /// In es, this message translates to:
  /// **'{minutos, plural, =1{Tiempo de espera: 1 minuto} other{Tiempo de espera: {minutos} minutos}}'**
  String familiaEsperaToast(int minutos);

  /// No description provided for @familiaEsperaToastTexto.
  ///
  /// In es, this message translates to:
  /// **'Se aplicará en las próximas alertas.'**
  String get familiaEsperaToastTexto;

  /// inicio and fin are times, shown in a monospaced style.
  ///
  /// In es, this message translates to:
  /// **'Ej.: alerta a las {inicio} sin atender → {nombre} a las {fin}.'**
  String familiaEjemploEspera(String inicio, String nombre, String fin);

  /// No description provided for @familiaUsaConSecundario.
  ///
  /// In es, this message translates to:
  /// **'Se usa cuando haya un contacto secundario.'**
  String get familiaUsaConSecundario;

  /// Screen-reader label. puesto: principal or secundario.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contacto {puesto, select, principal{principal} other{secundario}}'**
  String familiaCambiarContacto(String puesto);

  /// No description provided for @familiaCambiar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get familiaCambiar;

  /// No description provided for @familiaPrimeroOtroPrincipal.
  ///
  /// In es, this message translates to:
  /// **'Primero elige otro principal'**
  String get familiaPrimeroOtroPrincipal;

  /// No description provided for @familiaYaEsPrincipal.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ya es el contacto principal.'**
  String familiaYaEsPrincipal(String nombre);

  /// puesto: principal or secundario.
  ///
  /// In es, this message translates to:
  /// **'{nombre} es contacto {puesto, select, principal{principal} other{secundario}}'**
  String familiaEsContacto(String nombre, String puesto);

  /// No description provided for @familiaUsaremosOrden.
  ///
  /// In es, this message translates to:
  /// **'Usaremos este orden en las próximas alertas.'**
  String get familiaUsaremosOrden;

  /// puesto: principal or secundario.
  ///
  /// In es, this message translates to:
  /// **'¿Quién será el contacto {puesto, select, principal{principal} other{secundario}}?'**
  String familiaQuienSera(String puesto);

  /// No description provided for @familiaAtiendePrimero.
  ///
  /// In es, this message translates to:
  /// **'Atiende cada alerta primero.'**
  String get familiaAtiendePrimero;

  /// No description provided for @familiaLeAvisamos.
  ///
  /// In es, this message translates to:
  /// **'Le avisamos si nadie la marca en {minutos} min.'**
  String familiaLeAvisamos(int minutos);

  /// papel: the role tag in lower case.
  ///
  /// In es, this message translates to:
  /// **'ahora: {papel}'**
  String familiaOrdenAhora(String papel);

  /// No description provided for @familiaQuitarSecundario.
  ///
  /// In es, this message translates to:
  /// **'Quitar contacto secundario'**
  String get familiaQuitarSecundario;

  /// No description provided for @familiaNadieMasSeraAvisado.
  ///
  /// In es, this message translates to:
  /// **'Nadie más será avisado si no se atiende una alerta.'**
  String get familiaNadieMasSeraAvisado;

  /// No description provided for @invitarCorreoVacio.
  ///
  /// In es, this message translates to:
  /// **'Escribe su correo electrónico.'**
  String get invitarCorreoVacio;

  /// No description provided for @invitarPropioCorreo.
  ///
  /// In es, this message translates to:
  /// **'Ese es tu propio correo. Invita a otra persona.'**
  String get invitarPropioCorreo;

  /// No description provided for @invitarYaEnFamilia.
  ///
  /// In es, this message translates to:
  /// **'Esa persona ya está en la familia de {nombre}.'**
  String invitarYaEnFamilia(String nombre);

  /// No description provided for @invitarEnviada.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada'**
  String get invitarEnviada;

  /// No description provided for @invitarEnviadaTexto.
  ///
  /// In es, this message translates to:
  /// **'Le enviamos un enlace a {correo}.'**
  String invitarEnviadaTexto(String correo);

  /// No description provided for @invitarQuePodra.
  ///
  /// In es, this message translates to:
  /// **'Qué podrá hacer'**
  String get invitarQuePodra;

  /// No description provided for @invitarPuntoVer.
  ///
  /// In es, this message translates to:
  /// **'Ver alertas, historial y la cámara en vivo'**
  String get invitarPuntoVer;

  /// No description provided for @invitarPuntoMarcar.
  ///
  /// In es, this message translates to:
  /// **'Marcar alertas y pausar la cámara'**
  String get invitarPuntoMarcar;

  /// No description provided for @invitarPuntoNoCambia.
  ///
  /// In es, this message translates to:
  /// **'No cambia datos, consentimiento, cámaras ni familia'**
  String get invitarPuntoNoCambia;

  /// No description provided for @invitarEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar invitación'**
  String get invitarEnviar;

  /// No description provided for @invitarTeInvito.
  ///
  /// In es, this message translates to:
  /// **'{titular} te invitó a cuidar a {adulto}'**
  String invitarTeInvito(String titular, String adulto);

  /// No description provided for @invitarCrearAcceso.
  ///
  /// In es, this message translates to:
  /// **'Crear mi acceso'**
  String get invitarCrearAcceso;

  /// No description provided for @invitarCreaTuAcceso.
  ///
  /// In es, this message translates to:
  /// **'Crea tu acceso para recibir sus alertas.'**
  String get invitarCreaTuAcceso;

  /// No description provided for @invitarCampoClave.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña'**
  String get invitarCampoClave;

  /// No description provided for @invitarListo.
  ///
  /// In es, this message translates to:
  /// **'Listo, {yo}. Ya recibes las alertas de {adulto}.'**
  String invitarListo(String yo, String adulto);

  /// No description provided for @invitarPuedes.
  ///
  /// In es, this message translates to:
  /// **'Puedes'**
  String get invitarPuedes;

  /// No description provided for @invitarPuedesDetalle.
  ///
  /// In es, this message translates to:
  /// **'Ver alertas, clips y la cámara en vivo; marcar alertas y pausar.'**
  String get invitarPuedesDetalle;

  /// No description provided for @invitarSoloPuede.
  ///
  /// In es, this message translates to:
  /// **'Solo {titular} puede'**
  String invitarSoloPuede(String titular);

  /// No description provided for @invitarSoloPuedeDetalle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar datos, consentimiento, cámaras y familia.'**
  String get invitarSoloPuedeDetalle;

  /// No description provided for @invitarIrInicio.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get invitarIrInicio;

  /// No description provided for @perfilErrorSubir.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la foto. Vuelve a intentarlo.'**
  String get perfilErrorSubir;

  /// No description provided for @perfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get perfilTitulo;

  /// No description provided for @perfilCampoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get perfilCampoNombre;

  /// No description provided for @perfilCorreoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Con él inicias sesión.'**
  String get perfilCorreoAyuda;

  /// No description provided for @perfilErrorTelefono.
  ///
  /// In es, this message translates to:
  /// **'Revisa el teléfono: solo números.'**
  String get perfilErrorTelefono;

  /// No description provided for @perfilCambiosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get perfilCambiosGuardados;

  /// No description provided for @perfilNombreNuevo.
  ///
  /// In es, this message translates to:
  /// **'Tu familia verá tu nombre nuevo.'**
  String get perfilNombreNuevo;

  /// No description provided for @perfilCampoTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get perfilCampoTelefono;

  /// No description provided for @perfilParentesco.
  ///
  /// In es, this message translates to:
  /// **'Parentesco'**
  String get perfilParentesco;

  /// No description provided for @perfilParentescoCon.
  ///
  /// In es, this message translates to:
  /// **'Parentesco con {nombre}'**
  String perfilParentescoCon(String nombre);

  /// Hint of a free-text field.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Hija, sobrino, vecina'**
  String get perfilParentescoMarcador;

  /// No description provided for @perfilGuardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get perfilGuardarCambios;

  /// No description provided for @perfilCambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get perfilCambiarContrasena;

  /// No description provided for @perfilQuitandoFoto.
  ///
  /// In es, this message translates to:
  /// **'Quitando la foto'**
  String get perfilQuitandoFoto;

  /// No description provided for @perfilSubiendoFoto.
  ///
  /// In es, this message translates to:
  /// **'Subiendo la foto'**
  String get perfilSubiendoFoto;

  /// No description provided for @perfilPorcentaje.
  ///
  /// In es, this message translates to:
  /// **'{n} %'**
  String perfilPorcentaje(int n);

  /// No description provided for @perfilCambiarFoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get perfilCambiarFoto;

  /// No description provided for @perfilQuitando.
  ///
  /// In es, this message translates to:
  /// **'Quitando…'**
  String get perfilQuitando;

  /// No description provided for @perfilSubiendo.
  ///
  /// In es, this message translates to:
  /// **'Subiendo…'**
  String get perfilSubiendo;

  /// No description provided for @perfilSubiendoPorcentaje.
  ///
  /// In es, this message translates to:
  /// **'Subiendo… {n} %'**
  String perfilSubiendoPorcentaje(int n);

  /// No description provided for @perfilNoSeCambioFoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la foto'**
  String get perfilNoSeCambioFoto;

  /// No description provided for @perfilVolverIntentar.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentarlo'**
  String get perfilVolverIntentar;

  /// No description provided for @perfilFotoQuitada.
  ///
  /// In es, this message translates to:
  /// **'Foto quitada'**
  String get perfilFotoQuitada;

  /// No description provided for @perfilSeVeranIniciales.
  ///
  /// In es, this message translates to:
  /// **'Se verán las iniciales.'**
  String get perfilSeVeranIniciales;

  /// No description provided for @perfilNoPudimosAbrir.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esa foto'**
  String get perfilNoPudimosAbrir;

  /// No description provided for @perfilEligeOtra.
  ///
  /// In es, this message translates to:
  /// **'Elige otra.'**
  String get perfilEligeOtra;

  /// No description provided for @perfilNoPudimosAbrirEligeOtra.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esa foto. Elige otra.'**
  String get perfilNoPudimosAbrirEligeOtra;

  /// No description provided for @perfilFotoActualizada.
  ///
  /// In es, this message translates to:
  /// **'Foto actualizada'**
  String get perfilFotoActualizada;

  /// No description provided for @perfilLaVeraFamilia.
  ///
  /// In es, this message translates to:
  /// **'La verá toda la familia.'**
  String get perfilLaVeraFamilia;

  /// No description provided for @perfilSinPermisoCamara.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para usar la cámara'**
  String get perfilSinPermisoCamara;

  /// No description provided for @perfilSinPermisoFotos.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso para ver tus fotos'**
  String get perfilSinPermisoFotos;

  /// No description provided for @perfilOtraOpcion.
  ///
  /// In es, this message translates to:
  /// **'Puedes elegir otra opción.'**
  String get perfilOtraOpcion;

  /// No description provided for @perfilCamaraBloqueada.
  ///
  /// In es, this message translates to:
  /// **'La cámara del celular está bloqueada'**
  String get perfilCamaraBloqueada;

  /// No description provided for @perfilFotosBloqueadas.
  ///
  /// In es, this message translates to:
  /// **'Tus fotos están bloqueadas para Te Tengo'**
  String get perfilFotosBloqueadas;

  /// No description provided for @perfilPermitelo.
  ///
  /// In es, this message translates to:
  /// **'Permítelo en los ajustes del celular y vuelve a intentarlo.'**
  String get perfilPermitelo;

  /// No description provided for @perfilAbrirAjustes.
  ///
  /// In es, this message translates to:
  /// **'Abrir los ajustes del celular'**
  String get perfilAbrirAjustes;

  /// No description provided for @perfilAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get perfilAhoraNo;

  /// No description provided for @perfilFotoDe.
  ///
  /// In es, this message translates to:
  /// **'Foto de {nombre}'**
  String perfilFotoDe(String nombre);

  /// No description provided for @perfilLaVeFamilia.
  ///
  /// In es, this message translates to:
  /// **'La ve toda la familia.'**
  String get perfilLaVeFamilia;

  /// No description provided for @perfilTomarFoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar una foto'**
  String get perfilTomarFoto;

  /// No description provided for @perfilElegirGaleria.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get perfilElegirGaleria;

  /// No description provided for @perfilQuitarFoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar la foto'**
  String get perfilQuitarFoto;

  /// No description provided for @perfilErrorActualVacia.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña actual.'**
  String get perfilErrorActualVacia;

  /// No description provided for @perfilActualIncorrecta.
  ///
  /// In es, this message translates to:
  /// **'No coincide con tu contraseña actual.'**
  String get perfilActualIncorrecta;

  /// No description provided for @perfilContrasenaActual.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get perfilContrasenaActual;

  /// No description provided for @perfilRepiteNueva.
  ///
  /// In es, this message translates to:
  /// **'Repite la nueva contraseña'**
  String get perfilRepiteNueva;

  /// No description provided for @perfilAjustaFoto.
  ///
  /// In es, this message translates to:
  /// **'Ajusta la foto'**
  String get perfilAjustaFoto;

  /// No description provided for @perfilMueveAcerca.
  ///
  /// In es, this message translates to:
  /// **'Mueve y acerca la foto para centrar la cara.'**
  String get perfilMueveAcerca;

  /// No description provided for @perfilUsarFoto.
  ///
  /// In es, this message translates to:
  /// **'Usar esta foto'**
  String get perfilUsarFoto;

  /// No description provided for @sesionErrorNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre y apellido.'**
  String get sesionErrorNombre;

  /// No description provided for @sesionErrorCorreoVacio.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo electrónico.'**
  String get sesionErrorCorreoVacio;

  /// No description provided for @sesionErrorCorreoIncompleto.
  ///
  /// In es, this message translates to:
  /// **'Revisa el correo: parece incompleto.'**
  String get sesionErrorCorreoIncompleto;

  /// No description provided for @sesionErrorClaveVacia.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña.'**
  String get sesionErrorClaveVacia;

  /// No description provided for @sesionErrorClaveCorta.
  ///
  /// In es, this message translates to:
  /// **'Usa al menos 8 caracteres y un número.'**
  String get sesionErrorClaveCorta;

  /// No description provided for @sesionErrorNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get sesionErrorNoCoinciden;

  /// No description provided for @sesionAyudaContrasena.
  ///
  /// In es, this message translates to:
  /// **'8 caracteres o más, con un número.'**
  String get sesionAyudaContrasena;

  /// No description provided for @sesionCampoNombre.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre y apellido'**
  String get sesionCampoNombre;

  /// No description provided for @sesionCampoCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get sesionCampoCorreo;

  /// No description provided for @sesionCampoContrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get sesionCampoContrasena;

  /// No description provided for @sesionNuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get sesionNuevaContrasena;

  /// No description provided for @sesionGuardarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get sesionGuardarContrasena;

  /// No description provided for @sesionContrasenaActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get sesionContrasenaActualizada;

  /// No description provided for @sesionCerrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get sesionCerrarTitulo;

  /// No description provided for @sesionCerrarTexto.
  ///
  /// In es, this message translates to:
  /// **'Dejarás de recibir las alertas en este celular.'**
  String get sesionCerrarTexto;

  /// No description provided for @sesionCerrarTextoSus.
  ///
  /// In es, this message translates to:
  /// **'Dejarás de recibir sus alertas en este celular.'**
  String get sesionCerrarTextoSus;

  /// No description provided for @sesionCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get sesionCerrar;

  /// No description provided for @sesionCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get sesionCancelar;

  /// No description provided for @sesionBienvenidaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cuida a tu familiar aunque no estés en casa.'**
  String get sesionBienvenidaTitulo;

  /// No description provided for @sesionBienvenidaTexto.
  ///
  /// In es, this message translates to:
  /// **'Detecta caídas y te avisa al instante.'**
  String get sesionBienvenidaTexto;

  /// No description provided for @sesionVinetaSinPulseras.
  ///
  /// In es, this message translates to:
  /// **'Sin pulseras ni botones'**
  String get sesionVinetaSinPulseras;

  /// No description provided for @sesionVinetaEnVivo.
  ///
  /// In es, this message translates to:
  /// **'En vivo, con su permiso'**
  String get sesionVinetaEnVivo;

  /// No description provided for @sesionVinetaPostura.
  ///
  /// In es, this message translates to:
  /// **'Solo postura, nunca rostros'**
  String get sesionVinetaPostura;

  /// No description provided for @sesionCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get sesionCrearCuenta;

  /// No description provided for @sesionYaTengoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo una cuenta'**
  String get sesionYaTengoCuenta;

  /// Description of the welcome photo for screen readers.
  ///
  /// In es, this message translates to:
  /// **'Una hija abraza a su madre'**
  String get sesionFotoDescripcion;

  /// No description provided for @sesionCerradaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sesión cerrada'**
  String get sesionCerradaTitulo;

  /// No description provided for @sesionCerradaTexto.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para volver a recibir alertas.'**
  String get sesionCerradaTexto;

  /// No description provided for @sesionClaveActualizadaTexto.
  ///
  /// In es, this message translates to:
  /// **'Ya puedes iniciar sesión con ella.'**
  String get sesionClaveActualizadaTexto;

  /// No description provided for @sesionErrorCorreo.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo.'**
  String get sesionErrorCorreo;

  /// No description provided for @sesionErrorContrasena.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña.'**
  String get sesionErrorContrasena;

  /// Heading and link.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get sesionIniciaSesion;

  /// No description provided for @sesionBloqueadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado por 15 minutos'**
  String get sesionBloqueadoTitulo;

  /// hora is shown in a monospaced style.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a intentarlo a las {hora}.'**
  String sesionBloqueadoTexto(String hora);

  /// No description provided for @sesionIncorrectos.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get sesionIncorrectos;

  /// No description provided for @sesionIntentosRestantes.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Te queda 1 intento antes de un bloqueo de 15 min.} other{Te quedan {n} intentos antes de un bloqueo de 15 min.}}'**
  String sesionIntentosRestantes(int n);

  /// No description provided for @sesionFaltanDatos.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y tu contraseña'**
  String get sesionFaltanDatos;

  /// No description provided for @sesionOlvidaste.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get sesionOlvidaste;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get sesionIniciarSesion;

  /// No description provided for @sesionSinCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no tienes cuenta?'**
  String get sesionSinCuenta;

  /// No description provided for @sesionCreaUna.
  ///
  /// In es, this message translates to:
  /// **'Crea una'**
  String get sesionCreaUna;

  /// No description provided for @registroCorreoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Este correo ya está registrado.'**
  String get registroCorreoRegistrado;

  /// No description provided for @registroCorreoConCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ese correo ya tiene una cuenta'**
  String get registroCorreoConCuenta;

  /// No description provided for @registroIniciarConCorreo.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con este correo'**
  String get registroIniciarConCorreo;

  /// No description provided for @registroRecuperarMiContrasena.
  ///
  /// In es, this message translates to:
  /// **'Recuperar mi contraseña'**
  String get registroRecuperarMiContrasena;

  /// No description provided for @registroCompletaCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa los campos marcados'**
  String get registroCompletaCampos;

  /// Followed by the «Terms» link.
  ///
  /// In es, this message translates to:
  /// **'Aceptas los'**
  String get registroAceptasLos;

  /// Link to the terms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get registroTerminos;

  /// Between the «Terms» and «Privacy» links.
  ///
  /// In es, this message translates to:
  /// **'y la'**
  String get registroYLa;

  /// Link to the privacy policy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get registroPrivacidad;

  /// No description provided for @registroYaTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get registroYaTienesCuenta;

  /// No description provided for @registroCuentaLista.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está lista, {nombre}.'**
  String registroCuentaLista(String nombre);

  /// No description provided for @registroDosPasos.
  ///
  /// In es, this message translates to:
  /// **'2 pasos más:'**
  String get registroDosPasos;

  /// No description provided for @registroPasoDatos.
  ///
  /// In es, this message translates to:
  /// **'Datos de la persona'**
  String get registroPasoDatos;

  /// No description provided for @registroPasoConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento informado'**
  String get registroPasoConsentimiento;

  /// No description provided for @registroEmpezar.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get registroEmpezar;

  /// No description provided for @recuperarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get recuperarContrasena;

  /// No description provided for @recuperarTeEnviaremos.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace.'**
  String get recuperarTeEnviaremos;

  /// No description provided for @recuperarEnviarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get recuperarEnviarEnlace;

  /// No description provided for @recuperarRevisaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get recuperarRevisaCorreo;

  /// correo is shown in bold.
  ///
  /// In es, this message translates to:
  /// **'Si {correo} tiene cuenta, te llegará un enlace. Vence en 30 minutos.'**
  String recuperarSiTieneCuenta(String correo);

  /// No description provided for @recuperarSpam.
  ///
  /// In es, this message translates to:
  /// **'Revisa también el spam.'**
  String get recuperarSpam;

  /// No description provided for @recuperarVolverIniciar.
  ///
  /// In es, this message translates to:
  /// **'Volver a iniciar sesión'**
  String get recuperarVolverIniciar;

  /// tiempo: a countdown like 0:45, shown in a monospaced style.
  ///
  /// In es, this message translates to:
  /// **'Reenviar enlace en {tiempo}'**
  String recuperarReenviarEn(String tiempo);

  /// No description provided for @recuperarReenviar.
  ///
  /// In es, this message translates to:
  /// **'Reenviar enlace'**
  String get recuperarReenviar;

  /// correo is shown in bold.
  ///
  /// In es, this message translates to:
  /// **'Para la cuenta {correo}.'**
  String recuperarParaCuenta(String correo);

  /// No description provided for @recuperarRepite.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get recuperarRepite;

  /// No description provided for @recuperarVencido.
  ///
  /// In es, this message translates to:
  /// **'Este enlace ya venció'**
  String get recuperarVencido;

  /// No description provided for @recuperarDura.
  ///
  /// In es, this message translates to:
  /// **'Dura 30 minutos y sirve una sola vez.'**
  String get recuperarDura;

  /// No description provided for @recuperarPedirNuevo.
  ///
  /// In es, this message translates to:
  /// **'Pedir un enlace nuevo'**
  String get recuperarPedirNuevo;

  /// No description provided for @recuperarCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get recuperarCerrar;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Vista en vivo en cualquier momento'**
  String get consentimientoSeccionVivoTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cuando la familia quiera'**
  String get consentimientoSeccionVivoResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'La familia vinculada puede verla en vivo cuando quiera, no solo en una alerta. Cada acceso queda registrado: quién, cuándo y cuánto.'**
  String get consentimientoSeccionVivoTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué hacemos'**
  String get consentimientoSeccionHacemosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Caídas por la postura'**
  String get consentimientoSeccionHacemosResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'La PC de la casa analiza la postura para detectar caídas y movimientos inestables. El video continuo nunca sale de la casa. Solo salen el aviso y el clip de cada alerta, y la vista en vivo mientras alguien de la familia la mira.'**
  String get consentimientoSeccionHacemosTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué no hacemos'**
  String get consentimientoSeccionNoHacemosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ni rostros ni grabación continua'**
  String get consentimientoSeccionNoHacemosResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Sin reconocimiento facial ni grabación continua. La vista en vivo no se guarda.'**
  String get consentimientoSeccionNoHacemosTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué guardamos'**
  String get consentimientoSeccionGuardamosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Clip de cada alerta, 30 días'**
  String get consentimientoSeccionGuardamosResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo el clip de cada alerta, 30 días; luego se borra. Se guarda en Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú: es un flujo transfronterizo de datos personales. Sus movimientos (puntos del cuerpo, sin imagen) solo se guardan con un permiso aparte.'**
  String get consentimientoSeccionGuardamosTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Sus derechos'**
  String get consentimientoSeccionDerechosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ley N.° 29733 · revocable'**
  String get consentimientoSeccionDerechosResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Por la Ley N.° 29733, puede ver, corregir o borrar sus datos, oponerse a su uso y revocar este consentimiento.'**
  String get consentimientoSeccionDerechosTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cómo se registra'**
  String get consentimientoRegistroTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Guardamos quién lo otorgó, quién lo registró, fecha y hora (Ley N.° 29733).'**
  String get consentimientoRegistroTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué es Te Tengo'**
  String get legalTerminosQueEsTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Avisa a tu familia si la cámara de la casa detecta una posible caída o un movimiento inestable. No es una cámara de seguridad.'**
  String get legalTerminosQueEsTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get legalTerminosCuentaTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo el titular (quien la crea) cambia los datos de la persona cuidada, el consentimiento, las habitaciones, la familia y el orden de aviso.'**
  String get legalTerminosCuentaTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cada cuenta cuida a una sola persona. Contraseña de 8 caracteres o más, con un número; 5 intentos fallidos bloquean el acceso 15 minutos.'**
  String get legalTerminosCuentaTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Familiares invitados'**
  String get legalTerminosInvitadosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ven alertas, clips, historial y vista en vivo; marcan alertas y pausan la cámara. El titular puede retirar el acceso.'**
  String get legalTerminosInvitadosTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento'**
  String get legalTerminosConsentimientoTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Sin el consentimiento de la persona cuidada o de su representante legal, la cámara no envía video. Revocarlo detiene la captura y borra las grabaciones.'**
  String get legalTerminosConsentimientoTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Guardar sus movimientos necesita un permiso aparte y opcional; las alertas funcionan igual sin él.'**
  String get legalTerminosConsentimientoTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get legalTerminosAlertasTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Las reciben todos los familiares vinculados. Si el principal no marca una en el tiempo de espera (3, 5 o 10 minutos), avisamos al secundario.'**
  String get legalTerminosAlertasTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Límites del servicio'**
  String get legalTerminosLimitesTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Sin detección con la PC de la casa apagada, la cámara desconectada, en pausa o sin consentimiento; no es confiable si no ve bien a la persona.'**
  String get legalTerminosLimitesTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Con la app cerrada, las alertas llegan solo con las notificaciones activadas.'**
  String get legalTerminosLimitesTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué datos guardamos'**
  String get legalPoliticaDatosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cuenta: nombre, correo y contraseña.'**
  String get legalPoliticaDatosTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Persona cuidada: nombre, edad, dirección y con quién vive.'**
  String get legalPoliticaDatosTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Alertas: tipo, habitación, fecha, hora y quién atendió.'**
  String get legalPoliticaDatosTexto3;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Video'**
  String get legalPoliticaVideoTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Se analiza en la PC de la casa. Sin reconocimiento facial ni video en la nube.'**
  String get legalPoliticaVideoTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo salen de la casa el aviso y el clip de cada alerta, y la vista en vivo mientras alguien de la familia la mira con el consentimiento vigente.'**
  String get legalPoliticaVideoTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo el clip de cada alerta (6 s antes y 6 s después), 30 días. La vista en vivo no se graba.'**
  String get legalPoliticaVideoTexto3;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get legalPoliticaMovimientosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo con un permiso aparte y opcional: puntos del cuerpo (hombros, caderas, rodillas…), sin imagen ni video.'**
  String get legalPoliticaMovimientosTexto1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'En la PC de la casa y, si el titular lo elige, en la nube, de 7 días a 1 año. Retirar el permiso borra los de la nube; la PC pregunta si también los borra.'**
  String get legalPoliticaMovimientosTexto2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Dónde se guardan'**
  String get legalPoliticaDondeTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Los clips y los movimientos de la nube se guardan en Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú: es un flujo transfronterizo de datos personales.'**
  String get legalPoliticaDondeTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Quién ve los datos'**
  String get legalPoliticaQuienTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo la familia vinculada. Cada acceso en vivo y cada repetición quedan en un registro que ven todos: quién, cuándo y cuánto.'**
  String get legalPoliticaQuienTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Revocar el consentimiento'**
  String get legalPoliticaRevocarTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Detiene la captura y la vista en vivo y borra las grabaciones; te enviamos la constancia.'**
  String get legalPoliticaRevocarTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Tus derechos'**
  String get legalPoliticaDerechosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ver, corregir o borrar tus datos, u oponerte a su uso (Ley N.° 29733): privacidad@tetengo.pe.'**
  String get legalPoliticaDerechosTexto;

  /// Title of the terms of use (screen and link).
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get legalTerminosTitulo;

  /// Link at the end of the terms.
  ///
  /// In es, this message translates to:
  /// **'Ver la política de privacidad'**
  String get legalVerPolitica;

  /// Title of the privacy policy (screen and link).
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get legalPoliticaTitulo;

  /// Title of the consent screens.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento'**
  String get consentimientoTitulo;

  /// Stands in for the first name while the household loads, inside a sentence.
  ///
  /// In es, this message translates to:
  /// **'la persona cuidada'**
  String get consentimientoPersonaGenerica;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Lo acepta {nombre} o su representante legal antes de que la cámara envíe video.'**
  String consentimientoDocumentoIntro(String nombre);

  /// Heading of the consent certificate in the full document.
  ///
  /// In es, this message translates to:
  /// **'Constancia'**
  String get consentimientoConstancia;

  /// Certificate row label; the value comes from the backend.
  ///
  /// In es, this message translates to:
  /// **'Otorgado por'**
  String get consentimientoOtorgadoPor;

  /// Certificate row label.
  ///
  /// In es, this message translates to:
  /// **'Registrado por'**
  String get consentimientoRegistradoPor;

  /// Certificate row label.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get consentimientoFecha;

  /// Certificate row label.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get consentimientoHora;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Lo acepta {nombre} o su representante. Sin él, no detectamos caídas.'**
  String consentimientoIntro(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'¿Quién otorga el consentimiento?'**
  String get consentimientoQuienOtorga;

  /// Option: the older adult (full name) gives the consent.
  ///
  /// In es, this message translates to:
  /// **'{nombre}, directamente'**
  String consentimientoDirectamente(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Su representante legal'**
  String get consentimientoRepresentante;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'{nombre} fue informada y acepta la cámara para detectar caídas y que su familia la vea en vivo cuando quiera.'**
  String consentimientoCasillaAcepta(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Leí el resumen y el documento completo.'**
  String get consentimientoCasillaLeyo;

  /// Error when a box is unchecked.
  ///
  /// In es, this message translates to:
  /// **'Marca las dos casillas.'**
  String get consentimientoFaltanCasillas;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Guardamos fecha y hora como constancia (Ley N.° 29733).'**
  String get consentimientoGuardamosFecha;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Registrar consentimiento'**
  String get consentimientoRegistrar;

  /// Button: leave the consent for later.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get consentimientoAhoraNo;

  /// Link.
  ///
  /// In es, this message translates to:
  /// **'Leer el documento completo'**
  String get consentimientoLeerDocumento;

  /// Screen title.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento registrado'**
  String get consentimientoRegistradoTitulo;

  /// No description provided for @consentimientoCamarasDetectan.
  ///
  /// In es, this message translates to:
  /// **'Las cámaras ya detectan caídas.'**
  String get consentimientoCamarasDetectan;

  /// No description provided for @consentimientoDetectaranAlVincular.
  ///
  /// In es, this message translates to:
  /// **'Detectarán caídas al vincular la PC.'**
  String get consentimientoDetectaranAlVincular;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get consentimientoVolverInicio;

  /// Toast title.
  ///
  /// In es, this message translates to:
  /// **'Cámara activada'**
  String get consentimientoCamaraActivada;

  /// Toast text. deHabitacion is the Spanish «de la Sala»; habitacion is the bare room name.
  ///
  /// In es, this message translates to:
  /// **'La cámara {deHabitacion} detecta caídas desde las {hora}.'**
  String consentimientoCamaraDetectaDesde(
    String deHabitacion,
    String habitacion,
    String hora,
  );

  /// Certificate card title.
  ///
  /// In es, this message translates to:
  /// **'Constancia de consentimiento'**
  String get consentimientoConstanciaTitulo;

  /// Link.
  ///
  /// In es, this message translates to:
  /// **'Ver la constancia completa'**
  String get consentimientoVerConstancia;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Constancia exigida por la Ley N.° 29733.'**
  String get consentimientoConstanciaLey;

  /// Screen title.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacidadTitulo;

  /// Link.
  ///
  /// In es, this message translates to:
  /// **'Ver el documento aceptado'**
  String get privacidadVerDocumento;

  /// No description provided for @privacidadSinConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Sin consentimiento'**
  String get privacidadSinConsentimiento;

  /// No description provided for @privacidadRevocadoEliminadas.
  ///
  /// In es, this message translates to:
  /// **'Revocado. Grabaciones eliminadas.'**
  String get privacidadRevocadoEliminadas;

  /// No description provided for @privacidadAunNoRegistra.
  ///
  /// In es, this message translates to:
  /// **'Aún no se registra. La cámara no envía video.'**
  String get privacidadAunNoRegistra;

  /// Section header.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get privacidadMovimientos;

  /// No description provided for @privacidadGuardarMovimientos.
  ///
  /// In es, this message translates to:
  /// **'Guardar movimientos'**
  String get privacidadGuardarMovimientos;

  /// No description provided for @privacidadVigenteDesde.
  ///
  /// In es, this message translates to:
  /// **'Vigente desde el {fecha}'**
  String privacidadVigenteDesde(String fecha);

  /// No description provided for @privacidadNoAutorizado.
  ///
  /// In es, this message translates to:
  /// **'No autorizado'**
  String get privacidadNoAutorizado;

  /// No description provided for @privacidadMovimientosNube.
  ///
  /// In es, this message translates to:
  /// **'Movimientos en la nube'**
  String get privacidadMovimientosNube;

  /// No description provided for @privacidadNubeDesactivada.
  ///
  /// In es, this message translates to:
  /// **'Desactivado · falta el permiso'**
  String get privacidadNubeDesactivada;

  /// Section header (the cared-for person's data).
  ///
  /// In es, this message translates to:
  /// **'Sus datos'**
  String get privacidadSusDatos;

  /// No description provided for @privacidadComoCuidamos.
  ///
  /// In es, this message translates to:
  /// **'Cómo los cuidamos'**
  String get privacidadComoCuidamos;

  /// No description provided for @privacidadComoCuidamosResumen.
  ///
  /// In es, this message translates to:
  /// **'Sin video en la nube · clips 30 días'**
  String get privacidadComoCuidamosResumen;

  /// No description provided for @privacidadDatoVideo.
  ///
  /// In es, this message translates to:
  /// **'Video'**
  String get privacidadDatoVideo;

  /// No description provided for @privacidadDatoVideoValor.
  ///
  /// In es, this message translates to:
  /// **'En la PC, nunca en la nube'**
  String get privacidadDatoVideoValor;

  /// No description provided for @privacidadDatoClips.
  ///
  /// In es, this message translates to:
  /// **'Clips'**
  String get privacidadDatoClips;

  /// No description provided for @privacidadDatoClipsValor.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get privacidadDatoClipsValor;

  /// No description provided for @privacidadDatoEnVivo.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get privacidadDatoEnVivo;

  /// No description provided for @privacidadDatoEnVivoValor.
  ///
  /// In es, this message translates to:
  /// **'No se graba'**
  String get privacidadDatoEnVivoValor;

  /// No description provided for @privacidadDatoRostros.
  ///
  /// In es, this message translates to:
  /// **'Rostros'**
  String get privacidadDatoRostros;

  /// No description provided for @privacidadDatoRostrosValor.
  ///
  /// In es, this message translates to:
  /// **'No se reconocen'**
  String get privacidadDatoRostrosValor;

  /// No description provided for @privacidadRegistroAccesos.
  ///
  /// In es, this message translates to:
  /// **'Registro de accesos'**
  String get privacidadRegistroAccesos;

  /// No description provided for @privacidadRegistroAccesosSub.
  ///
  /// In es, this message translates to:
  /// **'Quién miró, cuándo y cuánto'**
  String get privacidadRegistroAccesosSub;

  /// LEGAL: needs human/legal review in English. Followed by the e-mail address in bold.
  ///
  /// In es, this message translates to:
  /// **'Derechos (Ley N.° 29733): '**
  String get privacidadDerechos;

  /// Section header.
  ///
  /// In es, this message translates to:
  /// **'Revocar'**
  String get privacidadRevocar;

  /// No description provided for @privacidadRevocarTexto.
  ///
  /// In es, this message translates to:
  /// **'Detiene la cámara y borra las grabaciones.'**
  String get privacidadRevocarTexto;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Revocar consentimiento'**
  String get privacidadRevocarBoton;

  /// What only the owner can do, inside «Solo Carmen (titular) puede …».
  ///
  /// In es, this message translates to:
  /// **'revocar el consentimiento'**
  String get privacidadSoloLecturaRevocar;

  /// No description provided for @privacidadRevocarDialogoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Revocar el consentimiento?'**
  String get privacidadRevocarDialogoTitulo;

  /// No description provided for @privacidadRevocarDialogoTexto.
  ///
  /// In es, this message translates to:
  /// **'Se detiene la captura, no habrá más alertas y se borran las grabaciones. No se puede deshacer.'**
  String get privacidadRevocarDialogoTexto;

  /// No description provided for @privacidadRevocarDialogoAceptar.
  ///
  /// In es, this message translates to:
  /// **'Sí, revocar y eliminar'**
  String get privacidadRevocarDialogoAceptar;

  /// No description provided for @privacidadRevocarDialogoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar, mantenerlo'**
  String get privacidadRevocarDialogoCancelar;

  /// Toast title.
  ///
  /// In es, this message translates to:
  /// **'Tu consentimiento sigue vigente'**
  String get privacidadSigueVigente;

  /// Toast text.
  ///
  /// In es, this message translates to:
  /// **'La cámara sigue detectando caídas.'**
  String get privacidadSigueDetectando;

  /// No description provided for @privacidadRevocadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento revocado'**
  String get privacidadRevocadoTitulo;

  /// No description provided for @privacidadRevocandoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Revocando el consentimiento'**
  String get privacidadRevocandoTitulo;

  /// No description provided for @privacidadConstanciaEnviada.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos la constancia a {correo}.'**
  String privacidadConstanciaEnviada(String correo);

  /// No description provided for @privacidadNoCierres.
  ///
  /// In es, this message translates to:
  /// **'No cierres la app.'**
  String get privacidadNoCierres;

  /// No description provided for @privacidadCapturaDetenida.
  ///
  /// In es, this message translates to:
  /// **'Captura detenida'**
  String get privacidadCapturaDetenida;

  /// The time is shown in the mono font.
  ///
  /// In es, this message translates to:
  /// **'A las {hora}'**
  String privacidadALasHora(String hora);

  /// No description provided for @privacidadGrabacionesEliminadas.
  ///
  /// In es, this message translates to:
  /// **'Grabaciones eliminadas'**
  String get privacidadGrabacionesEliminadas;

  /// No description provided for @privacidadEliminandoGrabaciones.
  ///
  /// In es, this message translates to:
  /// **'Eliminando las grabaciones…'**
  String get privacidadEliminandoGrabaciones;

  /// No description provided for @privacidadClips.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 clip} other{{n} clips}}'**
  String privacidadClips(int n);

  /// Deleted clips and the time (mono font).
  ///
  /// In es, this message translates to:
  /// **'{clips} · {hora}'**
  String privacidadClipsHora(String clips, String hora);

  /// No description provided for @privacidadConstanciaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Constancia por correo'**
  String get privacidadConstanciaCorreo;

  /// No description provided for @privacidadEnviada.
  ///
  /// In es, this message translates to:
  /// **'Enviada'**
  String get privacidadEnviada;

  /// No description provided for @privacidadPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get privacidadPendiente;

  /// No description provided for @hogarConvivenciaSolo.
  ///
  /// In es, this message translates to:
  /// **'Vive solo(a)'**
  String get hogarConvivenciaSolo;

  /// No description provided for @hogarConvivenciaConFamiliar.
  ///
  /// In es, this message translates to:
  /// **'Vive conmigo'**
  String get hogarConvivenciaConFamiliar;

  /// No description provided for @hogarConvivenciaConCuidador.
  ///
  /// In es, this message translates to:
  /// **'Vive con otro cuidador'**
  String get hogarConvivenciaConCuidador;

  /// No description provided for @hogarErrorNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe su nombre y apellido.'**
  String get hogarErrorNombre;

  /// No description provided for @hogarErrorEdadVacia.
  ///
  /// In es, this message translates to:
  /// **'Escribe su edad.'**
  String get hogarErrorEdadVacia;

  /// No description provided for @hogarErrorEdadInvalida.
  ///
  /// In es, this message translates to:
  /// **'Escribe una edad válida, en años.'**
  String get hogarErrorEdadInvalida;

  /// No description provided for @hogarErrorDireccion.
  ///
  /// In es, this message translates to:
  /// **'Escribe la dirección de la vivienda.'**
  String get hogarErrorDireccion;

  /// No description provided for @hogarErrorConvivencia.
  ///
  /// In es, this message translates to:
  /// **'Elige una opción.'**
  String get hogarErrorConvivencia;

  /// No description provided for @hogarErrorTelefono.
  ///
  /// In es, this message translates to:
  /// **'Revisa el teléfono: solo números.'**
  String get hogarErrorTelefono;

  /// No description provided for @hogarCampoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get hogarCampoNombre;

  /// No description provided for @hogarCampoNombreEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Rosa Huamán'**
  String get hogarCampoNombreEjemplo;

  /// No description provided for @hogarCampoEdad.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get hogarCampoEdad;

  /// First name; may be empty while typing.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de {nombre}'**
  String hogarCampoTelefono(String nombre);

  /// No description provided for @hogarCampoTelefonoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lo usa «Llamar a {nombre}».'**
  String hogarCampoTelefonoAyuda(String nombre);

  /// No description provided for @hogarCampoDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección de la vivienda'**
  String get hogarCampoDireccion;

  /// No description provided for @hogarCampoDireccionEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Calle, número y distrito'**
  String get hogarCampoDireccionEjemplo;

  /// No description provided for @hogarConQuienVive.
  ///
  /// In es, this message translates to:
  /// **'¿Con quién vive?'**
  String get hogarConQuienVive;

  /// Screen title and setup step 1.
  ///
  /// In es, this message translates to:
  /// **'Persona cuidada'**
  String get hogarPersonaCuidadaTitulo;

  /// Toast.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados'**
  String get hogarCambiosGuardados;

  /// What only the owner can do, inside «Solo Carmen (titular) puede …».
  ///
  /// In es, this message translates to:
  /// **'cambiar los datos de {nombre}'**
  String hogarSoloLecturaCambiarDatos(String nombre);

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get hogarGuardarCambios;

  /// No description provided for @hogarUnaSolaPersonaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cada cuenta cuida a una sola persona'**
  String get hogarUnaSolaPersonaTitulo;

  /// No description provided for @hogarUnaSolaPersonaTexto.
  ///
  /// In es, this message translates to:
  /// **'Para cuidar a alguien más, crea otra cuenta.'**
  String get hogarUnaSolaPersonaTexto;

  /// No description provided for @hogarAQuienCuidar.
  ///
  /// In es, this message translates to:
  /// **'¿A quién vas a cuidar?'**
  String get hogarAQuienCuidar;

  /// No description provided for @hogarCompletaCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa los campos marcados'**
  String get hogarCompletaCampos;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Guardar y continuar'**
  String get hogarGuardarYContinuar;

  /// First name; empty while loading.
  ///
  /// In es, this message translates to:
  /// **'Todo listo. Ya estás cerca de {nombre}.'**
  String onboardingTodoListo(String nombre);

  /// No description provided for @onboardingQueNoSePase.
  ///
  /// In es, this message translates to:
  /// **'Que no se te pase ninguna caída'**
  String get onboardingQueNoSePase;

  /// No description provided for @onboardingAunqueCerrada.
  ///
  /// In es, this message translates to:
  /// **'Aunque la app esté cerrada o el celular en silencio.'**
  String get onboardingAunqueCerrada;

  /// No description provided for @onboardingNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get onboardingNotificaciones;

  /// No description provided for @onboardingParaRecibir.
  ///
  /// In es, this message translates to:
  /// **'Para recibir las alertas'**
  String get onboardingParaRecibir;

  /// Small button.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get onboardingPermitir;

  /// No description provided for @onboardingSuenanIgual.
  ///
  /// In es, this message translates to:
  /// **'Las caídas suenan igual'**
  String get onboardingSuenanIgual;

  /// No description provided for @onboardingFaltaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento'**
  String get onboardingFaltaConsentimiento;

  /// No description provided for @onboardingRegistraloInicio.
  ///
  /// In es, this message translates to:
  /// **'Regístralo desde Inicio'**
  String get onboardingRegistraloInicio;

  /// PC name from the backend.
  ///
  /// In es, this message translates to:
  /// **'PC {nombre} vinculada'**
  String onboardingPcVinculada(String nombre);

  /// No description provided for @onboardingFaltaElegirCamaras.
  ///
  /// In es, this message translates to:
  /// **'Falta elegir las cámaras'**
  String get onboardingFaltaElegirCamaras;

  /// lista: the room names.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara: {lista}} other{{n} cámaras: {lista}}}'**
  String onboardingPcCamaras(int n, String lista);

  /// No description provided for @onboardingSinDetectar.
  ///
  /// In es, this message translates to:
  /// **'{camaras} · sin detectar'**
  String onboardingSinDetectar(String camaras);

  /// No description provided for @onboardingSinPc.
  ///
  /// In es, this message translates to:
  /// **'Sin PC vinculada'**
  String get onboardingSinPc;

  /// No description provided for @onboardingAgregaPc.
  ///
  /// In es, this message translates to:
  /// **'Agrégala desde Ajustes › Cámaras y PCs'**
  String get onboardingAgregaPc;

  /// No description provided for @onboardingSinSecundario.
  ///
  /// In es, this message translates to:
  /// **'Sin contacto secundario'**
  String get onboardingSinSecundario;

  /// No description provided for @onboardingInvitaloFamilia.
  ///
  /// In es, this message translates to:
  /// **'Invítalo desde Familia'**
  String get onboardingInvitaloFamilia;

  /// Button.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get onboardingIrInicio;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Para qué'**
  String get movimientosSecParaQueTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ver qué pasó y mejorar la detección'**
  String get movimientosSecParaQueResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ver qué pasó antes y después de un aviso, y mejorar la detección.'**
  String get movimientosSecParaQueTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Qué guardamos'**
  String get movimientosSecQueTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Puntos del cuerpo, sin imagen'**
  String get movimientosSecQueResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo puntos del cuerpo (hombros, caderas, rodillas…), sin imagen ni video.'**
  String get movimientosSecQueTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Dónde'**
  String get movimientosSecDondeTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'PC y, si quieres, nube'**
  String get movimientosSecDondeResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'En la PC de la casa y, si lo eliges, en la nube (servidores fuera del Perú).'**
  String get movimientosSecDondeTextoV1;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'En la PC de la casa y, si lo eliges, en la nube: Cloudflare R2, con servidores fuera del Perú. Guardarlos ahí es un flujo transfronterizo de datos personales.'**
  String get movimientosSecDondeTextoV2;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'En la PC de la casa y, si lo eliges, en la nube: Microsoft Azure (Azure Blob Storage, región Chile Central), con servidores fuera del Perú. Guardarlos ahí es un flujo transfronterizo de datos personales.'**
  String get movimientosSecDondeTextoV3;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cuánto tiempo'**
  String get movimientosSecCuantoTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Tú eliges el plazo'**
  String get movimientosSecCuantoResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Nube: de 7 días a 1 año. PC: también sin borrar.'**
  String get movimientosSecCuantoTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Quién puede verlos'**
  String get movimientosSecQuienTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'La familia, con registro'**
  String get movimientosSecQuienResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Solo la familia vinculada; cada repetición queda registrada.'**
  String get movimientosSecQuienTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Sus derechos'**
  String get movimientosSecDerechosTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Ley N.° 29733'**
  String get movimientosSecDerechosResumen;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'{nombre} puede ver, corregir o borrar sus datos, u oponerse a su uso: privacidad@tetengo.pe (Ley N.° 29733).'**
  String movimientosSecDerechosTexto(String nombre);

  /// No description provided for @movimientosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Guardar movimientos'**
  String get movimientosTitulo;

  /// No description provided for @movimientosErrorRepresentante.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del representante.'**
  String get movimientosErrorRepresentante;

  /// No description provided for @movimientosRegistradoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Permiso registrado'**
  String get movimientosRegistradoTitulo;

  /// No description provided for @movimientosRegistradoTexto.
  ///
  /// In es, this message translates to:
  /// **'Ahora puedes elegir si se guardan en la nube.'**
  String get movimientosRegistradoTexto;

  /// No description provided for @movimientosDejarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Dejar de guardar los movimientos de {nombre}?'**
  String movimientosDejarTitulo(String nombre);

  /// No description provided for @movimientosDejarTexto.
  ///
  /// In es, this message translates to:
  /// **'Borraremos los de la nube; la PC preguntará si también los borra. Las alertas siguen igual.'**
  String get movimientosDejarTexto;

  /// No description provided for @movimientosDejarAceptar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de guardar'**
  String get movimientosDejarAceptar;

  /// No description provided for @movimientosCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get movimientosCancelar;

  /// No description provided for @movimientosSinInternetTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get movimientosSinInternetTitulo;

  /// No description provided for @movimientosSinInternetTexto.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión y vuelve a intentarlo.'**
  String get movimientosSinInternetTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'¿Guardamos los movimientos de {nombre}?'**
  String movimientosPregunta(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Es opcional: las alertas funcionan igual.'**
  String get movimientosOpcional;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'¿Quién da el permiso?'**
  String get movimientosQuienDa;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'{nombre}, en persona'**
  String movimientosEnPersona(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Su representante'**
  String get movimientosSuRepresentante;

  /// No description provided for @movimientosNombreRepresentante.
  ///
  /// In es, this message translates to:
  /// **'Nombre del representante'**
  String get movimientosNombreRepresentante;

  /// No description provided for @movimientosNombreMarcador.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get movimientosNombreMarcador;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'{nombre} aceptó que se guarden sus movimientos para estos fines.'**
  String movimientosAcepto(String nombre);

  /// No description provided for @movimientosErrorRedTitulo.
  ///
  /// In es, this message translates to:
  /// **'No pudimos registrar el permiso'**
  String get movimientosErrorRedTitulo;

  /// No description provided for @movimientosErrorRedTexto.
  ///
  /// In es, this message translates to:
  /// **'Nada se guardó.'**
  String get movimientosErrorRedTexto;

  /// No description provided for @movimientosRegistrar.
  ///
  /// In es, this message translates to:
  /// **'Registrar el permiso'**
  String get movimientosRegistrar;

  /// No description provided for @movimientosAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get movimientosAhoraNo;

  /// No description provided for @movimientosAccionRegistrar.
  ///
  /// In es, this message translates to:
  /// **'registrar este permiso'**
  String get movimientosAccionRegistrar;

  /// No description provided for @movimientosLeerDocumento.
  ///
  /// In es, this message translates to:
  /// **'Leer el documento completo'**
  String get movimientosLeerDocumento;

  /// No description provided for @movimientosFaltaConsentimientoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento'**
  String get movimientosFaltaConsentimientoTitulo;

  /// No description provided for @movimientosFaltaConsentimientoTexto.
  ///
  /// In es, this message translates to:
  /// **'Sin él no detectamos caídas.'**
  String get movimientosFaltaConsentimientoTexto;

  /// No description provided for @movimientosRegistrarConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Registrar consentimiento'**
  String get movimientosRegistrarConsentimiento;

  /// No description provided for @movimientosEnLaNube.
  ///
  /// In es, this message translates to:
  /// **'Movimientos en la nube'**
  String get movimientosEnLaNube;

  /// No description provided for @movimientosDejarBoton.
  ///
  /// In es, this message translates to:
  /// **'Dejar de guardar movimientos'**
  String get movimientosDejarBoton;

  /// No description provided for @movimientosAccionRetirar.
  ///
  /// In es, this message translates to:
  /// **'retirar este permiso'**
  String get movimientosAccionRetirar;

  /// No description provided for @movimientosConstanciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Permiso para guardar movimientos'**
  String get movimientosConstanciaTitulo;

  /// No description provided for @movimientosConstanciaOtorgadoPor.
  ///
  /// In es, this message translates to:
  /// **'Otorgado por'**
  String get movimientosConstanciaOtorgadoPor;

  /// No description provided for @movimientosConstanciaRepresentante.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (representante)'**
  String movimientosConstanciaRepresentante(String nombre);

  /// No description provided for @movimientosConstanciaRegistradoPor.
  ///
  /// In es, this message translates to:
  /// **'Registrado por'**
  String get movimientosConstanciaRegistradoPor;

  /// No description provided for @movimientosConstanciaFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get movimientosConstanciaFecha;

  /// No description provided for @movimientosConstanciaVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión del texto'**
  String get movimientosConstanciaVersion;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Constancia exigida por la Ley N.° 29733 para datos sensibles.'**
  String get movimientosConstanciaLey;

  /// No description provided for @movimientosLeerAceptado.
  ///
  /// In es, this message translates to:
  /// **'Leer el documento aceptado'**
  String get movimientosLeerAceptado;

  /// No description provided for @movimientosPersonaCuidada.
  ///
  /// In es, this message translates to:
  /// **'la persona cuidada'**
  String get movimientosPersonaCuidada;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Permiso aparte y opcional. Lo acepta {nombre} o su representante.'**
  String movimientosDocIntroduccion(String nombre);

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cómo se registra'**
  String get movimientosDocRegistraTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Guardamos quién lo otorgó, quién lo registró, fecha, hora y versión del texto (Ley N.° 29733).'**
  String get movimientosDocRegistraTexto;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'Cómo retirarlo'**
  String get movimientosDocRetirarTitulo;

  /// LEGAL: needs human/legal review in English.
  ///
  /// In es, this message translates to:
  /// **'El titular lo retira en Ajustes › Privacidad. Borramos los de la nube; la PC pregunta si también los borra.'**
  String get movimientosDocRetirarTexto;

  /// No description provided for @movimientosDocVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión del texto: {version}.'**
  String movimientosDocVersion(String version);

  /// No description provided for @movimientosBorradoListo.
  ///
  /// In es, this message translates to:
  /// **'Listo. Ya no guardamos los movimientos de {nombre}.'**
  String movimientosBorradoListo(String nombre);

  /// No description provided for @movimientosBorrandoNube.
  ///
  /// In es, this message translates to:
  /// **'Borrando los movimientos de la nube…'**
  String get movimientosBorrandoNube;

  /// No description provided for @movimientosAlertasIgual.
  ///
  /// In es, this message translates to:
  /// **'Las alertas siguen igual.'**
  String get movimientosAlertasIgual;

  /// No description provided for @movimientosNoCierres.
  ///
  /// In es, this message translates to:
  /// **'No cierres la app.'**
  String get movimientosNoCierres;

  /// No description provided for @movimientosYaNoGuardamos.
  ///
  /// In es, this message translates to:
  /// **'Ya no guardamos movimientos'**
  String get movimientosYaNoGuardamos;

  /// No description provided for @movimientosDesdeLas.
  ///
  /// In es, this message translates to:
  /// **'Desde las {hora}'**
  String movimientosDesdeLas(String hora);

  /// No description provided for @movimientosBorradosNube.
  ///
  /// In es, this message translates to:
  /// **'Movimientos borrados de la nube'**
  String get movimientosBorradosNube;

  /// No description provided for @movimientosEnLaPc.
  ///
  /// In es, this message translates to:
  /// **'En la PC de la casa'**
  String get movimientosEnLaPc;

  /// No description provided for @movimientosPcPreguntara.
  ///
  /// In es, this message translates to:
  /// **'Preguntará si también se borran ahí.'**
  String get movimientosPcPreguntara;

  /// No description provided for @movimientosVolverPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Volver a Privacidad'**
  String get movimientosVolverPrivacidad;

  /// No description provided for @nubePlazoDias.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, other{{dias} días}}'**
  String nubePlazoDias(int dias);

  /// No description provided for @nubePlazoAnio.
  ///
  /// In es, this message translates to:
  /// **'1 año'**
  String get nubePlazoAnio;

  /// No description provided for @nubeDesactivado.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get nubeDesactivado;

  /// No description provided for @nubeSeGuardan.
  ///
  /// In es, this message translates to:
  /// **'Se guardan {plazo}'**
  String nubeSeGuardan(String plazo);

  /// No description provided for @nubeApagarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Dejar de guardar en la nube?'**
  String get nubeApagarTitulo;

  /// No description provided for @nubeAcortarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar solo {plazo}?'**
  String nubeAcortarTitulo(String plazo);

  /// No description provided for @nubeApagarTexto.
  ///
  /// In es, this message translates to:
  /// **'Borraremos todos los movimientos de la nube. No se pueden recuperar.'**
  String get nubeApagarTexto;

  /// No description provided for @nubeAcortarTexto.
  ///
  /// In es, this message translates to:
  /// **'Borraremos los movimientos anteriores al {fecha}. No se pueden recuperar.'**
  String nubeAcortarTexto(String fecha);

  /// No description provided for @nubeNoGuardar.
  ///
  /// In es, this message translates to:
  /// **'No guardar en la nube'**
  String get nubeNoGuardar;

  /// No description provided for @nubeGuardarPlazo.
  ///
  /// In es, this message translates to:
  /// **'Guardar {plazo}'**
  String nubeGuardarPlazo(String plazo);

  /// No description provided for @nubeToastApagado.
  ///
  /// In es, this message translates to:
  /// **'Movimientos en la nube: no guardar'**
  String get nubeToastApagado;

  /// No description provided for @nubeToastPlazo.
  ///
  /// In es, this message translates to:
  /// **'Movimientos en la nube: {plazo}'**
  String nubeToastPlazo(String plazo);

  /// No description provided for @nubeBorramos.
  ///
  /// In es, this message translates to:
  /// **'Borramos los movimientos de la nube.'**
  String get nubeBorramos;

  /// No description provided for @nubeSeBorranSolos.
  ///
  /// In es, this message translates to:
  /// **'Se borran solos al cumplirse el plazo.'**
  String get nubeSeBorranSolos;

  /// No description provided for @nubeFaltaPermiso.
  ///
  /// In es, this message translates to:
  /// **'Falta el permiso de {nombre} para guardar movimientos'**
  String nubeFaltaPermiso(String nombre);

  /// No description provided for @nubeVerPermiso.
  ///
  /// In es, this message translates to:
  /// **'Ver el permiso'**
  String get nubeVerPermiso;

  /// No description provided for @nubeAccionCambiarPlazo.
  ///
  /// In es, this message translates to:
  /// **'cambiar el plazo'**
  String get nubeAccionCambiarPlazo;

  /// No description provided for @nubeErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio'**
  String get nubeErrorRed;

  /// No description provided for @nubePlazoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Plazo en la nube'**
  String get nubePlazoEtiqueta;

  /// No description provided for @nubeMaximoRecomendado.
  ///
  /// In es, this message translates to:
  /// **'Máximo recomendado'**
  String get nubeMaximoRecomendado;

  /// No description provided for @nubeEspacio.
  ///
  /// In es, this message translates to:
  /// **'Espacio aproximado'**
  String get nubeEspacio;

  /// No description provided for @nubeEspacioValor.
  ///
  /// In es, this message translates to:
  /// **'{minimo} a {maximo} MB por cámara al día (estimado)'**
  String nubeEspacioValor(int minimo, int maximo);

  /// No description provided for @nubeDatosDesde.
  ///
  /// In es, this message translates to:
  /// **'Hay movimientos desde'**
  String get nubeDatosDesde;

  /// No description provided for @nubeCamaras.
  ///
  /// In es, this message translates to:
  /// **'Cámaras'**
  String get nubeCamaras;

  /// No description provided for @nubePcSubira.
  ///
  /// In es, this message translates to:
  /// **'La PC {pc} subirá sus movimientos al reconectarse.'**
  String nubePcSubira(String pc);

  /// No description provided for @nubeNuncaVideo.
  ///
  /// In es, this message translates to:
  /// **'Nunca guardamos video en la nube.'**
  String get nubeNuncaVideo;

  /// No description provided for @historialTitulo.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historialTitulo;

  /// No description provided for @historialAlertas.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get historialAlertas;

  /// No description provided for @historialResumenSemanal.
  ///
  /// In es, this message translates to:
  /// **'Resumen semanal'**
  String get historialResumenSemanal;

  /// No description provided for @historialRangoSiete.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get historialRangoSiete;

  /// No description provided for @historialRangoTreinta.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get historialRangoTreinta;

  /// No description provided for @historialRangoTodo.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get historialRangoTodo;

  /// No description provided for @historialChipCaidas.
  ///
  /// In es, this message translates to:
  /// **'Caídas'**
  String get historialChipCaidas;

  /// No description provided for @historialChipInestables.
  ///
  /// In es, this message translates to:
  /// **'Movimientos inestables'**
  String get historialChipInestables;

  /// No description provided for @historialChipActivas.
  ///
  /// In es, this message translates to:
  /// **'Activas'**
  String get historialChipActivas;

  /// No description provided for @historialChipAtendidas.
  ///
  /// In es, this message translates to:
  /// **'Atendidas'**
  String get historialChipAtendidas;

  /// No description provided for @historialChipFalsas.
  ///
  /// In es, this message translates to:
  /// **'Falsas alarmas'**
  String get historialChipFalsas;

  /// No description provided for @historialFiltrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Filtrar alertas'**
  String get historialFiltrarTitulo;

  /// No description provided for @historialFiltroFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get historialFiltroFecha;

  /// No description provided for @historialFiltroTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get historialFiltroTipo;

  /// No description provided for @historialFiltroEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get historialFiltroEstado;

  /// No description provided for @historialFiltroTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get historialFiltroTodas;

  /// No description provided for @historialFiltroCaida.
  ///
  /// In es, this message translates to:
  /// **'Caída'**
  String get historialFiltroCaida;

  /// No description provided for @historialFiltroInestable.
  ///
  /// In es, this message translates to:
  /// **'Movimiento inestable'**
  String get historialFiltroInestable;

  /// No description provided for @historialFiltroTodos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get historialFiltroTodos;

  /// No description provided for @historialFiltroActiva.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get historialFiltroActiva;

  /// No description provided for @historialFiltroAtendida.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get historialFiltroAtendida;

  /// No description provided for @historialFiltroFalsa.
  ///
  /// In es, this message translates to:
  /// **'Falsa alarma'**
  String get historialFiltroFalsa;

  /// No description provided for @historialLimpiar.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get historialLimpiar;

  /// No description provided for @historialVerAlertas.
  ///
  /// In es, this message translates to:
  /// **'Ver alertas'**
  String get historialVerAlertas;

  /// No description provided for @historialVerConteo.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Ver {n} alerta} other{Ver {n} alertas}}'**
  String historialVerConteo(int n);

  /// No description provided for @historialVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos registrados'**
  String get historialVacio;

  /// No description provided for @historialNingunaCoincide.
  ///
  /// In es, this message translates to:
  /// **'Ninguna alerta coincide'**
  String get historialNingunaCoincide;

  /// No description provided for @historialQuitarFiltros.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get historialQuitarFiltros;

  /// No description provided for @historialHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get historialHoy;

  /// No description provided for @historialAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get historialAyer;

  /// No description provided for @historialFiltrar.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get historialFiltrar;

  /// No description provided for @historialFiltrarConteo.
  ///
  /// In es, this message translates to:
  /// **'Filtrar ({n})'**
  String historialFiltrarConteo(int n);

  /// No description provided for @historialQuitarFiltro.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtro {filtro}'**
  String historialQuitarFiltro(String filtro);

  /// No description provided for @historialSinMarcar.
  ///
  /// In es, this message translates to:
  /// **'Sin marcar'**
  String get historialSinMarcar;

  /// No description provided for @historialMarcadaPor.
  ///
  /// In es, this message translates to:
  /// **'por {nombre}'**
  String historialMarcadaPor(String nombre);

  /// No description provided for @historialFilaCaida.
  ///
  /// In es, this message translates to:
  /// **'Caída'**
  String get historialFilaCaida;

  /// No description provided for @historialFilaInestable.
  ///
  /// In es, this message translates to:
  /// **'Inestable'**
  String get historialFilaInestable;

  /// No description provided for @historialCargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando historial'**
  String get historialCargando;

  /// No description provided for @resumenSemanaAnterior.
  ///
  /// In es, this message translates to:
  /// **'Semana anterior'**
  String get resumenSemanaAnterior;

  /// No description provided for @resumenSemanaSiguiente.
  ///
  /// In es, this message translates to:
  /// **'Semana siguiente'**
  String get resumenSemanaSiguiente;

  /// No description provided for @resumenEstaSemana.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get resumenEstaSemana;

  /// No description provided for @resumenSemanaPasada.
  ///
  /// In es, this message translates to:
  /// **'Semana pasada'**
  String get resumenSemanaPasada;

  /// No description provided for @resumenHaceSemanas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, other{Hace {n} semanas}}'**
  String resumenHaceSemanas(int n);

  /// No description provided for @resumenRangoHastaHoy.
  ///
  /// In es, this message translates to:
  /// **'{rango} · hasta hoy'**
  String resumenRangoHastaHoy(String rango);

  /// No description provided for @resumenRangoAnio.
  ///
  /// In es, this message translates to:
  /// **'{rango} {anio}'**
  String resumenRangoAnio(String rango, String anio);

  /// No description provided for @resumenSinEventos.
  ///
  /// In es, this message translates to:
  /// **'Semana sin eventos'**
  String get resumenSinEventos;

  /// No description provided for @resumenPorTipo.
  ///
  /// In es, this message translates to:
  /// **'Por tipo'**
  String get resumenPorTipo;

  /// No description provided for @resumenVs.
  ///
  /// In es, this message translates to:
  /// **'vs. {rango}'**
  String resumenVs(String rango);

  /// No description provided for @resumenCaidas.
  ///
  /// In es, this message translates to:
  /// **'Caídas'**
  String get resumenCaidas;

  /// No description provided for @resumenInestables.
  ///
  /// In es, this message translates to:
  /// **'Movimientos inestables'**
  String get resumenInestables;

  /// No description provided for @resumenFalsas.
  ///
  /// In es, this message translates to:
  /// **'Falsas alarmas'**
  String get resumenFalsas;

  /// No description provided for @resumenFalsasNoSuman.
  ///
  /// In es, this message translates to:
  /// **'Las falsas alarmas no suman.'**
  String get resumenFalsasNoSuman;

  /// No description provided for @resumenEventosPorDia.
  ///
  /// In es, this message translates to:
  /// **'Eventos por día'**
  String get resumenEventosPorDia;

  /// No description provided for @resumenInicialesDias.
  ///
  /// In es, this message translates to:
  /// **'LMMJVSD'**
  String get resumenInicialesDias;

  /// No description provided for @resumenIgual.
  ///
  /// In es, this message translates to:
  /// **'Igual ({anterior})'**
  String resumenIgual(int anterior);

  /// No description provided for @resumenSubio.
  ///
  /// In es, this message translates to:
  /// **'Subió de {anterior} a {actual}'**
  String resumenSubio(int anterior, int actual);

  /// No description provided for @resumenBajo.
  ///
  /// In es, this message translates to:
  /// **'Bajó de {anterior} a {actual}'**
  String resumenBajo(int anterior, int actual);

  /// No description provided for @resumenVerResumen.
  ///
  /// In es, this message translates to:
  /// **'Ver resumen'**
  String get resumenVerResumen;

  /// No description provided for @resumenInicioCaidas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{caída} other{caídas}}'**
  String resumenInicioCaidas(int n);

  /// No description provided for @resumenInicioInestables.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{inestable} other{inestables}}'**
  String resumenInicioInestables(int n);

  /// No description provided for @resumenInicioFalsas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{falsa} other{falsas}}'**
  String resumenInicioFalsas(int n);

  /// Screen-reader action that closes a floating notice.
  ///
  /// In es, this message translates to:
  /// **'Cerrar aviso'**
  String get comunCerrarAviso;

  /// Read-only tag for an invited member.
  ///
  /// In es, this message translates to:
  /// **'Solo ver'**
  String get comunSoloVer;

  /// Read-only notice. accion is a lowercase verb phrase, e.g. «agregar una PC».
  ///
  /// In es, this message translates to:
  /// **'Solo {titular} (titular) puede {accion}.'**
  String comunSoloTitularPuede(String titular, String accion);

  /// No description provided for @comunPasoDe.
  ///
  /// In es, this message translates to:
  /// **'Paso {paso} de {pasos}'**
  String comunPasoDe(int paso, int pasos);

  /// No description provided for @comunMostrarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get comunMostrarContrasena;

  /// No description provided for @comunOcultarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get comunOcultarContrasena;

  /// Default label of a button while it is loading.
  ///
  /// In es, this message translates to:
  /// **'Un momento…'**
  String get comunUnMomento;

  /// Screen-reader label of the «?» help button.
  ///
  /// In es, this message translates to:
  /// **'Más información: {tema}'**
  String comunMasInformacion(String tema);

  /// No description provided for @comunErrorGenerico.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error.'**
  String get comunErrorGenerico;

  /// No description provided for @redSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión con Te Tengo. Revisa tu internet.'**
  String get redSinConexion;

  /// No description provided for @navInicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navInicio;

  /// No description provided for @navHistorial.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistorial;

  /// No description provided for @navFamilia.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get navFamilia;

  /// No description provided for @navAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navAjustes;

  /// No description provided for @navAlertasActivas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 alerta activa} other{{n} alertas activas}}'**
  String navAlertasActivas(int n);

  /// Where something happened. lugar is the room with its Spanish article («la Sala»); habitacion is the room name alone.
  ///
  /// In es, this message translates to:
  /// **'en {lugar}'**
  String nucleoEnHabitacion(String lugar, String habitacion);

  /// No description provided for @nucleoSinInternetTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu celular no tiene internet'**
  String get nucleoSinInternetTitulo;

  /// No description provided for @nucleoSinInternetTexto.
  ///
  /// In es, this message translates to:
  /// **'Las alertas llegarán cuando vuelvas a conectarte. Si no atiendes una a tiempo, avisamos a tu contacto secundario.'**
  String get nucleoSinInternetTexto;

  /// No description provided for @nucleoAlertaTitulo.
  ///
  /// In es, this message translates to:
  /// **'{tipo, select, inestable{Movimiento inestable} confirmada{Caída confirmada} other{Posible caída}}'**
  String nucleoAlertaTitulo(String tipo);

  /// Followed by a time in another font (keep the trailing space).
  ///
  /// In es, this message translates to:
  /// **'Alerta activa desde las '**
  String get nucleoAlertaActivaDesde;

  /// No description provided for @pushSigueEnElSueloTitulo.
  ///
  /// In es, this message translates to:
  /// **'{nombre} sigue en el suelo'**
  String pushSigueEnElSueloTitulo(String nombre);

  /// No description provided for @pushCaidaConfirmadaTexto.
  ///
  /// In es, this message translates to:
  /// **'Caída confirmada a las {hora}. La alerta sigue activa.'**
  String pushCaidaConfirmadaTexto(String hora);

  /// No description provided for @pushSeLevantoTitulo.
  ///
  /// In es, this message translates to:
  /// **'{nombre} se levantó'**
  String pushSeLevantoTitulo(String nombre);

  /// No description provided for @pushSeLevantoTexto.
  ///
  /// In es, this message translates to:
  /// **'{hora} · Se puso de pie. Confirma cómo está.'**
  String pushSeLevantoTexto(String hora);

  /// lugar is nucleoEnHabitacion («en la Sala»).
  ///
  /// In es, this message translates to:
  /// **'{hora} · Se puso de pie {lugar}. Confirma cómo está.'**
  String pushSeLevantoTextoEn(String hora, String lugar);

  /// No description provided for @pushMovimientosBorradosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Listo. Ya no guardamos los movimientos de {nombre}.'**
  String pushMovimientosBorradosTitulo(String nombre);

  /// No description provided for @pushMovimientosBorradosTexto.
  ///
  /// In es, this message translates to:
  /// **'Los borramos de la nube.'**
  String get pushMovimientosBorradosTexto;

  /// No description provided for @pushPcDesvinculadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Una PC se desvinculó de la casa'**
  String get pushPcDesvinculadaTitulo;

  /// No description provided for @pushPcDesvinculadaNombre.
  ///
  /// In es, this message translates to:
  /// **'La PC {pc} se desvinculó'**
  String pushPcDesvinculadaNombre(String pc);

  /// No description provided for @pushPcDesvinculadaSinCamaras.
  ///
  /// In es, this message translates to:
  /// **'Sus cámaras ya no detectan caídas. Revisa Cámaras y PCs.'**
  String get pushPcDesvinculadaSinCamaras;

  /// habitaciones: a list of room names, «Sala y Cocina».
  ///
  /// In es, this message translates to:
  /// **'Ya no detecta caídas en {habitaciones}.'**
  String pushPcDesvinculadaHabitaciones(String habitaciones);

  /// No description provided for @pushEscaladaMiaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nadie atendió la alerta: te toca'**
  String get pushEscaladaMiaTitulo;

  /// No description provided for @pushEscaladaMiaTexto.
  ///
  /// In es, this message translates to:
  /// **'Pasaron {espera} min sin respuesta. Eres el contacto secundario.'**
  String pushEscaladaMiaTexto(int espera);

  /// No description provided for @pushEscaladaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Alerta escalada a {nombre}'**
  String pushEscaladaTitulo(String nombre);

  /// No description provided for @pushTuContactoSecundario.
  ///
  /// In es, this message translates to:
  /// **'tu contacto secundario'**
  String get pushTuContactoSecundario;

  /// No description provided for @pushEscaladaTexto.
  ///
  /// In es, this message translates to:
  /// **'Nadie la marcó en {espera} min. Tú todavía puedes atenderla.'**
  String pushEscaladaTexto(int espera);

  /// No description provided for @pushSinSecundarioTitulo.
  ///
  /// In es, this message translates to:
  /// **'No hay contacto secundario'**
  String get pushSinSecundarioTitulo;

  /// No description provided for @pushSinSecundarioTexto.
  ///
  /// In es, this message translates to:
  /// **'Pasaron {espera} min sin respuesta. La alerta sigue siendo tuya.'**
  String pushSinSecundarioTexto(int espera);

  /// No description provided for @pushFalsaAlarmaTitulo.
  ///
  /// In es, this message translates to:
  /// **'{quien} la marcó como falsa alarma'**
  String pushFalsaAlarmaTitulo(String quien);

  /// No description provided for @pushAtendidaTitulo.
  ///
  /// In es, this message translates to:
  /// **'{quien} atendió la alerta'**
  String pushAtendidaTitulo(String quien);

  /// lugar is nucleoEnHabitacion.
  ///
  /// In es, this message translates to:
  /// **'{hora} · {tipo, select, caida{Caída} other{Movimiento inestable}} {lugar}.'**
  String pushAtendidaTexto(String hora, String tipo, String lugar);

  /// No description provided for @inicioHola.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}'**
  String inicioHola(String nombre);

  /// No description provided for @inicioNadieRecibeAlertas.
  ///
  /// In es, this message translates to:
  /// **'Nadie de la familia recibe las alertas'**
  String get inicioNadieRecibeAlertas;

  /// No description provided for @inicioActivaNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones'**
  String get inicioActivaNotificaciones;

  /// No description provided for @inicioEsteCelularNoRecibe.
  ///
  /// In es, this message translates to:
  /// **'Este celular no recibe las alertas'**
  String get inicioEsteCelularNoRecibe;

  /// No description provided for @inicioSinNotificacionesTexto.
  ///
  /// In es, this message translates to:
  /// **'Sin ellas no sabrás de una caída con la app cerrada.'**
  String get inicioSinNotificacionesTexto;

  /// No description provided for @inicioActivarNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get inicioActivarNotificaciones;

  /// No description provided for @inicioVerAlerta.
  ///
  /// In es, this message translates to:
  /// **'Ver la alerta'**
  String get inicioVerAlerta;

  /// No description provided for @inicioRegistrarConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Registrar consentimiento'**
  String get inicioRegistrarConsentimiento;

  /// No description provided for @inicioElegirCamaras.
  ///
  /// In es, this message translates to:
  /// **'Elegir las cámaras'**
  String get inicioElegirCamaras;

  /// No description provided for @inicioAgregarPc.
  ///
  /// In es, this message translates to:
  /// **'Agregar PC'**
  String get inicioAgregarPc;

  /// No description provided for @inicioVerQueRevisar.
  ///
  /// In es, this message translates to:
  /// **'Ver qué revisar'**
  String get inicioVerQueRevisar;

  /// No description provided for @inicioVerEnVivo.
  ///
  /// In es, this message translates to:
  /// **'Ver en vivo'**
  String get inicioVerEnVivo;

  /// No description provided for @inicioNoDisponibleAhora.
  ///
  /// In es, this message translates to:
  /// **'No disponible ahora'**
  String get inicioNoDisponibleAhora;

  /// Topic of the «?» help next to «Ver en vivo».
  ///
  /// In es, this message translates to:
  /// **'privacidad'**
  String get inicioTemaPrivacidad;

  /// No description provided for @inicioNotificacionesActivadas.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get inicioNotificacionesActivadas;

  /// No description provided for @inicioNotificacionesActivadasTexto.
  ///
  /// In es, this message translates to:
  /// **'Te llegarán las alertas aunque la app esté cerrada.'**
  String get inicioNotificacionesActivadasTexto;

  /// No description provided for @inicioAlertaTitulo.
  ///
  /// In es, this message translates to:
  /// **'{tipo, select, inestable{Movimiento inestable activo} confirmada{Caída confirmada} other{Alerta de caída activa}}'**
  String inicioAlertaTitulo(String tipo);

  /// lugar is nucleoEnHabitacion.
  ///
  /// In es, this message translates to:
  /// **'{tipo, select, caida{Caída} other{Movimiento inestable}} {lugar} a las {hora}. Nadie la marcó aún.'**
  String inicioAlertaTexto(String tipo, String lugar, String hora);

  /// No description provided for @inicioDeteccionDetenida.
  ///
  /// In es, this message translates to:
  /// **'Detección detenida'**
  String get inicioDeteccionDetenida;

  /// No description provided for @inicioRevocasteConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Revocaste el consentimiento.'**
  String get inicioRevocasteConsentimiento;

  /// No description provided for @inicioFaltaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento de {nombre}.'**
  String inicioFaltaConsentimiento(String nombre);

  /// No description provided for @inicioSinCamaras.
  ///
  /// In es, this message translates to:
  /// **'Sin cámaras'**
  String get inicioSinCamaras;

  /// No description provided for @inicioFaltaElegirCamaras.
  ///
  /// In es, this message translates to:
  /// **'Falta elegir las cámaras.'**
  String get inicioFaltaElegirCamaras;

  /// No description provided for @inicioVinculaPc.
  ///
  /// In es, this message translates to:
  /// **'Vincula la PC de la casa para detectar caídas.'**
  String get inicioVinculaPc;

  /// No description provided for @inicioUnaCamaraNoResponde.
  ///
  /// In es, this message translates to:
  /// **'1 cámara no responde · {habitacion}'**
  String inicioUnaCamaraNoResponde(String habitacion);

  /// No description provided for @inicioCamarasNoResponden.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara no responde} other{{n} cámaras no responden}}'**
  String inicioCamarasNoResponden(int n);

  /// lugares: a list of nucleoEnHabitacion, «en la Sala y en el Pasillo».
  ///
  /// In es, this message translates to:
  /// **'No detectamos caídas {lugares}. Las demás siguen.'**
  String inicioNoDetectamosEn(String lugares);

  /// No description provided for @inicioCamaraDesconectada.
  ///
  /// In es, this message translates to:
  /// **'La cámara está desconectada'**
  String get inicioCamaraDesconectada;

  /// lugar is nucleoEnHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Sin ella no detectamos caídas {lugar}.'**
  String inicioSinEllaNoDetectamos(String lugar);

  /// No description provided for @inicioNoConfiable.
  ///
  /// In es, this message translates to:
  /// **'La detección no es confiable'**
  String get inicioNoConfiable;

  /// No description provided for @inicioNoVeBien.
  ///
  /// In es, this message translates to:
  /// **'Hace más de 5 min que no ve bien a {nombre}.'**
  String inicioNoVeBien(String nombre);

  /// No description provided for @inicioTranquiloConPausa.
  ///
  /// In es, this message translates to:
  /// **'Todo tranquilo, con una pausa'**
  String get inicioTranquiloConPausa;

  /// No description provided for @inicioEnPausaHasta.
  ///
  /// In es, this message translates to:
  /// **'{habitacion} en pausa hasta las {hora}.'**
  String inicioEnPausaHasta(String habitacion, String hora);

  /// No description provided for @inicioTodoTranquilo.
  ///
  /// In es, this message translates to:
  /// **'Todo tranquilo'**
  String get inicioTodoTranquilo;

  /// No description provided for @inicioSinEventosHoy.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin eventos hoy.} =1{Sin eventos hoy.} other{{n} cámaras cuidando. Sin eventos hoy.}}'**
  String inicioSinEventosHoy(int n);

  /// No description provided for @inicioNombreEdad.
  ///
  /// In es, this message translates to:
  /// **'{nombre}, {edad} años'**
  String inicioNombreEdad(String nombre, int edad);

  /// No description provided for @inicioCamaras.
  ///
  /// In es, this message translates to:
  /// **'Cámaras'**
  String get inicioCamaras;

  /// No description provided for @inicioFamilia.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get inicioFamilia;

  /// No description provided for @inicioPersonas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 persona} other{{n} personas}}'**
  String inicioPersonas(int n);

  /// No description provided for @inicioCamarasNecesitanAtencion.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara necesita atención} other{{n} cámaras necesitan atención}}'**
  String inicioCamarasNecesitanAtencion(int n);

  /// Brand tagline on the splash screen.
  ///
  /// In es, this message translates to:
  /// **'Cerca de los tuyos, aunque estés lejos.'**
  String get arranqueLema;

  /// No description provided for @instalarAvisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Agrega Te Tengo a tu pantalla de inicio'**
  String get instalarAvisoTitulo;

  /// No description provided for @instalarAvisoTexto.
  ///
  /// In es, this message translates to:
  /// **'En el iPhone, las alertas solo llegan si abres Te Tengo desde su ícono.'**
  String get instalarAvisoTexto;

  /// No description provided for @instalarVerComo.
  ///
  /// In es, this message translates to:
  /// **'Ver cómo'**
  String get instalarVerComo;

  /// No description provided for @instalarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Agregar a la pantalla de inicio'**
  String get instalarTitulo;

  /// No description provided for @instalarEncabezado.
  ///
  /// In es, this message translates to:
  /// **'Instala Te Tengo en tu iPhone'**
  String get instalarEncabezado;

  /// No description provided for @instalarIntro.
  ///
  /// In es, this message translates to:
  /// **'Así te llegarán las alertas de caída aunque tengas la app cerrada. Necesitas iOS 16.4 o posterior.'**
  String get instalarIntro;

  /// No description provided for @instalarPaso1.
  ///
  /// In es, this message translates to:
  /// **'Abre esta página en Safari'**
  String get instalarPaso1;

  /// No description provided for @instalarPaso2.
  ///
  /// In es, this message translates to:
  /// **'Toca Compartir'**
  String get instalarPaso2;

  /// No description provided for @instalarPaso2Detalle.
  ///
  /// In es, this message translates to:
  /// **'El cuadrado con una flecha hacia arriba, en la barra de Safari o dentro del menú «···».'**
  String get instalarPaso2Detalle;

  /// Name of the iOS Safari menu item in each language.
  ///
  /// In es, this message translates to:
  /// **'Elige «Agregar a inicio»'**
  String get instalarPaso3;

  /// No description provided for @instalarPaso3Detalle.
  ///
  /// In es, this message translates to:
  /// **'Si no lo ves, toca «Ver más» y desliza la lista hacia arriba.'**
  String get instalarPaso3Detalle;

  /// No description provided for @instalarPaso4.
  ///
  /// In es, this message translates to:
  /// **'Toca «Agregar»'**
  String get instalarPaso4;

  /// No description provided for @instalarPaso5.
  ///
  /// In es, this message translates to:
  /// **'Abre Te Tengo desde su ícono'**
  String get instalarPaso5;

  /// No description provided for @instalarPaso5Detalle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión otra vez y toca «Activar notificaciones».'**
  String get instalarPaso5Detalle;

  /// No description provided for @widgetAbreLaApp.
  ///
  /// In es, this message translates to:
  /// **'Abre la app para ver el estado.'**
  String get widgetAbreLaApp;

  /// No description provided for @widgetTituloAlerta.
  ///
  /// In es, this message translates to:
  /// **'{tipo, select, confirmada{Caída confirmada} caida{Posible caída} other{Movimiento inestable}}'**
  String widgetTituloAlerta(String tipo);

  /// No description provided for @widgetSinCamaras.
  ///
  /// In es, this message translates to:
  /// **'Sin cámaras'**
  String get widgetSinCamaras;

  /// No description provided for @widgetAbreTeTengo.
  ///
  /// In es, this message translates to:
  /// **'Abre Te Tengo'**
  String get widgetAbreTeTengo;

  /// No description provided for @widgetDeteccionDetenida.
  ///
  /// In es, this message translates to:
  /// **'Detección detenida'**
  String get widgetDeteccionDetenida;

  /// No description provided for @widgetFaltaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento'**
  String get widgetFaltaConsentimiento;

  /// No description provided for @widgetCamarasNoResponden.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara no responde} other{{n} cámaras no responden}}'**
  String widgetCamarasNoResponden(int n);

  /// No description provided for @widgetTodoTranquilo.
  ///
  /// In es, this message translates to:
  /// **'Todo tranquilo'**
  String get widgetTodoTranquilo;

  /// No description provided for @widgetCamaras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara} other{{n} cámaras}}'**
  String widgetCamaras(int n);

  /// No description provided for @widgetPaso1.
  ///
  /// In es, this message translates to:
  /// **'Mantén presionado un espacio libre de la pantalla de inicio.'**
  String get widgetPaso1;

  /// No description provided for @widgetPaso2.
  ///
  /// In es, this message translates to:
  /// **'Toca «Widgets» y busca Te Tengo.'**
  String get widgetPaso2;

  /// No description provided for @widgetPaso3.
  ///
  /// In es, this message translates to:
  /// **'Elige el tamaño y suéltalo.'**
  String get widgetPaso3;

  /// No description provided for @widgetPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Muestra el estado, nunca imágenes de la casa.'**
  String get widgetPrivacidad;

  /// No description provided for @pcsSinInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin internet'**
  String get pcsSinInternet;

  /// No description provided for @pcsRevisaConexion.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión y vuelve a intentarlo.'**
  String get pcsRevisaConexion;

  /// No description provided for @pcsSinInternetReintenta.
  ///
  /// In es, this message translates to:
  /// **'Sin internet. Vuelve a intentarlo.'**
  String get pcsSinInternetReintenta;

  /// No description provided for @pcsAgregarPc.
  ///
  /// In es, this message translates to:
  /// **'Agregar PC'**
  String get pcsAgregarPc;

  /// No description provided for @pcsEscanearQr.
  ///
  /// In es, this message translates to:
  /// **'Escanear el código QR'**
  String get pcsEscanearQr;

  /// No description provided for @pcsEscribirCodigo.
  ///
  /// In es, this message translates to:
  /// **'Escribir el código'**
  String get pcsEscribirCodigo;

  /// No description provided for @pcsBuscandoPc.
  ///
  /// In es, this message translates to:
  /// **'Buscando la PC…'**
  String get pcsBuscandoPc;

  /// No description provided for @pcsCodigoVencidoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Este código ya venció o ya se usó'**
  String get pcsCodigoVencidoTitulo;

  /// No description provided for @pcsCodigoVencidoTexto.
  ///
  /// In es, this message translates to:
  /// **'La PC ya muestra uno nuevo: escríbelo o escanéalo.'**
  String get pcsCodigoVencidoTexto;

  /// No description provided for @pcsDemasiadosIntentos.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos'**
  String get pcsDemasiadosIntentos;

  /// No description provided for @pcsYaVinculadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Esta PC ya está vinculada'**
  String get pcsYaVinculadaTitulo;

  /// No description provided for @pcsYaVinculadaTexto.
  ///
  /// In es, this message translates to:
  /// **'La encuentras en Cámaras y PCs.'**
  String get pcsYaVinculadaTexto;

  /// No description provided for @pcsCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get pcsCancelar;

  /// No description provided for @pcsCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get pcsCerrar;

  /// No description provided for @pcsListo.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get pcsListo;

  /// No description provided for @pcsFaltaElegirCamaras.
  ///
  /// In es, this message translates to:
  /// **'Falta elegir las cámaras'**
  String get pcsFaltaElegirCamaras;

  /// No description provided for @pcsElegirCamaras.
  ///
  /// In es, this message translates to:
  /// **'Elegir las cámaras'**
  String get pcsElegirCamaras;

  /// Label of the PC's operating system row.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get pcsSistema;

  /// Label of the row with the Te Tengo Captura version.
  ///
  /// In es, this message translates to:
  /// **'Programa'**
  String get pcsPrograma;

  /// No description provided for @pcsRegistrarConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Registrar consentimiento'**
  String get pcsRegistrarConsentimiento;

  /// nombre: first name of the cared-for person.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento de {nombre}'**
  String pcsFaltaConsentimientoDe(String nombre);

  /// No description provided for @pcsQueRevisar.
  ///
  /// In es, this message translates to:
  /// **'Qué revisar'**
  String get pcsQueRevisar;

  /// No description provided for @pcsSinConexion.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get pcsSinConexion;

  /// No description provided for @pcsEnLinea.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get pcsEnLinea;

  /// hora: an already formatted time.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión desde las {hora}.'**
  String pcsSinConexionDesdeLas(String hora);

  /// nombre: the PC's name, e.g. «Sala-Rosa».
  ///
  /// In es, this message translates to:
  /// **'La PC {nombre} no responde'**
  String pcsPcNoResponde(String nombre);

  /// No description provided for @pcsPcNoRespondeDesde.
  ///
  /// In es, this message translates to:
  /// **'La PC {nombre} no responde desde las {hora}'**
  String pcsPcNoRespondeDesde(String nombre, String hora);

  /// No description provided for @pcsPcNombre.
  ///
  /// In es, this message translates to:
  /// **'PC {nombre}'**
  String pcsPcNombre(String nombre);

  /// No description provided for @pcsDejarDeUsar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de usar'**
  String get pcsDejarDeUsar;

  /// Topic of a «?» help button: «Más información: vista previa».
  ///
  /// In es, this message translates to:
  /// **'vista previa'**
  String get pcsVistaPreviaTema;

  /// No description provided for @pcsNCamaras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara} other{{n} cámaras}}'**
  String pcsNCamaras(int n);

  /// No description provided for @pcsNCamarasSinUsar.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara sin usar} other{{n} cámaras sin usar}}'**
  String pcsNCamarasSinUsar(int n);

  /// No description provided for @pcsUnaPorHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Una cámara por habitación.'**
  String get pcsUnaPorHabitacion;

  /// No description provided for @pcsBuscarDeNuevo.
  ///
  /// In es, this message translates to:
  /// **'Buscar de nuevo'**
  String get pcsBuscarDeNuevo;

  /// No description provided for @pcsEstadoSinConexionDesde.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión desde las {hora}'**
  String pcsEstadoSinConexionDesde(String hora);

  /// hace: «hace 6 s» / «6 s ago».
  ///
  /// In es, this message translates to:
  /// **'En línea · última señal {hace}'**
  String pcsEstadoEnLineaSenal(String hace);

  /// No description provided for @pcsRevisarEncendida.
  ///
  /// In es, this message translates to:
  /// **'Que la PC esté encendida'**
  String get pcsRevisarEncendida;

  /// No description provided for @pcsRevisarEncendidaDetalle.
  ///
  /// In es, this message translates to:
  /// **'Sin suspender'**
  String get pcsRevisarEncendidaDetalle;

  /// No description provided for @pcsRevisarInternet.
  ///
  /// In es, this message translates to:
  /// **'Que tenga internet'**
  String get pcsRevisarInternet;

  /// No description provided for @pcsRevisarInternetDetalle.
  ///
  /// In es, this message translates to:
  /// **'Con la luz del módem encendida'**
  String get pcsRevisarInternetDetalle;

  /// No description provided for @pcsRevisarCaptura.
  ///
  /// In es, this message translates to:
  /// **'Que Te Tengo Captura esté abierto'**
  String get pcsRevisarCaptura;

  /// No description provided for @pcsRevisarCapturaDetalle.
  ///
  /// In es, this message translates to:
  /// **'Junto al reloj de Windows'**
  String get pcsRevisarCapturaDetalle;

  /// Screen reader label of a room chip that cannot be chosen.
  ///
  /// In es, this message translates to:
  /// **'{habitacion}, ya tiene cámara'**
  String pcsChipOcupada(String habitacion);

  /// dispositivo: the webcam's name, e.g. «Webcam USB HD».
  ///
  /// In es, this message translates to:
  /// **'¿Dejar de usar la cámara {dispositivo}?'**
  String pcsDejarDeUsarTitulo(String dispositivo);

  /// enHabitacion: «en la Sala» / «in the Sala».
  ///
  /// In es, this message translates to:
  /// **'No detectaremos caídas {enHabitacion}. Puedes volver a elegirla.'**
  String pcsDejarDeUsarTexto(String enHabitacion);

  /// No description provided for @pcsDejamosDeUsar.
  ///
  /// In es, this message translates to:
  /// **'Dejamos de usar la cámara {dispositivo}'**
  String pcsDejamosDeUsar(String dispositivo);

  /// No description provided for @pcsYaNoDetectamos.
  ///
  /// In es, this message translates to:
  /// **'Ya no detectamos caídas {enHabitacion}.'**
  String pcsYaNoDetectamos(String enHabitacion);

  /// No description provided for @pcsCodigoNoExiste.
  ///
  /// In es, this message translates to:
  /// **'Ese código no existe. Revísalo letra por letra.'**
  String get pcsCodigoNoExiste;

  /// No description provided for @pcsCodigoFormato.
  ///
  /// In es, this message translates to:
  /// **'El código tiene 8 letras, solo consonantes y sin números.'**
  String get pcsCodigoFormato;

  /// No description provided for @pcsCodigoVencido.
  ///
  /// In es, this message translates to:
  /// **'Este código venció o ya se usó. La PC ya muestra uno nuevo.'**
  String get pcsCodigoVencido;

  /// No description provided for @pcsBloqueoQuinceMinutos.
  ///
  /// In es, this message translates to:
  /// **'Podrás volver a intentarlo en 15 minutos.'**
  String get pcsBloqueoQuinceMinutos;

  /// No description provided for @pcsBloqueoHasta.
  ///
  /// In es, this message translates to:
  /// **'Podrás volver a intentarlo a las {hora}.'**
  String pcsBloqueoHasta(String hora);

  /// No description provided for @pcsCampoCodigoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Código de la PC, 8 letras'**
  String get pcsCampoCodigoEtiqueta;

  /// No description provided for @pcsEscribeElCodigo.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código de la PC'**
  String get pcsEscribeElCodigo;

  /// No description provided for @pcsCodigoDe8Letras.
  ///
  /// In es, this message translates to:
  /// **'Código de 8 letras'**
  String get pcsCodigoDe8Letras;

  /// No description provided for @pcsSoloConsonantes.
  ///
  /// In es, this message translates to:
  /// **'El código solo lleva consonantes, sin números'**
  String get pcsSoloConsonantes;

  /// No description provided for @pcsCodigoDondeEsta.
  ///
  /// In es, this message translates to:
  /// **'Está debajo del QR, en Te Tengo Captura.'**
  String get pcsCodigoDondeEsta;

  /// No description provided for @pcsContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get pcsContinuar;

  /// No description provided for @pcsQrAjenoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ese código no es de Te Tengo Captura'**
  String get pcsQrAjenoTitulo;

  /// No description provided for @pcsQrAjenoTexto.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código QR que muestra la PC.'**
  String get pcsQrAjenoTexto;

  /// No description provided for @pcsVolver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get pcsVolver;

  /// No description provided for @pcsCamaraDelCelular.
  ///
  /// In es, this message translates to:
  /// **'Cámara del celular'**
  String get pcsCamaraDelCelular;

  /// No description provided for @pcsApuntaAlQr.
  ///
  /// In es, this message translates to:
  /// **'Apunta al QR de la PC'**
  String get pcsApuntaAlQr;

  /// No description provided for @pcsLinterna.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get pcsLinterna;

  /// No description provided for @pcsExplicarCamara.
  ///
  /// In es, this message translates to:
  /// **'Te Tengo usará la cámara para leer el QR.'**
  String get pcsExplicarCamara;

  /// No description provided for @pcsNoGuardaImagenes.
  ///
  /// In es, this message translates to:
  /// **'No guarda imágenes.'**
  String get pcsNoGuardaImagenes;

  /// No description provided for @pcsPermitir.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get pcsPermitir;

  /// No description provided for @pcsCamaraBloqueada.
  ///
  /// In es, this message translates to:
  /// **'La cámara del celular está bloqueada'**
  String get pcsCamaraBloqueada;

  /// No description provided for @pcsAbrirAjustesCelular.
  ///
  /// In es, this message translates to:
  /// **'Abrir los ajustes del celular'**
  String get pcsAbrirAjustesCelular;

  /// No description provided for @pcsNoPuedesEscanear.
  ///
  /// In es, this message translates to:
  /// **'¿No puedes escanearlo?'**
  String get pcsNoPuedesEscanear;

  /// No description provided for @pcsNoVinculamosTitulo.
  ///
  /// In es, this message translates to:
  /// **'No vinculamos la PC'**
  String get pcsNoVinculamosTitulo;

  /// No description provided for @pcsNoVinculamosTexto.
  ///
  /// In es, this message translates to:
  /// **'La PC no tendrá acceso. No escanees códigos ajenos.'**
  String get pcsNoVinculamosTexto;

  /// No description provided for @pcsEntendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get pcsEntendido;

  /// No description provided for @pcsAprobarLaPc.
  ///
  /// In es, this message translates to:
  /// **'Aprobar la PC'**
  String get pcsAprobarLaPc;

  /// No description provided for @pcsVolverAIntentarlo.
  ///
  /// In es, this message translates to:
  /// **'Volver a intentarlo'**
  String get pcsVolverAIntentarlo;

  /// nombre: first name of the cared-for person.
  ///
  /// In es, this message translates to:
  /// **'¿Vinculamos esta PC a la casa de {nombre}?'**
  String pcsVinculamosPregunta(String nombre);

  /// No description provided for @pcsNoPudimosVincular.
  ///
  /// In es, this message translates to:
  /// **'No pudimos vincular la PC'**
  String get pcsNoPudimosVincular;

  /// No description provided for @pcsNombreDeLaPc.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la PC'**
  String get pcsNombreDeLaPc;

  /// No description provided for @pcsCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get pcsCodigo;

  /// No description provided for @pcsSiLaApruebas.
  ///
  /// In es, this message translates to:
  /// **'Si la apruebas, esta PC podrá:'**
  String get pcsSiLaApruebas;

  /// No description provided for @pcsPermisoDetectar.
  ///
  /// In es, this message translates to:
  /// **'Detectar caídas con sus cámaras'**
  String get pcsPermisoDetectar;

  /// No description provided for @pcsPermisoAvisos.
  ///
  /// In es, this message translates to:
  /// **'Enviar avisos y clips de 12 s'**
  String get pcsPermisoAvisos;

  /// No description provided for @pcsPermisoVivo.
  ///
  /// In es, this message translates to:
  /// **'Mostrar la vista en vivo'**
  String get pcsPermisoVivo;

  /// No description provided for @pcsApruebalaSolo.
  ///
  /// In es, this message translates to:
  /// **'Apruébala solo si estás frente a la PC de {nombre} o tú la instalaste.'**
  String pcsApruebalaSolo(String nombre);

  /// Ends «Solo Rosa (titular) puede …» / «Only Rosa (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'vincular una PC. Pídele que escanee el código'**
  String get pcsAccionVincularPc;

  /// No description provided for @pcsAprobar.
  ///
  /// In es, this message translates to:
  /// **'Aprobar'**
  String get pcsAprobar;

  /// No description provided for @pcsVinculando.
  ///
  /// In es, this message translates to:
  /// **'Vinculando…'**
  String get pcsVinculando;

  /// No description provided for @pcsNoReconozco.
  ///
  /// In es, this message translates to:
  /// **'No reconozco esta PC'**
  String get pcsNoReconozco;

  /// No description provided for @pcsVinculaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Vincula la PC de la casa'**
  String get pcsVinculaTitulo;

  /// Ends «Solo Rosa (titular) puede …» / «Only Rosa (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'agregar una PC'**
  String get pcsAccionAgregarPc;

  /// No description provided for @pcsPasoInstalar.
  ///
  /// In es, this message translates to:
  /// **'Instala Te Tengo Captura en la PC'**
  String get pcsPasoInstalar;

  /// pagina: the download web address.
  ///
  /// In es, this message translates to:
  /// **'Desde {pagina}'**
  String pcsPasoInstalarDesde(String pagina);

  /// No description provided for @pcsPasoAbrir.
  ///
  /// In es, this message translates to:
  /// **'Ábrelo: muestra un código QR'**
  String get pcsPasoAbrir;

  /// No description provided for @pcsPasoEscanear.
  ///
  /// In es, this message translates to:
  /// **'Escanea el QR con este celular'**
  String get pcsPasoEscanear;

  /// No description provided for @pcsEstaVinculada.
  ///
  /// In es, this message translates to:
  /// **'La PC {nombre} está vinculada'**
  String pcsEstaVinculada(String nombre);

  /// No description provided for @pcsCamarasYaElegidas.
  ///
  /// In es, this message translates to:
  /// **'Sus cámaras ya están elegidas.'**
  String get pcsCamarasYaElegidas;

  /// No description provided for @pcsAhoraElige.
  ///
  /// In es, this message translates to:
  /// **'Ahora elige sus cámaras desde aquí.'**
  String get pcsAhoraElige;

  /// No description provided for @pcsSinElNoEnvian.
  ///
  /// In es, this message translates to:
  /// **'Sin él, las cámaras no envían nada.'**
  String get pcsSinElNoEnvian;

  /// No description provided for @pcsCompletarConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Completar el consentimiento'**
  String get pcsCompletarConsentimiento;

  /// No description provided for @pcsHacerloDespues.
  ///
  /// In es, this message translates to:
  /// **'Hacerlo después'**
  String get pcsHacerloDespues;

  /// No description provided for @pcsSinCamarasNoDetectamos.
  ///
  /// In es, this message translates to:
  /// **'Sin cámaras elegidas no detectamos caídas.'**
  String get pcsSinCamarasNoDetectamos;

  /// No description provided for @pcsPc.
  ///
  /// In es, this message translates to:
  /// **'PC'**
  String get pcsPc;

  /// Label of the row with the date the PC was linked.
  ///
  /// In es, this message translates to:
  /// **'Vinculada'**
  String get pcsVinculada;

  /// fecha: 03/08/2026; nombre: who approved it.
  ///
  /// In es, this message translates to:
  /// **'{fecha} por {nombre}'**
  String pcsVinculadaPor(String fecha, String nombre);

  /// No description provided for @pcsUltimaSenal.
  ///
  /// In es, this message translates to:
  /// **'Última señal'**
  String get pcsUltimaSenal;

  /// No description provided for @pcsCamarasDeEstaPc.
  ///
  /// In es, this message translates to:
  /// **'Cámaras de esta PC'**
  String get pcsCamarasDeEstaPc;

  /// No description provided for @pcsUsaOtraCamara.
  ///
  /// In es, this message translates to:
  /// **'Usa otra cámara o deja de usar una'**
  String get pcsUsaOtraCamara;

  /// No description provided for @pcsQuitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get pcsQuitar;

  /// No description provided for @pcsQuitarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Deja de detectar caídas con esta PC.'**
  String get pcsQuitarExplicacion;

  /// No description provided for @pcsQuitarEstaPc.
  ///
  /// In es, this message translates to:
  /// **'Quitar esta PC'**
  String get pcsQuitarEstaPc;

  /// Ends «Solo Rosa (titular) puede …» / «Only Rosa (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'elegir las cámaras o quitar esta PC'**
  String get pcsAccionElegirOQuitar;

  /// No description provided for @pcsQuitarPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar la PC {nombre}?'**
  String pcsQuitarPregunta(String nombre);

  /// habitaciones: «Sala y Cocina» / «Sala and Cocina».
  ///
  /// In es, this message translates to:
  /// **'Dejaremos de detectar caídas en {habitaciones}. La PC volverá a mostrar su QR.'**
  String pcsQuitarTextoHabitaciones(String habitaciones);

  /// No description provided for @pcsQuitarTexto.
  ///
  /// In es, this message translates to:
  /// **'La PC volverá a mostrar su QR.'**
  String get pcsQuitarTexto;

  /// No description provided for @pcsQuitarLaPc.
  ///
  /// In es, this message translates to:
  /// **'Quitar la PC'**
  String get pcsQuitarLaPc;

  /// No description provided for @pcsQuitamos.
  ///
  /// In es, this message translates to:
  /// **'Quitamos la PC {nombre}'**
  String pcsQuitamos(String nombre);

  /// No description provided for @pcsDejaraDeCapturar.
  ///
  /// In es, this message translates to:
  /// **'Dejará de capturar en cuanto se conecte.'**
  String get pcsDejaraDeCapturar;

  /// No description provided for @pcsCamaras.
  ///
  /// In es, this message translates to:
  /// **'Cámaras'**
  String get pcsCamaras;

  /// No description provided for @pcsFaltaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Falta el consentimiento'**
  String get pcsFaltaConsentimiento;

  /// No description provided for @pcsSinElNoDetectamos.
  ///
  /// In es, this message translates to:
  /// **'Sin él no detectamos caídas.'**
  String get pcsSinElNoDetectamos;

  /// No description provided for @pcsVerTodas.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get pcsVerTodas;

  /// No description provided for @pcsOrdenar.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get pcsOrdenar;

  /// Screen reader label of the row of PC filter chips.
  ///
  /// In es, this message translates to:
  /// **'Ver las cámaras de'**
  String get pcsFiltroSemantica;

  /// Filter chip: the cameras of every PC.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get pcsTodas;

  /// No description provided for @pcsNecesitanAtencion.
  ///
  /// In es, this message translates to:
  /// **'Necesitan atención'**
  String get pcsNecesitanAtencion;

  /// No description provided for @pcsFuncionando.
  ///
  /// In es, this message translates to:
  /// **'Funcionando'**
  String get pcsFuncionando;

  /// No description provided for @pcsDetenidas.
  ///
  /// In es, this message translates to:
  /// **'Detenidas'**
  String get pcsDetenidas;

  /// No description provided for @pcsPcsDeLaCasa.
  ///
  /// In es, this message translates to:
  /// **'PCs de la casa'**
  String get pcsPcsDeLaCasa;

  /// Ends «Solo Rosa (titular) puede …» / «Only Rosa (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'agregar o quitar PCs'**
  String get pcsAccionAgregarOQuitar;

  /// No description provided for @pcsAtencionPcSinConexion.
  ///
  /// In es, this message translates to:
  /// **'PC {nombre} sin conexión'**
  String pcsAtencionPcSinConexion(String nombre);

  /// habitacion: one room or a list of rooms.
  ///
  /// In es, this message translates to:
  /// **'{habitacion} sin conexión'**
  String pcsAtencionSinConexion(String habitacion);

  /// No description provided for @pcsAtencionEnPc.
  ///
  /// In es, this message translates to:
  /// **'En la PC {nombre}'**
  String pcsAtencionEnPc(String nombre);

  /// No description provided for @pcsAtencionEnPcElige.
  ///
  /// In es, this message translates to:
  /// **'En la PC {nombre} · elige en qué habitación está'**
  String pcsAtencionEnPcElige(String nombre);

  /// No description provided for @pcsReanudarAhora.
  ///
  /// In es, this message translates to:
  /// **'Reanudar ahora'**
  String get pcsReanudarAhora;

  /// No description provided for @pcsAtencionDesconectada.
  ///
  /// In es, this message translates to:
  /// **'{habitacion}: cámara desconectada'**
  String pcsAtencionDesconectada(String habitacion);

  /// No description provided for @pcsDesdeLas.
  ///
  /// In es, this message translates to:
  /// **'Desde las {hora}'**
  String pcsDesdeLas(String hora);

  /// No description provided for @pcsAtencionEnPausa.
  ///
  /// In es, this message translates to:
  /// **'{habitacion} en pausa'**
  String pcsAtencionEnPausa(String habitacion);

  /// No description provided for @pcsAtencionHastaLas.
  ///
  /// In es, this message translates to:
  /// **'Hasta las {hora} · se reactiva sola'**
  String pcsAtencionHastaLas(String hora);

  /// No description provided for @pcsAtencionNoConfiable.
  ///
  /// In es, this message translates to:
  /// **'Detección no confiable · {habitacion}'**
  String pcsAtencionNoConfiable(String habitacion);

  /// No description provided for @pcsAtencionRevisaLuz.
  ///
  /// In es, this message translates to:
  /// **'Revisa la luz y el encuadre'**
  String get pcsAtencionRevisaLuz;

  /// No description provided for @pcsAunNoHayPc.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay una PC vinculada'**
  String get pcsAunNoHayPc;

  /// No description provided for @pcsLineaSinCamaras.
  ///
  /// In es, this message translates to:
  /// **'Sin cámaras'**
  String get pcsLineaSinCamaras;

  /// No description provided for @pcsLineaFunciona.
  ///
  /// In es, this message translates to:
  /// **'Funciona · {habitacion}'**
  String pcsLineaFunciona(String habitacion);

  /// No description provided for @pcsLineaFuncionan.
  ///
  /// In es, this message translates to:
  /// **'{ok, plural, =1{{ok} de {n} funciona} other{{ok} de {n} funcionan}}'**
  String pcsLineaFuncionan(int ok, int n);

  /// No description provided for @pcsResumenSinCamaras.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cámaras elegidas'**
  String get pcsResumenSinCamaras;

  /// No description provided for @pcsResumenDetenidas.
  ///
  /// In es, this message translates to:
  /// **'detenidas'**
  String get pcsResumenDetenidas;

  /// No description provided for @pcsResumenFuncionaBien.
  ///
  /// In es, this message translates to:
  /// **'funciona bien'**
  String get pcsResumenFuncionaBien;

  /// No description provided for @pcsResumenTodasBien.
  ///
  /// In es, this message translates to:
  /// **'todas funcionan bien'**
  String get pcsResumenTodasBien;

  /// No description provided for @pcsResumenNoFunciona.
  ///
  /// In es, this message translates to:
  /// **'no funciona ahora'**
  String get pcsResumenNoFunciona;

  /// No description provided for @pcsResumenNingunaFunciona.
  ///
  /// In es, this message translates to:
  /// **'ninguna funciona ahora'**
  String get pcsResumenNingunaFunciona;

  /// No description provided for @pcsResumenAlgunasBien.
  ///
  /// In es, this message translates to:
  /// **'{ok, plural, =1{1 funciona bien} other{{ok} funcionan bien}}'**
  String pcsResumenAlgunasBien(int ok);

  /// No description provided for @pcsEscribeNombreHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre de la habitación.'**
  String get pcsEscribeNombreHabitacion;

  /// No description provided for @pcsSinBano.
  ///
  /// In es, this message translates to:
  /// **'Por privacidad, Te Tengo no admite cámaras en el baño.'**
  String get pcsSinBano;

  /// No description provided for @pcsOcupada.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una cámara {enHabitacion}. Por ahora, cada habitación usa una sola cámara.'**
  String pcsOcupada(String enHabitacion);

  /// No description provided for @pcsOcupadaConPc.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una cámara {enHabitacion} (PC {pc}). Por ahora, cada habitación usa una sola cámara.'**
  String pcsOcupadaConPc(String enHabitacion, String pc);

  /// laHabitacion: «la Sala» / «the Sala».
  ///
  /// In es, this message translates to:
  /// **'La cámara {dispositivo} cuida ahora {laHabitacion}'**
  String pcsCuidaAhora(String dispositivo, String laHabitacion);

  /// No description provided for @pcsProximasAlertas.
  ///
  /// In es, this message translates to:
  /// **'Las próximas alertas dirán «{enHabitacion}».'**
  String pcsProximasAlertas(String enHabitacion);

  /// No description provided for @pcsDetectaraConConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Detectará caídas cuando registres el consentimiento.'**
  String get pcsDetectaraConConsentimiento;

  /// No description provided for @pcsEligeLasCamaras.
  ///
  /// In es, this message translates to:
  /// **'Elige las cámaras'**
  String get pcsEligeLasCamaras;

  /// No description provided for @pcsCamarasEnLaPc.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cámara en la PC {pc}. Una por habitación.} other{{n} cámaras en la PC {pc}. Una por habitación.}}'**
  String pcsCamarasEnLaPc(int n, String pc);

  /// No description provided for @pcsSinElNoHayVistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Sin él no hay vista previa ni detección.'**
  String get pcsSinElNoHayVistaPrevia;

  /// Ends «Solo Rosa (titular) puede …» / «Only Rosa (owner) can …».
  ///
  /// In es, this message translates to:
  /// **'elegir las cámaras'**
  String get pcsAccionElegirCamaras;

  /// No description provided for @pcsQueRevisarEnCasa.
  ///
  /// In es, this message translates to:
  /// **'Qué revisar en la casa'**
  String get pcsQueRevisarEnCasa;

  /// No description provided for @pcsDeteccionLenta.
  ///
  /// In es, this message translates to:
  /// **'Si la detección va lenta, pasa cámaras a otra PC.'**
  String get pcsDeteccionLenta;

  /// No description provided for @pcsFaltaUna.
  ///
  /// In es, this message translates to:
  /// **'¿Falta una? Que la conecten por USB.'**
  String get pcsFaltaUna;

  /// No description provided for @pcsVerVistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Ver vista previa'**
  String get pcsVerVistaPrevia;

  /// No description provided for @pcsAyudaVistaPrevia.
  ///
  /// In es, this message translates to:
  /// **'Muestra lo que ve la cámara durante 15 s. No se graba y queda en el registro de accesos.'**
  String get pcsAyudaVistaPrevia;

  /// No description provided for @pcsRevisaCableConserva.
  ///
  /// In es, this message translates to:
  /// **'Revisa el cable USB. {habitacion} conserva esta cámara.'**
  String pcsRevisaCableConserva(String habitacion);

  /// No description provided for @pcsPideConectarUsb.
  ///
  /// In es, this message translates to:
  /// **'Pide que la conecten por USB.'**
  String get pcsPideConectarUsb;

  /// No description provided for @pcsEnQueHabitacion.
  ///
  /// In es, this message translates to:
  /// **'¿En qué habitación está?'**
  String get pcsEnQueHabitacion;

  /// Topic of a «?» help button: «Más información: habitaciones».
  ///
  /// In es, this message translates to:
  /// **'habitaciones'**
  String get pcsHabitacionesTema;

  /// Chip to type a room name that is not offered.
  ///
  /// In es, this message translates to:
  /// **'Otra…'**
  String get pcsOtra;

  /// No description provided for @pcsYaTienenCamara.
  ///
  /// In es, this message translates to:
  /// **'Las que ya tienen cámara no se pueden elegir.'**
  String get pcsYaTienenCamara;

  /// No description provided for @pcsNombreHabitacion.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la habitación'**
  String get pcsNombreHabitacion;

  /// No description provided for @pcsNombreHabitacionEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Estudio'**
  String get pcsNombreHabitacionEjemplo;

  /// No description provided for @pcsUsarEstaCamara.
  ///
  /// In es, this message translates to:
  /// **'Usar esta cámara'**
  String get pcsUsarEstaCamara;

  /// No description provided for @pcsBuscandoCamaras.
  ///
  /// In es, this message translates to:
  /// **'Buscando cámaras en la PC {pc}…'**
  String pcsBuscandoCamaras(String pc);

  /// No description provided for @pcsNoEncontramosCamaras.
  ///
  /// In es, this message translates to:
  /// **'No encontramos cámaras en la PC {pc}'**
  String pcsNoEncontramosCamaras(String pc);

  /// No description provided for @pcsConectenWebcam.
  ///
  /// In es, this message translates to:
  /// **'Que conecten una webcam por USB.'**
  String get pcsConectenWebcam;

  /// No description provided for @pcsWebcamDesconectadaEn.
  ///
  /// In es, this message translates to:
  /// **'Desconectada · {habitacion}'**
  String pcsWebcamDesconectadaEn(String habitacion);

  /// No description provided for @pcsWebcamEnUsoPausa.
  ///
  /// In es, this message translates to:
  /// **'En uso · {habitacion} · en pausa'**
  String pcsWebcamEnUsoPausa(String habitacion);

  /// No description provided for @pcsWebcamEnUso.
  ///
  /// In es, this message translates to:
  /// **'En uso · {habitacion}'**
  String pcsWebcamEnUso(String habitacion);

  /// No description provided for @pcsWebcamDesconectada.
  ///
  /// In es, this message translates to:
  /// **'Desconectada'**
  String get pcsWebcamDesconectada;

  /// No description provided for @pcsWebcamSinUsar.
  ///
  /// In es, this message translates to:
  /// **'Sin usar'**
  String get pcsWebcamSinUsar;

  /// No description provided for @pcsCamaraDesconectada.
  ///
  /// In es, this message translates to:
  /// **'La cámara está desconectada'**
  String get pcsCamaraDesconectada;

  /// No description provided for @pcsRevisenCable.
  ///
  /// In es, this message translates to:
  /// **'Que revisen el cable USB.'**
  String get pcsRevisenCable;

  /// No description provided for @pcsSinElNoHayVideo.
  ///
  /// In es, this message translates to:
  /// **'Sin él no hay video.'**
  String get pcsSinElNoHayVideo;

  /// No description provided for @pcsCamaraEnPausa.
  ///
  /// In es, this message translates to:
  /// **'La cámara está en pausa'**
  String get pcsCamaraEnPausa;

  /// No description provided for @pcsHastaLas.
  ///
  /// In es, this message translates to:
  /// **'Hasta las {hora}.'**
  String pcsHastaLas(String hora);

  /// No description provided for @pcsAccesoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Acceso registrado'**
  String get pcsAccesoRegistrado;

  /// duracion: already formatted, e.g. «12 s».
  ///
  /// In es, this message translates to:
  /// **'Viste la vista previa de {dispositivo} durante {duracion}.'**
  String pcsVisteVistaPrevia(String dispositivo, String duracion);

  /// No description provided for @pcsVistaPreviaDe.
  ///
  /// In es, this message translates to:
  /// **'Vista previa · {dispositivo}'**
  String pcsVistaPreviaDe(String dispositivo);

  /// No description provided for @pcsAyudaVistaPreviaCierre.
  ///
  /// In es, this message translates to:
  /// **'No se graba y queda en el registro de accesos. Se cierra sola a los {segundos} s.'**
  String pcsAyudaVistaPreviaCierre(int segundos);

  /// tiempo: countdown, e.g. «0:12».
  ///
  /// In es, this message translates to:
  /// **'VISTA PREVIA · {tiempo}'**
  String pcsVistaPreviaCuenta(String tiempo);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
