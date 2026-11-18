abstract final class Rutas {
  static const inicio = 'inicio';
  static const mascotas = 'mascotas';
  static const eventosPendientes = 'eventos_pendientes';
  static const calendario = 'calendario';
  static const configuracion = 'configuracion';
  static const privacidad = 'privacidad';
  static const acerca = 'acerca';

  static const rutasRaiz = {inicio, mascotas, eventosPendientes, calendario};

  static String titulo(String? ruta) => switch (ruta) {
        inicio => 'PetCard',
        mascotas => 'Mascotas',
        eventosPendientes => 'Evento de Salud',
        calendario => 'Calendario',
        configuracion => 'Configuración',
        privacidad => 'Privacidad de datos',
        acerca => 'Acerca de PetCard',
        _ => 'PetCard',
      };
}