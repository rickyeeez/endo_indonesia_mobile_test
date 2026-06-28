import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endo_indonesia_mobile_test/models/medical_device.dart';
import 'package:endo_indonesia_mobile_test/providers/catalog_provider.dart';
import 'package:endo_indonesia_mobile_test/providers/inquiry_provider.dart';
import 'package:endo_indonesia_mobile_test/services/api_service.dart';

// Mocking ApiService untuk Unit Testing agar tidak menembak HTTP Request nyata
class MockApiService extends ApiService {
  @override
  Future<List<MedicalDevice>> fetchDevices() async {
    return [
      MedicalDevice(
        id: '101',
        name: 'ECG Machine Cardiology',
        category: 'Cardiology',
        price: 1500.0,
        description: 'ECG Cardio Test',
        imageUrl: '',
        stock: 5,
        specifications: {},
      ),
      MedicalDevice(
        id: '102',
        name: 'ICU Ventilator',
        category: 'ICU',
        price: 3500.0,
        description: 'Ventilator Test',
        imageUrl: '',
        stock: 2,
        specifications: {},
      ),
    ];
  }
}

void main() {
  group('Unit Test - CatalogProvider', () {
    test('Penyaringan kategori (Category Filtering) harus menyaring items berdasarkan kategori', () async {
      // Mock SharedPreferences agar tidak error platform channel
      SharedPreferences.setMockInitialValues({});
      
      final provider = CatalogProvider(apiService: MockApiService());
      
      // 1. Muat perangkat dari Mock API
      await provider.loadDevices();
      expect(provider.items.length, 2);
      expect(provider.selectedCategory, 'All');

      // 2. Set Kategori ke 'Cardiology' (Tugas 3)
      provider.setCategory('Cardiology');
      expect(provider.selectedCategory, 'Cardiology');

      // 3. Verifikasi daftar items tersaring (TEST INI AKAN GAGAL sebelum Tugas 3 diselesaikan)
      expect(
        provider.items.length, 
        1,
        reason: 'Setelah filter Cardiology, jumlah item harusnya 1.',
      );
      expect(
        provider.items.first.id, 
        '101',
        reason: 'Item yang tersaring haruslah ECG Machine Cardiology dengan ID 101.',
      );
    });
  });

  group('Unit Test - InquiryProvider (Batas Stok & Kuantitas)', () {
    late InquiryProvider inquiryProvider;
    late MedicalDevice dummyDevice;

    setUp(() {
      inquiryProvider = InquiryProvider();
      dummyDevice = MedicalDevice(
        id: '1',
        name: 'ECG Machine Test',
        category: 'Cardiology',
        price: 1000.0,
        description: 'Test ECG',
        imageUrl: 'https://example.com/image.png',
        stock: 3, // Maksimum stok = 3
        specifications: {},
      );
    });

    test('Harus dapat menambahkan item baru ke keranjang penawaran', () {
      inquiryProvider.addItem(dummyDevice);
      expect(inquiryProvider.itemCount, 1);
      expect(inquiryProvider.items['1']!.quantity, 1);
    });

    test('Harus membatasi kuantitas agar TIDAK melebihi stok yang tersedia', () {
      // Tambahkan item pertama kali (quantity = 1)
      inquiryProvider.addItem(dummyDevice);
      
      // Tambahkan item kedua (quantity = 2)
      inquiryProvider.addItem(dummyDevice);
      
      // Tambahkan item ketiga (quantity = 3, batas maksimum tercapai)
      inquiryProvider.addItem(dummyDevice);
      expect(inquiryProvider.items['1']!.quantity, 3);

      // -------------------------------------------------------------------------
      // TEST BERIKUT INI SEHARUSNYA MELEMPAR EXCEPTION (FAIL BY DEFAULT)
      // Karena terdapat bug di InquiryProvider.addItem yang meloloskan kuantitas > stok.
      // Kandidat harus memperbaiki logic di InquiryProvider agar test ini LULUS.
      // -------------------------------------------------------------------------
      expect(
        () => inquiryProvider.addItem(dummyDevice),
        throwsA(isA<Exception>()),
        reason: 'Harus melempar error jika kuantitas melebihi stok (stok: 3).',
      );
    });

    test('Fungsi updateQuantity harus memvalidasi batas maksimum stok', () {
      inquiryProvider.addItem(dummyDevice);
      
      // Update ke kuantitas valid (2)
      inquiryProvider.updateQuantity('1', 2, 3);
      expect(inquiryProvider.items['1']!.quantity, 2);

      // Update ke kuantitas tidak valid (4, melebihi maxStock)
      expect(
        () => inquiryProvider.updateQuantity('1', 4, 3),
        throwsA(isA<Exception>()),
        reason: 'Harus menolak update kuantitas jika melebihi batas stok maxStock.',
      );
    });
  });
}
