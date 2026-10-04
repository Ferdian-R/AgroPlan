/// Kumpulan fungsi validasi yang bisa dipakai ulang (reusable).
/// Aturan validator di Flutter:
/// - return null -> input VALID
/// - return 'pesan' -> input TIDAK VALID, pesan tampil di bawah field
class Validators {
  Validators._();

  /// Validasi field wajib diisi
  static String? requiredField(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  /// Validasi panjang minimum
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;

    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Validasi dropdown wajib dipilih (value tidak boleh null)
  static String? requiredDropdown<T>(T? value, {String fieldName = 'Pilihan ini'}) {
    if (value == null) {
      return '$fieldName wajib dipilih';
    }
    return null;
  }

  /// Validasi tanggal wajib diisi dan tidak boleh di masa lalu
  static String? futureDate(DateTime? value, {String fieldName = 'Tanggal'}) {
    if (value == null) {
      return '$fieldName wajib diisi';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(value.year, value.month, value.day);

    if (selected.isBefore(today)) {
      return '$fieldName tidak boleh di masa lalu';
    }
    return null;
  }
}
