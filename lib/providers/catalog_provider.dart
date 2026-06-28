import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_device.dart';
import '../services/api_service.dart';

class CatalogProvider with ChangeNotifier {
  final ApiService _apiService;
  List<MedicalDevice> _devices = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Cardiology', 'ICU', 'Radiology'
  String? _errorMessage;

  CatalogProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // Getter untuk daftar alat medis
  List<MedicalDevice> get items {
    List<MedicalDevice> filteredList = [..._devices];

    // Filter berdasarkan Pencarian Nama
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((device) =>
              device.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // TODO: [TUGAS 3 - FILTER KATEGORI] Implementasikan Filter Berdasarkan Kategori Alat Medis
    // Jika _selectedCategory bukan 'All', saring filteredList agar hanya mengembalikan alat medis
    // yang kategorinya cocok dengan _selectedCategory (case-insensitive).
    
    return filteredList;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedDevices = await _apiService.fetchDevices();
      
      // TODO: [TUGAS 4 - LOAD BOOKMARK] Muat daftar favorit/bookmark dari SharedPreferences
      // Dapatkan list string ID yang difavoritkan (misal key: 'favorite_devices')
      // Tandai device.isFavorite = true untuk device yang ID-nya ada di daftar tersebut.
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_devices') ?? [];

      for (var device in fetchedDevices) {
        if (favList.contains(device.id)) {
          device.isFavorite = true;
        }
      }

      _devices = fetchedDevices;
    } catch (error) {
      _errorMessage = error.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final deviceIndex = _devices.indexWhere((dev) => dev.id == id);
    if (deviceIndex >= 0) {
      final updatedDevice = _devices[deviceIndex].copyWith(
        isFavorite: !_devices[deviceIndex].isFavorite
      );
      
      _devices[deviceIndex] = updatedDevice;
      notifyListeners();

      // TODO: [TUGAS 4 - SAVE BOOKMARK] Simpan daftar favorit/bookmark secara permanen ke SharedPreferences
      // 1. Dapatkan instansi SharedPreferences.
      // 2. Baca daftar ID favorit saat ini.
      // 3. Tambahkan ID ini jika isFavorite=true, atau hapus jika false.
      // 4. Simpan kembali daftar tersebut sebagai StringList.
      final prefs = await SharedPreferences.getInstance();
      
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
