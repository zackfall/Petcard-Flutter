import 'package:flutter/foundation.dart';

import '../data/ajustes_repository.dart';

/// Estado único de la pantalla Configuración.
@immutable
class ConfiguracionUiState {
  const ConfiguracionUiState({
    this.modoOscuro = false,
    this.notificacionesPush = true,
  });

  /// Tema elegido (persistido en [AjustesRepository]).
  final bool modoOscuro;

  /// Preferencia de recordatorios.
  final bool notificacionesPush;

  ConfiguracionUiState copyWith({bool? modoOscuro, bool? notificacionesPush}) {
    return ConfiguracionUiState(
      modoOscuro: modoOscuro ?? this.modoOscuro,
      notificacionesPush: notificacionesPush ?? this.notificacionesPush,
    );
  }
}

class ConfiguracionViewModel extends ChangeNotifier {
  /// El tema persistido manda; si el usuario aún no eligió se usa el modo
  /// del sistema [modoOscuroSistema].
  ConfiguracionViewModel({
    required AjustesRepository ajustes,
    required bool modoOscuroSistema,
  })  : _ajustes = ajustes,
        _estado = ConfiguracionUiState(
          modoOscuro: ajustes.modoOscuro ?? modoOscuroSistema,
        );

  final AjustesRepository _ajustes;
  ConfiguracionUiState _estado;

  ConfiguracionUiState get estado => _estado;

  void onModoOscuroChange(bool activado) {
    _estado = _estado.copyWith(modoOscuro: activado);
    notifyListeners();
    _ajustes.guardarModoOscuro(activado);
  }

  void onNotificacionesPushChange(bool activas) {
    _estado = _estado.copyWith(notificacionesPush: activas);
    notifyListeners();
  }
}