import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Illustrations of the prototype (`roomSVG`, `skeleton`, `emptyIll`), drawn from the same SVG.
///
/// Te Tengo never shows photos of the person: rooms are illustrated and the person is the pose
/// skeleton (PRODUCT.md, Positioning).
enum Postura { pie, inestable, caida, ninguna }

const _poses = <Postura, Map<String, List<num>>>{
  Postura.pie: {
    'h': [0, -106], 'n': [0, -96], 'sL': [-11, -92], 'sR': [11, -92], //
    'eL': [-15, -72], 'eR': [15, -72], 'wL': [-17, -54], 'wR': [17, -54],
    'hL': [-7, -52], 'hR': [7, -52], 'kL': [-8, -26], 'kR': [8, -26],
    'aL': [-9, 0], 'aR': [9, 0],
  },
  Postura.inestable: {
    'h': [8, -104], 'n': [6, -94], 'sL': [-6, -90], 'sR': [15, -92], //
    'eL': [-24, -82], 'eR': [30, -104], 'wL': [-38, -88], 'wR': [40, -118],
    'hL': [-4, -52], 'hR': [10, -52], 'kL': [-12, -27], 'kR': [14, -26],
    'aL': [-20, 0], 'aR': [12, 1],
  },
  Postura.caida: {
    'h': [-62, -10], 'n': [-50, -9], 'sL': [-44, -15], 'sR': [-44, -4], //
    'eL': [-30, -24], 'eR': [-34, 6], 'wL': [-16, -28], 'wR': [-22, 10],
    'hL': [-6, -11], 'hR': [-6, -5], 'kL': [18, -18], 'kR': [16, -4],
    'aL': [42, -12], 'aR': [40, 2],
  },
};

const _segmentos = [
  ['n', 'sL'], ['n', 'sR'], ['sL', 'eL'], ['eL', 'wL'], ['sR', 'eR'], //
  ['eR', 'wR'], ['sL', 'hL'], ['sR', 'hR'], ['hL', 'hR'], ['hL', 'kL'],
  ['kL', 'aL'], ['hR', 'kR'], ['kR', 'aR'],
];

String _esqueleto(Postura postura, num x, num y, String tono) {
  final p = _poses[postura]!;
  List<num> j(String k) => [x + p[k]![0], y + p[k]![1]];
  final s = StringBuffer('<g>');
  for (final [a, b] in _segmentos) {
    final pa = j(a), pb = j(b);
    s.write(
      '<line x1="${pa[0]}" y1="${pa[1]}" x2="${pb[0]}" y2="${pb[1]}" stroke="$tono" stroke-width="3.2"/>',
    );
  }
  final c = j('h');
  s.write(
    '<circle cx="${c[0]}" cy="${c[1]}" r="8" fill="#fff" stroke="$tono" stroke-width="3"/>',
  );
  for (final k in p.keys.where((k) => k != 'h')) {
    final q = j(k);
    s.write(
      '<circle cx="${q[0]}" cy="${q[1]}" r="3.4" fill="#fff" stroke="$tono" stroke-width="2"/>',
    );
  }
  s.write('</g>');
  return s.toString();
}

