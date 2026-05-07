import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Home — coming soon', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
