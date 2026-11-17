import 'package:flutter/material.dart';

class MascotasPage extends StatelessWidget {
  const MascotasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, size: 64),
          SizedBox(height: 12),
          Text('Mascotas', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
