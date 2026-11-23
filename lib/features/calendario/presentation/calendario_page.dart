import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notifications/notificaciones.dart';
import '../../../shared/evento_ui.dart';
import '../../../shared/fechas.dart';
import '../../mascotas/data/mascotas_repository.dart';
import 'calendario_view_model.dart';

const _diasSemana = ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'];

/// Contenedor CON estado del Calendario (diseño screen-container-5):
/// crea su ViewModel con Provider y traduce las acciones puntuales en
/// programar/cancelar avisos. A la vista solo le pasa estado + acciones.
class CalendarioPage extends StatelessWidget {
  const CalendarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CalendarioViewModel(
        repositorio: ctx.read<MascotasRepository>(),
      ),
      child: Consumer<CalendarioViewModel>(
        builder: (context, vm, _) => _CalendarioContent(
          estado: vm.estado,
          onMesAnterior: vm.onMesAnterior,
          onMesSiguiente: vm.onMesSiguiente,
          onDiaElegido: vm.onDiaElegido,
          onAlternarRecordatorio: (id) async {
            final accion = await vm.onAlternarRecordatorio(id);
            switch (accion) {
              case ProgramarAviso():
                await Notificaciones.programar(
                  eventoId: accion.eventoId,
                  titulo: accion.titulo,
                  detalle: 'Tienes un evento de salud hoy.',
                  trigger: accion.trigger,
                );
              case CancelarAviso():
                await Notificaciones.cancelar(accion.eventoId);
              case null:
                break;
            }
          },
        ),
      ),
    );
  }
}

/// Vista SIN estado del Calendario. Recibe estado inmutable + callbacks;
/// jamás un ViewModel.
class _CalendarioContent extends StatelessWidget {
  const _CalendarioContent({
    required this.estado,
    required this.onMesAnterior,
    required this.onMesSiguiente,
    required this.onDiaElegido,
    required this.onAlternarRecordatorio,
  });

  final CalendarioUiState estado;
  final VoidCallback onMesAnterior;
  final VoidCallback onMesSiguiente;
  final ValueChanged<DateTime> onDiaElegido;
  final ValueChanged<int> onAlternarRecordatorio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final dia = estado.diaSeleccionado;
    final celdas = estado.celdas;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Mes anterior',
              onPressed: onMesAnterior,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${nombreMes(estado.anio, estado.mes)} ${estado.anio}',
                style: tema.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: 'Mes siguiente',
              onPressed: onMesSiguiente,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final d in _diasSemana)
              Expanded(
                child: Text(
                  d,
                  style: tema.textTheme.labelLarge?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Grilla mensual: filas de 7 celdas (la última se completa con huecos).
        for (var i = 0; i < celdas.length; i += 7) ...[
          Row(
            children: [
              for (final celda in celdas.skip(i).take(7))
                Expanded(
                  child: Center(
                    child: _CeldaDia(
                      celda: celda,
                      onElegido: onDiaElegido,
                    ),
                  ),
                ),
              for (var j = celdas.skip(i).take(7).length; j < 7; j++)
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 2),
        ],
        const SizedBox(height: 12),
        Text(
          'Eventos para hoy (${dia.day} de ${nombreMes(dia.year, dia.month)})',
          style: tema.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (estado.eventos.isEmpty)
          Text(
            'Sin eventos este día.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final evento in estado.eventos) ...[
          EventoRow(
            titulo: evento.titulo,
            subtitulo: evento.subtitulo,
            detalle: evento.detalle,
            accion: IconButton(
              tooltip: 'Alternar recordatorio',
              onPressed: () => onAlternarRecordatorio(evento.id),
              icon: Icon(
                Icons.notifications,
                color: evento.tieneRecordatorio
                    ? tema.colorScheme.primary
                    : tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Celda circular de 40 con el número del día y el punto de eventos.
class _CeldaDia extends StatelessWidget {
  const _CeldaDia({required this.celda, required this.onElegido});

  final CeldaDia celda;
  final ValueChanged<DateTime> onElegido;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final numero = celda.numero;
    if (numero == null) return const SizedBox(width: 40, height: 40);

    final fondo = celda.seleccionado
        ? tema.colorScheme.primaryContainer
        : celda.esHoy
            ? tema.colorScheme.secondaryContainer
            : tema.colorScheme.surface;

    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: fondo,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: celda.fecha != null ? () => onElegido(celda.fecha!) : null,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$numero', style: tema.textTheme.bodyMedium),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: celda.tieneEventos
                        ? tema.colorScheme.primary
                        : tema.colorScheme.surface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}