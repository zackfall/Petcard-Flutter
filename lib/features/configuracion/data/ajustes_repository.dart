import 'package:flutter/foundation.dart';

/// Preferencias de la app (tema), persistidas en disco.
///
/// Contrato en `data/`, implementación en `ajustes_repository_impl.dart`,
/// entregado a los ViewModels con Provider. El ViewModel nunca toca
/// `SharedPreferences` directamente.
abstract class AjustesRepository extends ChangeNotifier {
  /// `true`/`false` = elección guardada del usuario; `null` = aún no eligió
  /// y la app sigue el modo del sistema.
  bool? get modoOscuro;

  Future<void> guardarModoOscuro(bool valor);
}