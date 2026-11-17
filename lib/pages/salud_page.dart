import 'package:flutter/material.dart';

class SaludPage extends StatelessWidget {
  const SaludPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monitor_heart, size: 64),
          SizedBox(height: 12),
          Text('Salud', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
