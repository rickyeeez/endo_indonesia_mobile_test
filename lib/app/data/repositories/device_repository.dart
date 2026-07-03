import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_device.dart';
import '../providers/api_provider.dart';

class DeviceRepository {
  final ApiProvider _apiProvider;
  static const _favKey = 'favorite_devices';

  DeviceRepository({ApiProvider? apiProvider})
      : _apiProvider = apiProvider ?? ApiProvider();

  Future<List<MedicalDevice>> fetchDevices() async {
    return _apiProvider.fetchDevices();
  }

  Future<List<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favKey) ?? [];
  }

  Future<void> saveFavoriteIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, ids);
  }
}