/// SVG of a room with the detected pose (`roomSVG` of the prototype).
String svgHabitacion(String habitacion, Postura postura, {String? aro}) {
  const wall = '#E7E3EE',
      wall2 = '#DDD7E7',
      floor = '#CFC7DC',
      f2 = '#C3BAD3',
      furn = '#B3A8C7',
      furn2 = '#9E91B6',
      wood = '#D9C1AE',
      win = '#D5DDE8';
  final s = StringBuffer(
    '<svg viewBox="0 0 320 200" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">'
    '<rect width="320" height="200" fill="$wall"/><rect y="0" width="320" height="10" fill="$wall2"/>'
    '<path d="M0 148h320v52H0Z" fill="$floor"/><path d="M0 148h320" stroke="$f2" stroke-width="3"/>',
  );
  var fx = 175, fy = 176;
  // A new name does not change the room: the same illustration is still shown.
  final cuarto =
      const ['Sala', 'Dormitorio', 'Cocina', 'Pasillo'].contains(habitacion)
      ? habitacion
      : 'Sala';
  switch (cuarto) {
    case 'Sala':
      s.write(
        '<rect x="150" y="30" width="86" height="62" rx="4" fill="$win"/><path d="M193 30v62M150 61h86" stroke="#fff" stroke-width="3"/>'
        '<rect x="18" y="96" width="112" height="30" rx="10" fill="$furn"/><rect x="12" y="118" width="124" height="28" rx="8" fill="$furn2"/><rect x="18" y="146" width="6" height="8" fill="$furn2"/><rect x="124" y="146" width="6" height="8" fill="$furn2"/>'
        '<path d="M286 60v88" stroke="$furn2" stroke-width="3"/><path d="M272 60h28l-6-20h-16Z" fill="$wood"/><ellipse cx="286" cy="150" rx="14" ry="3" fill="$f2"/>'
        '<ellipse cx="190" cy="178" rx="96" ry="14" fill="$f2"/>',
      );
      fx = 178;
      fy = 182;
    case 'Dormitorio':
      s.write(
        '<rect x="206" y="28" width="74" height="60" rx="4" fill="$win"/><path d="M243 28v60" stroke="#fff" stroke-width="3"/>'
        '<rect x="14" y="84" width="14" height="70" rx="4" fill="$wood"/><rect x="24" y="112" width="138" height="30" rx="8" fill="#EDE9F3"/><rect x="24" y="130" width="138" height="20" rx="4" fill="$furn2"/><rect x="30" y="104" width="40" height="14" rx="6" fill="#fff"/>'
        '<rect x="172" y="112" width="30" height="38" rx="4" fill="$wood"/><path d="M187 112v-18" stroke="$furn2" stroke-width="3"/><path d="M178 94h18l-4-14h-10Z" fill="$furn"/>',
      );
      fx = 240;
      fy = 182;
    case 'Cocina':
      s.write(
        '<rect x="0" y="28" width="150" height="40" rx="3" fill="$furn"/><path d="M50 28v40M100 28v40" stroke="$wall" stroke-width="2"/>'
        '<rect x="0" y="104" width="160" height="46" fill="$furn2"/><rect x="0" y="100" width="164" height="8" rx="2" fill="$wood"/><path d="M54 110v36M108 110v36" stroke="$furn" stroke-width="2"/>'
        '<rect x="176" y="34" width="52" height="46" rx="4" fill="$win"/><path d="M202 34v46" stroke="#fff" stroke-width="3"/>'
        '<rect x="252" y="46" width="54" height="104" rx="8" fill="#EEEAF4" stroke="$furn" stroke-width="2"/><path d="M252 88h54M260 60v14M260 96v20" stroke="$furn" stroke-width="3"/>',
      );
      fx = 200;
      fy = 180;
    default:
      s.write(
        '<rect x="30" y="40" width="54" height="108" rx="3" fill="$wood"/><circle cx="74" cy="98" r="3" fill="$furn2"/>'
        '<rect x="236" y="40" width="54" height="108" rx="3" fill="$wood"/><circle cx="246" cy="98" r="3" fill="$furn2"/>'
        '<rect x="128" y="50" width="64" height="44" rx="3" fill="#fff" stroke="$furn" stroke-width="3"/><path d="M136 86l14-16 10 10 8-6 16 12" stroke="$furn2" stroke-width="2.5" fill="none" stroke-linejoin="round"/>'
        '<path d="M110 200l20-44h60l20 44Z" fill="$f2"/>',
      );
      fx = 162;
      fy = 184;
  }
  if (postura == Postura.caida) {
    s.write(
      '<ellipse cx="${fx - 10}" cy="${fy - 7}" rx="72" ry="26" fill="none" stroke="${aro ?? '#BF2A1B'}" stroke-width="2.5" stroke-dasharray="7 6"/>',
    );
  }
  if (postura == Postura.inestable) {
    s.write(
      '<rect x="${fx - 52}" y="${fy - 134}" width="104" height="146" rx="14" fill="none" stroke="${aro ?? '#B07A00'}" stroke-width="2.5" stroke-dasharray="7 6"/>',
    );
  }
  if (postura != Postura.ninguna) {
    s.write(
      _esqueleto(
        postura,
        postura == Postura.caida ? fx + 8 : fx,
        fy,
        '#221A38',
      ),
    );
  }
  s.write('</svg>');
  return s.toString();
}

/// Illustrated room, decorative.
class Habitacion extends StatelessWidget {
  const Habitacion({
    super.key,
    required this.nombre,
    this.postura = Postura.pie,
    this.aro,
  });

  final String nombre;
  final Postura postura;
  final String? aro;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(
      svgHabitacion(nombre, postura, aro: aro),
      fit: BoxFit.cover,
    ),
  );
}

/// Empty-state illustrations (`emptyIll`).
enum IlustracionVacio { semana, ojo, filtro, calendario }

String _svgVacio(IlustracionVacio tipo) => switch (tipo) {
  IlustracionVacio.semana =>
    '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><circle cx="60" cy="60" r="56" fill="#E2F2E9"/><path d="M28 74a32 32 0 0 1 64 0Z" fill="#fff"/><path d="M60 30v8M36 40l6 6M84 40l-6 6" stroke="#1C7A4C" stroke-width="4" stroke-linecap="round"/><path d="M22 80h76" stroke="#1C7A4C" stroke-width="4" stroke-linecap="round"/><path d="M40 90h40" stroke="#1C7A4C" stroke-width="4" stroke-linecap="round"/></svg>',
  IlustracionVacio.ojo =>
    '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><circle cx="60" cy="60" r="56" fill="#ECE7F6"/><path d="M24 60s13-22 36-22 36 22 36 22-13 22-36 22-36-22-36-22Z" fill="#fff" stroke="#4A2A85" stroke-width="4" stroke-linejoin="round"/><circle cx="60" cy="60" r="10" fill="none" stroke="#4A2A85" stroke-width="4"/><path d="M40 92h40" stroke="#4A2A85" stroke-width="4" stroke-linecap="round"/></svg>',
  IlustracionVacio.filtro =>
    '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><circle cx="60" cy="60" r="56" fill="#ECE7F6"/><path d="M34 44h52M42 60h36M52 76h16" stroke="#4A2A85" stroke-width="6" stroke-linecap="round"/></svg>',
  IlustracionVacio.calendario =>
    '<svg viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg"><circle cx="60" cy="60" r="56" fill="#ECE7F6"/><rect x="30" y="36" width="60" height="52" rx="10" fill="#fff"/><path d="M30 50h60" stroke="#4A2A85" stroke-width="4"/><path d="M42 30v12M78 30v12" stroke="#4A2A85" stroke-width="4" stroke-linecap="round"/><path d="M48 68l8 8 16-16" stroke="#1C7A4C" stroke-width="5" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>',
};

class IlustracionEstadoVacio extends StatelessWidget {
  const IlustracionEstadoVacio(this.tipo, {super.key});

  final IlustracionVacio tipo;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.string(_svgVacio(tipo), width: 120, height: 120),
  );
}
