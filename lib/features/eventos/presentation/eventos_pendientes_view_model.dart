import 'package:flutter/foundation.dart';

import '../../../shared/evento_ui.dart';
import '../../mascotas/data/mascotas_repository.dart';

/// Estado único de la pantalla Eventos pendientes.
@immutable
class PendientesUiState {
  const PendientesUiState({
    this.eventos = const [],
    this.cargando = true,
  });

  final List<EventoItem> eventos;
  final bool cargando;
}

class EventosPendientesViewModel extends ChangeNotifier {
  EventosPendientesViewModel({required this._repositorio}) {
    _estado = _leer();
    // El repositorio avisa cuando cambia algo: la lista se actualiza sola
    // (equivale al Flow reactivo de Room).
    _repositorio.addListener(_alCambiarRepositorio);
  }

  final MascotasRepository _repositorio;
  late PendientesUiState _estado;

  PendientesUiState get estado => _estado;

  PendientesUiState _leer() {
    return PendientesUiState(
      cargando: false,
      eventos: _repositorio.pendientes
          .map((e) => e.aItem(_repositorio.mascotaPorId(e.mascotaId)?.nombre ?? '?'))
          .toList(),
    );
  }

  void _alCambiarRepositorio() {
    _estado = _leer();
    notifyListeners();
  }

  /// Botón "Hecho": el evento sale de la lista solo, vía el repositorio.
  Future<void> onHecho(int id) => _repositorio.marcarEventoHecho(id);

  /// Papelera del diseño: elimina el evento definitivamente.
  Future<void> onEliminar(int id) => _repositorio.eliminarEvento(id);

  @override
  void dispose() {
    _repositorio.removeListener(_alCambiarRepositorio);
    super.dispose();
  }
}