import 'package:flutter/material.dart';

class DestinoBottomBar {
  const DestinoBottomBar({
    required this.ruta,
    required this.etiqueta,
    required this.icono,
  });

  final String ruta;
  final String etiqueta;
  final IconData icono;
}

class PetCardBottomBar extends StatelessWidget {
  const PetCardBottomBar({
    super.key,
    required this.destinos,
    required this.rutaActual,
    required this.alNavegar,
  });

  final List<DestinoBottomBar> destinos;
  final String rutaActual;
  final ValueChanged<String> alNavegar;

  @override
  Widget build(BuildContext context) {
    final indice = destinos.indexWhere((destino) => destino.ruta == rutaActual);
    return NavigationBar(
      selectedIndex: indice < 0 ? 0 : indice,
      onDestinationSelected: (i) => alNavegar(destinos[i].ruta),
      destinations: [
        for (final destino in destinos)
          NavigationDestination(
            icon: Icon(destino.icono),
            label: destino.etiqueta,
          ),
      ],
    );
  }
}
