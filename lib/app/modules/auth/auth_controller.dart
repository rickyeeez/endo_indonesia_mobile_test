import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final Rxn<User> user = Rxn<User>();
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAuthenticated => token.value.isNotEmpty;

  final String _baseUrl = 'http://10.0.2.2:8000/backend';

  @override
  void onInit() {
    super.onInit();
    tryAutoLogin();
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO 1: Hubungkan dengan API login PHP menggunakan HTTP POST
      // URL Endpoint: '$_baseUrl/login.php'
      // Payload JSON: {"email": email, "password": password}
      //
      // Ketentuan:
      // 1. Kirim HTTP POST request dengan headers Content-Type: application/json.
      // 2. Jika login berhasil (status code 200), parse respon JSON untuk mengambil token dan data user.
      // 3. Simpan token dan data user ke SharedPreferences (_authRepository.saveAuth()) agar persist setelah aplikasi ditutup.
      // 4. Set state local token.value dan user.value, lalu return true.
      // 5. Jika gagal (status code 400+, 500), tangkap pesan error dari response API dan throw exception.
      // Hint : https://www.geeksforgeeks.org/flutter/flutter-make-an-http-post-request/
      return true;
    } catch (error) {
      errorMessage.value = error.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tryAutoLogin() async {
    // TODO 2: Cek apakah ada token & data user yang tersimpan di SharedPreferences
    // Jika ada, muat kembali ke variabel token.value dan user.value untuk bypass halaman login.
    _authRepository.getToken();
  }

  Future<void> logout() async {
    // TODO 3: Bersihkan data login (token & user) dari SharedPreferences saat logout
  }
}
