import 'package:get/get.dart';
import '../../data/models/medical_device.dart';
import '../../data/models/inquiry_item.dart';

class InquiryController extends GetxController {
  final RxMap<String, InquiryItem> items = <String, InquiryItem>{}.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  int get itemCount => items.length;

  final String _baseUrl = 'http://10.0.2.2:8000/backend';

  double get totalEstimate {
    var total = 0.0;
    items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  // Kirim Pengajuan Penawaran ke API backend PHP
  Future<bool> sendInquiry({
    required String name,
    required String hospitalName,
    required String email,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = '';

    try {
      // TODO 11: Implementasikan Pengiriman Inquiry ke PHP API 'submit_inquiry.php'
      // 1. Siapkan body payload JSON sesuai format backend:
      //    {
      //       "name": name,
      //       "hospital_name": hospitalName,
      //       "email": email,
      //       "items": [
      //          {"device_id": 1, "quantity": 2, "price": 1250.00},
      //          ...
      //       ]
      //    }
      // 2. Kirim HTTP POST request ke '$_baseUrl/submit_inquiry.php'
      // 3. Jika berhasil (status 201), kosongkan keranjang penawaran menggunakan clear() dan return true.
      // 4. Jika gagal, tangkap pesan error dari backend dan lempar exception.

      return true;
    } catch (error) {
      errorMessage.value = error.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void addItem(MedicalDevice device) {
    // Cek jika alat medis kehabisan stok sejak awal
    if (device.stock <= 0) {
      throw Exception('Stok alat medis habis.');
    }

    if (items.containsKey(device.id)) {
      // ---------------------------------------------------------------------------------
      // TODO 12: Kode di bawah ini memperbolehkan penambahan kuantitas melewati batas stok!
      // Kandidat harus memperbaikinya dengan menambahkan pengecekan stok yang valid,
      // misal jika kuantitas saat ini sudah menyamai device.stock maka harus men-throw Exception('Stok terbatas!').
      // ---------------------------------------------------------------------------------
      final existingItem = items[device.id]!;
      items[device.id] = InquiryItem(
        id: existingItem.id,
        name: existingItem.name,
        quantity: existingItem.quantity + 1,
        price: existingItem.price,
      );
    } else {
      items[device.id] = InquiryItem(
        id: device.id,
        name: device.name,
        quantity: 1,
        price: device.price,
      );
    }
  }

  // TODO 13: Buat fungsi untuk mengurangi/mengubah kuantitas item secara langsung di keranjang penawaran
  // Pastikan tetap melakukan validasi agar kuantitas tidak <= 0 dan tidak > stok alat medis yang tersedia.
  void updateQuantity(String id, int newQuantity, int maxStock) {
  }

  void removeItem(String productId) {
    items.remove(productId);
  }

  void clear() {
    items.clear();
  }
}
