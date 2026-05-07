import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Profile — coming soon', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
