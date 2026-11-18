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

  Evento copyWith({int? id}) => Evento(
        id: id ?? this.id,
        mascotaId: mascotaId,
        tipo: tipo,
        titulo: titulo,
        fecha: fecha,
        horaMinutos: horaMinutos,
        lugar: lugar,
        notas: notas,
        proxima: proxima,
        hecho: hecho,
      );
}
