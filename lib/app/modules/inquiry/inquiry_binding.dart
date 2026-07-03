import 'package:get/get.dart';
import 'inquiry_controller.dart';

class InquiryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InquiryController>(() => InquiryController());
  }
}
