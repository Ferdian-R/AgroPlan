import 'dart:io';
import 'package:flutter/foundation.dart';

/// Konfigurasi URL dan Endpoint REST API AgroPlan Backend.
class ApiConfig {
  ApiConfig._();

  /// IP komputer lokal saat terhubung ke Wi-Fi yang sama dengan HP fisik
  static const String _defaultWifiIp = '10.44.54.125';
  static const int _port = 3000;

  static String? _overrideBaseUrl;

  /// Mengatur custom base URL jika IP komputer berubah
  static void setBaseUrl(String url) {
    _overrideBaseUrl = url;
  }

  /// Base URL otomatis berdasarkan lingkungan eksekusi
  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }

    if (Platform.isAndroid) {
      // 10.0.2.2 adalah localhost host machine untuk Android Emulator
      // Jika menggunakan HP fisik asli, gunakan IP Wi-Fi komputer
      return 'http://$_defaultWifiIp:$_port/api';
    }

    return 'http://localhost:$_port/api';
  }

  /// URL static untuk gambar/foto yang diunggah
  static String get uploadsUrl {
    final base = baseUrl.replaceAll('/api', '');
    return '$base/uploads';
  }

  // Endpoints
  static String get authLogin => '$baseUrl/auth/login';
  static String get authRegister => '$baseUrl/auth/register';
  static String get authMe => '$baseUrl/auth/me';

  static String get lahan => '$baseUrl/lahan';
  static String get siklus => '$baseUrl/siklus';
  static String get laporan => '$baseUrl/laporan';
  static String get jadwal => '$baseUrl/jadwal';
  static String get estimasi => '$baseUrl/jadwal/estimasi';
  static String get panen => '$baseUrl/panen';
}
