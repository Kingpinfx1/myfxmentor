import 'package:get/get.dart';
import '../views/auth_gate_view.dart';
import '../views/register_view.dart';
import '../views/forgot_password_view.dart';
import '../views/log_trade/log_trade_view.dart';
import '../controllers/log_trade_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.gate, page: () => const AuthGateView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(
      name: AppRoutes.logTrade,
      page: () => const LogTradeView(),
      binding: LogTradeBinding(),
      transition: Transition.downToUp,
    ),
  ];
}
