import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PaywallSheet extends StatelessWidget {
  const PaywallSheet({super.key, this.isModal = true});

  final bool isModal;

  static void showAsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallSheet(isModal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isModal) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const _PaywallContent(isModal: true),
      );
    }
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(child: _PaywallContent(isModal: false)),
    );
  }
}

class _PaywallContent extends StatefulWidget {
  const _PaywallContent({required this.isModal});
  final bool isModal;

  @override
  State<_PaywallContent> createState() => _PaywallContentState();
}

class _PaywallContentState extends State<_PaywallContent> {
  bool _isYearly = true;

  String get _price => _isYearly ? '\$39.99' : '\$4.99';
  String get _period => _isYearly ? '/ year' : '/ month';
  String get _equivalent => _isYearly ? '\$3.33 / mo — save 33%' : 'Billed monthly';

  void _onUpgrade() {
    if (widget.isModal) Get.back();
    Get.snackbar(
      'Coming Soon',
      'In-app purchases will be available soon. Stay tuned!',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable top section ──────────────────────────────
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Column(
              children: [
                if (widget.isModal) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
                const SizedBox(height: 24),
                Image.asset('assets/images/logo.png', width: 68, height: 68),
                const SizedBox(height: 14),
                Text(
                  'Unlock your full trading potential',
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Get unlimited access to all features',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _FeatureRow(Icons.auto_awesome_rounded, 'AI Trade Review', 'Get AI feedback on each trade you log.'),
                _FeatureRow(Icons.all_inclusive_rounded, 'Unlimited Logging', 'Log every trade with no cap or restrictions.'),
                _FeatureRow(Icons.bar_chart_rounded, 'Deep Analytics', 'Win rates by pair, session, and time period.'),
                _FeatureRow(Icons.filter_list_rounded, 'Journal Filters', 'Filter trades by date, pair, direction, and result.'),
                _FeatureRow(Icons.psychology_rounded, 'Mindset Insights', 'See how your emotions affect your P&L.'),
                _FeatureRow(Icons.verified_rounded, 'Discipline Tracking', 'Measure the real cost of breaking your rules.'),
              ],
            ),
          ),
        ),

        // ── Pinned bottom section ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plan toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _PlanTab(
                      label: 'Monthly',
                      selected: !_isYearly,
                      onTap: () => setState(() => _isYearly = false),
                    ),
                    _PlanTab(
                      label: 'Yearly',
                      badge: 'BEST VALUE',
                      selected: _isYearly,
                      onTap: () => setState(() => _isYearly = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _price,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(_period, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _equivalent,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _isYearly ? AppColors.profit : AppColors.textTertiary,
                  fontWeight: _isYearly ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Upgrade to Pro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),

              if (widget.isModal) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: Get.back,
                  child: Text('Maybe later', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Plan Tab ─────────────────────────────────────────────────────────────────

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.label, required this.selected, required this.onTap, this.badge});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (badge != null) ...[
                const SizedBox(height: 2),
                Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.profit : AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feature Row ──────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.icon, this.label, this.subtitle);
  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelLarge),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle_rounded, color: AppColors.profit, size: 18),
        ],
      ),
    );
  }
}
