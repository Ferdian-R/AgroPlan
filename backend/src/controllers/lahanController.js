const db = require('../config/db');

// GET /api/lahan (FR-02: Lihat daftar seluruh lahan)
exports.getAllLahan = async (req, res) => {
  try {
    const idPengguna = req.query.id_pengguna || 1;
    const [rows] = await db.query(
      `SELECT l.*, 
        (SELECT COUNT(*) FROM siklus_tanam s WHERE s.id_lahan = l.id_lahan AND s.status_siklus = 'Berjalan') AS jumlah_siklus_aktif
       FROM lahan l 
       WHERE l.id_pengguna = ? 
       ORDER BY l.tanggal_dibuat DESC`,
      [idPengguna]
    );

    return res.json({
      success: true,
      message: 'Berhasil memuat daftar lahan.',
      data: rows,
    });
  } catch (error) {
    console.error('Error getAllLahan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/lahan/:id (FR-02: Detail Lahan)
exports.getLahanById = async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query('SELECT * FROM lahan WHERE id_lahan = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Lahan tidak ditemukan.' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/lahan (FR-01: Tambah Lahan Baru)
exports.createLahan = async (req, res) => {
  try {
    const { nama_lahan, lokasi, luas_lahan, jenis_tanah, komoditas_utama, deskripsi, id_pengguna } = req.body;

    if (!nama_lahan || !lokasi || !luas_lahan) {
      return res.status(400).json({
        success: false,
        message: 'Nama lahan, lokasi, dan luas lahan wajib diisi.',
      });
    }

    const luas = parseFloat(luas_lahan);
    if (isNaN(luas) || luas <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Luas lahan harus berupa angka positif lebih besar dari 0.',
      });
    }

    const [result] = await db.query(
      `INSERT INTO lahan (id_pengguna, nama_lahan, lokasi, luas_lahan, jenis_tanah, komoditas_utama, deskripsi)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        id_pengguna || 1,
        nama_lahan.trim(),
        lokasi.trim(),
        luas,
        jenis_tanah || 'Aluvial',
        komoditas_utama || 'Padi',
        deskripsi || '',
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Lahan berhasil ditambahkan.',
      data: {
        id_lahan: result.insertId,
        id_pengguna: id_pengguna || 1,
        nama_lahan,
        lokasi,
        luas_lahan: luas,
        jenis_tanah: jenis_tanah || 'Aluvial',
        komoditas_utama: komoditas_utama || 'Padi',
        deskripsi,
      },
    });
  } catch (error) {
    console.error('Error createLahan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/lahan/:id (FR-03: Ubah Data Lahan)
exports.updateLahan = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama_lahan, lokasi, luas_lahan, jenis_tanah, komoditas_utama, deskripsi } = req.body;

    const [existing] = await db.query('SELECT * FROM lahan WHERE id_lahan = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Lahan tidak ditemukan.' });
    }

    const luas = luas_lahan ? parseFloat(luas_lahan) : existing[0].luas_lahan;

    await db.query(
      `UPDATE lahan 
       SET nama_lahan = ?, lokasi = ?, luas_lahan = ?, jenis_tanah = ?, komoditas_utama = ?, deskripsi = ?
       WHERE id_lahan = ?`,
      [
        nama_lahan || existing[0].nama_lahan,
        lokasi || existing[0].lokasi,
        luas,
        jenis_tanah || existing[0].jenis_tanah,
        komoditas_utama || existing[0].komoditas_utama,
        deskripsi !== undefined ? deskripsi : existing[0].deskripsi,
        id,
      ]
    );

    return res.json({
      success: true,
      message: 'Data lahan berhasil diperbarui.',
    });
  } catch (error) {
    console.error('Error updateLahan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/lahan/:id (FR-04: Hapus Lahan)
exports.deleteLahan = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await db.query('DELETE FROM lahan WHERE id_lahan = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Lahan tidak ditemukan.' });
    }

    return res.json({
      success: true,
      message: 'Lahan beserta seluruh data terkait berhasil dihapus.',
    });
  } catch (error) {
    console.error('Error deleteLahan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};
