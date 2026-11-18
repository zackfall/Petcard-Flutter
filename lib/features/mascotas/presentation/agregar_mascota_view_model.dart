import 'package:flutter/foundation.dart';

import '../../../shared/fechas.dart';
import '../data/mascotas_repository.dart';
import '../domain/mascota.dart';
import 'formato_peso.dart';

/// Estado único de Agregar Mascota. Todo lo escrito se guarda como texto;
/// la edad y el peso se convierten a número solo para validar y guardar.
@immutable
class AgregarMascotaUiState {
  const AgregarMascotaUiState({
    this.nombre = '',
    this.especie = '',
    this.raza = '',
    this.edadAnos = '',
    this.pesoKg = '',
    this.fotoPath,
    this.guardando = false,
    this.error,
  });

  final String nombre;
  final String especie;
  final String raza;
  final String edadAnos;
  final String pesoKg;
  final String? fotoPath;
  final bool guardando;
  final String? error;

  /// null si está vacío, no es número o fuera de 0..20.
  int? get edadAnosInt {
    final n = int.tryParse(edadAnos.trim());
    return (n != null && n >= 0 && n <= 20) ? n : null;
  }

  /// null si no hay peso o no es positivo; admite coma decimal.
  double? get pesoKgDouble {
    var texto = pesoKg.trim().replaceAll(',', '.');
    if (texto.endsWith('.')) texto = texto.substring(0, texto.length - 1);
    final n = double.tryParse(texto);
    return (n != null && n > 0) ? n : null;
  }

  /// Habilita el botón "Listo ✓" (peso y foto son opcionales).
  bool get puedeGuardar =>
      nombre.trim().isNotEmpty &&
      especie.trim().isNotEmpty &&
      edadAnosInt != null &&
      !guardando;

  /// `fotoPath` y `error` van como función para poder poner null a propósito:
  /// `copyWith(error: () => null)` borra el error; omitirlo lo deja igual.
  AgregarMascotaUiState copyWith({
    String? nombre,
    String? especie,
    String? raza,
    String? edadAnos,
    String? pesoKg,
    String? Function()? fotoPath,
    bool? guardando,
    String? Function()? error,
  }) {
    return AgregarMascotaUiState(
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      edadAnos: edadAnos ?? this.edadAnos,
      pesoKg: pesoKg ?? this.pesoKg,
      fotoPath: fotoPath != null ? fotoPath() : this.fotoPath,
      guardando: guardando ?? this.guardando,
      error: error != null ? error() : this.error,
    );
  }
}

class AgregarMascotaViewModel extends ChangeNotifier {
  AgregarMascotaViewModel({required MascotasRepository repositorio})
      : _repositorio = repositorio;

  final MascotasRepository _repositorio;
  AgregarMascotaUiState _estado = const AgregarMascotaUiState();
  bool _liberado = false;

  AgregarMascotaUiState get estado => _estado;

  void _notificar() {
    if (!_liberado) notifyListeners();
  }

  /// Aplica el cambio y borra el error en cuanto el usuario toca un campo.
  void _cambiar(AgregarMascotaUiState Function(AgregarMascotaUiState) cambio) {
    _estado = cambio(_estado).copyWith(error: () => null);
    _notificar();
  }

  void onNombreChange(String valor) =>
      _cambiar((e) => e.copyWith(nombre: valor));

  void onEspecieChange(String valor) =>
      _cambiar((e) => e.copyWith(especie: valor));

  void onRazaChange(String valor) => _cambiar((e) => e.copyWith(raza: valor));

  void onEdadChange(String valor) => _cambiar(
        (e) => e.copyWith(edadAnos: valor.replaceAll(RegExp(r'[^0-9]'), '')),
      );

  void onPesoChange(String valor) =>
      _cambiar((e) => e.copyWith(pesoKg: formatearPeso(valor)));

  void onFotoChange(String? ruta) =>
      _cambiar((e) => e.copyWith(fotoPath: () => ruta));

  /// Devuelve true si la mascota quedó guardada (la página entonces vuelve atrás).
  Future<bool> onGuardar() async {
    final actual = _estado;
    if (!actual.puedeGuardar) return false;

    _estado = actual.copyWith(guardando: true, error: () => null);
    _notificar();
    try {
      await _repositorio.guardarMascota(
        Mascota(
          nombre: actual.nombre.trim(),
          especie: actual.especie.trim(),
          raza: actual.raza.trim(),
          fechaNacimiento: nacimientoPorEdad(actual.edadAnosInt!),
          fotoPath: actual.fotoPath,
          pesoKg: actual.pesoKgDouble,
        ),
      );
      _estado = _estado.copyWith(guardando: false);
      _notificar();
      return true;
    } catch (_) {
      _estado = _estado.copyWith(
        guardando: false,
        error: () => 'No se pudo guardar la mascota. Inténtalo de nuevo.',
      );
      _notificar();
      return false;
    }
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
