import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Dialog modal sukses persis sesuai desain pada Gambar Kedua:
/// - Ilustrasi kalender centang hijau
/// - Judul tebal ("Jadwal perawatan berhasil ditambahkan!")
/// - Deskripsi ("Jadwal perawatan tanaman telah disimpan...")
/// - Tombol pill OK berwarna teal-green
class JadwalSuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onConfirm;

  const JadwalSuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText = 'OK',
    this.onConfirm,
  });

  /// Helper statis untuk menampilkan dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String buttonText = 'OK',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => JadwalSuccessDialog(
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ilustrasi Kalender Centang Hijau
            Image.asset(
              'assets/images/success_calendar.png',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // Judul
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.greeting.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),

            // Deskripsi Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // Tombol OK Hijau Teal (Pill Shape)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
