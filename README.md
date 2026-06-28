# Proyek Tes Rekrutmen Mobile Developer - ENDO Indonesia

Selamat datang di proyek tes pemrograman untuk calon Mobile Developer di **ENDO Indonesia**. Tes ini dirancang untuk menguji keahlian Anda dalam pengembangan aplikasi menggunakan Flutter, manajemen state, integrasi API, persistensi data lokal, serta penulisan & perbaikan pengujian (testing).

---

## Deskripsi Skenario Proyek

Anda ditugaskan untuk mengembangkan aplikasi **"Katalog Alat Medis & Permintaan Penawaran (Medical Device Catalog & Quote Inquiry)"** untuk ENDO Indonesia. Karena alat-alat medis berharga tinggi, pengguna tidak langsung membelinya melalui pembayaran elektronik, melainkan mengajukan **Permintaan Penawaran Harga (Inquiry)**.

Aplikasi ini sudah memiliki kerangka dasar (*boilerplate*) yang mencakup:
1. Alur halaman login.
2. Tampilan katalog alat medis dengan pencarian dan filter chip.
3. Keranjang pengajuan penawaran harga.
4. Kode pengujian otomatis (Unit & Widget testing).
5. Folder backend berbasis PHP dengan koneksi database MySQL.

Tugas Anda adalah melengkapi fitur-fitur yang masih kosong, memperbaiki bug logika yang sengaja disisipkan, menghubungkan aplikasi dengan backend PHP, dan memastikan seluruh tes otomatis lulus.

---

## Panduan Setup & Menjalankan Proyek

### 1. Setup Backend PHP & Database MySQL

Backend PHP diletakkan pada folder `/backend` di root proyek ini.

1. **Persiapan Database**:
   - Aktifkan MySQL server Anda (misal menggunakan XAMPP, Laragon, atau MySQL installer lokal).
   - Masuk ke tool database management Anda (seperti phpMyAdmin, DBeaver, dll).
   - Buat database baru bernama `endo_test_db`.
   - Impor struktur tabel dan seed data awal dari file `backend/db_setup.sql`.
   - Secara default, konfigurasi database di `backend/config.php` menggunakan user: `root` dan password: `''` (kosong). Silakan sesuaikan jika credential database Anda berbeda.

2. **Menjalankan Server PHP**:
   - Buka terminal/command prompt baru.
   - Arahkan ke direktori `backend` dari proyek ini:
     ```bash
     cd backend
     ```
   - Jalankan server PHP lokal bawaan pada port `8000`:
     ```bash
     php -S localhost:8000
     ```
   - Pastikan server PHP aktif di alamat `http://localhost:8000`. Anda bisa menguji endpoint ini di browser Anda: `http://localhost:8000/devices.php` (mungkin terdapat simulasi error 500 acak saat memuat halaman, cukup refresh untuk melihat datanya).

### 2. Setup Aplikasi Flutter

1. Jalankan perintah untuk mengunduh seluruh dependensi paket:
   ```bash
   flutter pub get
   ```
2. Jalankan aplikasi pada simulator/emulator atau perangkat fisik Anda:
   ```bash
   flutter run
   ```
   > **Catatan Penting Emulator Android**: 
   > Di dalam kode Flutter, URL API diarahkan ke `http://10.0.2.2:8000/backend` agar emulator Android dapat berkomunikasi dengan `localhost` komputer Anda. Jika Anda menggunakan iOS Simulator atau perangkat fisik, pastikan Anda mengubah alamat IP tersebut di `AuthProvider`, `CatalogProvider`, dan `ApiService` menggunakan IP lokal komputer Anda (misal: `http://192.168.x.x:8000/backend`).

---

## Daftar Tugas Kandidat (TO-DO List)

Selesaikan tugas-tugas berikut di dalam kode Flutter (ikuti tanda komentar `// TODO` yang tersebar di codebase):

