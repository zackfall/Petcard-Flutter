import 'package:flutter/foundation.dart';

import '../../../shared/fechas.dart';

/// Una mascota del usuario (equivale a `MascotaEntity` en Android).
@immutable
class Mascota {
  const Mascota({
    this.id = 0,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.fechaNacimiento,
    this.fotoPath,
    this.pesoKg,
  });

  /// 0 = aún sin guardar; el repositorio asigna el id real.
  final int id;
  final String nombre;
  final String especie;
  final String raza;
  final DateTime fechaNacimiento;
  final String? fotoPath;
  final double? pesoKg;

  Mascota copyWith({int? id}) => Mascota(
        id: id ?? this.id,
        nombre: nombre,
        especie: especie,
        raza: raza,
        fechaNacimiento: fechaNacimiento,
        fotoPath: fotoPath,
        pesoKg: pesoKg,
      );

  /// Subtítulo del perfil: "Golden Retriever • 3 años".
  String get lineaPerfil {
    final edad = edadEnAnos(fechaNacimiento);
    final textoEdad = edad == 1 ? '1 año' : '$edad años';
    return [raza.trim(), textoEdad].where((t) => t.isNotEmpty).join(' • ');
  }
}
