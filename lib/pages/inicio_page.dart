import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 64),
          SizedBox(height: 12),
          Text('Inicio', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
