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
const seccionesConsentimiento = [
  SeccionConsentimiento(
    icono: Ico.eye,
    titulo: 'Vista en vivo en cualquier momento',
    resumen: 'La familia puede verla cuando quiera',
    texto:
        'Los familiares vinculados a esta cuenta pueden ver la cámara en vivo '
        'cuando quieran, no solo durante una alerta. Cada acceso queda '
        'registrado: quién la vio, cuándo y cuánto tiempo.',
  ),
  SeccionConsentimiento(
    icono: Ico.cam,
    titulo: 'Qué hacemos',
    resumen: 'Detectamos caídas por la postura',
    texto:
        'La cámara instalada en su vivienda envía video a Te Tengo, donde '
        'analizamos la postura del cuerpo para detectar caídas y movimientos '
        'inestables.',
  ),
  SeccionConsentimiento(
    icono: Ico.eyeOff,
    titulo: 'Qué no hacemos',
    resumen: 'Sin reconocer rostros ni grabar siempre',
    texto:
        'No reconocemos rostros ni grabamos de forma continua. La vista en vivo '
        'no se guarda.',
  ),
  SeccionConsentimiento(
    icono: Ico.video,
    titulo: 'Qué guardamos',
    resumen: 'Solo el clip de cada alerta, 30 días',
    texto: 'Solo el clip de cada alerta, durante 30 días. Luego se elimina.',
  ),
  SeccionConsentimiento(
    icono: Ico.shield,
    titulo: 'Sus derechos',
    resumen: 'Ley N.° 29733 · puede revocarlo',
    texto:
        'Según la Ley N.° 29733 de Protección de Datos Personales, puede '
        'acceder a sus datos, corregirlos, pedir su eliminación u oponerse a su '
        'uso, y revocar este consentimiento cuando quiera.',
  ),
];

/// A titled section of a legal document, with one or more paragraphs.
typedef SeccionDocumento = (String titulo, List<String> parrafos);

/// «Términos de uso»: only facts the app already shows.
const seccionesTerminos = <SeccionDocumento>[
  (
    'Qué es Te Tengo',
    [
      'Te Tengo avisa a tu familia cuando la cámara instalada en la casa de la '
          'persona cuidada detecta una posible caída o un movimiento inestable. '
          'No es una cámara de seguridad.',
    ],
  ),
  (
    'Tu cuenta',
    [
      'Quien crea la cuenta es el titular. Solo el titular cambia los datos de '
          'la persona cuidada, el consentimiento, el nombre de la habitación, la '
          'familia y el orden de aviso.',
      'Cada cuenta cuida a una sola persona. La contraseña debe tener 8 '
          'caracteres o más, con un número. Tras 5 intentos fallidos, el acceso '
          'se bloquea 15 minutos.',
    ],
  ),
  (
    'Familiares invitados',
    [
      'Ven las mismas alertas, clips, historial y la cámara en vivo, y pueden '
          'marcar alertas y pausar la cámara. El titular puede retirar su acceso '
          'cuando quiera.',
    ],
  ),
  (
    'Consentimiento',
    [
      'La cámara solo envía video si la persona cuidada, o su representante '
          'legal, acepta el consentimiento informado. Se puede revocar en '
          'Ajustes: la captura se detiene y las grabaciones se borran.',
    ],
  ),
  (
    'Alertas',
    [
      'Todos los familiares vinculados reciben cada alerta. Si el contacto '
          'principal no la marca en el tiempo de espera (3, 5 o 10 minutos), '
          'avisamos al contacto secundario.',
    ],
  ),
  (
    'Límites del servicio',
    [
      'Solo detectamos caídas cuando la cámara está en línea. No hay detección '
          'si está desconectada, en pausa o sin consentimiento, y no es '
          'confiable si la cámara no ve bien a la persona por la luz o el '
          'encuadre.',
      'Para recibir las alertas con la app cerrada, las notificaciones del '
          'celular deben estar activadas.',
    ],
  ),
];

/// «Política de privacidad»: what is stored, who sees it and for how long.
const seccionesPolitica = <SeccionDocumento>[
  (
    'Qué datos guardamos',
    [
      'De tu cuenta: nombre, correo y contraseña.',
      'De la persona cuidada: nombre, edad, dirección y con quién vive.',
      'De cada alerta: tipo, habitación, fecha, hora y quién la atendió.',
    ],
  ),
  (
    'Video',
    [
      'La cámara envía video para analizar la postura del cuerpo. No '
          'reconocemos rostros ni grabamos de forma continua.',
      'Solo guardamos el clip de cada alerta (6 s antes y 6 s después) durante '
          '30 días; luego se elimina. La vista en vivo no se graba.',
    ],
  ),
  (
    'Quién ve los datos',
    [
      'Solo los familiares vinculados a la cuenta. Cada acceso a la vista en '
          'vivo queda registrado: quién, cuándo y cuánto duró, y toda la '
          'familia ve ese registro.',
    ],
  ),
  (
    'Revocar el consentimiento',
    [
      'Detiene la captura y la vista en vivo y borra las grabaciones. Te '
          'enviamos la constancia por correo.',
    ],
  ),
  (
    'Tus derechos',
    [
      'Según la Ley N.° 29733 de Protección de Datos Personales, puedes pedir '
          'acceder a tus datos, corregirlos, eliminarlos u oponerte a su uso. '
          'Escríbenos a privacidad@tetengo.pe.',
    ],
  ),
];

/// Last section of the full consent document.
const seccionRegistroConsentimiento = (
  'Cómo se registra',
  [
    'Guardamos quién lo otorgó, quién lo registró, la fecha y la hora, como '
        'constancia exigida por la Ley N.° 29733.',
  ],
);
