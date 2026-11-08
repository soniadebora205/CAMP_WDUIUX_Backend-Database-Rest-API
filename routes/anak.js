const express = require('express');
const pool = require('../db');

const router = express.Router();

const KOLOM_WAJIB = ['id_ibu', 'nama', 'jenis_kelamin', 'tanggal_lahir'];

function idValid(id) {
  return /^\d+$/.test(id);
}

function cekBodyWajib(body) {
  return KOLOM_WAJIB.filter((k) => body[k] === undefined || body[k] === '');
}

// 1. GET semua data
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM anak ORDER BY id_anak');
    res.json({ message: 'Berhasil mengambil semua data anak', total: result.rowCount, data: result.rows });
  } catch (err) {
    next(err);
  }
});

// 2. GET berdasarkan ID
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!idValid(id)) return res.status(400).json({ message: 'ID harus berupa angka' });

    const result = await pool.query('SELECT * FROM anak WHERE id_anak = $1', [id]);
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data anak tidak ditemukan' });

    res.json({ message: 'Berhasil mengambil data anak', data: result.rows[0] });
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

    const { id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir } = req.body;
    const result = await pool.query(
      `INSERT INTO anak (id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir ?? null]
    );
    res.status(201).json({ message: 'Data anak berhasil dibuat', data: result.rows[0] });
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

    const { id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir } = req.body;
    const result = await pool.query(
      `UPDATE anak
       SET id_ibu = $1, nama = $2, jenis_kelamin = $3, tanggal_lahir = $4, berat_lahir = $5
       WHERE id_anak = $6
       RETURNING *`,
      [id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir ?? null, id]
    );
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data anak tidak ditemukan' });

    res.json({ message: 'Data anak berhasil diperbarui', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// 5. DELETE
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    if (!idValid(id)) return res.status(400).json({ message: 'ID harus berupa angka' });

    const result = await pool.query('DELETE FROM anak WHERE id_anak = $1 RETURNING *', [id]);
    if (result.rowCount === 0) return res.status(404).json({ message: 'Data anak tidak ditemukan' });

    res.json({ message: 'Data anak berhasil dihapus', data: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

module.exports = router;