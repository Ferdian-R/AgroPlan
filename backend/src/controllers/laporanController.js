const db = require('../config/db');

// GET /api/laporan (FR-08: Lihat riwayat laporan kondisi lahan)
exports.getAllLaporan = async (req, res) => {
  try {
    const { id_lahan, id_siklus } = req.query;
    let query = `
      SELECT lp.*, l.nama_lahan, s.komoditas
      FROM laporan_kondisi lp
      JOIN lahan l ON lp.id_lahan = l.id_lahan
      JOIN siklus_tanam s ON lp.id_siklus = s.id_siklus
      WHERE 1=1
    `;
    const params = [];

    if (id_lahan) {
      query += ' AND lp.id_lahan = ?';
      params.push(id_lahan);
    }

    if (id_siklus) {
      query += ' AND lp.id_siklus = ?';
      params.push(id_siklus);
    }

    query += ' ORDER BY lp.tanggal_lapor DESC, lp.tanggal_dibuat DESC';

    const [rows] = await db.query(query, params);

    return res.json({
      success: true,
      message: 'Berhasil memuat daftar laporan kondisi lahan.',
      data: rows,
    });
  } catch (error) {
    console.error('Error getAllLaporan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/laporan (FR-07: Tambah Laporan Kondisi dengan Foto)
exports.createLaporan = async (req, res) => {
  try {
    const { id_lahan, id_siklus, tanggal_lapor, jenis_kondisi, tingkat_keparahan, catatan } = req.body;

    if (!id_lahan || !id_siklus || !tanggal_lapor || !jenis_kondisi || !tingkat_keparahan) {
      return res.status(400).json({
        success: false,
        message: 'Lahan, siklus, tanggal lapor, jenis kondisi, dan tingkat keparahan wajib diisi.',
      });
    }

    // Path foto dari file upload multer jika ada
    let fotoUrl = null;
    if (req.file) {
      fotoUrl = '/uploads/' + req.file.filename;
    } else if (req.body.foto_url) {
      fotoUrl = req.body.foto_url;
    }

    const [result] = await db.query(
      `INSERT INTO laporan_kondisi (id_siklus, id_lahan, tanggal_lapor, jenis_kondisi, tingkat_keparahan, catatan, foto_url)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        id_siklus,
        id_lahan,
        tanggal_lapor,
        jenis_kondisi,
        tingkat_keparahan,
        catatan || '',
        fotoUrl,
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Laporan kondisi lahan berhasil disimpan.',
      data: {
        id_laporan: result.insertId,
        id_siklus,
        id_lahan,
        tanggal_lapor,
        jenis_kondisi,
        tingkat_keparahan,
        catatan,
        foto_url: fotoUrl,
      },
    });
  } catch (error) {
    console.error('Error createLaporan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/laporan/:id (FR-09: Ubah Laporan Kondisi)
exports.updateLaporan = async (req, res) => {
  try {
    const { id } = req.params;
    const { jenis_kondisi, tingkat_keparahan, catatan, tanggal_lapor } = req.body;

    const [existing] = await db.query('SELECT * FROM laporan_kondisi WHERE id_laporan = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Laporan tidak ditemukan.' });
    }

    let fotoUrl = existing[0].foto_url;
    if (req.file) {
      fotoUrl = '/uploads/' + req.file.filename;
    }

    await db.query(
      `UPDATE laporan_kondisi
       SET jenis_kondisi = ?, tingkat_keparahan = ?, catatan = ?, tanggal_lapor = ?, foto_url = ?
       WHERE id_laporan = ?`,
      [
        jenis_kondisi || existing[0].jenis_kondisi,
        tingkat_keparahan || existing[0].tingkat_keparahan,
        catatan !== undefined ? catatan : existing[0].catatan,
        tanggal_lapor || existing[0].tanggal_lapor,
        fotoUrl,
        id,
      ]
    );

    return res.json({
      success: true,
      message: 'Laporan kondisi lahan berhasil diperbarui.',
    });
  } catch (error) {
    console.error('Error updateLaporan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/laporan/:id (FR-10: Hapus Laporan Kondisi)
exports.deleteLaporan = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await db.query('DELETE FROM laporan_kondisi WHERE id_laporan = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Laporan tidak ditemukan.' });
    }

    return res.json({
      success: true,
      message: 'Laporan kondisi lahan berhasil dihapus.',
    });
  } catch (error) {
    console.error('Error deleteLaporan:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};
