import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Layanan Notifikasi Lokal (Modul 3: FR-19 & Modul 1: FR-06).
/// Mengirim notifikasi pengingat ke status bar / control panel perangkat pengguna.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Inisialisasi plugin notifikasi lokal
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked with payload: ${details.payload}');
        },
      );

      // Meminta izin notifikasi pada Android 13+ (API 33+)
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Menampilkan notifikasi instan pada status bar / notification drawer pengguna
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      const androidDetails = AndroidNotificationDetails(
        'agroplan_reminders_channel',
        'Pengingat AgroPlan',
        channelDescription: 'Saluran pengingat jadwal perawatan dan rencana tanam AgroPlan',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// FR-19: Kirim notifikasi pengingat jadwal perawatan jatuh tempo
  static Future<void> kirimNotifikasiJadwalJatuhTempo({
    required int idJadwal,
    required String namaKegiatan,
    required String namaLahan,
  }) async {
    await showNotification(
      id: idJadwal + 1000,
      title: '🌾 Pengingat Perawatan: $namaKegiatan',
      body: 'Jadwal $namaKegiatan di $namaLahan telah jatuh tempo hari ini. Segera laksanakan!',
      payload: '/jadwal-perawatan',
    );
  }

  /// FR-06: Kirim notifikasi pengingat rencana tanam
  static Future<void> kirimNotifikasiRencanaTanam({
    required int idSiklus,
    required String komoditas,
    required String namaLahan,
  }) async {
    await showNotification(
      id: idSiklus + 2000,
      title: '🌱 Pengingat Tanam: $komoditas',
      body: 'Rencana penanaman $komoditas pada $namaLahan dijadwalkan hari ini!',
      payload: '/daftar-lahan',
    );
  }
}
