import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'kandidat@endo.co.id');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // TODO: [TUGAS 1 - INTEGRASI UI LOGIN] Hubungkan tombol login dengan AuthProvider
    // 1. Panggil method login di AuthProvider.
    // 2. Tampilkan Loading Indicator selama proses berlangsung (Gunakan authProvider.isLoading).
    // 3. Jika login berhasil, lakukan navigasi ke CatalogScreen dan hapus stack navigasi sebelumnya (pushReplacement).
    // 4. Jika login gagal, tampilkan pesan error yang didapat dari API menggunakan SnackBar atau Dialog.
    // --- SEMENTARA: Navigasi Langsung (Hapus/Ubah logika ini agar memvalidasi ke AuthProvider) ---
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.runMockLoginOnlyTemp(email, password); // Ini method sementara
    
    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const CatalogScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Gagal login.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // ---------------------------------------------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi.';
                          }
                          if (!value.contains('@')) {
                            return 'Format email tidak valid.';
                          }
                          return null;
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi.';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      // Login Button
                      SizedBox(
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
                          onPressed: authProvider.isLoading ? null : _submit,
                          child: authProvider.isLoading
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
                      ),
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

// Extensi sementara untuk mempermudah pengerjaan tes kandidat sebelum dihubungkan secara benar
extension TemporaryMockLogin on AuthProvider {
  Future<bool> runMockLoginOnlyTemp(String email, String password) async {
    // Jalankan pemanggilan login bawaan untuk sementara waktu
    return await login(email, password);
  }
}
