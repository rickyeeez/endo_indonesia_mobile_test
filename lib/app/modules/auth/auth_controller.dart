import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
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
      // TODO: [TUGAS 1 - API LOGIN] Hubungkan dengan API login PHP menggunakan HTTP POST
      // URL Endpoint: '$_baseUrl/login.php'
      // Payload JSON: {"email": email, "password": password}
      //
      // Ketentuan:
      // 1. Kirim HTTP POST request dengan headers Content-Type: application/json.
      // 2. Jika login berhasil (status code 200), parse respon JSON untuk mengambil token dan data user.
      // 3. Simpan token dan data user ke SharedPreferences agar persist setelah aplikasi ditutup.
      // 4. Set state local token.value dan user.value, lalu return true.
      // 5. Jika gagal (status code 400+, 500), tangkap pesan error dari response API dan throw exception.

      // --- SEMENTARA: Login Mock-up (HAPUS ATAU UBAH BAGIAN INI SAAT INTEGRASI DENGAN API) ---
      await Future.delayed(const Duration(seconds: 1)); // Simulasi network delay
      if (email == 'kandidat@endo.co.id' && password == 'password123') {
        token.value = 'mock_token_success_for_test';
        user.value = User(id: 2, name: 'Kandidat Test (Mock)', email: email);
        return true;
      } else {
        throw Exception('Email atau password salah (Mock). Hubungkan ke PHP API!');
      }
      // -------------------------------------------------------------------------------------

    } catch (error) {
      errorMessage.value = error.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tryAutoLogin() async {
    // TODO: [TUGAS 1 - AUTO LOGIN] Cek apakah ada token & data user yang tersimpan di SharedPreferences
    // Jika ada, muat kembali ke variabel token.value dan user.value untuk bypass halaman login.
    final savedToken = await _authRepository.getToken();
    if (savedToken == null) return;

    final savedUser = await _authRepository.getUser();
    if (savedUser != null) {
      token.value = savedToken;
      user.value = savedUser;
    }
  }

  Future<void> logout() async {
    token.value = '';
    user.value = null;

    // TODO: [TUGAS 1 - LOGOUT] Bersihkan data login (token & user) dari SharedPreferences saat logout
    await _authRepository.clearAuth();
  }
}
