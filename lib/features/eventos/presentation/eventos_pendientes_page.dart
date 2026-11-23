import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/evento_ui.dart';
import '../../mascotas/data/mascotas_repository.dart';
import 'eventos_pendientes_view_model.dart';
import 'nuevo_evento_page.dart';

/// Contenedor CON estado de Eventos pendientes (diseño screen-container-6):
/// crea su ViewModel con las dependencias que entrega Provider y navega a
/// Nuevo Evento. A la vista solo le pasa estado + acciones.
class EventosPendientesPage extends StatelessWidget {
  const EventosPendientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => EventosPendientesViewModel(
        repositorio: ctx.read<MascotasRepository>(),
      ),
      child: Consumer<EventosPendientesViewModel>(
        builder: (context, vm, _) => _PendientesContent(
          estado: vm.estado,
          onHecho: vm.onHecho,
          onEliminar: vm.onEliminar,
          onCrearEvento: () => NuevoEventoPage.abrir(context),
        ),
      ),
    );
  }
}

/// Vista SIN estado de Eventos pendientes. Recibe estado inmutable +
/// callbacks; jamás un ViewModel.
class _PendientesContent extends StatelessWidget {
  const _PendientesContent({
    required this.estado,
    required this.onHecho,
    required this.onEliminar,
    required this.onCrearEvento,
  });

  final PendientesUiState estado;
  final ValueChanged<int> onHecho;
  final ValueChanged<int> onEliminar;
  final VoidCallback onCrearEvento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: onCrearEvento,
        tooltip: 'Nuevo evento',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Eventos Pendientes', style: tema.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (!estado.cargando && estado.eventos.isEmpty)
            Text(
              'Sin pendientes. ¡Buen trabajo!',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          for (final evento in estado.eventos) ...[
            EventoRow(
              titulo: evento.titulo,
              subtitulo: evento.subtitulo,
              detalle: evento.detalle,
              accion: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (hecho) {
                      if (hecho == true) onHecho(evento.id);
                    },
                  ),
                  Text(
                    'Hecho (eliminar)',
                    style: tema.textTheme.labelLarge?.copyWith(
                      color: tema.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar evento',
                    onPressed: () => onEliminar(evento.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}