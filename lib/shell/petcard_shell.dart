import 'package:flutter/material.dart';

import '../features/configuracion/presentation/acerca_page.dart';
import '../features/configuracion/presentation/configuracion_page.dart';
import '../features/configuracion/presentation/privacidad_page.dart';
import '../features/mascotas/presentation/agregar_mascota_page.dart';
import '../features/mascotas/presentation/perfil_mascota_page.dart';
import '../pages/calendario_page.dart';
import '../pages/inicio_page.dart';
import '../pages/mascotas_page.dart';
import '../pages/salud_page.dart';
import 'petcard_bottom_bar.dart';
import 'rutas.dart';

const destinosPrincipales = [
  DestinoBottomBar(ruta: Rutas.inicio, etiqueta: 'Inicio', icono: Icons.home),
  DestinoBottomBar(
    ruta: Rutas.mascotas,
    etiqueta: 'Mascotas',
    icono: Icons.pets,
  ),
  DestinoBottomBar(
    ruta: Rutas.eventosPendientes,
    etiqueta: 'Salud',
    icono: Icons.monitor_heart,
  ),
  DestinoBottomBar(
    ruta: Rutas.calendario,
    etiqueta: 'Calendario',
    icono: Icons.calendar_month,
  ),
];

class PetCardShell extends StatefulWidget {
  const PetCardShell({super.key});

  @override
  State<PetCardShell> createState() => _PetCardShellState();
}

class _PetCardShellState extends State<PetCardShell> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _rutaActual = Rutas.inicio;

  void _alCambiarRuta(String? ruta) {
    if (ruta == null || ruta == _rutaActual) return;
    setState(() => _rutaActual = ruta);
  }

  void _alNavegar(String ruta) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    if (ruta == _rutaActual) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    navigator.pushNamedAndRemoveUntil(ruta, (route) => false);
  }

  void _irAtras() {
    _navigatorKey.currentState?.pop();
  }

  void _abrirConfiguracion() {
    _navigatorKey.currentState?.pushNamed(Rutas.configuracion);
  }

  List<Widget> _acciones(String ruta) {
    if (ruta == Rutas.inicio) {
      return [
        IconButton(
          tooltip: 'Recordatorios',
          onPressed: () => _alNavegar(Rutas.eventosPendientes),
          icon: const Icon(Icons.notifications),
        ),
        IconButton(
          tooltip: 'Configuración',
          onPressed: _abrirConfiguracion,
          icon: const Icon(Icons.settings),
        ),
      ];
    }
    if (ruta == Rutas.eventosPendientes) {
      return [
        IconButton(
          tooltip: 'Nuevo evento',
          onPressed: () {},
          icon: const Icon(Icons.add),
        ),
      ];
    }
    return const [];
  }

  Route<dynamic> _generarRuta(RouteSettings settings) {
    final pagina = switch (settings.name) {
      Rutas.mascotas => const MascotasPage(),
      Rutas.agregarMascota => const AgregarMascotaPage(),
      Rutas.perfilMascota => PerfilMascotaPage(
          mascotaId: settings.arguments as int,
        ),
      Rutas.eventosPendientes => const SaludPage(),
      Rutas.calendario => const CalendarioPage(),
      Rutas.configuracion => const ConfiguracionPage(),
      Rutas.privacidad => const PrivacidadPage(),
      Rutas.acerca => const AcercaPage(),
      _ => const InicioPage(),
    };
    return MaterialPageRoute(settings: settings, builder: (_) => pagina);
  }

  @override
  Widget build(BuildContext context) {
    final esRutaRaiz = Rutas.rutasRaiz.contains(_rutaActual);
    return Scaffold(
      appBar: AppBar(
        title: Text(Rutas.titulo(_rutaActual)),
        leading: esRutaRaiz
            ? null
            : IconButton(
                tooltip: 'Atrás',
                onPressed: _irAtras,
                icon: const Icon(Icons.arrow_back),
              ),
        actions: _acciones(_rutaActual),
      ),
      bottomNavigationBar: PetCardBottomBar(
        destinos: destinosPrincipales,
        rutaActual: _rutaActual,
        alNavegar: _alNavegar,
      ),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: Rutas.inicio,
        onGenerateRoute: _generarRuta,
        observers: [_ObservadorDeRuta(_alCambiarRuta)],
      ),
    );
  }
}

class _ObservadorDeRuta extends NavigatorObserver {
  _ObservadorDeRuta(this.alCambiarRuta);

  final void Function(String? ruta) alCambiarRuta;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    alCambiarRuta(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    alCambiarRuta(previousRoute?.settings.name);
  }
}