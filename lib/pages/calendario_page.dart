import 'package:flutter/material.dart';

class CalendarioPage extends StatelessWidget {
  const CalendarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, size: 64),
          SizedBox(height: 12),
          Text('Calendario', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
