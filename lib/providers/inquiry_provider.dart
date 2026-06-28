import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/medical_device.dart';

class InquiryItem {
  final String id;
  final String name;
  final int quantity;
  final double price;

  InquiryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

class InquiryProvider with ChangeNotifier {
  final Map<String, InquiryItem> _items = {};
  bool _isSubmitting = false;
  String? _errorMessage;

  Map<String, InquiryItem> get items => {..._items};
  int get itemCount => _items.length;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  final String _baseUrl = 'http://10.0.2.2:8000/backend';

  double get totalEstimate {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(MedicalDevice device) {
    // Cek jika alat medis kehabisan stok sejak awal
    if (device.stock <= 0) {
      throw Exception('Stok alat medis habis.');
    }

    if (_items.containsKey(device.id)) {
      // ---------------------------------------------------------------------------------
      // TODO: [BUG - TUGAS 6 - BATAS STOK ADD] Kode di bawah ini memperbolehkan penambahan kuantitas melewati batas stok!
      // Kandidat harus memperbaikinya dengan menambahkan pengecekan stok yang valid,
      // misal jika kuantitas saat ini sudah menyamai device.stock maka harus men-throw Exception('Stok terbatas!').
      // ---------------------------------------------------------------------------------
      _items.update(
        device.id,
        (existingItem) => InquiryItem(
          id: existingItem.id,
          name: existingItem.name,
          quantity: existingItem.quantity + 1, // BUG: Kuantitas bisa melebihi device.stock
          price: existingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        device.id,
        () => InquiryItem(
          id: device.id,
          name: device.name,
          quantity: 1,
          price: device.price,
        ),
      );
    }
    notifyListeners();
  }

  // TODO: [TUGAS 6 - BATAS STOK UPDATE] Buat fungsi untuk mengurangi/mengubah kuantitas item secara langsung di keranjang penawaran
  // Pastikan tetap melakukan validasi agar kuantitas tidak <= 0 dan tidak > stok alat medis yang tersedia.
  void updateQuantity(String id, int newQuantity, int maxStock) {
    if (newQuantity <= 0) {
      removeItem(id);
      return;
    }
    
    // Pengecekan batas stok
    if (newQuantity > maxStock) {
      throw Exception('Stok tidak mencukupi (Tersisa: $maxStock)');
    }

    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingItem) => InquiryItem(
          id: existingItem.id,
          name: existingItem.name,
          quantity: newQuantity,
          price: existingItem.price,
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Kirim Pengajuan Penawaran ke API backend PHP
  Future<bool> sendInquiry({
    required String name,
    required String hospitalName,
    required String email,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: [TUGAS 5 - SUBMIT INQUIRY API] Implementasikan Pengiriman Inquiry ke PHP API 'submit_inquiry.php'
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

      // --- SEMENTARA: Mock-up Request Sukses (Ubah/Hapus saat integrasi API) ---
      await Future.delayed(const Duration(milliseconds: 1500));
      if (email.contains('@')) {
        clear();
        return true;
      } else {
        throw Exception('Koneksi backend gagal. Hubungkan ke PHP API!');
      }
      // ------------------------------------------------------------------------

    } catch (error) {
      _errorMessage = error.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
