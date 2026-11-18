import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'privacidad_view_model.dart';

/// Contenedor de Privacidad de datos: crea su ViewModel y pasa solo estado
/// a la vista (la pantalla no tiene acciones).
class PrivacidadPage extends StatelessWidget {
  const PrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrivacidadViewModel(),
      child: Consumer<PrivacidadViewModel>(
        builder: (context, vm, _) => _PrivacidadContent(estado: vm.estado),
      ),
    );
  }
}

class _PrivacidadContent extends StatelessWidget {
  const _PrivacidadContent({required this.estado});

  final PrivacidadUiState estado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colorSecundario = tema.colorScheme.onSurfaceVariant;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text(estado.titulo, style: tema.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          estado.encabezado,
          style: tema.textTheme.titleMedium?.copyWith(color: colorSecundario),
        ),
        const SizedBox(height: 12),
        Text(
          estado.descripcion,
          style: tema.textTheme.bodyMedium?.copyWith(color: colorSecundario),
        ),
        for (final punto in estado.puntos) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check, color: tema.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(punto, style: tema.textTheme.bodyMedium)),
            ],
          ),
        ],
      ],
    );
  }
}