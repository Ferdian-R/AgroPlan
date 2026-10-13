# 📋 PANDUAN UJIAN PRAKTIKAL - MODUL 2 (ADINDA)
## Branch: `adin_practical`
## Workflow: Modul 2 — Pelaporan Kondisi Lahan & Deteksi Risiko Tinggi (FR-07, FR-08, FR-09, FR-12)

---

## 📌 1. Mengapa Branch Ini Dibuat Khusus?
Branch `adin_practical` ini **hanya berisi file dan kode yang relevan dengan Modul 2 (Monitoring Kondisi & Peringatan Dini)**, tanpa tercampur dengan modul login atau jadwal perawatan.

Ketika aplikasi dijalankan (`flutter run`), aplikasi **langsung membuka layar Laporan Kondisi Lahan** dengan ringkasan statistik pemantauan (Total Laporan, Risiko Tinggi), filter chip, dan tombol FAB **Lapor Kondisi**.

---

## 📂 2. Struktur File & Pembagian Peran

```text
lib/
├── main.dart                          → Titik awal aplikasi Flutter
├── app.dart                           → MultiProvider & Root langsung ke RiwayatLaporanScreen
│
├── models/
│   ├── laporan_kondisi.dart           → Model laporan, logika deteksi risiko (tentukanStatusRisiko), helper warna & format
│   └── lahan.dart                     → Model data lahan untuk dropdown referensi lahan yang diamati
│
├── providers/
│   ├── laporan_provider.dart          → State Management Laporan (tambah, edit, hapus, filter, hitung risiko tinggi)
│   └── lahan_provider.dart            → Menyediakan daftar lahan untuk dropdown form laporan
│
├── screens/laporan/
│   ├── riwayat_laporan_screen.dart    → Layar daftar laporan, header statistik risiko, filter chip, detail modal & hapus
│   └── tambah_laporan_screen.dart      → Form pelaporan: foto bukti, pilihan lahan, jenis kondisi, tingkat keparahan, catatan
│
├── widgets/
│   └── laporan_card.dart              → Kartu laporan dengan thumbnail foto, tanggal, badge keparahan & status risiko
│
├── utils/
│   └── validators.dart                → Validasi (minLength catatan, requiredDropdown)
│
├── theme/                             → Desain tema, warna (AppColors), spacing, dan typography
│   ├── app_colors.dart
│   ├── app_spacing.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
│
└── data/
    ├── laporan_repository.dart        → Mock data awal laporan kondisi
    └── lahan_repository.dart          → Mock data awal lahan
```

---

## 🔄 3. Penjelasan 5 Tahap Workflow (Rubrik Penilaian Dosen)

### 1️⃣ INPUT / EVENT (Aksi Pengguna)
- User tap tombol FAB **"Lapor Kondisi"** di [riwayat_laporan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/laporan/riwayat_laporan_screen.dart).
- User mengisi formulir pada [tambah_laporan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/laporan/tambah_laporan_screen.dart):
  - Memilih foto bukti kondisi lapangan (Kamera / Galeri / Contoh Foto).
  - Memilih **Lahan Yang Diamati** dari dropdown.
  - Memilih **Jenis Kondisi Tanaman** (Normal, Serangan Hama/Penyakit, Kekeringan, Banjir, Kurang Nutrisi, dll).
  - Memilih **Tingkat Keparahan** (Rendah, Sedang, atau Berat).
  - Menuliskan **Catatan Observasi Lapangan** (minimal 5 karakter).
- User tap tombol **"Kirim Laporan Kondisi"**.

### 2️⃣ STATE MANAGEMENT (Penyimpanan Data)
- **Local State Form**:
  - `_selectedLahanId`, `_selectedJenisKondisi`, `_selectedTingkatKeparahan`, `_catatanController`, `_fotoPath`, `_isLoading`.
- **Global State Laporan** ([laporan_provider.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/providers/laporan_provider.dart)):
  - Menyimpan daftar `_laporanList`.
  - Fungsi `tambahLaporan()` otomatis menambahkan item dan memanggil `notifyListeners()`.
  - **Business Logic Otomatis (FR-12)**: `LaporanKondisi.tentukanStatusRisiko()` otomatis mengevaluasi jika keparahan = **"Berat"** atau Hama = **"Sedang"**, maka status risiko menjadi **"Risiko Tinggi"**.

### 3️⃣ VALIDATION (Pencegahan Input Salah)
- Dikelola oleh [validators.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/utils/validators.dart):
  - **Lahan**: Wajib dipilih (`val == null ? 'Lahan pertanian wajib dipilih' : null`).
  - **Jenis Kondisi**: Wajib dipilih (`Validators.requiredDropdown(val)`).
  - **Catatan Observasi**: Wajib diisi, minimal 5 karakter (`Validators.minLength(val, 5)`).

### 4️⃣ USER FEEDBACK (Respon Antarmuka)
- **Error**: Field memunculkan teks error berwarna merah jika kosong/kurang panjang.
- **Loading**: Tombol kirim berubah menjadi spinner `CircularProgressIndicator`.
- **Sukses & Early Warning (FR-12)**:
  - Muncul modal dialog khusus papan laporan centang hijau (`success_laporan.png`).
  - **Jika Risiko Tinggi**: Dialog otomatis menampilkan kotak peringatan merah *"Peringatan Dini: Risiko Tinggi - Kondisi memicu status Risiko Tinggi"*.

### 5️⃣ NAVIGATION & RESULT (Hasil Akhir)
- Setelah user tap tombol "OK", layar form ditutup (`Navigator.pop`).
- Layar kembali ke **Riwayat Laporan**, item laporan baru langsung berada di paling atas daftar dengan thumbnail foto, badge keparahan, dan tag Risiko Tinggi.
- Angka counter statistik risiko di header otomatis bertambah!

---

## 🎯 4. Cheat Sheet Pertanyaan Dosen Saat Live Coding

### ❓ Pertanyaan 1: "Coba ubah catatan observasi agar minimal 10 karakter, bukan 5!"
> **Buka file**: [lib/screens/laporan/tambah_laporan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/laporan/tambah_laporan_screen.dart#L667)  
> Ubah angka `5` menjadi `10`:
> ```dart
> validator: (val) => Validators.minLength(val, 10, fieldName: 'Catatan observasi'),
> ```

### ❓ Pertanyaan 2: "Bagaimana logika penentuan Risiko Tinggi (FR-12) bekerja?"
> **Buka file**: [lib/models/laporan_kondisi.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/models/laporan_kondisi.dart#L75)  
> Di method `tentukanStatusRisiko`:
> - Jika tingkat keparahan == `'Berat'`, otomatis **Risiko Tinggi**.
> - Jika jenis kondisi mengandung hama/penyakit/kekeringan dan keparahan == `'Sedang'`, maka **Risiko Tinggi**.
> - Selain itu, status adalah **Normal**.

### ❓ Pertanyaan 3: "Coba tambahkan jenis kondisi tanaman baru, misalnya 'Serangan Jamur'!"
> **Buka file**: [lib/models/laporan_kondisi.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/models/laporan_kondisi.dart#L10)  
> Tambahkan `'Serangan Jamur'` ke list `daftarJenisKondisi`.

---

## 🧪 5. Menjalankan Unit Test & Aplikasi

```bash
# Jalankan unit test
flutter test

# Jalankan aplikasi langsung
flutter run
```
