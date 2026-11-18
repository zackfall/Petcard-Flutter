import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shell/rutas.dart';
import '../../../shared/titulo_seccion.dart';
import '../data/ajustes_repository.dart';
import 'configuracion_view_model.dart';

/// Contenedor CON estado de Configuración: crea su ViewModel con las
/// dependencias que entrega Provider y pasa solo estado + acciones a la vista.
class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Se lee aquí (en build) y no dentro de `create`, donde no se puede escuchar.
    final modoOscuroSistema =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return ChangeNotifierProvider(
      create: (ctx) => ConfiguracionViewModel(
        ajustes: ctx.read<AjustesRepository>(),
        modoOscuroSistema: modoOscuroSistema,
      ),
      child: Consumer<ConfiguracionViewModel>(
        builder: (context, vm, _) => _ConfiguracionContent(
          estado: vm.estado,
          onModoOscuroChange: vm.onModoOscuroChange,
          onNotificacionesPushChange: vm.onNotificacionesPushChange,
          onPrivacidad: () => Navigator.of(context).pushNamed(Rutas.privacidad),
          onAcerca: () => Navigator.of(context).pushNamed(Rutas.acerca),
          onCerrarSesion: () {
            // Pendiente: aún no hay usuarios en la app.
          },
        ),
      ),
    );
  }
}

/// Vista SIN estado de Configuración. Recibe estado inmutable + callbacks;
/// jamás un ViewModel.
class _ConfiguracionContent extends StatelessWidget {
  const _ConfiguracionContent({
    required this.estado,
    required this.onModoOscuroChange,
    required this.onNotificacionesPushChange,
    required this.onPrivacidad,
    required this.onAcerca,
    required this.onCerrarSesion,
  });

  final ConfiguracionUiState estado;
  final ValueChanged<bool> onModoOscuroChange;
  final ValueChanged<bool> onNotificacionesPushChange;
  final VoidCallback onPrivacidad;
  final VoidCallback onAcerca;
  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const TituloSeccion('Aspecto de la app'),
        _FilaAjuste(
          icono: Icons.wb_sunny,
          titulo: 'Modo Claro / Oscuro',
          trailing: Switch(
            value: estado.modoOscuro,
            onChanged: onModoOscuroChange,
          ),
        ),
        const TituloSeccion('Ajustes generales'),
        _FilaAjuste(
          icono: Icons.notifications,
          titulo: 'Notificaciones Push',
          trailing: Switch(
            value: estado.notificacionesPush,
            onChanged: onNotificacionesPushChange,
          ),
        ),
        _FilaAjuste(
          icono: Icons.privacy_tip,
          titulo: 'Privacidad de datos',
          onTap: onPrivacidad,
          trailing: const _EtiquetaAcceso('Gestionar'),
        ),
        _FilaAjuste(
          icono: Icons.info,
          titulo: 'Acerca de PetCard',
          onTap: onAcerca,
          trailing: const _EtiquetaAcceso('Ver más'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onCerrarSesion,
          child: const Text('Cerrar Sesión'),
        ),
      ],
    );
  }
}

class _EtiquetaAcceso extends StatelessWidget {
  const _EtiquetaAcceso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          texto,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
        Icon(Icons.chevron_right, color: color),
      ],
    );
  }
}

class _FilaAjuste extends StatelessWidget {
  const _FilaAjuste({
    required this.icono,
    required this.titulo,
    required this.trailing,
    this.onTap,
  });

  final IconData icono;
  final String titulo;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icono, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}