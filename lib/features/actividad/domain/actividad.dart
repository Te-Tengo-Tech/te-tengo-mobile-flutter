import '../../../core/formato.dart';
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
  String? get _momento => switch (momentoRepetido) {
    (final d, final h) => '${_diaMes(d)} ${hora(d)}–${hora(h)}',
    null => null,
  };

  /// «3 min», how long it was watched.
  String? get _visto => switch (segundosVistos) {
    final s? => duracion(Duration(seconds: s)),
    null => null,
  };

  String get _desdeLaPc => 'Desde la PC ${pc ?? objeto ?? ''}';

  /// The row's sentence, with the prototype's pattern: «Carmen vinculó la PC Cocina-Rosa»,
  /// «Desde la PC Sala-Rosa: la cámara Logitech C920 pasó a Dormitorio», «Terminó la pausa de la
  /// Sala». [adultoMayor] is the older adult's first name.
  String frase({required String adultoMayor}) {
    final o = objeto ?? '';
    final antes = valorAnterior;
    final despues = valorNuevo;
    String familiar(String accion) => '$_quien $accion';
    String desdePc(String accion) => '$_desdeLaPc: $accion';
    String segun(String accion) => switch (actor) {
      TipoActor.familiar => familiar(accion),
      TipoActor.pc => desdePc(accion),
      TipoActor.sistema => mayusculaInicial(accion),
    };
    switch (tipo) {
      case 'PC_VINCULADA':
        return segun('vinculó la PC $o');
      case 'PC_RENOMBRADA':
        return segun('renombró la PC ${antes ?? o} a ${despues ?? ''}');
      case 'PC_DESVINCULADA':
        return switch (actor) {
          TipoActor.familiar => familiar('quitó la PC $o'),
          TipoActor.pc when despues == 'RESTABLECIDA' =>
            'La PC ${pc ?? o} se restableció',
          TipoActor.pc when despues == 'DESINSTALADA' =>
            'La PC ${pc ?? o} se desinstaló',
          TipoActor.pc => desdePc('se desvinculó esta PC'),
          TipoActor.sistema =>
            despues == 'VENCIDA'
                ? 'Se desvinculó la PC $o: no se conectó en 90 días'
                : 'Se desvinculó la PC $o por seguridad',
        };
      case 'CAMARA_ASIGNADA':
        final a = despues == null ? '' : conArticulo(despues);
        return switch (actor) {
          TipoActor.pc => desdePc('la cámara $o pasó a ${despues ?? ''}'),
          _ when antes == null => segun('eligió la cámara $o para $a'),
          _ => segun(
            'pasó la cámara $o ${deHabitacion(antes)} '
            '${a.startsWith('el ') ? 'al ${a.substring(3)}' : 'a $a'}',
          ),
        };
      case 'CAMARA_RETIRADA':
        return actor == TipoActor.pc
            ? desdePc('se dejó de usar la cámara $o')
            : segun('dejó de usar la cámara $o');
      case 'AMBIENTE_RENOMBRADO':
        return segun(
          'cambió el nombre de la habitación '
          '${deHabitacion(antes ?? o)} a ${despues ?? ''}',
        );
      case 'CAMARA_PAUSADA':
        final hasta = fechaDesdeJson(despues);
        return segun(
          'pausó la cámara ${deHabitacion(o)}'
          '${hasta == null ? '' : ' hasta ${_hasta(hasta)}'}',
        );
      case 'CAMARA_REANUDADA':
        return actor == TipoActor.sistema
            ? 'Terminó la pausa ${deHabitacion(o)}'
            : segun('reanudó la cámara ${deHabitacion(o)}');
      case 'FOTO_ADULTO_MAYOR_CAMBIADA':
        return segun('cambió la foto de ${o.isEmpty ? adultoMayor : o}');
      case 'FOTO_ADULTO_MAYOR_QUITADA':
        return segun('quitó la foto de ${o.isEmpty ? adultoMayor : o}');
      case 'CONSENTIMIENTO_OTORGADO':
        return segun('registró el consentimiento de monitoreo');
      case 'CONSENTIMIENTO_REVOCADO':
        return segun('revocó el consentimiento de monitoreo');
      case 'CONSENTIMIENTO_MOVIMIENTOS_OTORGADO':
        return segun(
          'registró el permiso de $adultoMayor para guardar movimientos',
        );
      case 'CONSENTIMIENTO_MOVIMIENTOS_REVOCADO':
        return actor == TipoActor.sistema
            ? 'Se dejaron de guardar los movimientos de $adultoMayor al '
                  'revocar el consentimiento'
            : segun('dejó de guardar los movimientos de $adultoMayor');
      case 'RETENCION_MOVIMIENTOS_CAMBIADA':
        final (de, a) = _plazos(antes, despues);
        return segun('cambió los movimientos en la nube de $de a $a');
      case 'MODO_AVANZADO_ACTIVADO':
        return segun('se activó el modo avanzado');
      case 'MODO_AVANZADO_DESACTIVADO':
        return segun('se desactivó el modo avanzado');
      case 'GUARDADO_LOCAL_CAMBIADO':
        return segun(
          '${_minuscula(o.isEmpty ? 'el guardado en la PC' : o)} pasó de '
          '${antes ?? 'No'} a ${despues ?? 'No'}',
        );
      case 'DATOS_LOCALES_ELIMINADOS':
        return segun('se borraron los datos guardados en la PC');
      case 'REPETICION_VISTA':
        final detalle = [?_momento, ?_visto].join(', ');
        return segun(
          'se vio qué pasó${o.isEmpty ? '' : ' ${enHabitacion(o)}'}'
          '${detalle.isEmpty ? '' : ' ($detalle)'}',
        );
      case 'PC_ACTUALIZADA':
        // «Sala-Rosa se actualizó a 0.5.0» (screen 389, US-43).
        return '${pc ?? o} se actualizó a ${despues ?? ''}'.trim();
      case 'ACTUALIZACION_AUTOMATICA_ACTIVADA':
        return segun('se activó la actualización automática');
      case 'ACTUALIZACION_AUTOMATICA_DESACTIVADA':
        return segun('se desactivó la actualización automática');
      default:
        return switch (actor) {
          TipoActor.familiar => familiar('hizo un cambio en la configuración'),
          TipoActor.pc => desdePc('hubo un cambio en la configuración'),
          TipoActor.sistema => 'Hubo un cambio en la configuración',
        };
    }
  }

  /// «Antes» and «Después» of the detail sheet, in words («Sin usar» → «Dormitorio»).
  (String, String) get antesYDespues {
    final antes = valorAnterior;
    final despues = valorNuevo;
    return switch (tipo) {
      'PC_VINCULADA' => ('—', 'Vinculada'),
      'PC_DESVINCULADA' => ('Vinculada', 'Desvinculada'),
      'CAMARA_ASIGNADA' => (antes ?? 'Sin usar', despues ?? '—'),
      'CAMARA_RETIRADA' => (antes ?? '—', 'Sin usar'),
      'CAMARA_PAUSADA' => (
        'En línea',
        switch (fechaDesdeJson(despues)) {
          final h? => 'En pausa hasta ${_hasta(h)}',
          null => 'En pausa',
        },
      ),
      'CAMARA_REANUDADA' => ('En pausa', 'En línea'),
      'CONSENTIMIENTO_OTORGADO' ||
      'CONSENTIMIENTO_MOVIMIENTOS_OTORGADO' => ('No autorizado', 'Vigente'),
      'CONSENTIMIENTO_REVOCADO' ||
      'CONSENTIMIENTO_MOVIMIENTOS_REVOCADO' => ('Vigente', 'Revocado'),
      'MODO_AVANZADO_ACTIVADO' => ('Desactivado', 'Activado'),
      'MODO_AVANZADO_DESACTIVADO' => ('Activado', 'Desactivado'),
      _ => (antes ?? '—', despues ?? '—'),
    };
  }

  /// The detail rows of a replay watched on the PC, instead of «Antes» and «Después»: «Momento»
  /// and «Duración»; null for the other types.
  (String, String)? get momentoYDuracion =>
      tipo == 'REPETICION_VISTA' ? (_momento ?? '—', _visto ?? '—') : null;

  /// A new version of Te Tengo Captura installed on a PC (US-43): drawn with the update icon.
  bool get esActualizacion => tipo == 'PC_ACTUALIZADA';

  /// «Quién»: the member, «Alguien en la PC», «Te Tengo», or «Te Tengo Captura» for an update
  /// (screen 390).
  String get quien => esActualizacion
      ? (objeto ?? 'Te Tengo Captura')
      : switch (actor) {
          TipoActor.familiar => usuario ?? '—',
          TipoActor.pc => 'Alguien en la PC',
          TipoActor.sistema => 'Te Tengo',
        };

  /// «Desde»: «Celular de Carmen», «PC Sala-Rosa» or «Automático».
  String get desde => switch (actor) {
    TipoActor.familiar => 'Celular de $_quien',
    TipoActor.pc => 'PC ${pc ?? ''}',
    TipoActor.sistema => 'Automático',
  };

  /// «las 11:42», or «el jue 24 sep a las 07:00» when the pause ends another day.
  String _hasta(DateTime h) => mismoDia(h, ocurridaEn)
      ? 'las ${hora(h)}'
      : 'el ${fechaCorta(h)} a las ${hora(h)}';
}

/// «7 días» → «30 días» reads «de 7 a 30 días».
(String, String) _plazos(String? antes, String? despues) {
  final de = antes ?? 'No guardar';
  final a = despues ?? 'No guardar';
  const dias = ' días';
  if (de.endsWith(dias) && a.endsWith(dias)) {
    return (de.substring(0, de.length - dias.length), a);
  }
  return (de, a);
}

String _diaMes(DateTime t) =>
    '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';

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
