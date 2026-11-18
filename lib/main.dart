import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/configuracion/data/ajustes_repository.dart';
import 'features/configuracion/data/ajustes_repository_impl.dart';
import 'shell/petcard_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ajustes = AjustesRepositoryImpl();
  await ajustes.cargar();
  runApp(PetCardApp(ajustes: ajustes));
}

class PetCardApp extends StatelessWidget {
  const PetCardApp({super.key, this.ajustes});

  /// Permite inyectar el repositorio ya cargado desde `main()` (o uno falso
  /// en pruebas). Si no se entrega, se crea uno sin preferencia guardada.
  final AjustesRepository? ajustes;

  static const _semilla = Color(0xFF6650A4);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AjustesRepository>(
      create: (_) => ajustes ?? AjustesRepositoryImpl(),
      child: Consumer<AjustesRepository>(
        builder: (context, ajustes, _) {
          final oscuro = ajustes.modoOscuro;
          return MaterialApp(
            title: 'PetCard',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: _semilla),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _semilla,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            // null = el usuario aún no eligió: se sigue el modo del sistema.
            themeMode: oscuro == null
                ? ThemeMode.system
                : (oscuro ? ThemeMode.dark : ThemeMode.light),
            home: const PetCardShell(),
          );
        },
      ),
    );
  }
}