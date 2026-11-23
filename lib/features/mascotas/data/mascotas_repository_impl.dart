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
  List<Evento> get pendientes {
    final lista = _eventos.where((e) => !e.hecho).toList()
      ..sort((a, b) {
        final porFecha = a.fecha.compareTo(b.fecha);
        if (porFecha != 0) return porFecha;
        // Sin hora va después de los que sí tienen (ASC con null al final).
        final ha = a.horaMinutos, hb = b.horaMinutos;
        if (ha == null && hb == null) return 0;
        if (ha == null) return 1;
        if (hb == null) return -1;
        return ha.compareTo(hb);
      });
    return lista;
  }

  @override
  Evento? eventoPorId(int id) {
    for (final e in _eventos) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<void> actualizarEvento(Evento evento) async {
    final i = _eventos.indexWhere((e) => e.id == evento.id);
    if (i == -1) return;
    _eventos[i] = evento;
    notifyListeners();
  }

  @override
  Future<void> eliminarEvento(int id) async {
    _eventos.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  @override
  Future<void> marcarEventoHecho(int id) async {
    final i = _eventos.indexWhere((e) => e.id == id);
    if (i == -1) return;
    _eventos[i] = _eventos[i].copyWith(hecho: true);
    notifyListeners();
  }

  @override
  Future<void> eliminarMascota(int id) async {
    _mascotas.removeWhere((m) => m.id == id);
    _eventos.removeWhere((e) => e.mascotaId == id);
    notifyListeners();
  }
}
