import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/colores_petcard.dart';
import '../../../shared/fechas.dart';
import '../../../shell/rutas.dart';
import '../data/mascotas_repository.dart';
import '../domain/evento.dart';
import 'foto_mascota.dart';
import 'perfil_mascota_view_model.dart';

/// Contenedor CON estado del Perfil de Mascota. El `mascotaId` llega como
/// argumento de la ruta (ver `petcard_shell.dart`).
class PerfilMascotaPage extends StatelessWidget {
  const PerfilMascotaPage({super.key, required this.mascotaId});

  final int mascotaId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PerfilMascotaViewModel(
        repositorio: ctx.read<MascotasRepository>(),
        mascotaId: mascotaId,
      ),
      child: Consumer<PerfilMascotaViewModel>(
        builder: (context, vm, _) => _PerfilMascotaContent(
          estado: vm.estado,
          onNuevoEvento: () =>
              Navigator.of(context).pushNamed(Rutas.nuevoEvento),
        ),
      ),
    );
  }
}

/// Vista SIN estado del perfil. Recibe estado inmutable + callbacks.
class _PerfilMascotaContent extends StatelessWidget {
  const _PerfilMascotaContent({
    required this.estado,
    required this.onNuevoEvento,
  });

  final PerfilMascotaUiState estado;
  final VoidCallback onNuevoEvento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final mascota = estado.mascota;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (estado.cargando) ...[
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ] else if (mascota == null) ...[
              const SizedBox(height: 48),
              Text(
                'No se encontró la mascota.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              FotoMascota(
                fotoPath: mascota.fotoPath,
                size: 96,
                colorBorde: verdePetCard.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 12),
              Text(
                mascota.nombre,
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineSmall?.copyWith(
                  color: verdePetCard,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                estado.subtitulo,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: onNuevoEvento,
                child: Text(
                  '+ Nuevo Evento',
                  style: tema.textTheme.bodyLarge?.copyWith(
                    color: verdePetCard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Historial de Eventos',
                    style: tema.textTheme.titleMedium,
                  ),
                ),
              ),
              if (estado.eventos.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Aún no hay eventos registrados.',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              for (final evento in estado.eventos) _ItemHistorial(evento: evento),
            ],
          ],
        ),
      ),
    );
  }
}

/// Fila del historial: círculo hueco + título, fecha en verde y detalle.
class _ItemHistorial extends StatelessWidget {
  const _ItemHistorial({required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: verdePetCard, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(evento.titulo, style: tema.textTheme.titleSmall),
                Text(
                  formatearFecha(evento.fecha),
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: verdePetCard,
                  ),
                ),
                Text(
                  _detalleDe(evento),
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Notas → lugar → etiqueta del tipo (la primera que no esté vacía).
String _detalleDe(Evento evento) {
  final notas = evento.notas?.trim();
  if (notas != null && notas.isNotEmpty) return notas;
  final lugar = evento.lugar?.trim();
  if (lugar != null && lugar.isNotEmpty) return lugar;
  return evento.tipo.etiqueta;
}
