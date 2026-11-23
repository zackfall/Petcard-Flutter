import 'package:flutter/foundation.dart';

import '../data/mascotas_repository.dart';
import '../domain/evento.dart';
import '../domain/mascota.dart';

/// Estado único del Perfil de Mascota.
@immutable
class PerfilMascotaUiState {
  const PerfilMascotaUiState({
    this.cargando = true,
    this.mascota,
    this.eventos = const [],
  });

  final bool cargando;
  final Mascota? mascota;

  /// Más reciente primero.
  final List<Evento> eventos;

  bool get encontrada => mascota != null;

  /// "Golden Retriever • 3 años"
  String get subtitulo => mascota?.lineaPerfil ?? '';
}

class PerfilMascotaViewModel extends ChangeNotifier {
  PerfilMascotaViewModel({
    required this._repositorio,
    required this._mascotaId,
  }) {
    _estado = _leer();
    // El repositorio avisa cuando cambia algo (nueva mascota, nuevo evento).
    _repositorio.addListener(_alCambiarRepositorio);
  }

  final MascotasRepository _repositorio;
  final int _mascotaId;
  late PerfilMascotaUiState _estado;

  PerfilMascotaUiState get estado => _estado;

  PerfilMascotaUiState _leer() {
    final eventos = [..._repositorio.eventosDeMascota(_mascotaId)]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return PerfilMascotaUiState(
      cargando: false,
      mascota: _repositorio.mascotaPorId(_mascotaId),
      eventos: eventos,
    );
  }

  void _alCambiarRepositorio() {
    _estado = _leer();
    notifyListeners();
  }

  @override
  void dispose() {
    _repositorio.removeListener(_alCambiarRepositorio);
    super.dispose();
  }
}
