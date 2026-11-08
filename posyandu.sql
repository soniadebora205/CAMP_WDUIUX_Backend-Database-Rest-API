-- master data
-- One-to-many dengan anak
CREATE TABLE ibu (
  id_ibu           SERIAL PRIMARY KEY,
  nik              CHAR(16) UNIQUE NOT NULL,
  nama             VARCHAR(100) NOT NULL,
  tanggal_lahir    DATE NOT NULL,
  alamat           TEXT,
  no_hp            VARCHAR(15),
  status_kehamilan VARCHAR(15) NOT NULL DEFAULT 'tidak_hamil'
    CHECK (status_kehamilan IN ('hamil', 'tidak_hamil')),
  hpl              DATE,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- master data
-- One-to-many dengan pemeriksaan_anak
CREATE TABLE anak (
  id_anak       SERIAL PRIMARY KEY,
  id_ibu        INT NOT NULL,
  nama          VARCHAR(100) NOT NULL,
  jenis_kelamin CHAR(1) NOT NULL CHECK (jenis_kelamin IN ('L', 'P')),
  tanggal_lahir DATE NOT NULL,
  berat_lahir   NUMERIC(4,2),
  CONSTRAINT fk_anak_ibu FOREIGN KEY (id_ibu)
    REFERENCES ibu (id_ibu) ON DELETE CASCADE ON UPDATE CASCADE
);

-- master data
CREATE TABLE jadwal_posyandu (
  id_jadwal     SERIAL PRIMARY KEY,
  nama_kegiatan VARCHAR(100) NOT NULL,
  tanggal       DATE NOT NULL,
  jam_mulai     TIME NOT NULL,
  jam_selesai   TIME NOT NULL,
  lokasi        VARCHAR(150) NOT NULL,
  keterangan    TEXT
);

-- master data
CREATE TABLE petugas (
  id_petugas   SERIAL PRIMARY KEY,
  nama_petugas VARCHAR(100) NOT NULL,
  jabatan      VARCHAR(10) NOT NULL CHECK (jabatan IN ('kader', 'bidan')),
  no_hp        VARCHAR(15)
);

-- master data
-- One-to-one dengan petugas
CREATE TABLE akun (
  id_akun       SERIAL PRIMARY KEY,
  id_petugas    INT NOT NULL UNIQUE,
  username      VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  peran         VARCHAR(10) NOT NULL CHECK (peran IN ('admin', 'kader', 'bidan')),
  CONSTRAINT fk_akun_petugas FOREIGN KEY (id_petugas)
    REFERENCES petugas (id_petugas) ON DELETE CASCADE ON UPDATE CASCADE
);

-- transaction
CREATE TABLE pemeriksaan_ibu (
  id_periksa            SERIAL PRIMARY KEY,
  id_ibu                INT NOT NULL,
  id_jadwal             INT NOT NULL,
  id_petugas            INT NOT NULL,
  berat_badan           NUMERIC(5,2),
  tekanan_darah         VARCHAR(10),
  lila                  NUMERIC(4,1),
  usia_kehamilan_minggu INT,
  catatan               TEXT,
  CONSTRAINT fk_pibu_ibu FOREIGN KEY (id_ibu)
    REFERENCES ibu (id_ibu) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pibu_jadwal FOREIGN KEY (id_jadwal)
    REFERENCES jadwal_posyandu (id_jadwal),
  CONSTRAINT fk_pibu_petugas FOREIGN KEY (id_petugas)
    REFERENCES petugas (id_petugas)
);

-- transaction
CREATE TABLE pemeriksaan_anak (
  id_periksa     SERIAL PRIMARY KEY,
  id_anak        INT NOT NULL,
  id_jadwal      INT NOT NULL,
  id_petugas     INT NOT NULL,
  berat_badan    NUMERIC(5,2),
  tinggi_badan   NUMERIC(5,1),
  lingkar_kepala NUMERIC(4,1),
  status_gizi    VARCHAR(10) NOT NULL DEFAULT 'baik'
    CHECK (status_gizi IN ('baik', 'kurang', 'buruk', 'lebih')),
  catatan        TEXT,
  CONSTRAINT fk_panak_anak FOREIGN KEY (id_anak)
    REFERENCES anak (id_anak) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_panak_jadwal FOREIGN KEY (id_jadwal)
    REFERENCES jadwal_posyandu (id_jadwal),
  CONSTRAINT fk_panak_petugas FOREIGN KEY (id_petugas)
    REFERENCES petugas (id_petugas)
);

-- master data
CREATE TABLE imunisasi (
  id_imunisasi   SERIAL PRIMARY KEY,
  nama_imunisasi VARCHAR(50) NOT NULL UNIQUE,
  keterangan     TEXT
);

-- transaction
-- many-to-many
-- (CATATAN: satu anak bisa menerima banyak vaksin, satu vaksin diberikan ke banyak anak;
--  dosis_ke memungkinkan vaksin yang sama dicatat berkali-kali)
CREATE TABLE riwayat_imunisasi (
  id_riwayat       SERIAL PRIMARY KEY,
  id_anak          INT NOT NULL,
  id_imunisasi     INT NOT NULL,
  id_jadwal        INT,
  dosis_ke         INT NOT NULL DEFAULT 1,
  tanggal_diberikan DATE NOT NULL,
  CONSTRAINT uq_riwayat UNIQUE (id_anak, id_imunisasi, dosis_ke),
  CONSTRAINT fk_riwayat_anak FOREIGN KEY (id_anak)
    REFERENCES anak (id_anak) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_riwayat_imunisasi FOREIGN KEY (id_imunisasi)
    REFERENCES imunisasi (id_imunisasi) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_riwayat_jadwal FOREIGN KEY (id_jadwal)
    REFERENCES jadwal_posyandu (id_jadwal) ON DELETE SET NULL
);


INSERT INTO ibu (nik, nama, tanggal_lahir, alamat, no_hp, status_kehamilan, hpl) VALUES
('3214010101900001', 'Siti Aminah',  '1992-03-14', 'Jl. Melati No. 5, Purwakarta',   '081234560001', 'hamil',       '2027-02-07'),
('3214010101910002', 'Rina Marlina', '1995-07-22', 'Jl. Mawar No. 12, Purwakarta',   '081234560002', 'tidak_hamil', NULL),
('3214010101930003', 'Dewi Lestari', '1993-11-05', 'Jl. Anggrek No. 8, Purwakarta',  '081234560003', 'hamil',       '2026-12-13');

INSERT INTO anak (id_ibu, nama, jenis_kelamin, tanggal_lahir, berat_lahir) VALUES
(1, 'Aisyah Putri', 'P', '2024-05-10', 3.10),
(2, 'Raka Pratama', 'L', '2025-02-18', 3.40),
(3, 'Naufal Hakim', 'L', '2023-09-01', 2.90);

INSERT INTO jadwal_posyandu (nama_kegiatan, tanggal, jam_mulai, jam_selesai, lokasi, keterangan) VALUES
('Posyandu Melati', '2026-10-18', '08:00', '11:00', 'Balai RW 03', 'Penimbangan dan imunisasi'),
('Posyandu Mawar',  '2026-11-01', '09:00', '12:00', 'Balai RW 05', 'Penimbangan balita dan pemeriksaan ibu hamil'),
('Posyandu Melati', '2026-11-15', '08:00', '11:00', 'Balai RW 03', 'Penimbangan dan imunisasi'),
('Posyandu Mawar',  '2026-11-22', '09:00', '12:00', 'Balai RW 05', 'Penimbangan balita');

INSERT INTO petugas (nama_petugas, jabatan, no_hp) VALUES
('Ani Wulandari',     'kader', '081500000001'),
('Bidan Lilis Suryani', 'bidan', '081500000002'),
('Maya Sari',         'kader', '081500000003');

INSERT INTO akun (id_petugas, username, password_hash, peran) VALUES
(1, 'ani.kader',  'hash_dummy_akun_1', 'admin'),
(2, 'lilis.bidan', 'hash_dummy_akun_2', 'bidan');

INSERT INTO pemeriksaan_ibu (id_ibu, id_jadwal, id_petugas, berat_badan, tekanan_darah, lila, usia_kehamilan_minggu, catatan) VALUES
(1, 1, 2, 62.5, '110/70', 25.0, 24, 'Kondisi baik'),
(3, 2, 2, 68.0, '120/80', 26.5, 34, 'Disarankan kontrol bidan');

INSERT INTO pemeriksaan_anak (id_anak, id_jadwal, id_petugas, berat_badan, tinggi_badan, lingkar_kepala, status_gizi, catatan) VALUES
(1, 1, 1, 12.00, 87.0, 47.5, 'baik',   'Perkembangan normal'),
(2, 1, 1, 10.20, 80.0, 47.0, 'baik',   'Sehat'),
(3, 2, 3, 12.00, 88.0, 48.0, 'kurang', 'Perlu pemantauan gizi');

INSERT INTO imunisasi (nama_imunisasi, keterangan) VALUES
('Hepatitis B',          'Diberikan segera setelah lahir'),
('BCG',                  'Mencegah tuberkulosis'),
('Polio',                'Tetes atau suntik, beberapa dosis'),
('DPT-HB-Hib',           'Difteri, pertusis, tetanus, hepatitis B, Hib'),
('Campak Rubella (MR)',  'Campak dan rubella');

INSERT INTO riwayat_imunisasi (id_anak, id_imunisasi, id_jadwal, dosis_ke, tanggal_diberikan) VALUES
(1, 1, NULL, 1, '2024-05-10'),
(1, 5, 1,    2, '2026-10-18'),
(2, 4, 1,    4, '2026-10-18'),
(3, 5, 2,    2, '2026-11-01');