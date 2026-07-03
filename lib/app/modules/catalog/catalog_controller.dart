import 'package:get/get.dart';
import '../../data/models/medical_device.dart';
import '../../data/repositories/device_repository.dart';

class CatalogController extends GetxController {
  final DeviceRepository _deviceRepository;

  CatalogController({DeviceRepository? deviceRepository})
      : _deviceRepository = deviceRepository ?? DeviceRepository();

  final RxList<MedicalDevice> devices = <MedicalDevice>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString errorMessage = ''.obs;

  // Getter untuk daftar alat medis yang sudah difilter
  List<MedicalDevice> get items {
    List<MedicalDevice> filteredList = [...devices];

    // Filter berdasarkan Pencarian Nama
    if (searchQuery.value.isNotEmpty) {
      filteredList = filteredList
          .where((device) => device.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // TODO: [TUGAS 3 - FILTER KATEGORI] Implementasikan Filter Berdasarkan Kategori Alat Medis
    // Jika selectedCategory.value bukan 'All', saring filteredList agar hanya mengembalikan alat medis
    // yang kategorinya cocok dengan selectedCategory.value (case-insensitive).

    return filteredList;
  }

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedDevices = await _deviceRepository.fetchDevices();

      // TODO: [TUGAS 4 - LOAD BOOKMARK] Muat daftar favorit/bookmark dari SharedPreferences
      // Dapatkan list string ID yang difavoritkan (misal key: 'favorite_devices')
      // Tandai device.isFavorite = true untuk device yang ID-nya ada di daftar tersebut.
      final favList = await _deviceRepository.loadFavoriteIds();

      for (var device in fetchedDevices) {
        if (favList.contains(device.id)) {
          device.isFavorite = true;
        }
      }

      devices.value = fetchedDevices;
    } catch (error) {
      errorMessage.value = error.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final deviceIndex = devices.indexWhere((dev) => dev.id == id);
    if (deviceIndex >= 0) {
      final updatedDevice = devices[deviceIndex].copyWith(
        isFavorite: !devices[deviceIndex].isFavorite,
      );

      devices[deviceIndex] = updatedDevice;
      devices.refresh();

      // TODO: [TUGAS 4 - SAVE BOOKMARK] Simpan daftar favorit/bookmark secara permanen ke SharedPreferences
      // 1. Dapatkan instansi SharedPreferences.
      // 2. Baca daftar ID favorit saat ini.
      // 3. Tambahkan ID ini jika isFavorite=true, atau hapus jika false.
      // 4. Simpan kembali daftar tersebut sebagai StringList.
      final favIds = devices
          .where((d) => d.isFavorite)
          .map((d) => d.id)
          .toList();
      await _deviceRepository.saveFavoriteIds(favIds);
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }
}
