import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';

const rosa = AdultoMayor(
  nombre: 'Rosa Huamán',
  edad: 78,
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
  ProblemaApi? errorCrear;
  ProblemaApi? errorActualizar;
  Sesion sesionCreada = const Sesion(
    tokenAcceso: 'acceso-hogar',
    tokenRefresco: 'refresco-hogar',
    usuario: Usuario(
      id: 'u-carmen',
      nombre: 'Carmen Huamán',
      correo: 'carmen.huaman@gmail.com',
    ),
    hogarId: 'h-1',
    rol: Rol.titular,
  );
  final creados = <AdultoMayor>[];
  final actualizados = <AdultoMayor>[];

  @override
  Future<Hogar> obtener() async => hogar;

  @override
  Future<Sesion> crear(AdultoMayor adultoMayor) async {
    creados.add(adultoMayor);
    if (errorCrear != null) throw errorCrear!;
    return sesionCreada;
  }

  final consentimientos = <String>[];
  int revocaciones = 0;

  @override
  Future<void> revocarConsentimiento() async {
    revocaciones++;
    final c = hogar.consentimiento!;
    hogar = Hogar(
      hogarId: hogar.hogarId,
      adultoMayor: hogar.adultoMayor,
      rol: hogar.rol,
      consentimiento: Consentimiento(
        otorgadoEn: c.otorgadoEn,
        otorgadoPor: c.otorgadoPor,
        registradoPor: c.registradoPor,
        vistaEnVivoAceptada: c.vistaEnVivoAceptada,
        vigente: false,
      ),
    );
  }

  @override
  Future<Consentimiento> registrarConsentimiento({
    required String otorgadoPor,
  }) async {
    consentimientos.add(otorgadoPor);
    final c = Consentimiento(
      otorgadoEn: DateTime(2026, 9, 23, 9, 14),
      otorgadoPor: otorgadoPor,
      registradoPor: 'Carmen Huamán',
      vistaEnVivoAceptada: true,
      vigente: true,
    );
    hogar = Hogar(
      hogarId: hogar.hogarId,
      adultoMayor: hogar.adultoMayor,
      rol: hogar.rol,
      consentimiento: c,
    );
    return c;
  }

  @override
  Future<AdultoMayor> actualizarAdultoMayor(AdultoMayor adultoMayor) async {
    actualizados.add(adultoMayor);
    if (errorActualizar != null) throw errorActualizar!;
    hogar = Hogar(
      hogarId: hogar.hogarId,
      adultoMayor: adultoMayor,
      rol: hogar.rol,
      consentimiento: hogar.consentimiento,
    );
    return adultoMayor;
  }
}
