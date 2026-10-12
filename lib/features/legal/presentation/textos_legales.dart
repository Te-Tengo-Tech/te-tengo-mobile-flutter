import '../../../core/ui/iconos.dart';

/// One section of the informed consent (`CONSENT_SEC` in the prototype): the same text feeds the
/// folded summary of the consent screen and the full document.
class SeccionConsentimiento {
  const SeccionConsentimiento({
    required this.icono,
    required this.titulo,
    required this.resumen,
    required this.texto,
  });

  final Ico icono;
  final String titulo;

  /// One line shown while the section is folded.
  final String resumen;
  final String texto;
}

/// The consent text. The live-view clause goes first: the checkbox mentions it.
///
/// Video is analysed on the household PC (docs `04-arquitectura/decision-procesamiento-en-pc.md`).
/// The prototype's words are kept; the sentences it does not have, and the ones naming
/// Cloudflare R2 and the cross-border flow, are pending legal review (docs/BLOCKERS.md).
const seccionesConsentimiento = [
  SeccionConsentimiento(
    icono: Ico.eye,
    titulo: 'Vista en vivo en cualquier momento',
    resumen: 'Cuando la familia quiera',
    texto:
        'La familia vinculada puede verla en vivo cuando quiera, no solo en una '
        'alerta. Cada acceso queda registrado: quién, cuándo y cuánto.',
  ),
  SeccionConsentimiento(
    icono: Ico.cam,
    titulo: 'Qué hacemos',
    resumen: 'Caídas por la postura',
    texto:
        'La PC de la casa analiza la postura para detectar caídas y '
        'movimientos inestables. El video continuo nunca sale de la casa. Solo '
        'salen el aviso y el clip de cada alerta, y la vista en vivo mientras '
        'alguien de la familia la mira.',
  ),
  SeccionConsentimiento(
    icono: Ico.eyeOff,
    titulo: 'Qué no hacemos',
    resumen: 'Ni rostros ni grabación continua',
    texto:
        'Sin reconocimiento facial ni grabación continua. La vista en vivo no se '
        'guarda.',
  ),
  SeccionConsentimiento(
    icono: Ico.video,
    titulo: 'Qué guardamos',
    resumen: 'Clip de cada alerta, 30 días',
    texto:
        'Solo el clip de cada alerta, 30 días; luego se borra. Se guarda en '
        'Cloudflare R2, con servidores fuera del Perú: es un flujo '
        'transfronterizo de datos personales. Sus movimientos (puntos del '
        'cuerpo, sin imagen) solo se guardan con un permiso aparte.',
  ),
  SeccionConsentimiento(
    icono: Ico.shield,
    titulo: 'Sus derechos',
    resumen: 'Ley N.° 29733 · revocable',
    texto:
        'Por la Ley N.° 29733, puede ver, corregir o borrar sus datos, oponerse a '
        'su uso y revocar este consentimiento.',
  ),
];

/// A titled section of a legal document, with one or more paragraphs.
typedef SeccionDocumento = (String titulo, List<String> parrafos);

/// «Términos de uso»: only facts the app already shows.
const seccionesTerminos = <SeccionDocumento>[
  (
    'Qué es Te Tengo',
    [
      'Avisa a tu familia si la cámara de la casa detecta una posible caída o '
          'un movimiento inestable. No es una cámara de seguridad.',
    ],
  ),
  (
    'Tu cuenta',
    [
      'Solo el titular (quien la crea) cambia los datos de la persona cuidada, '
          'el consentimiento, las habitaciones, la familia y el orden de aviso.',
      'Cada cuenta cuida a una sola persona. Contraseña de 8 caracteres o más, '
          'con un número; 5 intentos fallidos bloquean el acceso 15 minutos.',
    ],
  ),
  (
    'Familiares invitados',
    [
      'Ven alertas, clips, historial y vista en vivo; marcan alertas y pausan '
          'la cámara. El titular puede retirar el acceso.',
    ],
  ),
  (
    'Consentimiento',
    [
      'Sin el consentimiento de la persona cuidada o de su representante legal, '
          'la cámara no envía video. Revocarlo detiene la captura y borra las '
          'grabaciones.',
      'Guardar sus movimientos necesita un permiso aparte y opcional; las '
          'alertas funcionan igual sin él.',
    ],
  ),
  (
    'Alertas',
    [
      'Las reciben todos los familiares vinculados. Si el principal no marca '
          'una en el tiempo de espera (3, 5 o 10 minutos), avisamos al '
          'secundario.',
    ],
  ),
  (
    'Límites del servicio',
    [
      'Sin detección con la PC de la casa apagada, la cámara desconectada, en '
          'pausa o sin consentimiento; no es confiable si no ve bien a la '
          'persona.',
      'Con la app cerrada, las alertas llegan solo con las notificaciones '
          'activadas.',
    ],
  ),
];

/// «Política de privacidad»: what is stored, who sees it and for how long.
const seccionesPolitica = <SeccionDocumento>[
  (
    'Qué datos guardamos',
    [
      'Cuenta: nombre, correo y contraseña.',
      'Persona cuidada: nombre, edad, dirección y con quién vive.',
      'Alertas: tipo, habitación, fecha, hora y quién atendió.',
    ],
  ),
  (
    'Video',
    [
      'Se analiza en la PC de la casa. Sin reconocimiento facial ni video en '
          'la nube.',
      'Solo salen de la casa el aviso y el clip de cada alerta, y la vista en '
          'vivo mientras alguien de la familia la mira con el consentimiento '
          'vigente.',
      'Solo el clip de cada alerta (6 s antes y 6 s después), 30 días. La '
          'vista en vivo no se graba.',
    ],
  ),
  (
    'Movimientos',
    [
      'Solo con un permiso aparte y opcional: puntos del cuerpo (hombros, '
          'caderas, rodillas…), sin imagen ni video.',
      'En la PC de la casa y, si el titular lo elige, en la nube, de 7 días a '
          '1 año. Retirar el permiso borra los de la nube; la PC pregunta si '
          'también los borra.',
    ],
  ),
  (
    'Dónde se guardan',
    [
      'Los clips y los movimientos de la nube se guardan en Cloudflare R2, con '
          'servidores fuera del Perú: es un flujo transfronterizo de datos '
          'personales.',
    ],
  ),
  (
    'Quién ve los datos',
    [
      'Solo la familia vinculada. Cada acceso en vivo y cada repetición quedan '
          'en un registro que ven todos: quién, cuándo y cuánto.',
    ],
  ),
  (
    'Revocar el consentimiento',
    [
      'Detiene la captura y la vista en vivo y borra las grabaciones; te '
          'enviamos la constancia.',
    ],
  ),
  (
    'Tus derechos',
    [
      'Ver, corregir o borrar tus datos, u oponerte a su uso (Ley N.° 29733): '
          'privacidad@tetengo.pe.',
    ],
  ),
];

/// Last section of the full consent document.
const seccionRegistroConsentimiento = (
  'Cómo se registra',
  [
    'Guardamos quién lo otorgó, quién lo registró, fecha y hora (Ley N.° '
        '29733).',
  ],
);
