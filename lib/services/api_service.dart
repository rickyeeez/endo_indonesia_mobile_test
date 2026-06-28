import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_device.dart';

class ApiService {
  // Base URL backend PHP (Sesuaikan jika port/IP berbeda)
  // Tips: Di Android Emulator gunakan 'http://10.0.2.2:8000/backend' untuk mengakses localhost komputer
  final String _baseUrl = 'http://10.0.2.2:8000/backend';

  Future<List<MedicalDevice>> fetchDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/devices.php'),
        headers: {"Accept": "application/json"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => MedicalDevice.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Gagal mengambil data.');
        }
      } else {
        // Menangkap error 500 dari simulasi backend PHP
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Gagal menghubungi server (${response.statusCode}).');
      }
    } catch (error) {
      // Re-throw exception agar ditangkap oleh CatalogProvider
      if (error.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Pastikan server PHP Anda berjalan.');
      }
      throw Exception('Gagal memuat data: ${error.toString().replaceAll('Exception: ', '')}');
    }
  }
}
