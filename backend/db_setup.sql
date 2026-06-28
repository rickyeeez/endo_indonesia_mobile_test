-- Buat Database jika belum ada
CREATE DATABASE IF NOT EXISTS endo_test_db;
USE endo_test_db;

-- Hapus tabel jika sudah ada (untuk reset)
DROP TABLE IF EXISTS inquiry_items;
DROP TABLE IF EXISTS inquiries;
DROP TABLE IF EXISTS medical_devices;
DROP TABLE IF EXISTS users;

-- 1. Tabel Users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Medical Devices
CREATE TABLE medical_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    description TEXT,
    image_url VARCHAR(500), -- Kolom untuk URL Gambar Alat Medis
    stock INT NOT NULL,
    specifications JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabel Inquiries (Permintaan Penawaran)
CREATE TABLE inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    hospital_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Tabel Inquiry Items (Detail Permintaan Penawaran)
CREATE TABLE inquiry_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inquiry_id INT NOT NULL,
    device_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (inquiry_id) REFERENCES inquiries(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES medical_devices(id) ON DELETE CASCADE
);

-- Seed Data Users
-- Password default: 'password123'
INSERT INTO users (name, email, password) VALUES 
('HRD ENDO Indonesia', 'hrd@endo.co.id', '$2y$10$tPjG4v.1Yp8rV151R5GZ1O3dJv.e30Z0l87jU1Vf1Z6cR.cpePzK2'),
('Kandidat Test', 'kandidat@endo.co.id', '$2y$10$tPjG4v.1Yp8rV151R5GZ1O3dJv.e30Z0l87jU1Vf1Z6cR.cpePzK2');

-- Seed Data Medical Devices (Katalog yang lebih lengkap dengan URL Gambar Unsplash)
INSERT INTO medical_devices (name, category, price, description, image_url, stock, specifications) VALUES 
-- Kategori: Cardiology
( 
    'Aselsan Heartline AED Defibrillator', 
    'Cardiology', 
    NULL, 
    'Automated External Defibrillator portabel dengan keandalan analisis ritme patologis superior, integrasi pendeteksi artefak gerak somatik, dan komando audio CPR.', 
    'https://endo.id/id/storage/uploads/section/4117/heartline-aselsan.png',
    15, 
    '{"Waveform": "Truncated Biphasic Waveform", "Charge Time": "< 10 seconds", "Energy Protocols": "150J-200J-200J (Adult)", "Ingress Protection": "IP-55"}'
),
( 
    'ECG 3-Channel ECG-301', 
    'Cardiology', 
    NULL, 
    'Mesin perekam kelistrikan jantung 3 saluran portabel dengan rasio CMRR tinggi untuk mereduksi artefak serta bandwidth diagnostik yang lebar.', 
    NULL,
    10, 
    '{"CMRR": "> 140 dB", "Sampling Frequency": "16,000 Hz", "Diagnostic Bandwidth": "0.01 - 300 Hz", "Analysis": "SEMIP ECG algorithm"}'
),
( 
    'PC Based ECG ENDO PC ECG-1', 
    'Cardiology', 
    NULL, 
    'Modul elektrokardiogram berbasis PC 12-lead (dapat dikembangkan menjadi 15/16-lead) dengan interpretasi otomatis SEMIP dan perangkat lunak evaluasi aritmia.', 
    NULL,
    7, 
    '{"Sampling Rate": "16,000 Hz", "CMRR": "> 140 dB", "Bandwidth": "0.01 - 300 Hz", "A/D Converter": "24-bit"}'
),

-- Kategori: Pulmonology
( 
    'Spirometer Spirobank II', 
    'Pulmonology', 
    NULL, 
    'Spirometer portabel dengan uji real-time via USB dan koneksi nirkabel Bluetooth. Mendukung turbin FlowMIR sekali pakai untuk uji paru higienis.', 
    'https://endo.id/id/storage/uploads/section/1172/MIR-2015.png',
    22, 
    '{"Device Memory": "10,000 tests", "Data Connectivity": "Bluetooth/USB 2.0", "Battery": "Rechargeable (~40 hours)", "Software": "WinspiroPRO"}'
),
( 
    'Spirometer Spirolab New', 
    'Pulmonology', 
    NULL, 
    'Spirometer desktop dengan layar sentuh resolusi tinggi berukuran 7 inci, printer termal senyap, dan sistem animasi insentif khusus pasien pediatrik.', 
    NULL,
    5, 
    '{"Display": "7-inch Touchscreen LCD", "Printing Output": "Built-in thermal printer", "Database Memory": "10,000 tests", "Pediatric Feature": "On-screen incentive animations"}'
),
( 
    'Spirometer Spirodoc', 
    'Pulmonology', 
    NULL, 
    'Empat perangkat diagnostik dalam satu unit: spirometer, oksimeter cerdas, accelerometer 3D, dan kuesioner otomatis untuk rehabilitasi.', 
    NULL,
    12, 
    '{"Functions": "Spirometer, 3D Accelerometer, Questionnaire, Oximeter", "Memory": "10,000 tests", "Software": "WinspiroPRO", "Sensor": "Disposable FlowMIR"}'
),

