import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/modules/auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InitialBinding().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return GetMaterialApp(
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
      initialRoute: auth.isAuthenticated ? AppRoutes.catalog : AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
