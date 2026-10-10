import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icons of the prototype (`P` in prototipo.html), drawn from the same SVG paths.
enum Ico {
  home,
  hist,
  users,
  sliders,
  cam,
  phone,
  play,
  pause,
  download,
  wifiOff,
  check,
  x,
  chevR,
  chevD,
  chevL,
  back,
  fall,
  unsteady,
  stand,
  shield,
  lock,
  bell,
  bellOff,
  mail,
  eye,
  eyeOff,
  plus,
  user,
  pin,
  cal,
  filter,
  trash,
  logout,
  clock,
  info,
  warn,
  video,
  key,
  doc,
  refresh,
  send,
  swap,
  home2,
  battery,
  signal,
  wifi,
  flash,
  plug,
  pc,
  up,
  down,
  equal,
  sun,
  share,
  expand,
  contract;

  String get _trazo => _trazos[this]!;
}

const _trazos = <Ico, String>{
  Ico.home:
      '<path d="M3 10.5 12 3l9 7.5"/><path d="M5.5 9v11h4.5v-6h4v6h4.5V9"/>',
  Ico.hist:
      '<path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1"/><path d="M3.5 4.5v4h4"/><path d="M12 7.5V12l3 2"/>',
  Ico.users:
      '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.6-3.6 3.2-5.5 6.5-5.5s5.9 1.9 6.5 5.5"/><path d="M16 4.8a3.5 3.5 0 0 1 0 6.4"/><path d="M18 14.8c2 .6 3.2 2.4 3.5 5.2"/>',
  Ico.sliders:
      '<path d="M4 6h9M18 6h2M4 12h3M12 12h8M4 18h11M20 18h0"/><circle cx="15.5" cy="6" r="2.2"/><circle cx="9.5" cy="12" r="2.2"/><circle cx="17.5" cy="18" r="2.2"/>',
  Ico.cam:
      '<rect x="4" y="3" width="16" height="12.5" rx="6.25"/><circle cx="12" cy="9.25" r="2.8"/><path d="M8.5 21h7M12 15.5V21"/>',
  Ico.phone:
      '<path d="M5.2 3.5h3l1.6 4.2-2.1 1.4a11 11 0 0 0 7.2 7.2l1.4-2.1 4.2 1.6v3a1.8 1.8 0 0 1-1.9 1.8A16.4 16.4 0 0 1 3.4 5.4a1.8 1.8 0 0 1 1.8-1.9Z"/>',
  Ico.play: '<path d="M7.5 4.8v14.4L19 12 7.5 4.8Z" fill="currentColor"/>',
  Ico.pause: '<path d="M8.5 5v14M15.5 5v14" stroke-width="3"/>',
  Ico.download: '<path d="M12 3.5v11.5M7 10.5l5 5 5-5M4.5 20h15"/>',
  Ico.wifiOff:
      '<path d="M3 3l18 18"/><path d="M8.6 16.3a4.9 4.9 0 0 1 6.3-.5"/><path d="M5 12.8a10 10 0 0 1 4.3-2.4M19 12.8a10 10 0 0 0-2.7-1.9"/><path d="M2 9.2a14.7 14.7 0 0 1 4.2-2.7M22 9.2A14.8 14.8 0 0 0 10.8 5"/><circle cx="12" cy="19.6" r="1.1" fill="currentColor" stroke="none"/>',
  Ico.check: '<path d="M4.5 12.5l5 5L20 7"/>',
  Ico.x: '<path d="M6 6l12 12M18 6 6 18"/>',
  Ico.chevR: '<path d="M9 5l7 7-7 7"/>',
  Ico.chevD: '<path d="M5 9l7 7 7-7"/>',
  Ico.chevL: '<path d="M15 5l-7 7 7 7"/>',
  Ico.back: '<path d="M20 12H5M11 5l-7 7 7 7"/>',
  Ico.fall:
      '<circle cx="6" cy="6.5" r="2.3"/><path d="M8.2 8.6 14 13.4M9 10.2 5 12.6M11.2 11 12.6 6.8M14 13.4l5.5-.8M14 13.4l2.8 4.6M3 21h18"/>',
  Ico.unsteady:
      '<path d="M12 2.8 21.2 12 12 21.2 2.8 12Z"/><path d="M7.6 12.6l2-2.2 2.2 3.2 2.1-3.2 2.4 2.2"/>',
  Ico.stand:
      '<circle cx="12" cy="4.6" r="2.3"/><path d="M12 7.8v7M12 14.8l-3.2 6.4M12 14.8l3.2 6.4M7.6 10.6h8.8"/>',
  Ico.shield:
      '<path d="M12 3 4.5 6v5.5c0 4.6 3.1 8.2 7.5 9.5 4.4-1.3 7.5-4.9 7.5-9.5V6L12 3Z"/><path d="M8.8 12.2l2.2 2.2 4.3-4.4"/>',
  Ico.lock:
      '<rect x="5" y="10.5" width="14" height="10" rx="3"/><path d="M8.2 10.5V7.6a3.8 3.8 0 0 1 7.6 0v2.9"/>',
  Ico.bell:
      '<path d="M6 16.5V11a6 6 0 1 1 12 0v5.5l1.5 2h-15l1.5-2Z"/><path d="M10 21.2h4"/>',
  Ico.bellOff:
      '<path d="M3 3l18 18"/><path d="M8.3 5.8A6 6 0 0 1 18 11v4.2M16 18.5H4.5l1.5-2V11c0-.9.2-1.8.6-2.6"/><path d="M10 21.2h4"/>',
  Ico.mail:
      '<rect x="3" y="5" width="18" height="14" rx="3"/><path d="M4 7.5l8 5.8 8-5.8"/>',
  Ico.eye:
      '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="3"/>',
  Ico.eyeOff:
      '<path d="M3 3l18 18"/><path d="M10.6 6A9.5 9.5 0 0 1 21.5 12a15 15 0 0 1-2.7 3.4M6.4 7.6A14.5 14.5 0 0 0 2.5 12S6 18.5 12 18.5a9 9 0 0 0 4-1"/><path d="M9.9 10a3 3 0 0 0 4.1 4.1"/>',
  Ico.plus: '<path d="M12 5v14M5 12h14"/>',
  Ico.user:
      '<circle cx="12" cy="8" r="4"/><path d="M4.5 20.5c.8-4 3.8-6 7.5-6s6.7 2 7.5 6"/>',
  Ico.pin:
      '<path d="M12 21s-7-6.2-7-11.5a7 7 0 0 1 14 0C19 14.8 12 21 12 21Z"/><circle cx="12" cy="9.5" r="2.5"/>',
  Ico.cal:
      '<rect x="3.5" y="5" width="17" height="15.5" rx="3"/><path d="M3.5 10h17M8 3v4M16 3v4"/>',
  Ico.filter: '<path d="M4 6.5h16M7 12h10M10 17.5h4"/>',
  Ico.trash:
      '<path d="M4.5 7h15M9.5 7V4.5h5V7M6.5 7l1 13h9l1-13"/><path d="M10.5 11v5.5M13.5 11v5.5"/>',
  Ico.logout:
      '<path d="M14 4.5H6.5a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2H14"/><path d="M11 12h10M17 8l4 4-4 4"/>',
  Ico.clock: '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
  Ico.info:
      '<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5.5"/><circle cx="12" cy="7.8" r="1.1" fill="currentColor" stroke="none"/>',
  Ico.warn:
      '<path d="M12 3.5 21.5 20h-19L12 3.5Z"/><path d="M12 9.5v5"/><circle cx="12" cy="17.3" r="1.1" fill="currentColor" stroke="none"/>',
  Ico.video:
      '<rect x="2.5" y="6" width="13.5" height="12" rx="3"/><path d="M16 10.5l5.5-3v9l-5.5-3"/>',
  Ico.key:
      '<circle cx="8" cy="15" r="4.5"/><path d="M11.2 11.8 20 3M16.5 6.5l2.5 2.5M14 9l2 2"/>',
  Ico.doc:
      '<path d="M6.5 3h8l4 4v14h-12V3Z"/><path d="M14.5 3v4h4M9.5 12h6M9.5 16h6"/>',
  Ico.refresh: '<path d="M20 12a8 8 0 1 1-2.4-5.7"/><path d="M20 4v4.5h-4.5"/>',
  Ico.send: '<path d="M21 3 10.5 13.5M21 3l-6.5 18-4-7.5L3 9.5 21 3Z"/>',
  Ico.swap:
      '<path d="M7 4v16M7 4 3.5 7.5M7 4l3.5 3.5M17 20V4M17 20l-3.5-3.5M17 20l3.5-3.5"/>',
  Ico.home2:
      '<path d="M3.5 11 12 4l8.5 7"/><path d="M6 9.5V20h12V9.5"/><path d="M12 17.2s-3.3-2-3.3-4.2a1.8 1.8 0 0 1 3.3-1 1.8 1.8 0 0 1 3.3 1c0 2.2-3.3 4.2-3.3 4.2Z"/>',
  Ico.battery:
      '<rect x="2.5" y="7" width="17" height="10" rx="3"/><rect x="4.5" y="9" width="11" height="6" rx="1.5" fill="currentColor" stroke="none"/><path d="M21.5 10.5v3"/>',
  Ico.signal:
      '<path d="M4 18v-2M9 18v-5M14 18v-8M19 18V7" stroke-width="2.6"/>',
  Ico.wifi:
      '<path d="M2.5 9.2a14.5 14.5 0 0 1 19 0M5.5 12.6a10 10 0 0 1 13 0M8.6 16a5 5 0 0 1 6.8 0"/><circle cx="12" cy="19.4" r="1.1" fill="currentColor" stroke="none"/>',
  Ico.flash: '<path d="M13 2.5 5 13.5h6.5L10.5 21.5 19 10h-6.5L13 2.5Z"/>',
  Ico.plug:
      '<path d="M9 3v4.5M15 3v4.5"/><path d="M6.5 7.5h11v3.5a5.5 5.5 0 0 1-11 0V7.5Z"/><path d="M12 16.5V21"/>',
  Ico.pc:
      '<rect x="3" y="4" width="18" height="12" rx="2.5"/><path d="M9 20h6M12 16v4"/>',
  Ico.up: '<path d="M12 19V5M6 11l6-6 6 6"/>',
  // Safari's share button, for the «Agregar a la pantalla de inicio» guide (web only).
  Ico.share:
      '<path d="M12 3.5v11M8 7.5l4-4 4 4"/><path d="M8.5 10.5h-2a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2h-2"/>',
  Ico.down: '<path d="M12 5v14M6 13l6 6 6-6"/>',
  // Not in the prototype: full screen of the event clip (enter and leave).
  Ico.expand: '<path d="M4 9V4h5M15 4h5v5M20 15v5h-5M9 20H4v-5"/>',
  Ico.contract: '<path d="M9 4v5H4M20 9h-5V4M15 20v-5h5M4 15h5v5"/>',
  Ico.equal: '<path d="M5 9.5h14M5 14.5h14"/>',
  Ico.sun:
      '<circle cx="12" cy="12" r="4"/><path d="M12 2.5v2M12 19.5v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M2.5 12h2M19.5 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4"/>',
};

/// Prototype icon: 24×24 stroke drawing in the current color. Decorative unless [etiqueta] is set.
class Icono extends StatelessWidget {
  const Icono(
    this.icono, {
    super.key,
    this.tamano = 24,
    this.color,
    this.etiqueta,
  });

  final Ico icono;
  final double tamano;
  final Color? color;

  /// Accessibility label; null means the icon is decorative (its text is next to it).
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final color =
        this.color ?? IconTheme.of(context).color ?? const Color(0xFF221A38);
    final imagen = SvgPicture.string(
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" '
      'stroke-linecap="round" stroke-linejoin="round" xmlns="http://www.w3.org/2000/svg">'
      '${icono._trazo}</svg>',
      width: tamano,
      height: tamano,
      theme: SvgTheme(currentColor: color),
      excludeFromSemantics: true,
    );
    final etiqueta = this.etiqueta;
    if (etiqueta == null) return ExcludeSemantics(child: imagen);
    return Semantics(label: etiqueta, image: true, child: imagen);
  }
}
