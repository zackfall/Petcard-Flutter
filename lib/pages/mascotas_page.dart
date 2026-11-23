import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/mascotas/data/mascotas_repository.dart';
import '../features/mascotas/domain/mascota.dart';
import '../shared/colores_petcard.dart';
import '../shell/rutas.dart';

class MascotasPage extends StatelessWidget {
  const MascotasPage({super.key});

  String _proximo(MascotasRepository repo, Mascota m) {
    final n = DateTime.now();
    final hoy = DateTime(n.year, n.month, n.day);
    final futuros = repo
        .eventosDeMascota(m.id)
        .where((e) => !e.hecho && !e.fecha.isBefore(hoy))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    if (futuros.isEmpty) return 'Sin seguimientos';
    final dias = futuros.first.fecha.difference(hoy).inDays;
    return 'Próx. Seguimiento: ${dias == 0 ? 'Hoy' : dias == 1 ? 'Mañana' : '${futuros.first.fecha.day}/${futuros.first.fecha.month}'}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MascotasRepository>();
    final tema = Theme.of(context);

    // Material propio: el ColoredBox del Scaffold taparía el ink splash
    // del ListTile (assert de Flutter en modo debug).
    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Rutas.agregarMascota),
              icon: const Icon(Icons.add, color: verdePetCard),
              label: const Text('Agregar Mascota',
                  style: TextStyle(
                      color: verdePetCard, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Tus Mascotas', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (repo.mascotas.isEmpty)
            const Text('Aún no tienes mascotas registradas.'),
          for (final m in repo.mascotas)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.pets)),
              title: Text(m.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_proximo(repo, m)),
              onTap: () => Navigator.of(context)
                  .pushNamed(Rutas.perfilMascota, arguments: m.id),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined),
                    // Igual que en Kotlin: "Editar" abre el perfil.
                    onPressed: () => Navigator.of(context)
                        .pushNamed(Rutas.perfilMascota, arguments: m.id),
                  ),
                  IconButton(
                    tooltip: 'Agregar evento',
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Rutas.nuevoEvento),
                  ),
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.eliminarMascota(m.id),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}