const db = require('../config/db');

// GET /api/siklus (Lihat semua siklus tanam)
exports.getAllSiklus = async (req, res) => {
  try {
    const { id_lahan, status } = req.query;
    let query = `
      SELECT s.*, l.nama_lahan, l.luas_lahan,
        DATEDIFF(CURDATE(), COALESCE(s.tanggal_tanam_aktual, s.tanggal_rencana_tanam)) AS hst
      FROM siklus_tanam s
      JOIN lahan l ON s.id_lahan = l.id_lahan
      WHERE 1=1
    `;
    const params = [];

    if (id_lahan) {
      query += ' AND s.id_lahan = ?';
      params.push(id_lahan);
    }

    if (status) {
      query += ' AND s.status_siklus = ?';
      params.push(status);
    }

    query += ' ORDER BY s.tanggal_dibuat DESC';

    const [rows] = await db.query(query, params);

    return res.json({
      success: true,
      message: 'Berhasil memuat daftar siklus tanam.',
      data: rows,
    });
  } catch (error) {
    console.error('Error getAllSiklus:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/siklus (FR-05: Tambah Siklus Tanam Baru & Otomatis Generate Jadwal Perawatan)
exports.createSiklus = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_lahan, komoditas, tanggal_rencana_tanam, tanggal_tanam_aktual, catatan } = req.body;

    if (!id_lahan || !komoditas || !tanggal_rencana_tanam) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Lahan, komoditas, dan tanggal rencana tanam wajib diisi.',
      });
    }

    // Cek apakah lahan valid
    const [lahanRows] = await connection.query('SELECT * FROM lahan WHERE id_lahan = ?', [id_lahan]);
    if (lahanRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Lahan tidak ditemukan.' });
    }
    const lahan = lahanRows[0];

    // Simpan siklus tanam
    const [result] = await connection.query(
      `INSERT INTO siklus_tanam (id_lahan, komoditas, tanggal_rencana_tanam, tanggal_tanam_aktual, status_siklus, catatan)
       VALUES (?, ?, ?, ?, 'Berjalan', ?)`,
      [id_lahan, komoditas, tanggal_rencana_tanam, tanggal_tanam_aktual || tanggal_rencana_tanam, catatan || '']
    );

    const idSiklus = result.insertId;

    // FR-13: Otomatis generate jadwal perawatan berdasarkan template resmi PRD Tabel 2.5.3
    const [refKomoditas] = await connection.query(
      'SELECT id_komoditas FROM referensi_komoditas WHERE LOWER(nama_komoditas) = LOWER(?)',
      [komoditas]
    );

    if (refKomoditas.length > 0) {
      const idKomoditas = refKomoditas[0].id_komoditas;
      const [templates] = await connection.query(
        'SELECT * FROM template_jadwal WHERE id_komoditas = ?',
        [idKomoditas]
      );

      const acuanDate = new Date(tanggal_tanam_aktual || tanggal_rencana_tanam);

      for (const t of templates) {
        const tglPelaksanaan = new Date(acuanDate);
        tglPelaksanaan.setDate(tglPelaksanaan.getDate() + t.hst_pengingat);

        await connection.query(
          `INSERT INTO jadwal_perawatan (id_siklus, id_lahan, id_template, nama_kegiatan, jenis_perawatan, tanggal_pelaksanaan, status_pelaksanaan, waktu_sumber, hst_pengingat)
           VALUES (?, ?, ?, ?, ?, ?, 'Belum', ?, ?)`,
          [
            idSiklus,
            id_lahan,
            t.id_template,
            t.nama_kegiatan,
            t.nama_kegiatan,
            tglPelaksanaan.toISOString().split('T')[0],
            t.rentang_hst,
            t.hst_pengingat,
          ]
        );
      }
    }

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Siklus tanam berhasil dibuat dan jadwal perawatan otomatis telah disiapkan.',
      data: {
        id_siklus: idSiklus,
        id_lahan,
        nama_lahan: lahan.nama_lahan,
        komoditas,
        tanggal_rencana_tanam,
        status_siklus: 'Berjalan',
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error createSiklus:', error);
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    connection.release();
  }
};

// PUT /api/siklus/:id/selesai (FR-18: Tandai Siklus Tanam Selesai)
exports.finishSiklus = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await db.query(
      `UPDATE siklus_tanam SET status_siklus = 'Selesai' WHERE id_siklus = ?`,
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Siklus tanam tidak ditemukan.' });
    }

    return res.json({
      success: true,
      message: 'Status siklus tanam berhasil diubah menjadi Selesai.',
    });
  } catch (error) {
    console.error('Error finishSiklus:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/siklus/:id/tanggal-tanam (FR-13: Sesuaikan tanggal tanam dan jadwal belum selesai)
exports.updateTanggalTanam = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id } = req.params;
    const { tanggal_tanam_baru } = req.body;

    if (!tanggal_tanam_baru) {
      await connection.rollback();
      return res.status(400).json({ success: false, message: 'Tanggal tanam baru wajib diisi.' });
    }

    const [siklusRows] = await connection.query('SELECT * FROM siklus_tanam WHERE id_siklus = ?', [id]);
    if (siklusRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Siklus tanam tidak ditemukan.' });
    }

    const tglLama = new Date(siklusRows[0].tanggal_tanam_aktual || siklusRows[0].tanggal_rencana_tanam);
    const tglBaru = new Date(tanggal_tanam_baru);
    const selisihHari = Math.round((tglBaru - tglLama) / (1000 * 60 * 60 * 24));

    // Update tanggal tanam siklus
    await connection.query(
      `UPDATE siklus_tanam SET tanggal_tanam_aktual = ?, tanggal_rencana_tanam = ? WHERE id_siklus = ?`,
      [tanggal_tanam_baru, tanggal_tanam_baru, id]
    );

    // FR-13: Jadwal yang statusnya 'Belum' tanggalnya bergeser otomatis, jadwal 'Selesai' dipertahankan
    if (selisihHari !== 0) {
      await connection.query(
        `UPDATE jadwal_perawatan 
         SET tanggal_pelaksanaan = DATE_ADD(tanggal_pelaksanaan, INTERVAL ? DAY)
         WHERE id_siklus = ? AND status_pelaksanaan = 'Belum'`,
        [selisihHari, id]
      );
    }

    await connection.commit();

    return res.json({
      success: true,
      message: 'Tanggal tanam dan jadwal perawatan belum selesai berhasil disesuaikan.',
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error updateTanggalTanam:', error);
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    connection.release();
  }
};
