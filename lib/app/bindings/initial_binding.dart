import 'package:get/get.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/catalog/catalog_controller.dart';
import '../modules/inquiry/inquiry_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController());
    Get.put<CatalogController>(CatalogController());
    Get.put<InquiryController>(InquiryController());
  }
}