-- Kategori: ICU / Pompa Medis
( 
    'Syringe Pump ENDO EI.SP', 
    'ICU', 
    NULL, 
    'Pompa jarum suntik mikro digital presisi tinggi dengan pengenalan otomatis ukuran jarum dan fungsi keselamatan seperti alarm oklusi serta KVO.', 
    'https://endo.id/id/storage/uploads/section/4121/ei-sp.png',
    25, 
    '{"Flow Rate Capability": "0.1 - 1200 ml/h", "Mechanism Accuracy": "± 1%", "Battery Reserve": "2 hours", "Alarms": "Occlusion, KVO, Near Empty"}'
),
( 
    'Infusion Pump ENDO EI.IP', 
    'ICU', 
    NULL, 
    'Pompa infus dengan mekanisme linear peristaltic finger penggerak laminar murni. Menampilkan data LCD berwarna dan sensor gelembung udara mikroskopik.', 
    'https://endo.id/id/storage/uploads/section/4121/ei-ip.png',
    30, 
    '{"Mechanism": "Linear Peristaltic Finger", "Flow Rate": "0.1 - 1000 ml/h", "Accuracy Tolerance": "± 2%", "Battery Reserve": "4 hours"}'
),
( 
    'Syringe Pump ENDO EI.SP3', 
    'ICU', 
    NULL, 
    'Pompa jarum suntik dengan layar sentuh 3.5 inci resolusi tinggi. Mendukung ukuran jarum 5ml hingga 50ml dengan deteksi otomatis dan mode titrasi multi-profil.', 
    NULL,
    14, 
    '{"Screen": "3.5 inch touch screen", "Flow Rate": "0.10 - 1500 ml/h", "Battery Capacity": "2600mAh", "KVO Rate": "0.10 - 5.00 ml/h"}'
),

-- Kategori: Surgery
( 
    'Electrosurgical Unit (ESU) Pulsar MB350', 
    'Surgery', 
    NULL, 
    'Generator elektrobedah frekuensi tinggi dengan portofolio pemrograman tingkat lanjut untuk intervensi terbuka dan laparoskopi, termasuk mode bipolar dalam saline.', 
    'https://endo.id/id/storage/uploads/section/2503/pulsar.png',
    8, 
    '{"Operating Frequency": "440kHz ± 10%", "Max Output (Pure Cut)": "350 W / 350 Ω", "Memory Slots": "33 presets", "Weight": "15 Kg"}'
),
( 
    'Electrosurgical Unit (ESU) Zeus Prime', 
    'Surgery', 
    NULL, 
    'Unit bedah listrik asal Korea dengan teknologi impedansi jaringan dan fitur vessel sealing otomatis. Mendukung operasi TURP dengan cairan saline.', 
    NULL,
    4, 
    '{"Main Frequency": "333 - 727kHz", "Power Consumption": "800VA", "Technology": "Tissue Impedance, Vessel Sealing", "Display": "8 inch touch screen"}'
),

-- Kategori: Endoscopy
( 
    'SonoScape HD-550 Video Endoscopy System', 
    'Endoscopy', 
    NULL, 
    'Sistem endoskopi definisi tinggi beresolusi 1080p, sumber pencahayaan 4-LED masa pakai panjang, serta mengandalkan teknologi SFI dan VIST chromoendoscopy.', 
    NULL,
    3, 
    '{"Resolution": "1080p via 2MP CMOS", "Light Source": "4-LED 10,000 hours", "Chromoendoscopy": "VIST and SFI Multi-mode", "Storage": "500GB HDD"}'
),
( 
    'SonoScape HD-350 Flexible Endoscopy System', 
    'Endoscopy', 
    NULL, 
    'Sistem video endoskopi gastrointestinal definisi tinggi dengan sensor gambar CMOS. Dilengkapi workstation terintegrasi dan fungsi waterjet pembersih.', 
    NULL,
    5, 
    '{"Image Sensor": "CMOS", "Light Source": "50W LED (HDL-35E)", "Video Outputs": "DVI, SDI, VGA, S-Video", "Workstation": "Built-in"}'
),

