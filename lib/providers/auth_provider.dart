import 'package:flutter/material.dart';

/// Provider pengelola status autentikasi pengguna (Login, Register, Logout).
///
/// Catatan PRD:
/// PRD menyebutkan tahapan "User login" pada alur pengguna (User Flow 2.4)
/// namun tidak mendefinisikan FR spesifik autentikasi. Sesuai instruksi,
/// provider ini mengelola state login/register secara reaktif tanpa dependensi
/// Firebase, dan siap disambungkan ke REST API backend MySQL.
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  /// Melakukan login pengguna.
  ///
  /// TODO: Ganti implementasi ini dengan pemanggilan REST API:
  /// POST /api/auth/login dengan body { "email": email, "password": password }
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulasi delay pemanggilan network
      await Future.delayed(const Duration(milliseconds: 600));

      // Simulasi sukses login
      _isAuthenticated = true;
      _userEmail = email;
      // Gunakan username dari email atau default petani
      _userName = email.split('@').first;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal masuk: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Melakukan registrasi pengguna baru.
  ///
  /// Catatan: Field noTelepon berasal dari desain Figma (meski tidak tercantum di PRD).
  /// TODO: Ganti implementasi ini dengan pemanggilan REST API:
  /// POST /api/auth/register dengan body { "nama": nama, "email": email, "no_telepon": noTelepon, "password": password }
  Future<bool> register({
    required String nama,
    required String email,
    required String noTelepon,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulasi delay pendaftaran
      await Future.delayed(const Duration(milliseconds: 600));

      _isAuthenticated = true;
      _userName = nama;
      _userEmail = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal mendaftar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Keluar dari sesi aplikasi
  void logout() {
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }
}
