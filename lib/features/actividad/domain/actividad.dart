import '../../../core/formato.dart';
import '../../../l10n/l10n.dart';
import '../../camaras/domain/camara.dart';

/// Who made a change (contract §10 `actor.tipo`).
enum TipoActor {
  familiar('FAMILIAR'),
  pc('PC'),
  sistema('SISTEMA');

  const TipoActor(this.codigo);

  final String codigo;

  static TipoActor desde(Object? v) =>
      values.where((t) => t.codigo == v).firstOrNull ?? sistema;
}

/// An entry of the activity log (contract §10, US-33): who changed what and when, from the app
/// or from a PC. Nobody can edit or delete it.
class Actividad {
  const Actividad({
    required this.id,
    required this.ocurridaEn,
    required this.tipo,
    required this.actor,
    this.usuarioId,
    this.usuario,
    this.pcId,
    this.pc,
    this.camaraId,
    this.objeto,
    this.valorAnterior,
    this.valorNuevo,
  });

  final String id;
  final DateTime ocurridaEn;

  /// `PC_VINCULADA`, `CAMARA_ASIGNADA`… kept as text: an unknown future value gets a generic
  /// sentence.
  final String tipo;
  final TipoActor actor;
  final String? usuarioId;

  /// Full name of the family member who made it.
  final String? usuario;
  final String? pcId;

  /// The PC's name as it was then.
  final String? pc;
  final String? camaraId;
  final String? objeto;
  final String? valorAnterior;
  final String? valorNuevo;

