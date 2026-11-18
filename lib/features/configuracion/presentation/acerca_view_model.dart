import 'package:flutter/foundation.dart';

/// Dato etiqueta/valor del bloque "Contexto académico".
@immutable
class DatoAcerca {
  const DatoAcerca(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;
}

/// Estado único de la pantalla Acerca de PetCard.
@immutable
class AcercaUiState {
  const AcercaUiState({
    this.titulo = 'Acerca de PetCard',
    this.descripcion =
        'PetCard es una aplicación móvil que funciona como un carné de '
            'vacunación y control de salud digital para mascotas, permitiendo '
            'al dueño registrar y consultar de forma rápida y sin conexión a '
            'internet el historial de vacunas, desparasitaciones y controles '
            'veterinarios de su mascota.',
    this.contexto = const [
      DatoAcerca('Asignatura', 'Aplicaciones Móviles'),
      DatoAcerca('Universidad', 'Universidad Laica Eloy Alfaro de Manabí'),
      DatoAcerca('Facultad', 'Ciencias Informáticas'),
      DatoAcerca('Carrera', 'Tecnología de la Información'),
      DatoAcerca('Docente', 'Joffre Edgardo Panchana Flores'),
    ],
    this.integrantes = const [
      'Eduardo Josue López López',
      'Castillo Loor José Manuel',
      'Reyes Peñaherrera Pierina Natalia',
      'Ruben Isaac Zamora Reyes',
    ],
    this.caracteristicas = const [
      '100% offline-first: la información se guarda en tu dispositivo.',
      'Un solo usuario: sin cuentas, roles ni invitaciones.',
      'Funciona sin internet ni servidores externos.',
    ],
    this.version = 'Versión 1.0',
  });

  final String titulo;
  final String descripcion;
  final List<DatoAcerca> contexto;
  final List<String> integrantes;
  final List<String> caracteristicas;
  final String version;
}

/// Estado fijo de Acerca de PetCard: el texto vive en el UiState y la vista
/// solo lo pinta.
class AcercaViewModel extends ChangeNotifier {
  final AcercaUiState estado = const AcercaUiState();
}