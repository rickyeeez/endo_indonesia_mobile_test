import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/catalog/catalog_binding.dart';
import '../modules/catalog/views/catalog_view.dart';
import '../modules/device_detail/device_detail_binding.dart';
import '../modules/device_detail/views/device_detail_view.dart';
import '../modules/inquiry/inquiry_binding.dart';
import '../modules/inquiry/views/inquiry_view.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.catalog,
      page: () => const CatalogView(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: AppRoutes.deviceDetail,
      page: () => const DeviceDetailView(),
      binding: DeviceDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.inquiry,
      page: () => const InquiryView(),
      binding: InquiryBinding(),
    ),
  ];
}
