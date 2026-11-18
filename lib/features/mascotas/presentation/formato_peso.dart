import 'package:flutter/services.dart';

/// Un solo separador decimal, máximo 2 decimales; acepta coma o punto.
String formatearPeso(String valor) {
  final normalizado = valor.replaceAll(',', '.');
  final primerPunto = normalizado.indexOf('.');
  final buffer = StringBuffer();
  for (var i = 0; i < normalizado.length; i++) {
    final c = normalizado[i];
    final esDigito = c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
    if (esDigito || (c == '.' && i == primerPunto)) buffer.write(c);
  }
  final sinRepetidos = buffer.toString();

  final partes = sinRepetidos.split('.');
  if (partes.length == 1) return partes[0];

  final decimales = partes.skip(1).join();
  final dosDecimales =
      decimales.length > 2 ? decimales.substring(0, 2) : decimales;
  // "4." se conserva para que el usuario pueda seguir escribiendo decimales.
  return dosDecimales.isEmpty ? '${partes[0]}.' : '${partes[0]}.$dosDecimales';
}

/// Aplica [formatearPeso] mientras se escribe en el campo.
class PesoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final texto = formatearPeso(nuevo.text);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
