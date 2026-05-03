import 'package:get/get.dart';
import '../views/auth_gate_view.dart';
import '../views/register_view.dart';
import '../views/forgot_password_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.gate, page: () => const AuthGateView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
  ];
}
