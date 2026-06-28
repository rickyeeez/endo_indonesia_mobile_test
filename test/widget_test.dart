import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:endo_indonesia_mobile_test/main.dart';
import 'package:endo_indonesia_mobile_test/screens/login_screen.dart';

void main() {
  testWidgets('Aplikasi harus menampilkan halaman Login pertama kali dibuka', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Bangun aplikasi MyApp
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verifikasi bahwa halaman Login ditampilkan
    expect(find.byType(LoginScreen), findsOneWidget);
    
    // Verifikasi keberadaan komponen utama login
    expect(find.text('ENDO INDONESIA'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });
}
