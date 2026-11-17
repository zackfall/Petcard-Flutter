import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petcard/main.dart';
import 'package:petcard/shell/petcard_bottom_bar.dart';
import 'package:petcard/shell/petcard_shell.dart';
import 'package:petcard/shell/rutas.dart';

void main() {
  Finder enAppBar(String texto) => find.descendant(
        of: find.byType(AppBar),
        matching: find.text(texto),
      );

  Finder enBottomBar(String texto) => find.descendant(
        of: find.byType(PetCardBottomBar),
        matching: find.text(texto),
      );

  testWidgets('muestra AppBar con título PetCard y las 4 pestañas',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());

    expect(enAppBar('PetCard'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(PetCardBottomBar), findsOneWidget);
    for (final destino in destinosPrincipales) {
      expect(
        find.descendant(
          of: find.byType(PetCardBottomBar),
          matching: find.byIcon(destino.icono),
        ),
        findsOneWidget,
      );
      expect(enBottomBar(destino.etiqueta), findsOneWidget);
    }
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });

  testWidgets('cambia de pestaña y actualiza el título del AppBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());

    await tester.tap(find.text('Calendario'));
    await tester.pumpAndSettle();

    expect(enAppBar('Calendario'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('Configuración se apila con botón atrás y vuelve al inicio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PetCardApp());

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(enAppBar('Configuración'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(enAppBar('PetCard'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  test('títulos de rutas', () {
    expect(Rutas.titulo(Rutas.inicio), 'PetCard');
    expect(Rutas.titulo(Rutas.mascotas), 'Mascotas');
    expect(Rutas.titulo(Rutas.eventosPendientes), 'Evento de Salud');
    expect(Rutas.titulo(Rutas.calendario), 'Calendario');
    expect(Rutas.titulo(Rutas.configuracion), 'Configuración');
    expect(Rutas.titulo('desconocida'), 'PetCard');
  });
}
