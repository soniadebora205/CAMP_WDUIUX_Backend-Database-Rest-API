require('dotenv').config();
const express = require('express');
const ibuRoutes = require('./routes/ibu');
const AnakRoutes = require('./routes/anak');

const app = express();
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'API Posyandu berjalan', endpoint: '/api/ibu' });
});

app.use('/api/ibu', ibuRoutes);

app.use('/api/anak', AnakRoutes);

// Kalau route tidak ditemukan
app.use((req, res) => {
  res.status(404).json({ message: 'Route tidak ditemukan' });
});

// Penanganan error
app.use((err, req, res, next) => {
  // kalau JSON di body Postman kurang (kurang { } , atau tanda kutip)
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ message: 'Format JSON tidak valid. Periksa tanda { }, koma, dan tanda kutip di body' });
  }

  // Kalau ada duplikat UNIQUE
  if (err.code === '23505') {
    return res.status(409).json({ message: 'Data duplikat: NIK sudah terdaftar' });
  }

  // Kalau foreign key tidak ditemukan
  if (err.code === '23503') {
    return res.status(409).json({ message: 'Data tidak ditemukan: ID Ibu tidak valid' });
  }

  // 22P02 / 22007 / 22008 = format nilai tidak valid (mis. tanggal salah)
  if (['22P02', '22007', '22008', '23514', '22001'].includes(err.code)) {
    return res.status(400).json({ message: 'Format nilai tidak valid. Periksa tipe data dan panjang karakter di body' });
  }
  console.error(err);
  res.status(500).json({ message: 'Terjadi kesalahan pada server' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
