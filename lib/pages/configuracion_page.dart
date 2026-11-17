import 'package:flutter/material.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings, size: 64),
          SizedBox(height: 12),
          Text('Configuración', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
