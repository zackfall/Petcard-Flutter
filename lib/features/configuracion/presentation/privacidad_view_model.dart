import 'package:flutter/foundation.dart';

/// Estado único de la pantalla Privacidad de datos.
@immutable
class PrivacidadUiState {
  const PrivacidadUiState({
    this.titulo = 'Privacidad de datos',
    this.encabezado = 'Tus datos se guardan localmente',
    this.descripcion = 'PetCard usa Room para almacenar mascotas, eventos y '
        'salud directamente en tu dispositivo.',
    this.puntos = const [
      'No requiere cuenta ni inicio de sesión.',
      'No se comparten con terceros.',
      'Podrían perderse al desinstalar la app o borrar sus datos.',
    ],
  });

  final String titulo;
  final String encabezado;
  final String descripcion;
  final List<String> puntos;
}

/// Estado fijo: el texto del diseño vive en el UiState y la vista solo lo pinta.
class PrivacidadViewModel extends ChangeNotifier {
  final PrivacidadUiState estado = const PrivacidadUiState();
}