# AgroPlan REST API Backend

Backend REST API untuk aplikasi mobile **AgroPlan** menggunakan **Node.js (Express.js)** dan basis data **MySQL**. Dibuat sesuai spesifikasi PRD AgroPlan v2.0 Bagian 2.5 dan 2.6 (tanpa Firebase).

---

## 🗄️ Spesifikasi Database
* **Nama Database**: `agroplan_db`
* **DBMS**: MySQL / MariaDB (Port 3306)
* **File Skema & Seeder**: `backend/database/schema.sql`

### Tabel Utama:
1. `pengguna`: Akun petani dan autentikasi.
2. `lahan`: Data lahan (nama, lokasi, luas ha, jenis tanah, komoditas utama).
3. `referensi_komoditas`: 6 komoditas PRD (Padi, Jagung, Kedelai, Cabai Merah, Bawang Merah, Tomat) beserta produktivitas resmi (ton/ha).
4. `template_jadwal`: Template standar jadwal perawatan tanaman berdasarkan HST (Hari Setelah Tanam) dari publikasi resmi Kementan/Dinas Pertanian.
5. `siklus_tanam`: Siklus tanam per lahan (status Berjalan / Selesai).
6. `laporan_kondisi`: Pemantauan kondisi lahan (Normal/Kekeringan/Banjir/Hama/Lainnya) dengan unggah foto.
7. `jadwal_perawatan`: Jadwal perawatan otomatis & manual (status Belum/Selesai/Ditunda).
8. `riwayat_panen`: Catatan hasil panen aktual (ton), perbandingan estimasi, dan evaluasi produktivitas.

---

## 🚀 Cara Menjalankan Backend

1. **Pastikan MySQL berjalan** (misalnya melalui Laragon / XAMPP di port 3306).
2. **Masuk ke folder backend**:
   ```bash
   cd backend
   ```
3. **Instal dependensi** (jika belum):
   ```bash
   npm install
   ```
4. **Jalankan server**:
   * Mode produksi:
     ```bash
     npm start
     ```
   * Mode development (auto-reload saat ada perubahan kode):
     ```bash
     npm run dev
     ```

Server akan aktif pada:
* Lokal: `http://localhost:3000`
* Jaringan HP (satu Wi-Fi): `http://<IP_KOMPUTER_ANDA>:3000`
* Cek Kesehatan: `http://localhost:3000/api/health`

---

## 📡 Daftar Endpoint REST API

### 1. Autentikasi (`/api/auth`)
* `POST /api/auth/register` : Mendaftarkan akun petani baru.
* `POST /api/auth/login` : Masuk menggunakan email & kata sandi.
* `GET /api/auth/me` : Mendapatkan profil pengguna aktif.

### 2. Manajemen Lahan (`/api/lahan`) - Modul 1
* `GET /api/lahan` : Mendapatkan seluruh daftar lahan.
* `GET /api/lahan/:id` : Detail data lahan.
* `POST /api/lahan` : Menambahkan lahan baru.
* `PUT /api/lahan/:id` : Memperbarui data lahan.
* `DELETE /api/lahan/:id` : Menghapus lahan beserta seluruh siklus & perawatannya.

### 3. Siklus Tanam (`/api/siklus`) - Modul 1
* `GET /api/siklus` : Daftar siklus tanam (filter `?id_lahan=` atau `?status=`).
* `POST /api/siklus` : Membuat siklus tanam baru (**otomatis membuat jadwal perawatan sesuai komoditas**).
* `PUT /api/siklus/:id/selesai` : Mengubah status siklus menjadi Selesai.
* `PUT /api/siklus/:id/tanggal-tanam` : Menyesuaikan tanggal tanam dan otomatis menggeser jadwal belum selesai.

### 4. Laporan Kondisi Lahan (`/api/laporan`) - Modul 2
* `GET /api/laporan` : Daftar riwayat laporan kondisi lahan.
* `POST /api/laporan` : Mengunggah laporan kondisi lahan (mendukung multipart form-data `foto`).
* `PUT /api/laporan/:id` : Memperbarui laporan kondisi lahan.
* `DELETE /api/laporan/:id` : Menghapus laporan kondisi lahan.

### 5. Jadwal Perawatan & Estimasi Panen (`/api/jadwal`) - Modul 3
* `GET /api/jadwal` : Daftar jadwal perawatan (filter status Belum/Selesai/Ditunda).
* `GET /api/jadwal/estimasi` : Perhitungan estimasi panen resmi (`Luas ha × Produktivitas ton/ha`).
* `POST /api/jadwal` : Menambahkan jadwal perawatan manual / mandiri ('Lainnya').
* `PUT /api/jadwal/:id/status` : Mengubah status pelaksanaan (*Belum*, *Selesai*, atau *Ditunda* dengan tanggal baru).
* `DELETE /api/jadwal/:id` : Menghapus jadwal perawatan.

### 6. Pencatatan & Riwayat Panen (`/api/panen`) - Modul 3
* `GET /api/panen` : Riwayat hasil panen lengkap dengan selisih ton, persentase target, dan evaluasi.
* `POST /api/panen` : Mencatat hasil panen aktual (**otomatis menandai siklus tanam terkait menjadi 'Selesai'**).
