import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/inquiry_provider.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
      ],
      child: MaterialApp(
        title: 'ENDO Indonesia Mobile Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            primary: Colors.red.shade700,
            secondary: Colors.red.shade900,
          ),
          useMaterial3: true,
        ),
        // Menentukan halaman awal berdasarkan status login
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            // Melakukan pengecekan token login saat pertama kali aplikasi dibuka
            return FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) {
                if (authResultSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // Jika sudah login, arahkan ke Katalog, jika belum arahkan ke Login
                return auth.isAuthenticated 
                    ? const CatalogScreen() 
                    : const LoginScreen();
              },
            );
          },
        ),
      ),
    );
  }
}
