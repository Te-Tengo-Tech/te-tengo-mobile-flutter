import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';

const rosa = AdultoMayor(
  nombre: 'Rosa Huamán',
  direccion: 'Jr. Los Pinos 482, San Miguel, Lima',
  convivencia: Convivencia.solo,
);

final consentimientoVigente = Consentimiento(
  otorgadoEn: DateTime(2026, 8, 3, 9, 12),
  otorgadoPor: 'Rosa Huamán',
  registradoPor: 'Carmen Huamán',
  vistaEnVivoAceptada: true,
  vigente: true,
);

Hogar hogarDeRosa({bool consentimiento = true, Rol rol = Rol.titular}) => Hogar(
  hogarId: 'h-1',
  adultoMayor: rosa,
  rol: rol,
  consentimiento: consentimiento ? consentimientoVigente : null,
);

class HogarRepositorioFalso implements HogarRepositorio {
  HogarRepositorioFalso([Hogar? hogar]) : hogar = hogar ?? hogarDeRosa();

  Hogar hogar;

  @override
  Future<Hogar> obtener() async => hogar;
}
