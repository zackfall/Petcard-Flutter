import 'package:flutter/material.dart';

import '../features/mascotas/domain/evento.dart';
import 'fechas.dart';

/// "Max • Vacuna 24 oct 2026" + "10:00 • Clínica..." para reutilizar formato
/// (equivale a `lineaEvento` de `EventoUi.kt`).
({String subtitulo, String detalle}) lineaEvento({
  required String nombreMascota,
  required TipoEvento tipo,
  required DateTime fecha,
  int? horaMinutos,
  String? lugar,
}) {
  final subtitulo =
      '$nombreMascota • ${tipo.etiqueta} ${formatearFecha(fecha)}';
  final detalle = [
    if (horaMinutos != null) formatearHora(horaMinutos),
    if (lugar != null && lugar.trim().isNotEmpty) lugar,
  ].join(' • ');
  return (subtitulo: subtitulo, detalle: detalle);
}

/// Item plano listo para pintar (lo arman los ViewModels, no la UI).
@immutable
class EventoItem {
  const EventoItem({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.detalle,
    this.hecho = false,
    this.tieneRecordatorio = false,
  });

  final int id;
  final String titulo;
  final String subtitulo;
  final String detalle;
  final bool hecho;
  final bool tieneRecordatorio;
}

/// Convierte un [Evento] en [EventoItem] resolviendo el nombre de la mascota.
extension EventoAItem on Evento {
  EventoItem aItem(String nombreMascota) {
    final linea = lineaEvento(
      nombreMascota: nombreMascota,
      tipo: tipo,
      fecha: fecha,
      horaMinutos: horaMinutos,
      lugar: lugar,
    );
    return EventoItem(
      id: id,
      titulo: titulo,
      subtitulo: linea.subtitulo,
      detalle: linea.detalle,
      hecho: hecho,
      tieneRecordatorio: proxima != null,
    );
  }
}

/// Fila sin estado para mostrar un evento (la usan Calendario y Pendientes).
/// Solo recibe datos inmutables y un widget de acción: jamás un ViewModel.
class EventoRow extends StatelessWidget {
  const EventoRow({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.detalle,
    this.accion,
  });

  final String titulo;
  final String subtitulo;
  final String detalle;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: tema.textTheme.titleMedium),
                  Text(subtitulo, style: tema.textTheme.bodyMedium),
                  Text(
                    detalle,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ?accion,
          ],
        ),
      ),
    );
  }
}