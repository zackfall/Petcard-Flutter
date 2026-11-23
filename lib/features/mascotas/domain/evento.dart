import 'package:flutter/foundation.dart';

/// Tipos de evento de salud (igual que `TipoEvento` en Android).
enum TipoEvento {
  vacuna,
  desparasitacion,
  controlVeterinario,
  medicacion,
  bano,
  otro,
}

extension TipoEventoEtiqueta on TipoEvento {
  String get etiqueta => switch (this) {
        TipoEvento.vacuna => 'Vacuna',
        TipoEvento.desparasitacion => 'Desparasitación',
        TipoEvento.controlVeterinario => 'Control veterinario',
        TipoEvento.medicacion => 'Medicación',
        TipoEvento.bano => 'Baño',
        TipoEvento.otro => 'Otro',
      };
}

/// Evento de salud de una mascota (equivale a `EventoEntity`).
@immutable
class Evento {
  const Evento({
    this.id = 0,
    required this.mascotaId,
    required this.tipo,
    required this.titulo,
    required this.fecha,
    this.horaMinutos,
    this.lugar,
    this.notas,
    this.proxima,
    this.hecho = false,
  });

  final int id;
  final int mascotaId;
  final TipoEvento tipo;
  final String titulo;
  final DateTime fecha;

  /// Minutos desde medianoche (600 = 10:00). Null = sin hora.
  final int? horaMinutos;
  final String? lugar;
  final String? notas;
  final DateTime? proxima;
  final bool hecho;

  /// Los campos anulables (`horaMinutos`, `lugar`, `notas`, `proxima`) van
  /// como función para poder poner null a propósito, igual que en
  /// `AgregarMascotaUiState.copyWith`: `copyWith(proxima: () => null)` quita
  /// el recordatorio; omitir el parámetro lo deja igual.
  Evento copyWith({
    int? id,
    int? mascotaId,
    TipoEvento? tipo,
    String? titulo,
    DateTime? fecha,
    int? Function()? horaMinutos,
    String? Function()? lugar,
    String? Function()? notas,
    DateTime? Function()? proxima,
    bool? hecho,
  }) =>
      Evento(
        id: id ?? this.id,
        mascotaId: mascotaId ?? this.mascotaId,
        tipo: tipo ?? this.tipo,
        titulo: titulo ?? this.titulo,
        fecha: fecha ?? this.fecha,
        horaMinutos: horaMinutos != null ? horaMinutos() : this.horaMinutos,
        lugar: lugar != null ? lugar() : this.lugar,
        notas: notas != null ? notas() : this.notas,
        proxima: proxima != null ? proxima() : this.proxima,
        hecho: hecho ?? this.hecho,
      );
}
