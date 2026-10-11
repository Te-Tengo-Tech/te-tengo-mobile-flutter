import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/camara_detectada.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';

/// The PC of the pilot, with the camera of the living room.
final camaraSalaPc = Camara(
  id: 'c1',
  nombreHabitacion: 'Sala',
  estado: EstadoConexion.enLinea,
  ultimaSenal: DateTime(2026, 9, 23, 10, 42),
  instaladaEn: DateTime(2026, 8, 3),
  pcId: 'pc-sala',
  ambienteId: 'a-sala',
  nombreDispositivo: 'Webcam USB HD',
);

Pc pcSalaRosa({
  List<Camara>? camaras,
  EstadoConexion estado = EstadoConexion.enLinea,
  int sinUsar = 0,
}) => Pc(
  id: 'pc-sala',
  nombre: 'Sala-Rosa',
  sistemaOperativo: 'Windows 11 Home',
  versionAgente: '0.5.0',
  estado: estado,
  ultimaSenal: estado == EstadoConexion.enLinea
      ? DateTime(2026, 9, 23, 10, 42)
      : DateTime(2026, 9, 23, 9, 58),
  vinculadaEn: DateTime(2026, 8, 3),
  vinculadaPor: (id: 'u-carmen', nombre: 'Carmen'),
  camaras: camaras ?? [camaraSalaPc],
  camarasSinUsar: sinUsar,
);

const consultaSalaRosa = ConsultaPc(
  codigo: 'KQWT-MXHD',
  nombrePc: 'Sala-Rosa',
  sistemaOperativo: 'Windows 11 Home',
  versionAgente: '0.5.0',
);

CamaraDetectada webcam(
  String id,
  String nombre, {
  String? habitacion,
  bool conectada = true,
  DateTime? pausadaHasta,
}) => CamaraDetectada(
  id: id,
  pcId: 'pc-sala',
  nombreDispositivo: nombre,
  enUso: habitacion != null,
  conectada: conectada,
  ambienteId: habitacion == null ? null : 'a-${habitacion.toLowerCase()}',
  nombreHabitacion: habitacion,
  estado: habitacion == null
      ? null
      : conectada
      ? EstadoConexion.enLinea
      : EstadoConexion.desconectada,
  pausadaHasta: pausadaHasta,
);

Ambiente ambiente(String nombre, {String? camara, String pc = 'Sala-Rosa'}) =>
    Ambiente(
      id: 'a-${nombre.toLowerCase()}',
      nombre: nombre,
      camaras: [
        if (camara != null)
          CamaraDeAmbiente(
            id: camara,
            pcId: 'pc-sala',
            pcNombre: pc,
            nombreDispositivo: 'Webcam',
          ),
      ],
    );

class PcsRepositorioFalso implements PcsRepositorio {
  PcsRepositorioFalso({
    List<Pc>? pcs,
    List<CamaraDetectada>? webcams,
    List<Ambiente>? habitaciones,
  }) : pcs = pcs ?? [pcSalaRosa()],
       webcams = webcams ?? [webcam('c1', 'Webcam USB HD', habitacion: 'Sala')],
       habitaciones = habitaciones ?? [ambiente('Sala', camara: 'c1')];

  List<Pc> pcs;
  List<CamaraDetectada> webcams;
  List<Ambiente> habitaciones;

  final consultas = <String>[];
  final aprobaciones = <String>[];
  final rechazos = <String>[];
  final busquedas = <String>[];
  final usos = <(String, String?, String?)>[];
  final dejadas = <String>[];
  final vistasPrevias = <String>[];

  ProblemaApi? errorConsulta;
  ProblemaApi? errorAprobacion;
  ProblemaApi? errorUso;
  ProblemaApi? errorVistaPrevia;

  /// The PC that `aprobar` links.
  Pc pcAprobada = const Pc(
    id: 'pc-nueva',
    nombre: 'Sala-Rosa',
    sistemaOperativo: 'Windows 11 Home',
    versionAgente: '0.5.0',
    estado: EstadoConexion.enLinea,
  );

  /// When the preview session ends.
  DateTime? expiraVistaPrevia;

  @override
  Future<List<Pc>> listar() async => pcs;

  @override
  Future<ConsultaPc> consultar(String codigo) async {
    consultas.add(codigo);
    if (errorConsulta != null) throw errorConsulta!;
    return ConsultaPc(
      codigo: codigo,
      nombrePc: consultaSalaRosa.nombrePc,
      sistemaOperativo: consultaSalaRosa.sistemaOperativo,
      versionAgente: consultaSalaRosa.versionAgente,
    );
  }

  @override
  Future<Pc> aprobar(String codigo) async {
    aprobaciones.add(codigo);
    if (errorAprobacion != null) throw errorAprobacion!;
    pcs = [...pcs, pcAprobada];
    return pcAprobada;
  }

  @override
  Future<void> rechazar(String codigo) async => rechazos.add(codigo);

  @override
  Future<List<CamaraDetectada>> camaras(String pcId) async =>
      webcams.where((w) => w.pcId == pcId).toList();

  @override
  Future<void> buscarCamaras(String pcId) async => busquedas.add(pcId);

  @override
  Future<Camara> usarCamara(
    String camaraId, {
    String? ambienteId,
    String? nombreAmbiente,
  }) async {
    usos.add((camaraId, ambienteId, nombreAmbiente));
    if (errorUso != null) throw errorUso!;
    final nombre =
        nombreAmbiente ??
        habitaciones.firstWhere((a) => a.id == ambienteId).nombre;
    final w = webcams.firstWhere((w) => w.id == camaraId);
    webcams = [
      for (final x in webcams)
        x.id == camaraId
            ? webcam(x.id, x.nombreDispositivo, habitacion: nombre)
            : x,
    ];
    habitaciones = [
      ...habitaciones.where((a) => a.nombre != nombre),
      ambiente(nombre, camara: camaraId),
    ];
    return Camara(
      id: camaraId,
      nombreHabitacion: nombre,
      estado: EstadoConexion.enLinea,
      pcId: w.pcId,
      nombreDispositivo: w.nombreDispositivo,
    );
  }

  @override
  Future<void> dejarDeUsar(String camaraId) async {
    dejadas.add(camaraId);
    webcams = [
      for (final x in webcams)
        x.id == camaraId ? webcam(x.id, x.nombreDispositivo) : x,
    ];
  }

  @override
  Future<List<Ambiente>> ambientes() async => habitaciones;

  @override
  Future<SesionVivo> vistaPrevia(String camaraId) async {
    vistasPrevias.add(camaraId);
    if (errorVistaPrevia != null) throw errorVistaPrevia!;
    return SesionVivo(
      sesionId: 'vp-${vistasPrevias.length}',
      urlTransmision: Uri.parse(
        'https://api.tetengo.pe/vivo/camaras/$camaraId/index.m3u8?token=t',
      ),
      expiraEn: expiraVistaPrevia,
    );
  }
}
