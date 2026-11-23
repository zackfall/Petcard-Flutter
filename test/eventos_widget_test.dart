import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcard/features/mascotas/domain/evento.dart';
import 'package:petcard/main.dart';
import 'package:petcard/shared/fechas.dart';

void main() {
  Finder enAppBar(String texto) => find.descendant(
        of: find.byType(AppBar),
        matching: find.text(texto),
      );

  /// El botón "Listo ✓" puede quedar fuera de pantalla en formularios
  /// largos: hay que hacer scroll antes de tocarlo.
  Future<void> tapListo(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Listo ✓'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo ✓'));
    await tester.pumpAndSettle();
  }

  /// Crea una mascota "Max" desde el formulario de Agregar Mascota.
  Future<void> crearMascota(WidgetTester tester) async {
    await tester.tap(find.text('Mascotas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar Mascota'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Max');
    await tester.enterText(find.byType(TextFormField).at(1), 'Perro');
    await tester.enterText(find.byType(TextFormField).at(3), '3');
    await tapListo(tester);
  }

  testWidgets('sin mascotas, el FAB y el "+" piden crear una mascota primero',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());

    await tester.tap(find.text('Salud'));
    await tester.pumpAndSettle();

    expect(enAppBar('Evento de Salud'), findsOneWidget);
    expect(find.text('Eventos Pendientes'), findsOneWidget);
    expect(find.text('Sin pendientes. ¡Buen trabajo!'), findsOneWidget);

    // El FAB muestra el popup en vez del formulario vacío.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes mascotas'), findsOneWidget);
    expect(
      find.text('Para crear un evento de salud primero necesitas registrar una mascota.'),
      findsOneWidget,
    );

    // Cancelar deja todo como estaba.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes mascotas'), findsNothing);
    expect(enAppBar('Evento de Salud'), findsOneWidget);

    // El "+" del AppBar muestra el mismo popup.
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes mascotas'), findsOneWidget);

    // "Agregar Mascota" lleva al formulario de mascota.
    await tester.tap(find.text('Agregar Mascota'));
    await tester.pumpAndSettle();
    expect(enAppBar('Agregar Mascota'), findsOneWidget);
  });

  testWidgets('flujo completo: mascota → evento → hecho → historial en Inicio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());
    await crearMascota(tester);

    // Nuevo evento desde el tab Salud.
    await tester.tap(find.text('Salud'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Elegir mascota en el dropdown.
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Max (Perro)').last);
    await tester.pumpAndSettle();

    // Título y tipo.
    await tester.enterText(find.byType(TextFormField).first, 'Vacuna de la Rabia');
    await tester.tap(find.byType(DropdownButton<TipoEvento>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vacuna').last);
    await tester.pumpAndSettle();

    await tapListo(tester);

    // Volvió a pendientes y el evento aparece con el formato del diseño.
    expect(enAppBar('Evento de Salud'), findsOneWidget);
    expect(find.text('Vacuna de la Rabia'), findsOneWidget);
    expect(find.text('Max • Vacuna ${formatearFecha(hoyInicio())}'), findsOneWidget);
    expect(find.text('Hecho (eliminar)'), findsOneWidget);

    // Marcar como hecho: la lista queda vacía.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Sin pendientes. ¡Buen trabajo!'), findsOneWidget);

    // En Inicio aparece en el historial reciente.
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Historial Reciente'), findsOneWidget);
    expect(find.text('Vacuna de la Rabia'), findsOneWidget);
  });

  testWidgets('Calendario muestra el mes actual y los eventos del día',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());
    await crearMascota(tester);

    // Crear un evento para hoy (fecha por defecto del formulario).
    await tester.tap(find.text('Salud'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Max (Perro)').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Chequeo de Peso');
    await tester.tap(find.byType(DropdownButton<TipoEvento>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Control veterinario').last);
    await tester.pumpAndSettle();
    await tapListo(tester);

    // Ir al calendario: hoy queda seleccionado y lista el evento.
    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();

    final hoy = hoyInicio();
    expect(enAppBar('Calendario'), findsOneWidget);
    expect(find.text('${nombreMes(hoy.year, hoy.month)} ${hoy.year}'), findsOneWidget);
    for (final d in ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá']) {
      expect(find.text(d), findsOneWidget);
    }
    expect(
      find.text('Eventos para hoy (${hoy.day} de ${nombreMes(hoy.year, hoy.month)})'),
      findsOneWidget,
    );
    expect(find.text('Chequeo de Peso'), findsOneWidget);

    // La campana alterna el recordatorio sin romper la pantalla.
    await tester.tap(find.byIcon(Icons.notifications).last);
    await tester.pumpAndSettle();
    expect(find.text('Chequeo de Peso'), findsOneWidget);

    // Navegar al mes siguiente: el día elegido se conserva (igual que en
    // Kotlin); al tocar un día sin eventos la lista queda vacía.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    final otroMes = DateTime(hoy.year, hoy.month + 1, 1);
    expect(
      find.text('${nombreMes(otroMes.year, otroMes.month)} ${otroMes.year}'),
      findsOneWidget,
    );
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(find.text('Sin eventos este día.'), findsOneWidget);

    // Volver al mes actual y reelegir el día de hoy.
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${hoy.day}'));
    await tester.pumpAndSettle();
    expect(find.text('Chequeo de Peso'), findsOneWidget);
  });

  testWidgets('perfil y mascotas abren Nuevo Evento', (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());
    await crearMascota(tester);

    // Desde el "+" de la lista de mascotas.
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(enAppBar('Nuevo Evento'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Desde "+ Nuevo Evento" del perfil.
    await tester.tap(find.text('Max'));
    await tester.pumpAndSettle();
    expect(enAppBar('Perfil de Mascota'), findsOneWidget);
    await tester.tap(find.text('+ Nuevo Evento'));
    await tester.pumpAndSettle();
    expect(enAppBar('Nuevo Evento'), findsOneWidget);
  });
}