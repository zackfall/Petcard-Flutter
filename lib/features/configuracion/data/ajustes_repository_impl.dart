import 'package:shared_preferences/shared_preferences.dart';

import 'ajustes_repository.dart';

/// Persiste las preferencias en `shared_preferences` (solo el tema visual,
/// una preferencia no crítica) y notifica a la UI para que reaccione en vivo.
class AjustesRepositoryImpl extends AjustesRepository {
  static const _claveModoOscuro = 'modoOscuro';

  bool? _modoOscuro;

  @override
  bool? get modoOscuro => _modoOscuro;

  /// Lee el valor guardado. Se llama una vez en `main()` antes de `runApp`.
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _modoOscuro =
        prefs.containsKey(_claveModoOscuro) ? prefs.getBool(_claveModoOscuro) : null;
    notifyListeners();
  }

  @override
  Future<void> guardarModoOscuro(bool valor) async {
    _modoOscuro = valor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveModoOscuro, valor);
  }
}