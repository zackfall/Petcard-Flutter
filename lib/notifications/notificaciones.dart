import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Recordatorios locales (requisito 11, puerto de `Notificaciones.kt`):
/// una notificación programada por evento con recordatorio. Todo funciona
/// sin internet. El id de la notificación es el id del evento, para poder
/// cancelarla (igual que `requestCode = eventoId` en Android).
///
/// En plataformas sin soporte (o en pruebas) las llamadas se ignoran en
/// silencio: la app nunca debe caerse por un aviso.
class Notificaciones {
  Notificaciones._();

  static const canalId = 'recordatorios';
  static const _canalNombre = 'Recordatorios de salud';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _listo = false;

  /// Crea el canal y deja lista la zona horaria local. Se llama una vez en
  /// `main()` antes de `runApp` (equivale a `crearCanal`).
  static Future<void> inicializar() async {
    if (_listo) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final zona = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zona.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
          macOS: DarwinInitializationSettings(),
          linux: LinuxInitializationSettings(defaultActionName: 'Abrir PetCard'),
          windows: WindowsInitializationSettings(
            appName: 'PetCard',
            appUserModelId: 'com.petcard.petcard',
            guid: '7c4f2a90-5b3e-4d1f-9a6c-e00000000001',
          ),
        ),
      );
      // Android 13+: el permiso de notificaciones se pide en runtime.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _listo = true;
    } catch (_) {
      // Sin soporte de notificaciones en esta plataforma: seguir sin avisos.
    }
  }

  /// Programa el aviso de un evento. `inexactAllowWhileIdle` equivale al
  /// `AlarmManager.set(RTC_WAKEUP, …)` del proyecto Kotlin (alarma inexacta,
  /// sin necesidad del permiso SCHEDULE_EXACT_ALARM).
  static Future<void> programar({
    required int eventoId,
    required String titulo,
    required String detalle,
    required DateTime trigger,
  }) async {
    if (!_listo) return;
    try {
      await _plugin.zonedSchedule(
        id: eventoId,
        title: titulo,
        body: detalle.isEmpty ? 'Tienes un evento de salud pendiente.' : detalle,
        scheduledDate: tz.TZDateTime.from(trigger, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            canalId,
            _canalNombre,
            channelDescription: 'Avisos de vacunas, controles y medicación',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Un aviso fallido no debe romper el guardado del evento.
    }
  }

  /// Cancela el aviso programado de un evento (campana del Calendario).
  static Future<void> cancelar(int eventoId) async {
    if (!_listo) return;
    try {
      await _plugin.cancel(id: eventoId);
    } catch (_) {
      // Ignorado: la preferencia del usuario ya quedó guardada.
    }
  }
}