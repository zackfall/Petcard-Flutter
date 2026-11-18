import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/titulo_seccion.dart';
import 'acerca_view_model.dart';

/// Contenedor de Acerca de PetCard: crea su ViewModel y pasa solo estado a
/// la vista (la pantalla no tiene acciones).
class AcercaPage extends StatelessWidget {
  const AcercaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AcercaViewModel(),
      child: Consumer<AcercaViewModel>(
        builder: (context, vm, _) => _AcercaContent(estado: vm.estado),
      ),
    );
  }
}

class _AcercaContent extends StatelessWidget {
  const _AcercaContent({required this.estado});

  final AcercaUiState estado;

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
          estado.descripcion,
          style: tema.textTheme.bodyMedium?.copyWith(color: colorSecundario),
        ),
        const TituloSeccion('Contexto académico'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final dato in estado.contexto)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            dato.etiqueta,
                            style: tema.textTheme.labelMedium
                                ?.copyWith(color: colorSecundario),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            dato.valor,
                            style: tema.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const TituloSeccion('Integrantes'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final integrante in estado.integrantes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(integrante, style: tema.textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
        ),
        const TituloSeccion('Características'),
        for (final caracteristica in estado.caracteristicas)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check, color: tema.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(caracteristica, style: tema.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            estado.version,
            style: tema.textTheme.labelMedium?.copyWith(color: colorSecundario),
          ),
        ),
      ],
    );
  }
}