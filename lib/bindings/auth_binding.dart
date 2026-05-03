import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AuthController>(AuthController(Get.find()), permanent: true);
  }
}
