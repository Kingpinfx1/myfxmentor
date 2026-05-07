import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Insights — coming soon', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
