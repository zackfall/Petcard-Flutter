import 'package:flutter/foundation.dart';

import '../../../shared/evento_ui.dart';
import '../../../shared/fechas.dart';
import '../../mascotas/data/mascotas_repository.dart';

/// Una celda de la grilla mensual. `numero == null` = hueco vacío.
@immutable
class CeldaDia {
  const CeldaDia({
    this.numero,
    this.fecha,
    this.tieneEventos = false,
    this.esHoy = false,
    this.seleccionado = false,
  });

  final int? numero;
  final DateTime? fecha;
  final bool tieneEventos;
  final bool esHoy;
  final bool seleccionado;
}

/// Estado único de la pantalla Calendario.
@immutable
class CalendarioUiState {
  const CalendarioUiState({
    required this.anio,
    required this.mes,
    this.celdas = const [],
    required this.diaSeleccionado,
    this.eventos = const [],
    this.cargando = true,
  });

  final int anio;

  /// 1..12.
  final int mes;
  final List<CeldaDia> celdas;
  final DateTime diaSeleccionado;
  final List<EventoItem> eventos;
  final bool cargando;
}

/// Acción puntual tras alternar la campana (equivale a `CalendarioEvent`):
/// la página la traduce en programar/cancelar la notificación del sistema.
sealed class CalendarioAccion {
  const CalendarioAccion();
}

class ProgramarAviso extends CalendarioAccion {
  const ProgramarAviso({
    required this.eventoId,
    required this.titulo,
    required this.trigger,
  });

  final int eventoId;
  final String titulo;
  final DateTime trigger;
}

class CancelarAviso extends CalendarioAccion {
  const CancelarAviso(this.eventoId);

  final int eventoId;
}

class CalendarioViewModel extends ChangeNotifier {
  CalendarioViewModel({required this._repositorio}) {
    final hoy = hoyInicio();
    _anio = hoy.year;
    _mes = hoy.month;
    _dia = hoy;
    _estado = _leer();
    _repositorio.addListener(_alCambiarRepositorio);
  }

  final MascotasRepository _repositorio;
  late int _anio;
  late int _mes;
  late DateTime _dia;
  late CalendarioUiState _estado;

  CalendarioUiState get estado => _estado;

  CalendarioUiState _leer() {
    final eventos = _repositorio.eventos;
    final diasConEvento = eventos
        .where((e) => !e.hecho)
        .map((e) => e.fecha)
        .toSet();
    return CalendarioUiState(
      anio: _anio,
      mes: _mes,
      celdas: _construirCeldas(_anio, _mes, _dia, diasConEvento),
      diaSeleccionado: _dia,
      eventos: eventos
          .where((e) => e.fecha == _dia)
          .map((e) =>
              e.aItem(_repositorio.mascotaPorId(e.mascotaId)?.nombre ?? '?'))
          .toList(),
      cargando: false,
    );
  }

  void _alCambiarRepositorio() {
    _estado = _leer();
    notifyListeners();
  }

  void onMesAnterior() {
    if (_mes == 1) {
      _anio--;
      _mes = 12;
    } else {
      _mes--;
    }
    _estado = _leer();
    notifyListeners();
  }

  void onMesSiguiente() {
    if (_mes == 12) {
      _anio++;
      _mes = 1;
    } else {
      _mes++;
    }
    _estado = _leer();
    notifyListeners();
  }

  void onDiaElegido(DateTime fecha) {
    _dia = fecha;
    _estado = _leer();
    notifyListeners();
  }

  /// Campana del diseño: si el evento no tiene aviso, se lo pone para su
  /// propia fecha/hora; si ya lo tiene, lo quita (y cancela la alarma).
  Future<CalendarioAccion?> onAlternarRecordatorio(int eventoId) async {
    final evento = _repositorio.eventoPorId(eventoId);
    if (evento == null) return null;
    if (evento.proxima == null) {
      final proxima = evento.fecha;
      await _repositorio.actualizarEvento(evento.copyWith(proxima: () => proxima));
      final trigger = proxima.add(
        Duration(minutes: evento.horaMinutos ?? 9 * 60),
      );
      if (trigger.isAfter(DateTime.now())) {
        return ProgramarAviso(
          eventoId: eventoId,
          titulo: evento.titulo,
          trigger: trigger,
        );
      }
      return null;
    }
    await _repositorio.actualizarEvento(evento.copyWith(proxima: () => null));
    return CancelarAviso(eventoId);
  }

  List<CeldaDia> _construirCeldas(
    int anio,
    int mes,
    DateTime diaSeleccionado,
    Set<DateTime> diasConEvento,
  ) {
    final hoy = hoyInicio();
    // La grilla empieza en domingo (Do Lu Ma Mi Ju Vi Sá).
    final huecos = DateTime(anio, mes, 1).weekday % 7;
    final diasEnMes = DateTime(anio, mes + 1, 0).day;
    final celdas = <CeldaDia>[
      for (var i = 0; i < huecos; i++) const CeldaDia(),
    ];
    for (var dia = 1; dia <= diasEnMes; dia++) {
      final fecha = inicioDia(anio, mes, dia);
      celdas.add(CeldaDia(
        numero: dia,
        fecha: fecha,
        tieneEventos: diasConEvento.contains(fecha),
        esHoy: fecha == hoy,
        seleccionado: fecha == diaSeleccionado,
      ));
    }
    return celdas;
  }

  @override
  void dispose() {
    _repositorio.removeListener(_alCambiarRepositorio);
    super.dispose();
  }
}