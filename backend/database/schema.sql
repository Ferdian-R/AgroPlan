-- Database Schema untuk AgroPlan Mobile (Sesuai PRD v2.0 Bagian 2.5)
-- Database: MySQL

CREATE DATABASE IF NOT EXISTS agroplan_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE agroplan_db;

-- 1. Tabel Pengguna (Auth & Akun Petani)
CREATE TABLE IF NOT EXISTS pengguna (
  id_pengguna INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  nomor_hp VARCHAR(20) NULL,
  foto_profil VARCHAR(255) NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tanggal_diubah TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabel Lahan Pertanian (Modul 1: FR-01 s.d FR-04)
CREATE TABLE IF NOT EXISTS lahan (
  id_lahan INT AUTO_INCREMENT PRIMARY KEY,
  id_pengguna INT NOT NULL,
  nama_lahan VARCHAR(100) NOT NULL,
  lokasi VARCHAR(200) NOT NULL,
  luas_lahan DECIMAL(8, 2) NOT NULL, -- dalam hektare (ha)
  jenis_tanah VARCHAR(50) DEFAULT 'Aluvial',
  komoditas_utama VARCHAR(50) DEFAULT 'Padi',
  deskripsi TEXT NULL,
  foto_lahan VARCHAR(255) NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tanggal_diubah TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Tabel Referensi Komoditas & Produktivitas Resmi PRD Tabel 2.5.2
CREATE TABLE IF NOT EXISTS referensi_komoditas (
  id_komoditas INT AUTO_INCREMENT PRIMARY KEY,
  nama_komoditas VARCHAR(50) NOT NULL UNIQUE,
  produktivitas_referensi DECIMAL(8, 3) NOT NULL, -- ton/ha
  wilayah_acuan VARCHAR(100) NOT NULL,
  sumber_data VARCHAR(100) DEFAULT 'BPS & Kementan',
  status_verifikasi VARCHAR(100) DEFAULT 'Referensi awal, perlu diverifikasi'
) ENGINE=InnoDB;

-- 4. Tabel Template Jadwal Perawatan Resmi PRD Tabel 2.5.3
CREATE TABLE IF NOT EXISTS template_jadwal (
  id_template INT AUTO_INCREMENT PRIMARY KEY,
  id_komoditas INT NOT NULL,
  nama_kegiatan VARCHAR(100) NOT NULL,
  rentang_hst VARCHAR(50) NOT NULL,
  hst_pengingat INT NOT NULL, -- Hari Setelah Tanam
  sumber VARCHAR(50) NOT NULL,
  FOREIGN KEY (id_komoditas) REFERENCES referensi_komoditas(id_komoditas) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Tabel Siklus Tanam (Modul 1: FR-05 & FR-06)
CREATE TABLE IF NOT EXISTS siklus_tanam (
  id_siklus INT AUTO_INCREMENT PRIMARY KEY,
  id_lahan INT NOT NULL,
  komoditas VARCHAR(50) NOT NULL,
  tanggal_rencana_tanam DATE NOT NULL,
  tanggal_tanam_aktual DATE NULL,
  status_siklus ENUM('Berjalan', 'Selesai') DEFAULT 'Berjalan',
  catatan TEXT NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tanggal_diubah TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_lahan) REFERENCES lahan(id_lahan) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Tabel Laporan Kondisi Lahan (Modul 2: FR-07 s.d FR-11)
CREATE TABLE IF NOT EXISTS laporan_kondisi (
  id_laporan INT AUTO_INCREMENT PRIMARY KEY,
  id_siklus INT NOT NULL,
  id_lahan INT NOT NULL,
  tanggal_lapor DATE NOT NULL,
  jenis_kondisi VARCHAR(50) NOT NULL, -- Normal, Kekeringan, Banjir, Hama, Lainnya
  tingkat_keparahan VARCHAR(50) NOT NULL, -- Rendah, Sedang, Tinggi
  catatan TEXT NOT NULL,
  foto_url VARCHAR(255) NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_siklus) REFERENCES siklus_tanam(id_siklus) ON DELETE CASCADE,
  FOREIGN KEY (id_lahan) REFERENCES lahan(id_lahan) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Tabel Jadwal Perawatan (Modul 3: FR-13 s.d FR-15, FR-19)
CREATE TABLE IF NOT EXISTS jadwal_perawatan (
  id_jadwal INT AUTO_INCREMENT PRIMARY KEY,
  id_siklus INT NOT NULL,
  id_lahan INT NOT NULL,
  id_template INT NULL,
  nama_kegiatan VARCHAR(100) NOT NULL,
  jenis_perawatan VARCHAR(100) NOT NULL,
  tanggal_pelaksanaan DATE NOT NULL,
  status_pelaksanaan ENUM('Belum', 'Selesai', 'Ditunda') DEFAULT 'Belum',
  tanggal_ditunda DATE NULL,
  waktu_sumber VARCHAR(50) NULL,
  hst_pengingat INT NULL,
  catatan TEXT NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  tanggal_diubah TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_siklus) REFERENCES siklus_tanam(id_siklus) ON DELETE CASCADE,
  FOREIGN KEY (id_lahan) REFERENCES lahan(id_lahan) ON DELETE CASCADE,
  FOREIGN KEY (id_template) REFERENCES template_jadwal(id_template) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 8. Tabel Riwayat Panen (Modul 3: FR-17 & FR-18)
CREATE TABLE IF NOT EXISTS riwayat_panen (
  id_panen INT AUTO_INCREMENT PRIMARY KEY,
  id_siklus INT NOT NULL,
  id_lahan INT NOT NULL,
  nama_lahan VARCHAR(100) NOT NULL,
  komoditas VARCHAR(50) NOT NULL,
  luas_lahan DECIMAL(8, 2) NOT NULL,
  tanggal_panen DATE NOT NULL,
  jumlah_hasil_ton DECIMAL(8, 3) NOT NULL, -- ton aktual
  estimasi_hasil_ton DECIMAL(8, 3) NOT NULL, -- luas * produktivitas
  catatan TEXT NULL,
  tanggal_dibuat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_siklus) REFERENCES siklus_tanam(id_siklus) ON DELETE CASCADE,
  FOREIGN KEY (id_lahan) REFERENCES lahan(id_lahan) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ══════════════════════════════════════════════════════════════
-- SEED DATA AWAL (PRD Tabel 2.5.2 - Referensi Komoditas)
-- ══════════════════════════════════════════════════════════════
INSERT INTO referensi_komoditas (id_komoditas, nama_komoditas, produktivitas_referensi, wilayah_acuan, sumber_data)
VALUES
  (1, 'Padi', 4.594, 'Sumatera Barat', 'BPS & Kementan'),
  (2, 'Jagung', 6.176, 'Sumatera Barat', 'BPS & Kementan'),
  (3, 'Kedelai', 1.623, 'Nasional', 'BPS & Kementan'),
  (4, 'Cabai Merah', 10.620, 'Nasional, kategori cabai besar', 'BPS & Kementan'),
  (5, 'Bawang Merah', 11.050, 'Nasional', 'BPS & Kementan'),
  (6, 'Tomat', 19.540, 'Nasional', 'BPS & Kementan')
ON DUPLICATE KEY UPDATE produktivitas_referensi = VALUES(produktivitas_referensi);

-- ══════════════════════════════════════════════════════════════
-- SEED DATA AWAL (PRD Tabel 2.5.3 - Template Jadwal Perawatan)
-- ══════════════════════════════════════════════════════════════
INSERT INTO template_jadwal (id_komoditas, nama_kegiatan, rentang_hst, hst_pengingat, sumber)
VALUES
  -- Padi
  (1, 'Pemupukan susulan I', '7-10 HST', 7, 'S1, S3'),
  (1, 'Penyiangan I', '21 HST', 21, 'S2, S3'),
  (1, 'Pemupukan susulan II', '21-25 HST', 21, 'S1'),
  (1, 'Penyiangan II', '42 HST', 42, 'S2'),
  (1, 'Pengendalian hama & penyakit', '40-45 HST', 40, 'S3'),
  (1, 'Pengeringan sawah bertahap', '75-80 HST', 75, 'S3'),
  (1, 'Persiapan panen', '100-110 HST', 100, 'S3'),
  -- Jagung
  (2, 'Pemupukan susulan I', '10-15 HST', 10, 'S4, S5'),
  (2, 'Penyiangan & pembumbunan I', '15-20 HST', 15, 'S4, S6'),
  (2, 'Pemupukan susulan II', '28-30 HST', 28, 'S4'),
  (2, 'Penyiangan II & pembumbunan II', '35-40 HST', 35, 'S5'),
  (2, 'Pengairan fase berbunga', '45-55 HST', 45, 'S4, S6'),
  (2, 'Persiapan panen', '90-100 HST', 90, 'S4'),
  -- Kedelai
  (3, 'Penyulaman bibit', '7-10 HST', 7, 'S7, S8'),
  (3, 'Penyiangan I', '14-20 HST', 14, 'S7, S9'),
  (3, 'Pemupukan susulan', '20-25 HST', 20, 'S8'),
  (3, 'Penyiangan II', '35-40 HST', 35, 'S7'),
  (3, 'Pemeriksaan hama ulat grayak', '45-50 HST', 45, 'S9'),
  (3, 'Persiapan panen polong kering', '75-85 HST', 75, 'S7'),
  -- Cabai Merah
  (4, 'Pemasangan ajir/lanjaran', '7-10 HST', 7, 'S10, S11'),
  (4, 'Pemupukan susulan I', '10-14 HST', 10, 'S10, S12'),
  (4, 'Perompesan tunas air', '15-20 HST', 15, 'S10'),
  (4, 'Pemupukan susulan II', '25-30 HST', 25, 'S10'),
  (4, 'Pengikatan batang pada ajir', '30-35 HST', 30, 'S11'),
  (4, 'Pengendalian hama antraknosa/thrips', '45-50 HST', 45, 'S12'),
  (4, 'Persiapan panen pertama', '75-80 HST', 75, 'S10'),
  -- Bawang Merah
  (5, 'Pemupukan susulan I', '10-15 HST', 10, 'S13, S15'),
  (5, 'Penyiangan gulma I', '15-20 HST', 15, 'S14'),
  (5, 'Pemupukan susulan II', '30-35 HST', 30, 'S13, S16'),
  (5, 'Penyiraman intensif pembentukan umbi', '40-45 HST', 40, 'S14, S15'),
  (5, 'Penghentian penyiraman jelang panen', '50-55 HST', 50, 'S16'),
  (5, 'Persiapan panen dan penjemuran', '60-70 HST', 60, 'S13'),
  -- Tomat
  (6, 'Pemasangan ajir bambu', '7-10 HST', 7, 'S17, S19'),
  (6, 'Pemupukan susulan I', '14-21 HST', 14, 'S17, S18'),
  (6, 'Pemangkasan tunas liar (wiwil)', '20-25 HST', 20, 'S18'),
  (6, 'Pengikatan batang utama', '30 HST', 30, 'S19'),
  (6, 'Pemupukan susulan II (fase bunga)', '35-40 HST', 35, 'S17'),
  (6, 'Pengendalian busuk buah & daun', '50-55 HST', 50, 'S18'),
  (6, 'Persiapan panen buah pertama', '70-80 HST', 70, 'S17');

-- Akun demo default untuk kemudahan testing
INSERT INTO pengguna (id_pengguna, nama, email, password, nomor_hp)
VALUES (1, 'Ferdian Rahman', 'petani@agroplan.com', '$2a$10$wK1RkIePevM1J4xZf8F8IuYkPv8O2UaO8/GqFpU6pP4YpG9bK4T5i', '081234567890')
ON DUPLICATE KEY UPDATE nama = VALUES(nama);