  factory Actividad.desdeJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>? ?? const {};
    final usuario = actor['usuario'] as Map<String, dynamic>?;
    final pc = json['pc'] as Map<String, dynamic>?;
    return Actividad(
      id: json['id'] as String,
      ocurridaEn: fechaDesdeJson(json['ocurridaEn'])!,
      tipo: json['tipo'] as String? ?? '',
      actor: TipoActor.desde(actor['tipo']),
      usuarioId: usuario?['id'] as String?,
      usuario: usuario?['nombre'] as String?,
      pcId: pc?['id'] as String?,
      pc: pc?['nombre'] as String?,
      camaraId: json['camaraId'] as String?,
      objeto: json['objeto'] as String?,
      valorAnterior: json['valorAnterior'] as String?,
      valorNuevo: json['valorNuevo'] as String?,
    );
  }

  String get _quien => (usuario ?? '').trim().split(RegExp(r'\s+')).first;

  /// `REPETICION_VISTA`: the moment replayed on the PC, sent as an ISO-8601 interval
  /// `desde/hasta` in `valorAnterior` (contract §10).
  (DateTime, DateTime)? get momentoRepetido {
    final partes = (valorAnterior ?? '').split('/');
    if (partes.length != 2) return null;
    final desde = DateTime.tryParse(partes[0])?.toLocal();
    final hasta = DateTime.tryParse(partes[1])?.toLocal();
    return desde == null || hasta == null ? null : (desde, hasta);
  }

  /// `REPETICION_VISTA`: how long it was watched, in seconds (`valorNuevo`).
  int? get segundosVistos => int.tryParse(valorNuevo ?? '');

  /// «23/09 10:36–10:46», the replayed moment.
  String? _momento(AppLocalizations l) => switch (momentoRepetido) {
    (final d, final h) => l.actividadMomento(
      _diaMes(l, d),
      l.formato.hora(d),
      l.formato.hora(h),
    ),
    null => null,
  };

  /// «3 min», how long it was watched.
  String? _visto(AppLocalizations l) => switch (segundosVistos) {
    final s? => l.formato.duracion(Duration(seconds: s)),
    null => null,
  };

  /// The row's sentence, with the prototype's pattern: «Carmen vinculó la PC Cocina-Rosa»,
  /// «Desde la PC Sala-Rosa: la cámara Logitech C920 pasó a Dormitorio», «Terminó la pausa de la
  /// Sala». [adultoMayor] is the older adult's first name.
  ///
  /// Room names go with their Spanish article forms («de la Sala», «al Dormitorio») for the
  /// Spanish messages and bare for the other languages.
  String frase(AppLocalizations l, {required String adultoMayor}) {
    final o = objeto ?? '';
    final antes = valorAnterior;
    final despues = valorNuevo;
    String familiar(String accion) => l.actividadFraseFamiliar(_quien, accion);
    String desdePc(String accion) =>
        l.actividadFraseDesdePc(pc ?? objeto ?? '', accion);
    String segun(String accion) => switch (actor) {
      TipoActor.familiar => familiar(accion),
      TipoActor.pc => desdePc(accion),
      TipoActor.sistema => mayusculaInicial(accion),
    };
    switch (tipo) {
      case 'PC_VINCULADA':
        return segun(l.actividadVinculoPc(o));
      case 'PC_RENOMBRADA':
        return segun(l.actividadRenombroPc(antes ?? o, despues ?? ''));
      case 'PC_DESVINCULADA':
        return switch (actor) {
          TipoActor.familiar => familiar(l.actividadQuitoPc(o)),
          TipoActor.pc when despues == 'RESTABLECIDA' =>
            l.actividadPcRestablecida(pc ?? o),
          TipoActor.pc when despues == 'DESINSTALADA' =>
            l.actividadPcDesinstalada(pc ?? o),
          TipoActor.pc => desdePc(l.actividadPcSeDesvinculo),
          TipoActor.sistema =>
            despues == 'VENCIDA'
                ? l.actividadPcVencida(o)
                : l.actividadPcPorSeguridad(o),
        };
      case 'CAMARA_ASIGNADA':
        final a = despues == null ? '' : conArticulo(despues);
        return switch (actor) {
          TipoActor.pc => desdePc(l.actividadCamaraPasoA(o, despues ?? '')),
          _ when antes == null => segun(
            l.actividadEligioCamara(o, a, despues ?? ''),
          ),
          _ => segun(
            l.actividadPasoCamara(
              o,
              deHabitacion(antes),
              a.startsWith('el ') ? 'al ${a.substring(3)}' : 'a $a',
              antes,
              despues ?? '',
            ),
          ),
        };
      case 'CAMARA_RETIRADA':
        return actor == TipoActor.pc
            ? desdePc(l.actividadSeDejoDeUsarCamara(o))
            : segun(l.actividadDejoDeUsarCamara(o));
      case 'AMBIENTE_RENOMBRADO':
        return segun(
          l.actividadRenombroHabitacion(
            deHabitacion(antes ?? o),
            despues ?? '',
            antes ?? o,
          ),
        );
      case 'CAMARA_PAUSADA':
        final hasta = fechaDesdeJson(despues);
        return segun(
          hasta == null
              ? l.actividadPausoCamara(deHabitacion(o), o)
              : l.actividadPausoCamaraHasta(
                  deHabitacion(o),
                  _hasta(l, hasta),
                  o,
                ),
        );
      case 'CAMARA_REANUDADA':
        return actor == TipoActor.sistema
            ? l.actividadTerminoPausa(deHabitacion(o), o)
            : segun(l.actividadReanudoCamara(deHabitacion(o), o));
      case 'FOTO_ADULTO_MAYOR_CAMBIADA':
        return segun(l.actividadCambioFoto(o.isEmpty ? adultoMayor : o));
      case 'FOTO_ADULTO_MAYOR_QUITADA':
        return segun(l.actividadQuitoFoto(o.isEmpty ? adultoMayor : o));
      case 'CONSENTIMIENTO_OTORGADO':
        return segun(l.actividadRegistroConsentimiento);
      case 'CONSENTIMIENTO_REVOCADO':
        return segun(l.actividadRevocoConsentimiento);
      case 'CONSENTIMIENTO_MOVIMIENTOS_OTORGADO':
        return segun(l.actividadRegistroPermisoMovimientos(adultoMayor));
      case 'CONSENTIMIENTO_MOVIMIENTOS_REVOCADO':
        return actor == TipoActor.sistema
            ? l.actividadMovimientosRevocados(adultoMayor)
            : segun(l.actividadDejoDeGuardarMovimientos(adultoMayor));
      case 'RETENCION_MOVIMIENTOS_CAMBIADA':
        final (de, a) = _plazos(l, antes, despues);
        return segun(l.actividadCambioRetencion(de, a));
      case 'MODO_AVANZADO_ACTIVADO':
        return segun(l.actividadModoAvanzadoActivado);
      case 'MODO_AVANZADO_DESACTIVADO':
        return segun(l.actividadModoAvanzadoDesactivado);
      case 'GUARDADO_LOCAL_CAMBIADO':
        return segun(
          l.actividadGuardadoCambio(
            _minuscula(o.isEmpty ? l.actividadGuardadoEnPc : o),
            antes ?? l.actividadNo,
            despues ?? l.actividadNo,
          ),
        );
      case 'DATOS_LOCALES_ELIMINADOS':
        return segun(l.actividadBorroDatos);
      case 'REPETICION_VISTA':
        final detalle = [?_momento(l), ?_visto(l)].join(', ');
        final vio = o.isEmpty
            ? l.actividadVioQuePaso
            : l.actividadVioQuePasoEn(enHabitacion(o), o);
        return segun(
          detalle.isEmpty ? vio : l.actividadConDetalle(vio, detalle),
        );
      case 'PC_ACTUALIZADA':
        // «Sala-Rosa se actualizó a 0.5.0» (screen 389, US-43).
        return l.actividadPcActualizada(pc ?? o, despues ?? '').trim();
      case 'ACTUALIZACION_AUTOMATICA_ACTIVADA':
        return segun(l.actividadActualizacionAutomaticaActivada);
      case 'ACTUALIZACION_AUTOMATICA_DESACTIVADA':
        return segun(l.actividadActualizacionAutomaticaDesactivada);
      default:
        return switch (actor) {
          TipoActor.familiar => familiar(l.actividadCambioFamiliar),
          TipoActor.pc => desdePc(l.actividadCambioPc),
          TipoActor.sistema => l.actividadCambioSistema,
        };
    }
  }

  /// «Antes» and «Después» of the detail sheet, in words («Sin usar» → «Dormitorio»).
  (String, String) antesYDespues(AppLocalizations l) {
    final antes = valorAnterior;
    final despues = valorNuevo;
    return switch (tipo) {
      'PC_VINCULADA' => ('—', l.actividadVinculada),
      'PC_DESVINCULADA' => (l.actividadVinculada, l.actividadDesvinculada),
      'CAMARA_ASIGNADA' => (antes ?? l.actividadSinUsar, despues ?? '—'),
      'CAMARA_RETIRADA' => (antes ?? '—', l.actividadSinUsar),
      'CAMARA_PAUSADA' => (
        l.actividadEnLinea,
        switch (fechaDesdeJson(despues)) {
          final h? => l.actividadEnPausaHasta(_hasta(l, h)),
          null => l.actividadEnPausa,
        },
      ),
      'CAMARA_REANUDADA' => (l.actividadEnPausa, l.actividadEnLinea),
      'CONSENTIMIENTO_OTORGADO' || 'CONSENTIMIENTO_MOVIMIENTOS_OTORGADO' => (
        l.actividadNoAutorizado,
        l.actividadVigente,
      ),
      'CONSENTIMIENTO_REVOCADO' || 'CONSENTIMIENTO_MOVIMIENTOS_REVOCADO' => (
        l.actividadVigente,
        l.actividadRevocado,
      ),
      'MODO_AVANZADO_ACTIVADO' => (l.actividadDesactivado, l.actividadActivado),
      'MODO_AVANZADO_DESACTIVADO' => (
        l.actividadActivado,
        l.actividadDesactivado,
      ),
      _ => (antes ?? '—', despues ?? '—'),
    };
  }

  /// The detail rows of a replay watched on the PC, instead of «Antes» and «Después»: «Momento»
  /// and «Duración»; null for the other types.
  (String, String)? momentoYDuracion(AppLocalizations l) =>
      tipo == 'REPETICION_VISTA'
      ? (_momento(l) ?? '—', _visto(l) ?? '—')
      : null;

  /// A new version of Te Tengo Captura installed on a PC (US-43): drawn with the update icon.
  bool get esActualizacion => tipo == 'PC_ACTUALIZADA';

  /// «Quién»: the member, «Alguien en la PC», «Te Tengo», or «Te Tengo Captura» for an update
  /// (screen 390).
  String quien(AppLocalizations l) => esActualizacion
      ? (objeto ?? 'Te Tengo Captura')
      : switch (actor) {
          TipoActor.familiar => usuario ?? '—',
          TipoActor.pc => l.actividadAlguienEnPc,
          TipoActor.sistema => 'Te Tengo',
        };

  /// «Desde»: «Celular de Carmen», «PC Sala-Rosa» or «Automático».
  String desde(AppLocalizations l) => switch (actor) {
    TipoActor.familiar => l.actividadCelularDe(_quien),
    TipoActor.pc => l.actividadPc(pc ?? ''),
    TipoActor.sistema => l.actividadAutomatico,
  };

  /// «las 11:42», or «el jue 24 sep a las 07:00» when the pause ends another day.
  String _hasta(AppLocalizations l, DateTime h) => mismoDia(h, ocurridaEn)
      ? l.actividadHastaHora(l.formato.hora(h))
      : l.actividadHastaDia(l.formato.fechaCorta(h), l.formato.hora(h));
}

