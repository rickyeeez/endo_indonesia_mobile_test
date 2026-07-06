import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController(text: 'kandidat@endo.id');
    final _passwordController = TextEditingController(text: 'password123');

    void submit() async {
      if (!_formKey.currentState!.validate()) return;

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // TODO 4: Hubungkan tombol login dengan AuthController
      // 1. Panggil method login di AuthController.
      // 2. Tampilkan Loading Indicator selama proses berlangsung (Gunakan auth.isLoading.value).
      // 3. Jika login berhasil, lakukan navigasi ke CatalogScreen dan hapus stack navigasi sebelumnya (pushReplacement).
      // 4. Jika login gagal, tampilkan pesan error yang didapat dari API menggunakan SnackBar atau Dialog.

      final bool isSuccess = await controller.login("email", "password");
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade800,
              Colors.red.shade900,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / Icon
                      Icon(
                        Icons.medical_services,
                        size: 64.0,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'ENDO INDONESIA',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Portal Katalog Alat Medis',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        // TODO 5: Buat validasi untuk field email
                        // Ketentuan:
                        // Jika format email tidak valid (tidak mengandung '@'), tampilkan pesan "Format email tidak valid."
                        validator: (value) {
                          if(value == null || value == ''){
                            return 'Email wajib diisi.';
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        // TODO 6: Buat validasi untuk field password
                        // Ketentuan:
                        // 1. Jika password kosong, tampilkan pesan "Password wajib diisi."
                        // 2. Jika panjang password kurang dari 6 karakter, tampilkan pesan "Password minimal 6 karakter."
                        validator: (value) {

                        },
                      ),
                      const SizedBox(height: 24.0),
                      // Login Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 48.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed:
                                  controller.isLoading.value ? null : submit,
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text(
                                      'MASUK',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
