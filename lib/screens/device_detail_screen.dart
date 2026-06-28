import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_device.dart';
import '../providers/inquiry_provider.dart';
import '../providers/catalog_provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final MedicalDevice device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // TODO: [TUGAS 2 - DETAIL ALAT MEDIS] Bangun Halaman Detail Alat Medis dengan Lengkap
    // Persyaratan Desain:
    // 1. Tampilkan gambar/ikon representasi alat medis yang berukuran besar dan estetik.
    // 2. Tampilkan Nama, Kategori, Harga Estimasi, dan status Stok Barang.
    // 3. Tampilkan Deskripsi Alat Medis secara rapi.
    // 4. Render tabel dinamis untuk menampilkan 'specifications' (Map<String, dynamic>).
    //    Tabel harus menyesuaikan baris secara otomatis sesuai dengan jumlah spesifikasi alat medis tersebut.
    // 5. Tambahkan tombol "Tambah ke Penawaran" di bagian bawah layar detail.
    // 6. Hubungkan status bookmark/favorit di halaman ini agar sinkron dengan halaman Katalog.
    
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              device.isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.orange,
            ),
            onPressed: () {
              context.read<CatalogProvider>().toggleFavorite(device.id);
              // Tips: Karena halaman ini StatelessWidget, untuk mendeteksi perubahan state bookmark secara langsung,
              // Anda mungkin perlu menjadikannya StatefulWidget atau mendengarkan perubahan dari provider.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SKELETON AWAL (Kandidat wajib mendesain ulang bagian ini agar menarik)
            Center(
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: device.imageUrl.isNotEmpty
                      ? Image.network(
                          device.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Icon(
                            Icons.medical_services_outlined,
                            size: 100,
                            color: Colors.red.shade700,
                          ),
                        )
                      : Icon(
                          Icons.medical_services_outlined,
                          size: 100,
                          color: Colors.red.shade700,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              device.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kategori: ${device.category}',
              style: TextStyle(fontSize: 16, color: Colors.red.shade900),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi Alat:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              device.description,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Spesifikasi Teknis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Contoh parsing spesifikasi sederhana (Kandidat harus mengubah ini menjadi bentuk Tabel/Grid yang indah)
            ...device.specifications.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(entry.value.toString()),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: device.stock <= 0
                    ? null
                    : () {
                        try {
                          context.read<InquiryProvider>().addItem(device);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${device.name} ditambahkan ke penawaran.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Tambah ke Penawaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
