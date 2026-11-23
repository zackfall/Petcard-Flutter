import 'package:flutter/foundation.dart';

import '../../../shared/fechas.dart';
import '../../mascotas/data/mascotas_repository.dart';
import '../../mascotas/domain/evento.dart';
import '../../mascotas/domain/mascota.dart';

/// Estado único de la pantalla Nuevo Evento (un solo estado inmutable).
@immutable
class NuevoEventoUiState {
  const NuevoEventoUiState({
    this.mascotas = const [],
    this.mascotaId,
    this.titulo = '',
    this.tipo,
    required this.fecha,
    this.horaMinutos,
    this.lugar = '',
    this.notas = '',
    this.proxima,
    this.guardando = false,
  });

  final List<Mascota> mascotas;
  final int? mascotaId;
  final String titulo;

  /// Null = "Ninguno" (el diseño obliga a elegirlo explícitamente).
  final TipoEvento? tipo;
  final DateTime fecha;

  /// Minutos desde medianoche (600 = 10:00). Null = sin hora.
  final int? horaMinutos;
  final String lugar;
  final String notas;

  /// Próxima fecha del recordatorio (inicio del día). Null = sin aviso.
  final DateTime? proxima;
  final bool guardando;

  /// Habilita el botón "Listo ✓".
  bool get puedeGuardar =>
      mascotaId != null &&
      titulo.trim().isNotEmpty &&
      tipo != null &&
      !guardando;

  /// Los anulables van como función para poder poner null a propósito
  /// (mismo patrón que `AgregarMascotaUiState.copyWith`).
  NuevoEventoUiState copyWith({
    List<Mascota>? mascotas,
    int? Function()? mascotaId,
    String? titulo,
    TipoEvento? Function()? tipo,
    DateTime? fecha,
    int? Function()? horaMinutos,
    String? lugar,
    String? notas,
    DateTime? Function()? proxima,
    bool? guardando,
  }) {
    return NuevoEventoUiState(
      mascotas: mascotas ?? this.mascotas,
      mascotaId: mascotaId != null ? mascotaId() : this.mascotaId,
      titulo: titulo ?? this.titulo,
      tipo: tipo != null ? tipo() : this.tipo,
      fecha: fecha ?? this.fecha,
      horaMinutos: horaMinutos != null ? horaMinutos() : this.horaMinutos,
      lugar: lugar ?? this.lugar,
      notas: notas ?? this.notas,
      proxima: proxima != null ? proxima() : this.proxima,
      guardando: guardando ?? this.guardando,
    );
  }
}

/// Resultado puntual del guardado (equivale a `NuevoEventoEvent.Guardado`):
/// la página programa el aviso con [trigger] y vuelve atrás.
@immutable
class NuevoEventoGuardado {
  const NuevoEventoGuardado({
    required this.eventoId,
    required this.titulo,
    required this.mascotaNombre,
    this.trigger,
  });

  final int eventoId;
  final String titulo;
  final String mascotaNombre;

  /// Null = sin recordatorio; solo se programa si es futuro.
  final DateTime? trigger;
}

class NuevoEventoViewModel extends ChangeNotifier {
  NuevoEventoViewModel({required this._repositorio}) {
    _estado = NuevoEventoUiState(
      fecha: hoyInicio(),
      mascotas: _repositorio.mascotas,
    );
    _repositorio.addListener(_alCambiarRepositorio);
  }

  final MascotasRepository _repositorio;
  late NuevoEventoUiState _estado;

  NuevoEventoUiState get estado => _estado;

  void _alCambiarRepositorio() {
    final mascotas = _repositorio.mascotas;
    final elegida = _estado.mascotaId;
    _estado = _estado.copyWith(
      mascotas: mascotas,
      // Si la mascota elegida desaparece, limpiar la selección.
      mascotaId: () =>
          elegida != null && mascotas.any((m) => m.id == elegida)
              ? elegida
              : null,
    );
    notifyListeners();
  }

  void onMascotaChange(int? id) =>
      _cambiar((e) => e.copyWith(mascotaId: () => id));

  void onTituloChange(String titulo) =>
      _cambiar((e) => e.copyWith(titulo: titulo));

  void onTipoChange(TipoEvento tipo) =>
      _cambiar((e) => e.copyWith(tipo: () => tipo));

  void onFechaChange(DateTime fecha) =>
      _cambiar((e) => e.copyWith(fecha: fecha));

  void onHoraChange(int? horaMinutos) =>
      _cambiar((e) => e.copyWith(horaMinutos: () => horaMinutos));

  void onLugarChange(String lugar) => _cambiar((e) => e.copyWith(lugar: lugar));

  void onNotasChange(String notas) => _cambiar((e) => e.copyWith(notas: notas));

  void onRecordatorioChange(DateTime? proxima) =>
      _cambiar((e) => e.copyWith(proxima: () => proxima));

  void _cambiar(NuevoEventoUiState Function(NuevoEventoUiState) cambio) {
    _estado = cambio(_estado);
    notifyListeners();
  }

  /// Devuelve el resultado del guardado, o null si no se pudo guardar
  /// (la página entonces programa el aviso y vuelve atrás).
  Future<NuevoEventoGuardado?> onGuardar() async {
    final actual = _estado;
    if (!actual.puedeGuardar) return null;

    _estado = actual.copyWith(guardando: true);
    notifyListeners();
    try {
      // El aviso suena el día de la próxima fecha, a la hora del evento
      // (o a las 09:00 si no indicó hora).
      final trigger = actual.proxima?.add(
        Duration(minutes: actual.horaMinutos ?? 9 * 60),
      );
      final id = await _repositorio.guardarEvento(
        Evento(
          mascotaId: actual.mascotaId!,
          tipo: actual.tipo!,
          titulo: actual.titulo.trim(),
          fecha: actual.fecha,
          horaMinutos: actual.horaMinutos,
          lugar: _textoOpcional(actual.lugar),
          notas: _textoOpcional(actual.notas),
          proxima: actual.proxima,
        ),
      );
      final nombre = actual.mascotas
              .where((m) => m.id == actual.mascotaId)
              .firstOrNull
              ?.nombre ??
          '';
      _estado = _estado.copyWith(guardando: false);
      notifyListeners();
      return NuevoEventoGuardado(
        eventoId: id,
        titulo: actual.titulo.trim(),
        mascotaNombre: nombre,
        trigger: trigger,
      );
    } catch (_) {
      _estado = _estado.copyWith(guardando: false);
      notifyListeners();
      return null;
    }
  }

  static String? _textoOpcional(String texto) {
    final limpio = texto.trim();
    return limpio.isEmpty ? null : limpio;
  }

  @override
  void dispose() {
    _repositorio.removeListener(_alCambiarRepositorio);
    super.dispose();
  }
}