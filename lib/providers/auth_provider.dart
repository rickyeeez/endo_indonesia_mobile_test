import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Base URL backend PHP (Sesuaikan jika port/IP berbeda)
  // Tips: Di Android Emulator gunakan 'http://10.0.2.2:8000/backend' untuk mengakses localhost komputer
  final String _baseUrl = 'http://10.0.2.2:8000/backend';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: [TUGAS 1 - API LOGIN] Hubungkan dengan API login PHP menggunakan HTTP POST
      // URL Endpoint: '$_baseUrl/login.php'
      // Payload JSON: {"email": email, "password": password}
      //
      // Ketentuan:
      // 1. Kirim HTTP POST request dengan headers Content-Type: application/json.
      // 2. Jika login berhasil (status code 200), parse respon JSON untuk mengambil token dan data user.
      // 3. Simpan token dan data user ke SharedPreferences agar persist setelah aplikasi ditutup.
      // 4. Set state local _token dan _user, panggil notifyListeners(), lalu return true.
      // 5. Jika gagal (status code 400+, 500), tangkap pesan error dari response API dan throw exception.

      // --- SEMENTARA: Login Mock-up (HAPUS ATAU UBAH BAGIAN INI SAAT INTEGRASI DENGAN API) ---
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network delay
      if (email == 'kandidat@endo.co.id' && password == 'password123') {
        _token = 'mock_token_success_for_test';
        _user = User(id: 2, name: 'Kandidat Test (Mock)', email: email);
        notifyListeners();
        return true;
      } else {
        throw Exception('Email atau password salah (Mock). Hubungkan ke PHP API!');
      }
      // -------------------------------------------------------------------------------------

    } catch (error) {
      _errorMessage = error.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tryAutoLogin() async {
    // TODO: [TUGAS 1 - AUTO LOGIN] Cek apakah ada token & data user yang tersimpan di SharedPreferences
    // Jika ada, muat kembali ke variabel _token dan _user untuk bypass halaman login.
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_token')) {
      return;
    }
    
    // Implementasikan logika pembacaan data di sini
    
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    
    // TODO: [TUGAS 1 - LOGOUT] Bersihkan data login (token & user) dari SharedPreferences saat logout
    final prefs = await SharedPreferences.getInstance();
    
    notifyListeners();
  }
}
