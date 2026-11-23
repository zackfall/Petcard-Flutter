import '../domain/evento.dart';
import '../domain/mascota.dart';
import 'mascotas_repository.dart';

/// Implementación TEMPORAL en memoria: sirve para ver y probar las pantallas.
/// Los datos se pierden al cerrar la app. Se reemplaza por la implementación
/// que use el servicio remoto.
class MascotasRepositoryImpl extends MascotasRepository {
  final List<Mascota> _mascotas = [];
  final List<Evento> _eventos = [];
  int _siguienteMascotaId = 1;
  int _siguienteEventoId = 1;

  @override
  List<Mascota> get mascotas => List.unmodifiable(_mascotas);

  @override
  Mascota? mascotaPorId(int id) {
    for (final m in _mascotas) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  List<Evento> eventosDeMascota(int mascotaId) =>
      _eventos.where((e) => e.mascotaId == mascotaId).toList();

  @override
  Future<int> guardarMascota(Mascota mascota) async {
    final id = _siguienteMascotaId++;
    _mascotas.add(mascota.copyWith(id: id));
    notifyListeners();
    return id;
  }

  @override
  Future<int> guardarEvento(Evento evento) async {
    final id = _siguienteEventoId++;
    _eventos.add(evento.copyWith(id: id));
    notifyListeners();
    return id;
  }

    @override
  List<Evento> get eventos => List.unmodifiable(_eventos);

  @override
  Future<void> eliminarMascota(int id) async {
    _mascotas.removeWhere((m) => m.id == id);
    _eventos.removeWhere((e) => e.mascotaId == id);
    notifyListeners();
  }
}
