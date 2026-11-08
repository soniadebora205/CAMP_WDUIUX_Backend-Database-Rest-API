const express = require('express');
const pool = require('../db');

const router = express.Router();

const KOLOM_WAJIB = ['nik', 'nama', 'tanggal_lahir'];

function idValid(id) {
  return /^\d+$/.test(id);
}

function cekBodyWajib(body) {
  return KOLOM_WAJIB.filter((k) => body[k] === undefined || body[k] === '');
}

// 1. GET semua data
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM ibu ORDER BY id_ibu');
    res.json({ message: 'Berhasil mengambil semua data ibu', total: result.rowCount, data: result.rows });
  } catch (err) {
    next(err);
  }
});

// 2. GET berdasarkan ID
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!idValid(id)) return res.status(400).json({ message: 'ID harus berupa angka' });

    const result = await pool.query('SELECT * FROM ibu WHERE id_ibu = $1', [id]);
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data ibu tidak ditemukan' });

    res.json({ message: 'Berhasil mengambil data ibu', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// 3. POST
router.post('/', async (req, res, next) => {
  try {
    const kurang = cekBodyWajib(req.body);
    if (kurang.length > 0) {
      return res.status(400).json({ message: `Kolom wajib belum diisi: ${kurang.join(', ')}` });
    }

    const { nik, nama, tanggal_lahir, alamat, no_hp, status_kehamilan, hpl } = req.body;
    const result = await pool.query(
      `INSERT INTO ibu (nik, nama, tanggal_lahir, alamat, no_hp, status_kehamilan, hpl)
       VALUES ($1, $2, $3, $4, $5, COALESCE($6, 'tidak_hamil'), $7)
       RETURNING *`,
      [nik, nama, tanggal_lahir, alamat ?? null, no_hp ?? null, status_kehamilan ?? null, hpl ?? null]
    );
    res.status(201).json({ message: 'Data ibu berhasil dibuat', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// 4. PUT
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!idValid(id)) return res.status(400).json({ message: 'ID harus berupa angka' });

    const kurang = cekBodyWajib(req.body);
    if (kurang.length > 0) {
      return res.status(400).json({ message: `Kolom wajib belum diisi: ${kurang.join(', ')}` });
    }

    const { nik, nama, tanggal_lahir, alamat, no_hp, status_kehamilan, hpl } = req.body;
    const result = await pool.query(
      `UPDATE ibu
       SET nik = $1, nama = $2, tanggal_lahir = $3, alamat = $4, no_hp = $5,
           status_kehamilan = COALESCE($6, 'tidak_hamil'), hpl = $7
       WHERE id_ibu = $8
       RETURNING *`,
      [nik, nama, tanggal_lahir, alamat ?? null, no_hp ?? null, status_kehamilan ?? null, hpl ?? null, id]
    );
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data ibu tidak ditemukan' });

    res.json({ message: 'Data ibu berhasil diperbarui', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// 5. DELETE
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!idValid(id)) return res.status(400).json({ message: 'ID harus berupa angka' });

    const result = await pool.query('DELETE FROM ibu WHERE id_ibu = $1 RETURNING *', [id]);
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data ibu tidak ditemukan' });

    res.json({ message: 'Data ibu berhasil dihapus', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
