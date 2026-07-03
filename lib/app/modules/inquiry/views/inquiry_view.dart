import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../inquiry_controller.dart';
import '../../catalog/catalog_controller.dart';
import '../../../routes/app_routes.dart';

class InquiryView extends GetView<InquiryController> {
  const InquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _hospitalController = TextEditingController();
    final _emailController = TextEditingController();
    final catalog = Get.find<CatalogController>();

    void showInquiryForm() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formulir Permintaan Penawaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // TODO 14: Implementasikan Validasi Input
                    // 1. Nama Lengkap: Wajib diisi, minimal 3 karakter.
                    // 2. Nama Rumah Sakit: Wajib diisi.
                    // 3. Email: Wajib diisi dan harus menggunakan format email yang valid.

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: 'Rumah Sakit / Instansi',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Kontak',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tombol Kirim / Submit
                    Obx(() {
                      final submitting = controller.isSubmitting.value;

                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: submitting
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final success =
                                      await controller.sendInquiry(
                                    name: _nameController.text.trim(),
                                    hospitalName:
                                        _hospitalController.text.trim(),
                                    email: _emailController.text.trim(),
                                  );

                                  if (success) {
                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                      Get.snackbar(
                                        'Berhasil',
                                        'Permintaan penawaran berhasil dikirim!',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                      catalog.loadDevices();
                                    }
                                  } else {
                                    if (ctx.mounted) {
                                      Get.snackbar(
                                        'Gagal',
                                        controller
                                                    .errorMessage
                                                    .value
                                                    .isNotEmpty &&
                                                controller
                                                        .errorMessage.value !=
                                                    ''
                                            ? controller.errorMessage.value
                                            : 'Gagal mengirim permintaan.',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                },
                          child: submitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Kirim Pengajuan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Penawaran'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final cartList = controller.items.values.toList();

        if (cartList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada alat medis yang diajukan.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartList.length,
                itemBuilder: (ctx, i) {
                  final item = cartList[i];

                  // Cari data stok maksimum dari katalog
                  int maxStock = 99;
                  try {
                    final matchedDevice =
                        catalog.items.firstWhere((d) => d.id == item.id);
                    maxStock = matchedDevice.stock;
                  } catch (_) {}

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(item.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Estimasi Satuan: \$${item.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Kurang (-)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              try {
                                controller.updateQuantity(
                                    item.id, item.quantity - 1, maxStock);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e
                                      .toString()
                                      .replaceAll('Exception: ', ''),
                                );
                              }
                            },
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          // Tombol Tambah (+)
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              try {
                                // TODO 15: Di sini memanggil updateQuantity dengan menambahkan 1.
                                // Pengecekan kuantitas maksimum harus divalidasi terhadap maxStock di controller.
                                controller.updateQuantity(
                                    item.id, item.quantity + 1, maxStock);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e
                                      .toString()
                                      .replaceAll('Exception: ', ''),
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                          // Tombol Hapus (sampah)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.grey),
                            onPressed: () {
                              controller.removeItem(item.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Area Ringkasan Total & Pengiriman
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimasi Total:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${controller.totalEstimate.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => showInquiryForm(),
                        child: const Text(
                          'Ajukan Penawaran Harga',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
