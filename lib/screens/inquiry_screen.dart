import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inquiry_provider.dart';
import '../providers/catalog_provider.dart';

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showInquiryForm(BuildContext context, InquiryProvider inquiryProvider) {
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // TODO: [TUGAS 5 - VALIDASI FORM] Implementasikan Validasi Input
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
                      // Kandidat akan melengkapi validasi ini
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama lengkap harus diisi (Validasi awal)';
                      }
                      return null;
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
                      // Kandidat akan melengkapi validasi ini
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama Rumah Sakit harus diisi';
                      }
                      return null;
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
                      // Kandidat akan melengkapi validasi ini
                      if (value == null || value.trim().isEmpty) {
                        return 'Email harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Tombol Kirim / Submit
                  StatefulBuilder(
                    builder: (context, setModalState) {
                      final isSubmitting = inquiryProvider.isSubmitting;
                      
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  
                                  setModalState(() {});
                                  
                                  // Kirim inquiry
                                  final success = await inquiryProvider.sendInquiry(
                                    name: _nameController.text.trim(),
                                    hospitalName: _hospitalController.text.trim(),
                                    email: _emailController.text.trim(),
                                  );

                                  if (success) {
                                    if (context.mounted) {
                                      Navigator.of(context).pop(); // Tutup bottom sheet
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Permintaan penawaran berhasil dikirim!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      // Muat ulang daftar katalog untuk memperbarui stok barang
                                      context.read<CatalogProvider>().loadDevices();
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(inquiryProvider.errorMessage ?? 'Gagal mengirim permintaan.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Kirim Pengajuan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inquiry = context.watch<InquiryProvider>();
    final catalog = context.watch<CatalogProvider>();
    final cartList = inquiry.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Penawaran'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: cartList.isEmpty
          ? const Center(
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
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (ctx, i) {
                      final item = cartList[i];
                      
                      // Cari data stok maksimum dari katalog
                      int maxStock = 99;
                      try {
                        final matchedDevice = catalog.items.firstWhere((d) => d.id == item.id);
                        maxStock = matchedDevice.stock;
                      } catch (_) {}

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Estimasi Satuan: \$${item.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Kurang (-)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  try {
                                    inquiry.updateQuantity(item.id, item.quantity - 1, maxStock);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                    );
                                  }
                                },
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              // Tombol Tambah (+)
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                                onPressed: () {
                                  try {
                                    // TODO: [TUGAS 6 - VALIDASI KUANTITAS ADD] Di sini memanggil updateQuantity dengan menambahkan 1.
                                    // Pengecekan kuantitas maksimum harus divalidasi terhadap maxStock di provider.
                                    inquiry.updateQuantity(item.id, item.quantity + 1, maxStock);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString().replaceAll('Exception: ', '')),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                              // Tombol Hapus (sampah)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  inquiry.removeItem(item.id);
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${inquiry.totalEstimate.toStringAsFixed(2)}',
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
                            onPressed: () => _showInquiryForm(context, inquiry),
                            child: const Text(
                              'Ajukan Penawaran Harga',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
