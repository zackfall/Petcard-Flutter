import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/mascotas/data/mascotas_repository.dart';
import '../features/mascotas/domain/evento.dart';
import '../shared/colores_petcard.dart';
import '../shared/fechas.dart';
import '../shell/rutas.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  static String _dia(DateTime f) {
    final n = DateTime.now();
    final dias = DateTime(f.year, f.month, f.day)
        .difference(DateTime(n.year, n.month, n.day))
        .inDays;
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    return formatearFecha(f);
  }

  static String _hora(int? m) {
    if (m == null) return '';
    final h = m ~/ 60, min = m % 60;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${min.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MascotasRepository>();
    final tema = Theme.of(context);
    final n = DateTime.now();
    final hoy = DateTime(n.year, n.month, n.day);

    final proximos = repo.eventos
        .where((e) => !e.hecho && !e.fecha.isBefore(hoy))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final historial = repo.eventos.where((e) => e.hecho).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    String mascota(Evento e) =>
        repo.mascotaPorId(e.mascotaId)?.nombre ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Próximos Eventos de Salud',
            style: tema.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (proximos.isEmpty)
          const Text('No tienes eventos próximos.'),
        for (final e in proximos.take(3))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.pets)),
            title: Text(
              '${e.titulo} • ${_dia(e.fecha)}'
              '${e.horaMinutos != null ? ', ${_hora(e.horaMinutos)}' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(mascota(e)),
            trailing: const Icon(Icons.info_outline),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Historial Reciente',
                  style: tema.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(Rutas.eventosPendientes, (_) => false),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        if (historial.isEmpty) const Text('Aún no hay historial.'),
        for (final e in historial.take(5))
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.check, color: verdePetCard),
            title: Text(e.titulo),
            subtitle: Text(mascota(e)),
            trailing: Text(formatearFecha(e.fecha),
                style: tema.textTheme.bodySmall),
          ),
      ],
    );
  }
}