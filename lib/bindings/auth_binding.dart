import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/insights_controller.dart';
import '../controllers/journal_controller.dart';
import '../controllers/profile_controller.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import '../services/trade_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumService>(() => PremiumService(), fenix: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AuthController>(AuthController(Get.find()), permanent: true);
    Get.put<TradeService>(TradeService(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put<JournalController>(JournalController(), permanent: true);
    Get.lazyPut<InsightsController>(() => InsightsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
