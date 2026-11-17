import 'package:flutter/material.dart';

import 'shell/petcard_shell.dart';

void main() {
  runApp(const PetCardApp());
}

class PetCardApp extends StatelessWidget {
  const PetCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6650A4)),
        useMaterial3: true,
      ),
      home: const PetCardShell(),
    );
  }
}
