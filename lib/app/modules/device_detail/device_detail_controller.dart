import 'package:get/get.dart';
import '../../data/models/medical_device.dart';

class DeviceDetailController extends GetxController {
  late MedicalDevice device;

  @override
  void onInit() {
    super.onInit();
    device = Get.arguments as MedicalDevice;
  }
}
