import 'package:flutter/foundation.dart';

import '../domain/evento.dart';
import '../domain/mascota.dart';

/// Contrato del repositorio de mascotas y eventos.
///
/// Los ViewModels dependen SOLO de esta clase. Hoy la implementa
/// `MascotasRepositoryImpl` en memoria; cuando exista la API (dio) o
/// Firebase/Supabase se cambia la implementación sin tocar ViewModels ni vistas.
abstract class MascotasRepository extends ChangeNotifier {
  List<Mascota> get mascotas;

  Mascota? mascotaPorId(int id);

  List<Evento> eventosDeMascota(int mascotaId);

  /// Devuelve el id asignado.
  Future<int> guardarMascota(Mascota mascota);

  Future<int> guardarEvento(Evento evento);
}