/// «7 días» → «30 días» reads «de 7 a 30 días» (the values come from the backend as they are).
(String, String) _plazos(AppLocalizations l, String? antes, String? despues) {
  final de = antes ?? l.actividadNoGuardar;
  final a = despues ?? l.actividadNoGuardar;
  const dias = ' días';
  if (de.endsWith(dias) && a.endsWith(dias)) {
    return (de.substring(0, de.length - dias.length), a);
  }
  return (de, a);
}

/// «23/09» in Spanish, «09/23» in English.
String _diaMes(AppLocalizations l, DateTime t) => l.actividadDiaMes(
  t.day.toString().padLeft(2, '0'),
  t.month.toString().padLeft(2, '0'),
);

String _minuscula(String t) =>
    t.isEmpty ? t : '${t[0].toLowerCase()}${t.substring(1)}';

/// A page of `GET /api/actividad`.
class PaginaActividad {
  const PaginaActividad({required this.elementos, required this.total});

  final List<Actividad> elementos;
  final int total;

  factory PaginaActividad.desdeJson(Map<String, dynamic> json) =>
      PaginaActividad(
        elementos: [
          for (final e in json['elementos'] as List<dynamic>? ?? const [])
            Actividad.desdeJson(e as Map<String, dynamic>),
        ],
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}
