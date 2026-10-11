/// `hace 6 s`, `hace 3 min`.
String haceTiempo(DateTime momento, DateTime ahora) {
  final d = ahora.difference(momento);
  if (d.inMinutes < 1) return 'hace ${d.inSeconds.clamp(1, 59)} s';
  if (d.inHours < 1) return 'hace ${d.inMinutes} min';
  return 'hace ${d.inHours} h';
}
