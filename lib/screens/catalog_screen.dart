import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/inquiry_provider.dart';
import '../providers/auth_provider.dart';
import 'inquiry_screen.dart';
import 'device_detail_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<CatalogProvider>().loadDevices();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final inquiry = context.watch<InquiryProvider>();
    final auth = context.watch<AuthProvider>();

    final categories = ['All', 'Cardiology', 'ICU', 'Radiology'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Katalog Alat Medis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Shopping Cart / Inquiry Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.description_outlined),
                tooltip: 'Keranjang Penawaran',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const InquiryScreen()),
                  );
                },
              ),
              if (inquiry.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${inquiry.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Card
          if (auth.user != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    child: Text(auth.user!.name.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${auth.user!.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      Text(
                        auth.user!.email,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Alat Medis...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          catalog.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                catalog.setSearchQuery(value);
              },
            ),
          ),

          // Category Chips Horizontal Scroll
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: categories.length,
              itemBuilder: (ctx, idx) {
                final category = categories[idx];
                final isSelected = catalog.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.red.shade200,
                    checkmarkColor: Colors.red.shade900,
                    onSelected: (selected) {
                      catalog.setCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Catalog List Area
          Expanded(
            child: Builder(
              builder: (ctx) {
                if (catalog.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catalog.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                          const SizedBox(height: 16),
                          Text(
                            catalog.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => catalog.loadDevices(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = catalog.items;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada alat medis ditemukan.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final device = items[i];
                    final isOutOfStock = device.stock <= 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => DeviceDetailScreen(device: device),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Icon Medis / Foto representasi
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: device.imageUrl.isNotEmpty
                                      ? Image.network(
                                          device.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Icon(
                                            Icons.medical_services_outlined,
                                            size: 40,
                                            color: Colors.red.shade700,
                                          ),
                                        )
                                      : Icon(
                                          Icons.medical_services_outlined,
                                          size: 40,
                                          color: Colors.red.shade700,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info Detail Singkat
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        device.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      device.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Estimasi: \$${device.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Stock status
                                    isOutOfStock
                                        ? const Text(
                                            'Stok Habis (Inden)',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            'Tersedia: ${device.stock} unit',
                                            style: TextStyle(
                                              color: Colors.teal.shade900,
                                              fontSize: 12,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              // Tombol Aksi
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      device.isFavorite
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      catalog.toggleFavorite(device.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: isOutOfStock ? Colors.grey : Colors.red.shade700,
                                    ),
                                    onPressed: isOutOfStock
                                        ? null
                                        : () {
                                            try {
                                              inquiry.addItem(device);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${device.name} ditambahkan ke penawaran.'),
                                                  duration: const Duration(seconds: 1),
                                                ),
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
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
