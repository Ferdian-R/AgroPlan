const db = require('../config/db');

// GET /api/jadwal (FR-14: Lihat daftar jadwal perawatan)
exports.getAllJadwal = async (req, res) => {
  try {
    const { id_lahan, id_siklus, status } = req.query;
    let query = `
      SELECT j.*, l.nama_lahan, s.komoditas,
        CASE 
          WHEN j.status_pelaksanaan = 'Ditunda' AND j.tanggal_ditunda IS NOT NULL THEN j.tanggal_ditunda
          ELSE j.tanggal_pelaksanaan
        END AS tanggal_efektif,
        CASE
          WHEN j.status_pelaksanaan = 'Belum' AND CURDATE() >= j.tanggal_pelaksanaan THEN 1
          ELSE 0
        END AS is_jatuh_tempo
      FROM jadwal_perawatan j
      JOIN lahan l ON j.id_lahan = l.id_lahan
      JOIN siklus_tanam s ON j.id_siklus = s.id_siklus
      WHERE 1=1
    `;
    const params = [];

    if (id_lahan) {
      query += ' AND j.id_lahan = ?';
      params.push(id_lahan);
    }

    if (id_siklus) {
      query += ' AND j.id_siklus = ?';
      params.push(id_siklus);
    }

    if (status && status !== 'Semua') {
      query += ' AND j.status_pelaksanaan = ?';
      params.push(status);
    }

    query += ' ORDER BY tanggal_efektif ASC';

    const [rows] = await db.query(query, params);

    return res.json({
      success: true,
      message: 'Berhasil memuat jadwal perawatan.',
      data: rows,
    });
  } catch (error) {
    console.error('Error getAllJadwal:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/jadwal (FR-13: Tambah Jadwal Manual & Mandiri 'Lainnya')
exports.createJadwal = async (req, res) => {
  try {
    const { id_lahan, id_siklus, nama_kegiatan, jenis_perawatan, tanggal_pelaksanaan, catatan } = req.body;

    if (!id_lahan || !id_siklus || !nama_kegiatan || !tanggal_pelaksanaan) {
      return res.status(400).json({
        success: false,
        message: 'Lahan, siklus, nama kegiatan, dan tanggal pelaksanaan wajib diisi.',
      });
    }

    const [result] = await db.query(
      `INSERT INTO jadwal_perawatan (id_siklus, id_lahan, nama_kegiatan, jenis_perawatan, tanggal_pelaksanaan, status_pelaksanaan, catatan)
       VALUES (?, ?, ?, ?, ?, 'Belum', ?)`,
      [
        id_siklus,
        id_lahan,
        nama_kegiatan,
        jenis_perawatan || nama_kegiatan,
        tanggal_pelaksanaan,
        catatan || '',
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Jadwal perawatan berhasil ditambahkan.',
      data: {
        id_jadwal: result.insertId,
        id_siklus,
        id_lahan,
        nama_kegiatan,
        jenis_perawatan,
        tanggal_pelaksanaan,
        status_pelaksanaan: 'Belum',
      },
    });
  } catch (error) {
    console.error('Error createJadwal:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/jadwal/:id/status (FR-15: Ubah status pelaksanaan Belum / Selesai / Ditunda)
exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status_pelaksanaan, tanggal_ditunda } = req.body;

    if (!['Belum', 'Selesai', 'Ditunda'].includes(status_pelaksanaan)) {
      return res.status(400).json({
        success: false,
        message: 'Status pelaksanaan harus Belum, Selesai, atau Ditunda.',
      });
    }

    if (status_pelaksanaan === 'Ditunda' && !tanggal_ditunda) {
      return res.status(400).json({
        success: false,
        message: 'Tanggal tunda baru wajib ditentukan untuk status Ditunda.',
      });
    }

    const tglTunda = status_pelaksanaan === 'Ditunda' ? tanggal_ditunda : null;

    const [result] = await db.query(
      `UPDATE jadwal_perawatan 
       SET status_pelaksanaan = ?, tanggal_ditunda = ?
       WHERE id_jadwal = ?`,
      [status_pelaksanaan, tglTunda, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Jadwal tidak ditemukan.' });
    }

    return res.json({
      success: true,
      message: `Status jadwal berhasil diperbarui menjadi ${status_pelaksanaan}.`,
    });
  } catch (error) {
    console.error('Error updateStatus:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/jadwal/:id (Hapus Jadwal)
exports.deleteJadwal = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await db.query('DELETE FROM jadwal_perawatan WHERE id_jadwal = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Jadwal tidak ditemukan.' });
    }

    return res.json({
      success: true,
      message: 'Jadwal perawatan berhasil dihapus.',
    });
  } catch (error) {
    console.error('Error deleteJadwal:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/jadwal/estimasi (FR-16: Hitung estimasi panen resmi PRD)
exports.getEstimasiPanen = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT l.id_lahan, l.nama_lahan, l.luas_lahan, s.id_siklus, s.komoditas,
        r.produktivitas_referensi, r.wilayah_acuan,
        ROUND(l.luas_lahan * r.produktivitas_referensi, 3) AS estimasi_hasil_ton
      FROM lahan l
      JOIN siklus_tanam s ON l.id_lahan = s.id_lahan AND s.status_siklus = 'Berjalan'
      JOIN referensi_komoditas r ON LOWER(s.komoditas) = LOWER(r.nama_komoditas)
    `);

    return res.json({
      success: true,
      message: 'Berhasil menghitung estimasi hasil panen.',
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};
