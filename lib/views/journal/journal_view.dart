import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Journal — coming soon', style: AppTextStyles.bodyMedium),
        ),
      ),
    );
  }
}
