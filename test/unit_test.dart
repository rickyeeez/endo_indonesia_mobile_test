import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endo_indonesia_mobile_test/app/data/models/medical_device.dart';
import 'package:endo_indonesia_mobile_test/app/data/providers/api_provider.dart';
import 'package:endo_indonesia_mobile_test/app/data/repositories/device_repository.dart';
import 'package:endo_indonesia_mobile_test/app/modules/auth/auth_controller.dart';
import 'package:endo_indonesia_mobile_test/app/modules/catalog/catalog_controller.dart';
import 'package:endo_indonesia_mobile_test/app/modules/inquiry/inquiry_controller.dart';

// Mocking ApiProvider untuk Unit Testing agar tidak menembak HTTP Request nyata
class MockApiProvider extends ApiProvider {
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
  // ===========================================================================
  // TUGAS 1 - AUTENTIKASI (AuthController)
  // ===========================================================================
  group('Unit Test - AuthController (TODO 1-3)', () {
    late AuthController auth;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      auth = AuthController();
    });

    test('Login berhasil dengan kredensial yang benar', () async {
      final result = await auth.login('kandidat@endo.co.id', 'password123');
      expect(result, true);
      expect(auth.isAuthenticated, true);
      expect(auth.user.value, isNotNull);
      expect(auth.user.value!.email, 'kandidat@endo.co.id');
    });

    test('Login gagal dengan kredensial yang salah', () async {
      final result = await auth.login('wrong@email.com', 'wrongpass');
      expect(result, false);
      expect(auth.isAuthenticated, false);
      expect(auth.user.value, isNull);
      expect(auth.errorMessage.value, isNotEmpty);
    });

    test('Logout harus menghapus data user dan token', () async {
      await auth.login('kandidat@endo.co.id', 'password123');
      expect(auth.isAuthenticated, true);

      await auth.logout();
      expect(auth.isAuthenticated, false);
      expect(auth.user.value, isNull);
      expect(auth.token.value, isEmpty);
    });

    test('Auto-login tanpa token tersimpan harus tetap tidak terotentikasi', () async {
      SharedPreferences.setMockInitialValues({});
      await auth.tryAutoLogin();
      expect(auth.isAuthenticated, false);
    });

    // -------------------------------------------------------------------------
    // TEST BERIKUT INI AKAN GAGAL secara default.
    // Kandidat harus mengimplementasikan TODO 1 dan TODO 2 agar test ini LULUS.
    // -------------------------------------------------------------------------
    test('Auto-login dengan token tersimpan harus mengembalikan status login', () async {
      // Simpan token palsu ke SharedPreferences
      SharedPreferences.setMockInitialValues({
        'user_token': 'mock_token_success_for_test',
      });

      final authWithToken = AuthController();
      await authWithToken.tryAutoLogin();

      expect(
        authWithToken.isAuthenticated,
        true,
        reason: 'Jika token tersimpan ada di SharedPreferences, tryAutoLogin harus mengembalikan isAuthenticated = true.',
      );
    });

