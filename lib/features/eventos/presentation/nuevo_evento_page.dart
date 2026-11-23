import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notifications/notificaciones.dart';
import '../../../shared/colores_petcard.dart';
import '../../../shared/fechas.dart';
import '../../../shell/rutas.dart';
import '../../mascotas/data/mascotas_repository.dart';
import '../../mascotas/domain/evento.dart';
import 'nuevo_evento_view_model.dart';

/// Contenedor CON estado de Nuevo Evento (diseño screen-container-4):
/// crea su ViewModel con Provider y traduce el guardado en (1) programar el
/// aviso y (2) navegar atrás. A la vista solo le pasa estado + acciones.
class NuevoEventoPage extends StatelessWidget {
  const NuevoEventoPage({super.key});

  /// Punto de entrada único a Nuevo Evento: si aún no hay mascotas, muestra
  /// un popup que lleva a Agregar Mascota en vez de abrir el formulario vacío.
  ///
  /// [navigator] permite al shell pasar su Navigator interno (el contexto del
  /// AppBar queda por encima de él); desde una página basta con `abrir(context)`.
  static Future<void> abrir(BuildContext context, {NavigatorState? navigator}) async {
    final nav = navigator ?? Navigator.of(context);
    if (context.read<MascotasRepository>().mascotas.isNotEmpty) {
      nav.pushNamed(Rutas.nuevoEvento);
      return;
    }
    final irAgregar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aún no tienes mascotas'),
        content: const Text(
          'Para crear un evento de salud primero necesitas registrar una mascota.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Agregar Mascota'),
          ),
        ],
      ),
    );
    if (irAgregar == true) nav.pushNamed(Rutas.agregarMascota);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NuevoEventoViewModel(
        repositorio: ctx.read<MascotasRepository>(),
      ),
      child: Consumer<NuevoEventoViewModel>(
        builder: (context, vm, _) => _NuevoEventoContent(
          estado: vm.estado,
          onMascotaChange: vm.onMascotaChange,
          onTituloChange: vm.onTituloChange,
          onTipoChange: vm.onTipoChange,
          onFechaChange: vm.onFechaChange,
          onHoraChange: vm.onHoraChange,
          onLugarChange: vm.onLugarChange,
          onNotasChange: vm.onNotasChange,
          onRecordatorioChange: vm.onRecordatorioChange,
          onGuardar: () async {
            final guardado = await vm.onGuardar();
            if (guardado == null || !context.mounted) return;
            final trigger = guardado.trigger;
            if (trigger != null && trigger.isAfter(DateTime.now())) {
              await Notificaciones.programar(
                eventoId: guardado.eventoId,
                titulo: guardado.titulo,
                detalle: '${guardado.mascotaNombre} • Próximo control',
                trigger: trigger,
              );
            }
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Vista SIN estado del formulario Nuevo Evento. Recibe estado inmutable +
/// callbacks; jamás un ViewModel.
class _NuevoEventoContent extends StatelessWidget {
  const _NuevoEventoContent({
    required this.estado,
    required this.onMascotaChange,
    required this.onTituloChange,
    required this.onTipoChange,
    required this.onFechaChange,
    required this.onHoraChange,
    required this.onLugarChange,
    required this.onNotasChange,
    required this.onRecordatorioChange,
    required this.onGuardar,
  });

  final NuevoEventoUiState estado;
  final ValueChanged<int?> onMascotaChange;
  final ValueChanged<String> onTituloChange;
  final ValueChanged<TipoEvento> onTipoChange;
  final ValueChanged<DateTime> onFechaChange;
  final ValueChanged<int?> onHoraChange;
  final ValueChanged<String> onLugarChange;
  final ValueChanged<String> onNotasChange;
  final ValueChanged<DateTime?> onRecordatorioChange;
  final VoidCallback onGuardar;

  static final _primeraFecha = DateTime(2000);
  static final _ultimaFecha = DateTime(2100, 12, 31);

  Future<void> _elegirFecha(BuildContext context) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: estado.fecha,
      firstDate: _primeraFecha,
      lastDate: _ultimaFecha,
    );
    if (elegida != null) onFechaChange(DateTime(elegida.year, elegida.month, elegida.day));
  }

  /// Diálogo de hora con las tres salidas del diseño: OK, Sin hora, Cancelar.
  /// El botón "Sin hora" va debajo del picker porque `TimePickerDialog`
  /// solo trae Cancelar/OK propios.
  Future<void> _elegirHora(BuildContext context) async {
    final minutos = estado.horaMinutos ?? 600;
    final resultado = await showDialog<Object?>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimePickerDialog(
            initialTime: TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(_marcaSinHora),
            child: const Text('Sin hora'),
          ),
        ],
      ),
    );
    if (resultado == _marcaSinHora) {
      onHoraChange(null);
    } else if (resultado is TimeOfDay) {
      onHoraChange(resultado.hour * 60 + resultado.minute);
    }
  }

  /// Centinela para distinguir "Sin hora" de Cancelar (null) en el diálogo.
  static const _marcaSinHora = Object();

  /// Diálogo del recordatorio con "Sin aviso" para quitarlo.
  Future<void> _elegirRecordatorio(BuildContext context) async {
    var elegida = estado.proxima ?? estado.fecha;
    var sinAviso = false;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 320,
          height: 340,
          child: CalendarDatePicker(
            initialDate: elegida,
            firstDate: _primeraFecha,
            lastDate: _ultimaFecha,
            onDateChanged: (d) => elegida = d,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              sinAviso = true;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Sin aviso'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    onRecordatorioChange(
      sinAviso ? null : DateTime(elegida.year, elegida.month, elegida.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final borde = OutlineInputBorder(borderRadius: BorderRadius.circular(8));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          // --- Mascota ---
          // DropdownButton controlado (no FormField): el estado del VM manda
          // y puede limpiar la selección si la mascota desaparece.
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Mascota',
              border: borde,
            ),
            isEmpty: estado.mascotaId == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: estado.mascotaId,
                isExpanded: true,
                hint: const Text('Seleccionar mascota...'),
                items: [
                  for (final m in estado.mascotas)
                    DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.nombre} (${m.especie})'),
                    ),
                ],
                onChanged: onMascotaChange,
              ),
            ),
          ),
          // --- Título ---
          TextFormField(
            initialValue: estado.titulo,
            onChanged: onTituloChange,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Título',
              hintText: 'Ej. Vacuna de la Rabia',
              border: borde,
            ),
          ),
          // --- Tipo de evento ---
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tipo de Evento',
              border: borde,
            ),
            isEmpty: estado.tipo == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TipoEvento>(
                value: estado.tipo,
                isExpanded: true,
                hint: const Text('Ninguno'),
                items: [
                  for (final tipo in TipoEvento.values)
                    DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
                ],
                onChanged: (tipo) {
                  if (tipo != null) onTipoChange(tipo);
                },
              ),
            ),
          ),
          // --- Fecha y hora ---
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _elegirFecha(context),
                  child: Text(
                    'Fecha\n${formatearFechaCorta(estado.fecha)}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _elegirHora(context),
                  child: Text(
                    'Hora\n${estado.horaMinutos != null ? formatearHora(estado.horaMinutos!) : '--:--'}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          // --- Lugar (opcional) ---
          TextFormField(
            initialValue: estado.lugar,
            onChanged: onLugarChange,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Lugar / Clínica (opcional)',
              hintText: 'Ej. Clínica Veterinaria Principal',
              border: borde,
            ),
          ),
          // --- Notas ---
          TextFormField(
            initialValue: estado.notas,
            onChanged: onNotasChange,
            minLines: 3,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'Notas / Recordatorio',
              hintText: 'Añadir notas del evento...',
              border: borde,
            ),
          ),
          // --- Próxima fecha (aviso opcional) ---
          OutlinedButton(
            onPressed: () => _elegirRecordatorio(context),
            child: Text(
              'Próximo recordatorio: '
              '${estado.proxima != null ? formatearFechaCorta(estado.proxima!) : 'sin aviso'}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton(
              onPressed: estado.puedeGuardar ? onGuardar : null,
              style: FilledButton.styleFrom(
                backgroundColor: verdeBoton,
                foregroundColor: tema.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(estado.guardando ? 'Guardando...' : 'Listo ✓'),
            ),
          ),
        ],
      ),
    );
  }
}