import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Obx(() {
          final u = auth.user.value;
          return Text(u?.email ?? 'No user');
        }),
      ),
    );
  }
}
