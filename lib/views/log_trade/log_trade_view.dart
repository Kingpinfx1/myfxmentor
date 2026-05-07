import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_text_styles.dart';

class LogTradeView extends StatelessWidget {
  const LogTradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: Get.back,
        ),
        title: const Text('Log Trade'),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Log Trade — coming soon', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
