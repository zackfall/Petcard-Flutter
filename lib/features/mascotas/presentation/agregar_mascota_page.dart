import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../shared/colores_petcard.dart';
import '../data/foto_store.dart';
import '../data/mascotas_repository.dart';
import 'agregar_mascota_view_model.dart';
import 'foto_mascota.dart';
import 'formato_peso.dart';

/// Contenedor CON estado de Agregar Mascota: crea su ViewModel con las
/// dependencias que entrega Provider, abre la galería y vuelve atrás al
/// guardar. A la vista solo le pasa estado + acciones.
class AgregarMascotaPage extends StatelessWidget {
  const AgregarMascotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AgregarMascotaViewModel(
        repositorio: ctx.read<MascotasRepository>(),
      ),
      child: Consumer<AgregarMascotaViewModel>(
        builder: (context, vm, _) => _AgregarMascotaContent(
          estado: vm.estado,
          onNombreChange: vm.onNombreChange,
          onEspecieChange: vm.onEspecieChange,
          onRazaChange: vm.onRazaChange,
          onEdadChange: vm.onEdadChange,
          onPesoChange: vm.onPesoChange,
          onElegirFoto: () => _elegirFoto(vm),
          onGuardar: () async {
            final guardada = await vm.onGuardar();
            if (guardada && context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Abre la galería, copia la foto elegida al almacenamiento interno y borra
/// la anterior (si había).
Future<void> _elegirFoto(AgregarMascotaViewModel vm) async {
  final elegida = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (elegida == null) return;
  final anterior = vm.estado.fotoPath;
  final destino = await FotoStore.copiarFoto(elegida.path);
  await FotoStore.borrarFoto(anterior);
  vm.onFotoChange(destino);
}

/// Vista SIN estado del formulario. Recibe estado inmutable + callbacks;
/// jamás un ViewModel.
class _AgregarMascotaContent extends StatelessWidget {
  const _AgregarMascotaContent({
    required this.estado,
    required this.onNombreChange,
    required this.onEspecieChange,
    required this.onRazaChange,
    required this.onEdadChange,
    required this.onPesoChange,
    required this.onElegirFoto,
    required this.onGuardar,
  });

  final AgregarMascotaUiState estado;
  final ValueChanged<String> onNombreChange;
  final ValueChanged<String> onEspecieChange;
  final ValueChanged<String> onRazaChange;
  final ValueChanged<String> onEdadChange;
  final ValueChanged<String> onPesoChange;
  final VoidCallback onElegirFoto;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Center(
            child: Semantics(
              button: true,
              label: 'Elegir foto de la mascota',
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onElegirFoto,
                child: FotoMascota(
                  fotoPath: estado.fotoPath,
                  size: 76,
                  radio: 14,
                  icono: Icons.image_outlined,
                  tamanoIcono: 38,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'FOTO DE LA MASCOTA',
              style: tema.textTheme.labelMedium?.copyWith(
                color: verdePetCard,
                letterSpacing: 1,
              ),
            ),
          ),
          _CampoTexto(
            etiqueta: 'Nombre',
            placeholder: 'Ej. Max, Luna, Bobby',
            onChanged: onNombreChange,
          ),
          _CampoTexto(
            etiqueta: 'Especie / Tipo',
            placeholder: 'Ej. Perro, Gato, Ave, etc.',
            onChanged: onEspecieChange,
          ),
          _CampoTexto(
            etiqueta: 'Raza',
            placeholder: 'Ej. Golden Retriever, Criollo',
            onChanged: onRazaChange,
          ),
          _CampoTexto(
            etiqueta: 'Edad (Años)',
            placeholder: 'Ej. 3',
            onChanged: onEdadChange,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _CampoTexto(
            etiqueta: 'Peso (kg)',
            placeholder: 'Ej. 4.5',
            onChanged: onPesoChange,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PesoInputFormatter()],
          ),
          if (estado.error != null)
            Text(
              estado.error!,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.error,
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

/// Campo del formulario: etiqueta arriba + recuadro con placeholder.
class _CampoTexto extends StatelessWidget {
  const _CampoTexto({
    required this.etiqueta,
    required this.placeholder,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final String etiqueta;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
        TextFormField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
