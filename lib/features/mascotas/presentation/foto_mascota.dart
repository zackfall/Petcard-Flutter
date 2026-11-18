import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared/colores_petcard.dart';

/// Avatar de la mascota: foto elegida o, si no hay, un ícono.
/// Si el archivo no existe o está dañado también cae al ícono.
class FotoMascota extends StatelessWidget {
  const FotoMascota({
    super.key,
    this.fotoPath,
    required this.size,
    this.radio,
    this.icono = Icons.pets_outlined,
    this.tamanoIcono = 48,
    this.colorBorde,
  });

  final String? fotoPath;
  final double size;

  /// Radio de las esquinas. Null = círculo.
  final double? radio;
  final IconData icono;
  final double tamanoIcono;
  final Color? colorBorde;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(icono, size: tamanoIcono, color: verdePetCard);
    final ruta = fotoPath;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radio ?? size / 2),
        border: colorBorde == null ? null : Border.all(color: colorBorde!),
      ),
      child: ruta == null
          ? placeholder
          : Image.file(
              File(ruta),
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: 1024,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}