### [TUGAS 1] Integrasi API Autentikasi (Login & Auto-Login)
*Berkas target: [auth_provider.dart](file:///lib/providers/auth_provider.dart) & [login_screen.dart](file:///lib/screens/login_screen.dart)*
- Hubungkan tombol login di `LoginScreen` dengan API PHP melalui `login.php` di `AuthProvider`.
- Kirim request login dalam format JSON. Jika sukses, simpan token autentikasi dan detail data user secara lokal menggunakan `shared_preferences`.
- Implementasikan fitur **Auto-Login** di `tryAutoLogin()`, sehingga ketika aplikasi dibuka kembali, pengguna yang sudah login sebelumnya langsung diarahkan ke `CatalogScreen` tanpa harus mengisi form login lagi.
- Pastikan token dihapus dari penyimpanan lokal saat user menekan tombol Logout.

### [TUGAS 2] Halaman Detail Alat Medis (`DeviceDetailScreen`)
*Berkas target: [device_detail_screen.dart](file:///lib/screens/device_detail_screen.dart)*
- Desain halaman detail alat medis yang estetik dan informatif.
- Tampilkan deskripsi lengkap alat medis dan render data spesifikasi teknis (`specifications` yang bertipe `Map<String, dynamic>`) secara dinamis ke dalam bentuk **Tabel** (`Table` widget) atau layout tabular yang rapi.
- Hubungkan tombol "Tambah ke Penawaran" dan status bookmark (favorit) di halaman detail ini agar sinkron secara realtime dengan state di halaman katalog utama.

### [TUGAS 3] Penyaringan Kategori (Category Filtering)
*Berkas target: [catalog_provider.dart](file:///lib/providers/catalog_provider.dart)*
- Lengkapi logika getter `items` pada `CatalogProvider`. Saring daftar alat medis yang dikembalikan berdasarkan kategori terpilih dari horizontal chip filter (`Cardiology`, `ICU`, `Radiology`). Jika kategori terpilih adalah `All`, maka kembalikan semua data.

### [TUGAS 4] Persistensi Data Favorit/Bookmark Offline
*Berkas target: [catalog_provider.dart](file:///lib/providers/catalog_provider.dart)*
- Gunakan `shared_preferences` di dalam method `toggleFavorite` untuk menyimpan status favorit/bookmark alat medis secara permanen di memori lokal.
- Muat kembali data favorit ini saat aplikasi mengambil data dari server di `loadDevices()`, agar status bookmark tidak ter-reset saat aplikasi dimuat ulang.

### [TUGAS 5] Validasi Formulir & Submit Penawaran (Inquiry)
*Berkas target: [inquiry_screen.dart](file:///lib/screens/inquiry_screen.dart) & [inquiry_provider.dart](file:///lib/providers/inquiry_provider.dart)*
- Di halaman keranjang penawaran, saat tombol "Ajukan Penawaran Harga" ditekan, tampilkan dialog/bottom sheet formulir dengan validasi ketat:
  - **Nama Lengkap**: Wajib diisi, minimal 3 karakter.
  - **Rumah Sakit / Instansi**: Wajib diisi.
  - **Email Kontak**: Wajib diisi dan harus berformat alamat email yang valid.
- Jika form valid, kirim data pengajuan penawaran tersebut ke API PHP `submit_inquiry.php`. Format JSON yang dikirimkan harus mencakup data user beserta daftar item dan kuantitas yang diajukan.
- Jika pengiriman sukses, kosongkan keranjang penawaran, tampilkan pesan sukses, dan muat ulang katalog alat medis untuk memperbarui jumlah stok yang berkurang di server.

### [TUGAS 6] Perbaikan Logika Stok & Pengujian Otomatis
*Berkas target: [inquiry_provider.dart](file:///lib/providers/inquiry_provider.dart) & [unit_test.dart](file:///test/unit_test.dart)*
- Perbaiki bug logika pada `InquiryProvider`. Pastikan penambahan kuantitas barang ke keranjang penawaran (baik saat menekan tombol '+' di katalog maupun mengubah kuantitas di keranjang) **TIDAK** diperbolehkan melebihi jumlah stok alat medis yang tersedia di database. Jika melampaui stok, lemparkan `Exception`.
- Jalankan seluruh pengujian otomatis dengan perintah:
  ```bash
  flutter test
  ```
  Pastikan seluruh test cases di `test/unit_test.dart` dan `test/widget_test.dart` berhasil berjalan dengan status **PASS**.

---

## Tugas Bonus (Opsional - Fitur Tambahan)

Untuk kandidat yang ingin menunjukkan kemampuan lebih (nilai plus), Anda dapat menambahkan salah satu atau kedua fitur fungsional opsional berikut pada aplikasi:

1. **[FITUR BONUS 1] Bandingkan Alat Medis (Device Comparison Side-by-Side)**:
   - Buat fungsionalitas untuk membandingkan spesifikasi 2 alat medis secara berdampingan. 
   - Kandidat dapat menambahkan tombol "Pilih untuk Bandingkan" pada katalog, dan tombol "Bandingkan" yang akan membuka halaman baru (`DeviceComparisonScreen`) menampilkan tabel spesifikasi teknis kedua alat tersebut secara berdampingan (kolom kiri vs kolom kanan).
2. **[FITUR BONUS 2] Riwayat Permintaan Penawaran (Inquiry History)**:
   - Buat halaman baru (`InquiryHistoryScreen`) untuk menampilkan daftar permintaan penawaran harga yang pernah diajukan sebelumnya oleh pengguna.
   - Data riwayat ini bisa disimpan secara lokal menggunakan `SharedPreferences` (dalam bentuk JSON string list) setiap kali pengajuan penawaran berhasil dikirim.

---

## Kriteria Penilaian

Kandidat dinilai berdasarkan kriteria berikut:
1. **Fungsionalitas Kode**: Apakah semua tugas terselesaikan dan berfungsi tanpa error?
2. **Kualitas & Kebersihan Kode**: Penerapan clean code, penamaan variabel yang deskriptif, pemisahan layer logika/UI, serta efisiensi performa.
3. **Desain UI/UX (Aesthetics)**: Kerapian tata letak, kecocokan skema warna dengan profil medis, dan kenyamanan interaksi pengguna.
4. **Penanganan Error**: Bagaimana aplikasi menangani kondisi offline, timeout, atau kegagalan server API (error 500).
5. **Kesesuaian Pengujian**: Keberhasilan seluruh pengujian otomatis (`flutter test`).
