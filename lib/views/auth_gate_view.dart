import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';
import 'home_view.dart';

class AuthGateView extends StatelessWidget {
  const AuthGateView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final u = auth.user.value;
      if (u == null) return LoginView();
      return HomeView();
    });
  }
}
