require('dotenv').config();
const { Pool, types } = require('pg');

// Agar kolom DATE 'YYYY-MM-DD' tidak otomatis dikonversi menjadi objek Date di JavaScript, tapi tetap menjadi string!
types.setTypeParser(1082, (val) => val); 

// Connection string dari Neon
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = pool;