-- Kategori: Anesthesiology & Ventilator
( 
    'Anesthesia Machine ENDO AM3', 
    'Anesthesiology & Ventilator', 
    NULL, 
    'Mesin anestesi canggih untuk neonatus, pediatrik, hingga dewasa. Dilengkapi layar sentuh TFT 12 inci, vaporizer ganda, dan pengukuran aliran elektronik.', 
    NULL,
    4, 
    '{"Screen": "12 inch TFT touch screen", "Tidal Volume": "20ml - 1500ml", "Ventilation Modes": "VCV, PCV, SIMV-V, SIMV-P, PSV", "Battery Backup": "4 hours"}'
),
( 
    'ICU & Transport Ventilator ENDO V5', 
    'Anesthesiology & Ventilator', 
    NULL, 
    'Ventilator perawatan intensif bertenaga turbin yang ringkas dan ringan. Mendukung ventilasi invasif dan non-invasif untuk seluruh rentang usia pasien.', 
    NULL,
    6, 
    '{"Weight": "6.2 kg", "Screen": "10.4-inch color touch", "Min Tidal Volume": "2 ml", "Advanced Modes": "PRVC, APRV, BiPPV"}'
),
( 
    'ICU Ventilator ENDO V3', 
    'Anesthesiology & Ventilator', 
    NULL, 
    'Ventilator mekanis penunjang napas dengan kompresor internal rendah bising, katup pernapasan mudah disterilkan, dan layar antarmuka 10.4 inci.', 
    NULL,
    3, 
    '{"Screen": "10.4 inch TFT color", "Trigger": "Flow and pressure", "Special Functions": "Auto nebulizer, P-V loop, V-F loop"}'
),

-- Kategori: Suction Pump
( 
    'Portable Phlegm Suction Pump 7E-C', 
    'Suction Pump', 
    NULL, 
    'Pompa hisap portabel tanpa oli pelumas yang berfungsi membersihkan dahak dan cairan biologis seperti nanah serta darah dalam keadaan gawat darurat.', 
    NULL,
    20, 
    '{"Max Negative Pressure": ">= 0.075MPa", "Pumping Rate": ">= 15 L/min", "Reservoir Volume": "1000 mL", "Noise": "<= 65dB(A)"}'
),
( 
    'Suction Pump 7A-23B', 
    'Suction Pump', 
    NULL, 
    'Alat hisap cairan medis stasioner dengan dua tabung kaca berkapasitas masif 2500 ml. Memiliki pompa vakum bertenaga tinggi dan desain mobilitas beroda.', 
    NULL,
    12, 
    '{"Max Negative Pressure": ">= 0.09MPa", "Pumping Rate": ">= 40 L/min", "Reservoir Capacity": "2x 2500 mL", "Noise": "<= 65dB(A)"}'
),

-- Kategori: Radiology
( 
    'Ultrasound Diagnostic System EI.USGBW', 
    'Radiology', 
    NULL, 
    'Sistem USG hitam-putih mutakhir dengan dukungan monitor LED resolusi tinggi 15.6 inci yang dapat diputar, serta optimisasi algoritma i-Image, SRA, dan THI.', 
    NULL,
    2, 
    '{"Display": "15.6 inch Medical LED", "Gray Scale": "256 Levels", "Scanning Depth": "240mm Max", "Cine Loop": "256 frames"}'
),
( 
    'USG 4D Color Doppler EI.USG4D+EC.20', 
    'Radiology', 
    NULL, 
    'Sistem diagnostik USG Color Doppler 4D dengan teknologi Spatial Compound Imaging dan resolusi visual tinggi untuk diagnosis vaskular, abdomen, dan obstetri.', 
    NULL,
    2, 
    '{"Imaging Modes": "B, 2B, 4B, B/M, CFM, PW Mode", "Advanced Tech": "Real-time 4D, SRA, THI", "Probes Supported": "Convex, Linear, Transvaginal, 4D Volume"}'
);