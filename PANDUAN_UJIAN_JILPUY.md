# 🌾 PANDUAN UJIAN PRAKTIKAL - MODUL 1 (JILPUY)
## Branch: `jilpuy_practical`
## Workflow: Modul 1 — Tambah & Kelola Data Lahan Baru (FR-01, FR-02)

---

## 📌 1. Mengapa Branch Ini Dibuat Khusus?
Branch `jilpuy_practical` ini **hanya berisi file dan kode yang relevan dengan Modul 1 (Manajemen Lahan)**, tanpa tercampur dengan modul login, laporan kondisi, atau jadwal perawatan.

Ketika aplikasi dijalankan (`flutter run`), aplikasi **langsung membuka layar Daftar Lahan** dengan grid kartu lahan dan tombol FAB **+ Tambah Lahan**, sehingga siap didemokan langsung saat ujian.

---

## 📂 2. Struktur File & Pembagian Peran

```text
lib/
├── main.dart                          → Titik awal aplikasi Flutter
├── app.dart                           → MultiProvider & Root langsung ke DaftarLahanScreen
│
├── models/
│   └── lahan.dart                     → Model entitas lahan (id, nama, luas, komoditas, jenisTanah, lokasi, fotoPath)
│
├── providers/
│   └── lahan_provider.dart            → State Management Lahan (loadDaftarLahan, tambahLahan, updateLahan, hapusLahan)
│
├── screens/lahan/
│   ├── daftar_lahan_screen.dart       → Grid 2 kolom kartu lahan, menu opsi (Edit/Hapus), FAB Tambah Lahan
│   └── tambah_lahan_screen.dart       → Formulir interaktif tambah/edit lahan + picker foto (Kamera/Galeri)
│
├── widgets/
│   ├── land_card.dart                 → Kartu lahan dengan foto 4:3, nama, chip komoditas, dan lokasi
│   ├── status_chip.dart               → Chip indikator komoditas & luas (misal: "0,5 ha • Padi")
│   └── jadwal_success_dialog.dart     → Dialog modal sukses dengan ilustrasi lahan & tombol OK
│
├── utils/
│   └── validators.dart                → Validasi reusable (positiveNumber, minLength, requiredDropdown)
│
├── theme/                             → Desain warna (AppColors), spacing (AppSpacing), font (AppTextStyles)
│   ├── app_colors.dart
│   ├── app_spacing.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
│
└── data/
    └── lahan_repository.dart          → Mock data repository awal lahan
```

---

## 🔄 3. Penjelasan 5 Tahap Workflow (Rubrik Penilaian Dosen)

### 1️⃣ INPUT / EVENT (Aksi Pengguna)
- User tap tombol FAB **"+ Tambah Lahan"** pada [daftar_lahan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/lahan/daftar_lahan_screen.dart).
- User mengisi:
  - **Nama Lahan** (misal: `Lahan Jagung Timur`)
  - **Luas Lahan** dalam hektar (misal: `0.75`)
  - Memilih **Komoditas Utama** dari dropdown (Padi, Jagung, Cabai, Kedelai, dll)
  - Memilih **Jenis Tanah** dari dropdown (Aluvial, Andosol, Latosol, dll)
  - Mengisi **Lokasi / Alamat Lahan** (misal: `Kec. Kuranji, Padang`)
  - Opsi: Memilih Foto Lahan (Kamera / Galeri / Contoh Foto)
- User tap tombol **"Simpan Data Lahan"**.

### 2️⃣ STATE MANAGEMENT (Penyimpanan Data)
- **Local State Form** ([tambah_lahan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/lahan/tambah_lahan_screen.dart)):
  - Controller text: `_namaController`, `_luasController`, `_lokasiController`.
  - Dropdown state: `_selectedKomoditas`, `_selectedJenisTanah`.
  - Image state: `_selectedImage` / `_selectedPhotoSample`.
  - Progress state: `_isLoading`, `_autoValidate`.
- **Global State** ([lahan_provider.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/providers/lahan_provider.dart)):
  - Menyimpan `_lahanList`.
  - Memanggil `tambahLahan(lahanBaru)` dan `notifyListeners()`.
  - Layar [daftar_lahan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/lahan/daftar_lahan_screen.dart) dibungkus `Consumer<LahanProvider>` sehingga daftar otomatis me-render kartu lahan baru.

### 3️⃣ VALIDATION (Pencegahan Input Salah)
- Dikelola oleh [validators.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/utils/validators.dart):
  - **Nama Lahan**: Wajib diisi, minimal 3 karakter.
  - **Luas Lahan**: Wajib diisi angka positif $> 0$, mendukung format koma maupun titik (misal: `0,5` atau `0.5`).
  - **Komoditas & Jenis Tanah**: Wajib dipilih dari dropdown.
  - **Lokasi**: Wajib diisi, minimal 3 karakter.

### 4️⃣ USER FEEDBACK (Respon Antarmuka)
- **Error**: Field memunculkan pesan error merah di bawah input form jika validasi gagal.
- **Loading**: Tombol "Simpan Data Lahan" berubah menampilkan spinner `CircularProgressIndicator`.
- **Sukses**: Menampilkan modal dialog [JadwalSuccessDialog](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/widgets/jadwal_success_dialog.dart) dengan judul *"Data lahan berhasil ditambahkan!"* dan tombol "OK".

### 5️⃣ NAVIGATION & RESULT (Hasil Akhir)
- Setelah user tap "OK", layar form ditutup (`Navigator.pop`).
- Layar kembali ke **Daftar Lahan**, kartu lahan baru langsung tampil di Grid dengan foto, luas, dan chip komoditas.

---

## 🎯 4. Cheat Sheet Pertanyaan Dosen Saat Live Coding

### ❓ Pertanyaan 1: "Coba ubah validasi luas lahan agar minimal 0.1 hektar!"
> **Buka file**: [lib/utils/validators.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/utils/validators.dart#L39)  
> Ubah pengecekan `parsed <= 0` menjadi `parsed < 0.1`.

### ❓ Pertanyaan 2: "Coba tambahkan pilihan komoditas baru, misal 'Bawang Merah'!"
> **Buka file**: [lib/models/lahan.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/models/lahan.dart#L10)  
> Tambahkan `'Bawang Merah'` ke dalam list `daftarKomoditas`.

### ❓ Pertanyaan 3: "Bagaimana cara kerja fitur hapus lahan?"
> **Buka file**: [lib/screens/lahan/daftar_lahan_screen.dart](file:///d:/UTIWI%20CUMLAUDE/Bismiillah%20sem%205/Pemograman%20Mobile/AgroPlan/lib/screens/lahan/daftar_lahan_screen.dart#L36-L84)  
> Tap menu titik tiga di kartu lahan $\rightarrow$ Pilih Hapus $\rightarrow$ Muncul dialog konfirmasi $\rightarrow$ Jika yakin, `context.read<LahanProvider>().hapusLahan(id)` dipanggil $\rightarrow$ Tampil SnackBar feedback berhasil dihapus.

---

## 🧪 5. Menjalankan Unit Test & Aplikasi

```bash
# Jalankan test suite
flutter test

# Jalankan aplikasi langsung
flutter run
```