    // -------------------------------------------------------------------------
    // TEST BERIKUT INI AKAN GAGAL secara default.
    // Kandidat harus mengimplementasikan TODO 3 agar test ini LULUS.
    // -------------------------------------------------------------------------
    test('Logout harus menghapus token dari SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'user_token': 'mock_token_success_for_test',
      });

      final authLogout = AuthController();
      await authLogout.login('kandidat@endo.co.id', 'password123');
      await authLogout.logout();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.containsKey('user_token'),
        false,
        reason: 'Setelah logout, key user_token harus dihapus dari SharedPreferences.',
      );
    });
  });

  // ===========================================================================
  // TUGAS 3 - FILTER KATEGORI (CatalogController)
  // ===========================================================================
  group('Unit Test - CatalogController (TODO 8)', () {
    test('Penyaringan kategori harus menyaring items berdasarkan kategori', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = CatalogController(
        deviceRepository: DeviceRepository(apiProvider: MockApiProvider()),
      );

      // 1. Muat perangkat dari Mock API
      await controller.loadDevices();
      expect(controller.items.length, 2);
      expect(controller.selectedCategory.value, 'All');

      // 2. Set Kategori ke 'Cardiology'
      controller.setCategory('Cardiology');
      expect(controller.selectedCategory.value, 'Cardiology');

      // 3. Verifikasi daftar items tersaring (AKAN GAGAL sebelum TODO 8 diselesaikan)
      expect(
        controller.items.length,
        1,
        reason: 'Setelah filter Cardiology, jumlah item harusnya 1.',
      );
      expect(
        controller.items.first.id,
        '101',
        reason: 'Item yang tersaring haruslah ECG Machine Cardiology dengan ID 101.',
      );
    });

    test('Filter kategori "All" harus menampilkan semua item', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = CatalogController(
        deviceRepository: DeviceRepository(apiProvider: MockApiProvider()),
      );
      await controller.loadDevices();

      controller.setCategory('All');
      expect(controller.items.length, 2);
    });
  });

  // ===========================================================================
  // TUGAS 4 - BOOKMARK / FAVORIT (CatalogController)
  // ===========================================================================
  group('Unit Test - CatalogController Bookmark (TODO 9-10)', () {
    test('Harus memuat daftar favorit dari SharedPreferences saat loadDevices', () async {
      // Simpan ID favorit palsu di SharedPreferences
      SharedPreferences.setMockInitialValues({
        'favorite_devices': ['102'],
      });

      final controller = CatalogController(
        deviceRepository: DeviceRepository(apiProvider: MockApiProvider()),
      );
      await controller.loadDevices();

      // Device 102 (ICU Ventilator) harus bertanda favorit
      final ventilator = controller.devices.firstWhere((d) => d.id == '102');
      expect(
        ventilator.isFavorite,
        true,
        reason: 'Device 102 harus bertanda favorite karena ID-nya ada di SharedPreferences.',
      );

      // Device 101 bukan favorit
      final ecg = controller.devices.firstWhere((d) => d.id == '101');
      expect(ecg.isFavorite, false);
    });

    // -------------------------------------------------------------------------
    // TEST BERIKUT INI AKAN GAGAL secara default.
    // Kandidat harus mengimplementasikan TODO 10 agar test ini LULUS.
    // -------------------------------------------------------------------------
    test('Toggle favorite harus menyimpan perubahan ke SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = CatalogController(
        deviceRepository: DeviceRepository(apiProvider: MockApiProvider()),
      );
      await controller.loadDevices();

      // Toggle favorit device 101
      await controller.toggleFavorite('101');

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_devices') ?? [];

      expect(
        favList.contains('101'),
        true,
        reason: 'Setelah toggle favorite, ID device harus tersimpan di SharedPreferences (key: favorite_devices).',
      );
    });

    test('Toggle favorite dua kali harus menghapus dari favorit', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = CatalogController(
        deviceRepository: DeviceRepository(apiProvider: MockApiProvider()),
      );
      await controller.loadDevices();

      // Toggle ON
      await controller.toggleFavorite('101');
      // Toggle OFF
      await controller.toggleFavorite('101');

      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_devices') ?? [];

      expect(
        favList.contains('101'),
        false,
        reason: 'Setelah toggle dua kali, ID device harus dihapus dari SharedPreferences.',
      );
    });
  });

  // ===========================================================================
  // TUGAS 5 - SUBMIT INQUIRY (InquiryController)
  // ===========================================================================
  group('Unit Test - InquiryController Submit Inquiry (TODO 11)', () {
    late InquiryController inquiry;

    setUp(() {
      inquiry = InquiryController();
    });

    test('Send inquiry berhasil dengan email valid', () async {
      inquiry.addItem(MedicalDevice(
        id: '1',
        name: 'Test Device',
        category: 'ICU',
        price: 500.0,
        description: 'Test',
        imageUrl: '',
        stock: 5,
        specifications: {},
      ));

      final result = await inquiry.sendInquiry(
        name: 'John Doe',
        hospitalName: 'RS Test',
        email: 'john@test.com',
      );

      expect(result, true);
      expect(inquiry.itemCount, 0, reason: 'Keranjang harus kosong setelah inquiry berhasil.');
    });

    test('Send inquiry gagal dengan email tidak valid', () async {
      final result = await inquiry.sendInquiry(
        name: 'John Doe',
        hospitalName: 'RS Test',
        email: 'invalidemail',
      );

      expect(result, false);
      expect(inquiry.errorMessage.value, isNotEmpty);
    });

    test('isSubmitting harus true selama proses pengiriman', () async {
      // Jalankan sendInquiry dan cek isSubmitting di tengah proses
      final future = inquiry.sendInquiry(
        name: 'Test',
        hospitalName: 'RS',
        email: 'test@test.com',
      );

      // isSubmitting harus true saat proses berjalan
      expect(inquiry.isSubmitting.value, true);

      await future;

      // isSubmitting harus false setelah selesai
      expect(inquiry.isSubmitting.value, false);
    });
  });

  // ===========================================================================
  // TUGAS 6 - BATAS STOK & KUANTITAS (InquiryController)
  // ===========================================================================
  group('Unit Test - InquiryController (TODO 12-13 - Batas Stok)', () {
    late InquiryController inquiryController;
    late MedicalDevice dummyDevice;

    setUp(() {
      inquiryController = InquiryController();
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
      inquiryController.addItem(dummyDevice);
      expect(inquiryController.itemCount, 1);
      expect(inquiryController.items['1']!.quantity, 1);
    });

    test('Item dengan stok 0 harus melempar exception', () {
      final outOfStock = MedicalDevice(
        id: '99',
        name: 'Out of Stock Device',
        category: 'ICU',
        price: 100.0,
        description: 'Empty stock',
        imageUrl: '',
        stock: 0,
        specifications: {},
      );

      expect(
        () => inquiryController.addItem(outOfStock),
        throwsA(isA<Exception>()),
        reason: 'Device dengan stok 0 tidak boleh ditambahkan ke keranjang.',
      );
    });

    test('Harus membatasi kuantitas agar TIDAK melebihi stok yang tersedia', () {
      inquiryController.addItem(dummyDevice);   // qty = 1
      inquiryController.addItem(dummyDevice);   // qty = 2
      inquiryController.addItem(dummyDevice);   // qty = 3 (batas)
      expect(inquiryController.items['1']!.quantity, 3);

      // -------------------------------------------------------------------------
      // TEST BERIKUT INI SEHARUSNYA MELEMPAR EXCEPTION (FAIL BY DEFAULT)
      // Kandidat harus mengimplementasikan TODO 12 agar test ini LULUS.
      // -------------------------------------------------------------------------
      expect(
        () => inquiryController.addItem(dummyDevice),
        throwsA(isA<Exception>()),
        reason: 'Harus melempar error jika kuantitas melebihi stok (stok: 3).',
      );
    });

    test('Fungsi updateQuantity harus memvalidasi batas maksimum stok', () {
      inquiryController.addItem(dummyDevice);

      // Update ke kuantitas valid (2)
      inquiryController.updateQuantity('1', 2, 3);
      expect(inquiryController.items['1']!.quantity, 2);

      // Update ke kuantitas tidak valid (4, melebihi maxStock)
      expect(
        () => inquiryController.updateQuantity('1', 4, 3),
        throwsA(isA<Exception>()),
        reason: 'Harus menolak update kuantitas jika melebihi batas stok maxStock.',
      );
    });

    test('updateQuantity ke 0 harus menghapus item dari keranjang', () {
      inquiryController.addItem(dummyDevice);
      expect(inquiryController.itemCount, 1);

      inquiryController.updateQuantity('1', 0, 3);
      expect(inquiryController.itemCount, 0);
    });

    test('removeItem harus menghapus item dari keranjang', () {
      inquiryController.addItem(dummyDevice);
      expect(inquiryController.itemCount, 1);

      inquiryController.removeItem('1');
      expect(inquiryController.itemCount, 0);
      expect(inquiryController.items.containsKey('1'), false);
    });

    test('clear harus mengosongkan seluruh keranjang', () {
      inquiryController.addItem(dummyDevice);
      inquiryController.addItem(MedicalDevice(
        id: '2',
        name: 'Another Device',
        category: 'ICU',
        price: 2000.0,
        description: 'Test',
        imageUrl: '',
        stock: 10,
        specifications: {},
      ));
      expect(inquiryController.itemCount, 2);

      inquiryController.clear();
      expect(inquiryController.itemCount, 0);
    });

    test('totalEstimate harus menghitung total harga dengan benar', () {
      inquiryController.addItem(dummyDevice); // 1 x 1000 = 1000
      inquiryController.addItem(dummyDevice); // qty = 2, still 1 item x 1000

      inquiryController.addItem(MedicalDevice(
        id: '2',
        name: 'Device B',
        category: 'ICU',
        price: 2500.0,
        description: '',
        imageUrl: '',
        stock: 5,
        specifications: {},
      )); // 1 x 2500

      // Total: (1000 x 2) + (2500 x 1) = 4500
      expect(inquiryController.totalEstimate, 4500.0);
    });
  });
}
