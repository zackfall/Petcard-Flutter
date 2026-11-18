import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/mascotas/data/mascotas_repository.dart';
import '../shell/rutas.dart';

/// Lista TEMPORAL de mascotas: solo sirve para llegar a Agregar Mascota y al
/// Perfil mientras se migra la pantalla completa de Mascotas.
class MascotasPage extends StatelessWidget {
  const MascotasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mascotas = context.watch<MascotasRepository>().mascotas;
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pushNamed(Rutas.agregarMascota),
          icon: const Icon(Icons.add),
          label: const Text('Agregar Mascota'),
        ),
        const SizedBox(height: 12),
        Text('Tus Mascotas', style: tema.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (mascotas.isEmpty)
          Text(
            'Aún no tienes mascotas registradas.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final mascota in mascotas)
          Card(
            child: ListTile(
              title: Text(mascota.nombre),
              subtitle: Text(mascota.lineaPerfil),
              onTap: () => Navigator.of(context).pushNamed(
                Rutas.perfilMascota,
                arguments: mascota.id,
              ),
            ),
          ),
      ],
    );
  }
}
