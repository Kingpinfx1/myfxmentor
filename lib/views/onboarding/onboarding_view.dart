import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      isLogo: true,
      icon: null,
      title: 'Your Trading Journal,\nReimagined',
      subtitle: 'Track every trade, find your edge, and become a more disciplined trader.',
    ),
    _SlideData(
      isLogo: false,
      icon: Icons.auto_awesome_rounded,
      title: 'AI-Powered Coaching',
      subtitle: 'Get a personalised summary of your trading patterns after every session.',
    ),
    _SlideData(
      isLogo: false,
      icon: Icons.psychology_rounded,
      title: 'Track Your Mindset',
      subtitle: 'See exactly how your emotions are costing or earning you money.',
    ),
    _SlideData(
      isLogo: false,
      icon: Icons.bar_chart_rounded,
      title: 'Find Your Edge',
      subtitle: 'Win rate by pair, discipline score, and cumulative performance at a glance.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    Get.offAllNamed(AppRoutes.gate);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : _complete,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _OnboardingSlide(data: _slides[i]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.black : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isLast ? 'Get Started' : 'Next',
                      key: ValueKey(isLast),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Slide Data ───────────────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({
    required this.isLogo,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final bool isLogo;
  final IconData? icon;
  final String title;
  final String subtitle;
}

// ─── Slide Widget ─────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});
  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Icon / Logo
          if (data.isLogo)
            Image.asset('assets/images/logo.png', width: 120, height: 120)
          else
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: Colors.white, size: 40),
            ),

          const SizedBox(height: 40),

          Text(
            data.title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          Text(
            data.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
