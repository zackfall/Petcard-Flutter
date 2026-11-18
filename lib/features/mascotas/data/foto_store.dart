import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Copia la foto elegida a la carpeta interna de la app (la ruta que entrega
/// el selector es temporal) y borra la anterior si el usuario cambia de foto.
abstract final class FotoStore {
  static Future<String> copiarFoto(String origen) async {
    final base = await getApplicationDocumentsDirectory();
    final carpeta =
        Directory('${base.path}${Platform.pathSeparator}fotos_mascotas');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final punto = origen.lastIndexOf('.');
    final extension = punto >= 0 ? origen.substring(punto) : '.jpg';
    final destino = '${carpeta.path}${Platform.pathSeparator}'
        'mascota_${DateTime.now().millisecondsSinceEpoch}$extension';
    final copia = await File(origen).copy(destino);
    return copia.path;
  }

  static Future<void> borrarFoto(String? ruta) async {
    if (ruta == null) return;
    try {
      final archivo = File(ruta);
      if (await archivo.exists()) await archivo.delete();
    } catch (_) {
      // Si no se pudo borrar, no es motivo para romper el flujo.
    }
  }
}
