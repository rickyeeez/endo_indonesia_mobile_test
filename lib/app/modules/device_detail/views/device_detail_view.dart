import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../device_detail_controller.dart';
import '../../catalog/catalog_controller.dart';
import '../../inquiry/inquiry_controller.dart';

class DeviceDetailView extends GetView<DeviceDetailController> {
  const DeviceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final device = controller.device;
    final catalog = Get.find<CatalogController>();
    final inquiry = Get.find<InquiryController>();

    // ============================================================================================
    // TODO: [TUGAS 2 - DETAIL ALAT MEDIS] Desain Ulang Halaman Detail Alat Medis
    // ============================================================================================
    // UI di bawah ini sengaja dibuat basic/berantakan.
    // Kandidat dipersilakan mendesain ulang halaman ini sekreatif mungkin
    // agar terlihat menarik, profesional, dan informatif.
    //
    // Data yang tersedia dari objek `device` (MedicalDevice):
    //   - device.name         → Nama alat medis
    //   - device.category     → Kategori (Cardiology, ICU, Radiology)
    //   - device.price        → Harga estimasi (double)
    //   - device.stock        → Jumlah stok tersedia (int)
    //   - device.description  → Deskripsi alat medis
    //   - device.imageUrl     → URL gambar alat medis
    //   - device.specifications → Map<String, dynamic> spesifikasi teknis
    //   - device.isFavorite   → Status bookmark (sync dengan CatalogController)
    //
    // Fitur yang harus tetap berfungsi:
    //   - Bookmark/favorit (toggle via CatalogController)
    //   - Tombol "Tambah ke Penawaran" (addItem via InquiryController)
    //   - Jika stok habis (<= 0), tombol tambah harus disabled
    // ============================================================================================

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            final latestDevice = catalog.devices.firstWhere(
              (d) => d.id == device.id,
              orElse: () => device,
            );
            return IconButton(
              icon: Icon(
                latestDevice.isFavorite
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: Colors.orange,
              ),
              onPressed: () {
                catalog.toggleFavorite(device.id);
              },
            );
          }),
        ],
      ),
      // ============================================================================================
      // UI DI BAWAH INI SENGAJA DIBUAT BERANTAKAN / BASIC.
      // Kandidat HARUS mendesain ulang sesuai persyaratan di atas.
      // ============================================================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Gambar (mentah, tanpa styling) ---
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.grey.shade200,
              child: device.imageUrl.isNotEmpty
                  ? Image.network(
                      device.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    )
                  : const Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // --- Nama (plain text, kecil) ---
            Text(device.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),

            // --- Kategori (plain text biasa) ---
            Text('Kategori: ${device.category}'),
            const SizedBox(height: 4),

            // --- Harga (plain text) ---
            Text('Harga: \$${device.price.toStringAsFixed(2)}'),
            const SizedBox(height: 4),

            // --- Stok (plain text, tanpa indikator warna) ---
            Text('Stok: ${device.stock}'),
            const Divider(),

            // --- Deskripsi (langsung dump, tanpa heading card) ---
            const Text('Deskripsi:'),
            Text(device.description),
            const Divider(),

            // --- Spesifikasi (mentah, Row biasa) ---
            const Text('Spesifikasi:'),
            ...device.specifications.entries.map((e) =>
              Text('${e.key}: ${e.value}'),
            ),
            const SizedBox(height: 16),

            // --- Tombol tambah (basic ElevatedButton) ---
            ElevatedButton(
              onPressed: device.stock <= 0
                  ? null
                  : () {
                      try {
                        inquiry.addItem(device);
                        Get.snackbar(
                          'Berhasil',
                          '${device.name} ditambahkan.',
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          e.toString().replaceAll('Exception: ', ''),
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              child: const Text('Tambah ke Penawaran'),
            ),
          ],
        ),
      ),
    );
  }
}
