const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

const _mesesLargos = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

/// Inicio del día de hoy (00:00 locales). Las fechas del proyecto se guardan
/// siempre así, igual que `Dates.hoyInicioMillis()` en Android.
DateTime hoyInicio() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Inicio del día pedido (00:00 locales).
DateTime inicioDia(int anio, int mes1a12, int dia) =>
    DateTime(anio, mes1a12, dia);

/// "Octubre" (mes en español con mayúscula inicial).
String nombreMes(int anio, int mes1a12) => _mesesLargos[mes1a12 - 1];

/// Regla civil: múltiplo de 4, salvo los siglos que no son múltiplo de 400.
bool esBisiesto(int anio) =>
    (anio % 4 == 0 && anio % 100 != 0) || anio % 400 == 0;

/// "24 oct 2026"
String formatearFecha(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')} ${_meses[fecha.month - 1]} ${fecha.year}';

/// "24 oct" (botones de fecha del formulario Nuevo Evento).
String formatearFechaCorta(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')} ${_meses[fecha.month - 1]}';

/// Minutos desde medianoche → "10:00" (600 = 10:00).
String formatearHora(int horaMinutos) {
  final h = horaMinutos ~/ 60, m = horaMinutos % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// Edad completa en años al día de hoy (nunca negativa).
int edadEnAnos(DateTime nacimiento, {DateTime? hoy}) {
  final ahora = hoy ?? DateTime.now();
  var edad = ahora.year - nacimiento.year;
  final aunNoCumple = ahora.month < nacimiento.month ||
      (ahora.month == nacimiento.month && ahora.day < nacimiento.day);
  if (aunNoCumple) edad--;
  return edad < 0 ? 0 : edad;
}

/// Convierte la edad del formulario en fecha de nacimiento. Si hoy es 29/2 y
/// el año calculado no es bisiesto se usa el 28, porque `DateTime(…, 2, 29)`
/// rodaría al 1 de marzo y la edad mostrada quedaría un año menor.
DateTime nacimientoPorEdad(int edadAnos, {DateTime? hoy}) {
  final ahora = hoy ?? DateTime.now();
  final anio = ahora.year - edadAnos;
  final diaSeguro =
      (ahora.month == 2 && ahora.day == 29 && !esBisiesto(anio)) ? 28 : ahora.day;
  return DateTime(anio, ahora.month, diaSeguro);
}
