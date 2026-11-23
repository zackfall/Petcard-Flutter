import 'package:flutter_test/flutter_test.dart';
import 'package:petcard/features/calendario/presentation/calendario_view_model.dart';
import 'package:petcard/features/eventos/presentation/eventos_pendientes_view_model.dart';
import 'package:petcard/features/eventos/presentation/nuevo_evento_view_model.dart';
import 'package:petcard/features/mascotas/data/mascotas_repository_impl.dart';
import 'package:petcard/features/mascotas/domain/evento.dart';
import 'package:petcard/features/mascotas/domain/mascota.dart';
import 'package:petcard/shared/fechas.dart';

void main() {
  Mascota mascota(String nombre) => Mascota(
        nombre: nombre,
        especie: 'Perro',
        raza: 'Criollo',
        fechaNacimiento: DateTime(2023, 1, 1),
      );

  group('MascotasRepository (eventos)', () {
    test('pendientes excluye hechos y ordena por fecha/hora ascendente', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.vacuna,
        titulo: 'Tarde',
        fecha: DateTime(2026, 10, 24),
        horaMinutos: 900,
      ));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.vacuna,
        titulo: 'Mañana',
        fecha: DateTime(2026, 10, 24),
        horaMinutos: 600,
      ));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.controlVeterinario,
        titulo: 'Otro día',
        fecha: DateTime(2026, 10, 28),
      ));
      final hecho = await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.bano,
        titulo: 'Ya realizado',
        fecha: DateTime(2026, 10, 1),
        hecho: true,
      ));

      expect(repo.pendientes.map((e) => e.titulo), [
        'Mañana',
        'Tarde',
        'Otro día',
      ]);

      await repo.marcarEventoHecho(hecho);
      expect(repo.eventoPorId(hecho)!.hecho, isTrue);

      await repo.eliminarEvento(hecho);
      expect(repo.eventoPorId(hecho), isNull);
      expect(repo.eventos.length, 3);
    });

    test('actualizarEvento reemplaza por id (alternar recordatorio)', () async {
      final repo = MascotasRepositoryImpl();
      final idMascota = await repo.guardarMascota(mascota('Max'));
      final id = await repo.guardarEvento(Evento(
        mascotaId: idMascota,
        tipo: TipoEvento.vacuna,
        titulo: 'Vacuna',
        fecha: DateTime(2026, 10, 24),
      ));
      final evento = repo.eventoPorId(id)!;
      await repo.actualizarEvento(evento.copyWith(proxima: () => evento.fecha));
      expect(repo.eventoPorId(id)!.proxima, DateTime(2026, 10, 24));
      await repo.actualizarEvento(repo.eventoPorId(id)!.copyWith(proxima: () => null));
      expect(repo.eventoPorId(id)!.proxima, isNull);
    });

    test('eliminarMascota borra también sus eventos (CASCADE)', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.vacuna,
        titulo: 'Vacuna',
        fecha: DateTime(2026, 10, 24),
      ));
      await repo.eliminarMascota(id);
      expect(repo.eventos, isEmpty);
    });
  });

  group('EventosPendientesViewModel', () {
    test('arma items con el nombre de la mascota y reacciona al repositorio',
        () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.vacuna,
        titulo: 'Vacuna de la Rabia',
        fecha: DateTime(2026, 10, 24),
        horaMinutos: 600,
        lugar: 'Clínica Principal',
      ));
      final vm = EventosPendientesViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      expect(vm.estado.cargando, isFalse);
      expect(vm.estado.eventos.single.titulo, 'Vacuna de la Rabia');
      expect(vm.estado.eventos.single.subtitulo,
          'Max • Vacuna 24 oct 2026');
      expect(vm.estado.eventos.single.detalle, '10:00 • Clínica Principal');

      // "Hecho": sale de la lista solo, vía el repositorio reactivo.
      await vm.onHecho(vm.estado.eventos.single.id);
      expect(vm.estado.eventos, isEmpty);
    });

    test('onEliminar borra definitivamente', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Luna'));
      final idEvento = await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.controlVeterinario,
        titulo: 'Chequeo de Peso',
        fecha: DateTime(2026, 10, 28),
      ));
      final vm = EventosPendientesViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      await vm.onEliminar(idEvento);
      expect(vm.estado.eventos, isEmpty);
      expect(repo.eventos, isEmpty);
    });
  });

  group('NuevoEventoViewModel', () {
    test('puedeGuardar exige mascota, título y tipo', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      final vm = NuevoEventoViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      expect(vm.estado.puedeGuardar, isFalse);
      vm.onMascotaChange(id);
      vm.onTituloChange('Vacuna de la Rabia');
      expect(vm.estado.puedeGuardar, isFalse); // falta el tipo
      vm.onTipoChange(TipoEvento.vacuna);
      expect(vm.estado.puedeGuardar, isTrue);
    });

    test('guarda recortando textos y calcula el trigger del aviso', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      final vm = NuevoEventoViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      vm.onMascotaChange(id);
      vm.onTituloChange('  Vacuna de la Rabia  ');
      vm.onTipoChange(TipoEvento.vacuna);
      vm.onFechaChange(DateTime(2026, 10, 24));
      vm.onHoraChange(600);
      vm.onLugarChange('  Clínica Principal  ');
      vm.onNotasChange('   ');
      vm.onRecordatorioChange(DateTime(2026, 11, 24));

      final guardado = await vm.onGuardar();
      expect(guardado, isNotNull);
      expect(guardado!.mascotaNombre, 'Max');
      // El aviso suena a la hora del evento del día del recordatorio.
      expect(guardado.trigger, DateTime(2026, 11, 24, 10, 0));

      final evento = repo.eventoPorId(guardado.eventoId)!;
      expect(evento.titulo, 'Vacuna de la Rabia');
      expect(evento.lugar, 'Clínica Principal');
      expect(evento.notas, isNull);
      expect(evento.proxima, DateTime(2026, 11, 24));
    });

    test('sin hora el aviso usa las 09:00; sin recordatorio no hay trigger',
        () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      final vm = NuevoEventoViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      vm.onMascotaChange(id);
      vm.onTituloChange('Control');
      vm.onTipoChange(TipoEvento.controlVeterinario);
      vm.onRecordatorioChange(DateTime(2026, 11, 24));
      var guardado = await vm.onGuardar();
      expect(guardado!.trigger, DateTime(2026, 11, 24, 9, 0));

      vm.onRecordatorioChange(null);
      vm.onTituloChange('Control 2');
      guardado = await vm.onGuardar();
      expect(guardado!.trigger, isNull);
    });

    test('limpia la selección si la mascota desaparece', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      final vm = NuevoEventoViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      vm.onMascotaChange(id);
      expect(vm.estado.mascotaId, id);
      await repo.eliminarMascota(id);
      expect(vm.estado.mascotaId, isNull);
      expect(vm.estado.mascotas, isEmpty);
    });
  });

  group('CalendarioViewModel', () {
    /// Navega desde el mes actual hasta octubre 2026 (mes de prueba fijo).
    CalendarioViewModel irAOctubre2026(MascotasRepositoryImpl repo) {
      final vm = CalendarioViewModel(repositorio: repo);
      final hoy = DateTime.now();
      var pasos = (2026 - hoy.year) * 12 + (10 - hoy.month);
      while (pasos > 0) {
        vm.onMesSiguiente();
        pasos--;
      }
      while (pasos < 0) {
        vm.onMesAnterior();
        pasos++;
      }
      return vm;
    }

    test('grilla de octubre 2026: empieza en jueves, 35 celdas', () {
      final repo = MascotasRepositoryImpl();
      final vm = irAOctubre2026(repo);
      addTearDown(vm.dispose);

      expect(vm.estado.anio, 2026);
      expect(vm.estado.mes, 10);
      // 1 oct 2026 = jueves → 4 huecos (Do Lu Ma Mi) + 31 días.
      expect(vm.estado.celdas.length, 35);
      expect(vm.estado.celdas.take(4).every((c) => c.numero == null), isTrue);
      expect(vm.estado.celdas[4].numero, 1);
      expect(vm.estado.celdas.last.numero, 31);
    });

    test('navegación de meses cruza el año', () {
      final repo = MascotasRepositoryImpl();
      final vm = irAOctubre2026(repo);
      addTearDown(vm.dispose);

      vm.onMesAnterior();
      expect(vm.estado.mes, 9);
      vm.onMesSiguiente();
      vm.onMesSiguiente();
      vm.onMesSiguiente();
      expect(vm.estado.mes, 12);
      vm.onMesSiguiente();
      expect(vm.estado.anio, 2027);
      expect(vm.estado.mes, 1);
      vm.onMesAnterior();
      expect(vm.estado.anio, 2026);
      expect(vm.estado.mes, 12);
    });

    test('punto en días con evento y lista del día elegido', () async {
      final repo = MascotasRepositoryImpl();
      final id = await repo.guardarMascota(mascota('Max'));
      await repo.guardarEvento(Evento(
        mascotaId: id,
        tipo: TipoEvento.vacuna,
        titulo: 'Vacuna de Rabia',
        fecha: DateTime(2026, 10, 24),
        horaMinutos: 600,
        lugar: 'Clínica Principal',
      ));
      final vm = irAOctubre2026(repo);
      addTearDown(vm.dispose);

      final celda24 = vm.estado.celdas.firstWhere((c) => c.numero == 24);
      expect(celda24.tieneEventos, isTrue);
      expect(vm.estado.eventos, isEmpty); // hoy no es 24 oct 2026

      vm.onDiaElegido(DateTime(2026, 10, 24));
      expect(vm.estado.eventos.single.titulo, 'Vacuna de Rabia');
      expect(vm.estado.eventos.single.subtitulo, 'Max • Vacuna 24 oct 2026');
      expect(vm.estado.eventos.single.detalle, '10:00 • Clínica Principal');
      expect(
        vm.estado.celdas.firstWhere((c) => c.numero == 24).seleccionado,
        isTrue,
      );
    });

    test('campana: pone y quita el recordatorio del evento', () async {
      final repo = MascotasRepositoryImpl();
      final idMascota = await repo.guardarMascota(mascota('Max'));
      final fecha = hoyInicio().add(const Duration(days: 2));
      final id = await repo.guardarEvento(Evento(
        mascotaId: idMascota,
        tipo: TipoEvento.vacuna,
        titulo: 'Vacuna',
        fecha: fecha,
      ));
      final vm = CalendarioViewModel(repositorio: repo);
      addTearDown(vm.dispose);

      // Sin aviso → lo pone para su propia fecha (09:00 sin hora) y programa.
      final accion = await vm.onAlternarRecordatorio(id);
      expect(accion, isA<ProgramarAviso>());
      expect((accion as ProgramarAviso).trigger, fecha.add(const Duration(hours: 9)));
      expect(repo.eventoPorId(id)!.proxima, fecha);

      // Ya tiene aviso → lo quita y cancela.
      final accion2 = await vm.onAlternarRecordatorio(id);
      expect(accion2, isA<CancelarAviso>());
      expect(repo.eventoPorId(id)!.proxima, isNull);
    });
  });

  group('fechas compartidas', () {
    test('formatearHora y formatearFechaCorta', () {
      expect(formatearHora(600), '10:00');
      expect(formatearHora(0), '00:00');
      expect(formatearHora(23 * 60 + 59), '23:59');
      expect(formatearFechaCorta(DateTime(2026, 10, 24)), '24 oct');
      expect(nombreMes(2026, 10), 'Octubre');
    });
  });
}