const db = require('../config/db');

// GET /api/panen (FR-18: Riwayat Hasil Panen)
exports.getRiwayatPanen = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT p.*,
        ROUND(p.jumlah_hasil_ton - p.estimasi_hasil_ton, 3) AS selisih_ton,
        ROUND((p.jumlah_hasil_ton / p.estimasi_hasil_ton) * 100, 1) AS persentase_pencapaian,
        CASE
          WHEN p.jumlah_hasil_ton > p.estimasi_hasil_ton THEN 'Melampaui Target'
          WHEN p.jumlah_hasil_ton = p.estimasi_hasil_ton THEN 'Sesuai Target'
          ELSE 'Di Bawah Target'
        END AS status_evaluasi
      FROM riwayat_panen p
      ORDER BY p.tanggal_panen DESC, p.tanggal_dibuat DESC
    `);

    return res.json({
      success: true,
      message: 'Berhasil memuat riwayat hasil panen.',
      data: rows,
    });
  } catch (error) {
    console.error('Error getRiwayatPanen:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/panen (FR-17 & FR-18: Catat Hasil Panen & Otomatis Selesaikan Siklus)
exports.createPanen = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_siklus, id_lahan, nama_lahan, komoditas, luas_lahan, tanggal_panen, jumlah_hasil_ton, estimasi_hasil_ton, catatan } = req.body;

    if (!id_siklus || !id_lahan || !tanggal_panen || jumlah_hasil_ton === undefined) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Data siklus, lahan, tanggal panen, dan jumlah hasil panen wajib diisi.',
      });
    }

    const hasilTon = parseFloat(jumlah_hasil_ton);
    if (isNaN(hasilTon) || hasilTon <= 0) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Jumlah hasil panen harus berupa angka positif lebih besar dari 0.',
      });
    }

    // Validasi aturan PRD: Tanggal panen tidak boleh sebelum tanggal tanam
    const [siklusRows] = await connection.query('SELECT * FROM siklus_tanam WHERE id_siklus = ?', [id_siklus]);
    if (siklusRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Siklus tanam tidak ditemukan.' });
    }

    const siklus = siklusRows[0];
    const tglTanam = new Date(siklus.tanggal_tanam_aktual || siklus.tanggal_rencana_tanam);
    const tglPanen = new Date(tanggal_panen);

    if (tglPanen < tglTanam) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: 'Tanggal panen tidak boleh sebelum tanggal tanam.',
      });
    }

    // 1. Simpan catatan panen
    const [result] = await connection.query(
      `INSERT INTO riwayat_panen (id_siklus, id_lahan, nama_lahan, komoditas, luas_lahan, tanggal_panen, jumlah_hasil_ton, estimasi_hasil_ton, catatan)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id_siklus,
        id_lahan,
        nama_lahan || 'Lahan',
        komoditas || siklus.komoditas,
        luas_lahan || 1.0,
        tanggal_panen,
        hasilTon,
        estimasi_hasil_ton || 0.0,
        catatan || '',
      ]
    );

    // 2. PRD FR-18: Mengubah status siklus tanam menjadi 'Selesai'
    await connection.query(
      `UPDATE siklus_tanam SET status_siklus = 'Selesai' WHERE id_siklus = ?`,
      [id_siklus]
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Hasil panen berhasil dicatat dan siklus tanam telah diselesaikan.',
      data: {
        id_panen: result.insertId,
        id_siklus,
        id_lahan,
        nama_lahan,
        komoditas: komoditas || siklus.komoditas,
        jumlah_hasil_ton: hasilTon,
        estimasi_hasil_ton,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error createPanen:', error);
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    connection.release();
  }
};
