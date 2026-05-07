import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/log_trade_controller.dart';
import '../../domain/models/trade_direction.dart';
import '../../domain/models/trade_emotion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LogTradeView extends StatelessWidget {
  const LogTradeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LogTradeController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) c.previousStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: Obx(() => IconButton(
                icon: Icon(c.currentStep.value == 0 ? Icons.close : Icons.arrow_back),
                onPressed: c.previousStep,
              )),
          title: const Text('Log Trade'),
          actions: [
            Obx(() => c.currentStep.value == 0
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: Get.back,
                    child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  )),
          ],
        ),
        body: Column(
          children: [
            _StepIndicator(c: c),
            Expanded(
              child: PageView(
                controller: c.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1TradeDetails(c: c),
                  _Step2Result(c: c),
                  _Step3Checklist(c: c),
                  _Step4EmotionReason(c: c),
                ],
              ),
            ),
            _BottomBar(c: c),
          ],
        ),
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.c});
  final LogTradeController c;

  static const _labels = ['Details', 'Result', 'Checklist', 'Emotion'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = c.currentStep.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: List.generate(4, (i) {
            final isDone = i < step;
            final isActive = i == step;
            return Expanded(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: (isDone || isActive) ? AppColors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isDone || isActive) ? AppColors.black : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, color: AppColors.white, size: 14)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? AppColors.white : AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _labels[i],
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (i < 3)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: i < step ? AppColors.black : AppColors.border,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }
}

// ─── Step 1: Trade Details ────────────────────────────────────────────────────

class _Step1TradeDetails extends StatelessWidget {
  const _Step1TradeDetails({required this.c});
  final LogTradeController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What did you trade?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: c.pairController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'e.g. EURUSD'),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LogTradeController.commonPairs
                    .map((p) => _PairChip(pair: p, isSelected: c.pair.value == p, onTap: () => c.selectPair(p)))
                    .toList(),
              )),
          const SizedBox(height: 24),
          Text('Direction', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Obx(() => _SegmentedToggle(
                leftLabel: 'Buy',
                rightLabel: 'Sell',
                leftIcon: Icons.trending_up,
                rightIcon: Icons.trending_down,
                isLeft: c.direction.value == TradeDirection.buy,
                leftColor: AppColors.profit,
                rightColor: AppColors.loss,
                onLeftTap: () => c.direction.value = TradeDirection.buy,
                onRightTap: () => c.direction.value = TradeDirection.sell,
              )),
          const SizedBox(height: 24),
          Text('Position Size & Risk', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c.lotSizeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(hintText: 'Lot Size', labelText: 'Lot Size'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: c.riskController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(hintText: '1.0', labelText: 'Risk %', suffixText: '%'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Result ───────────────────────────────────────────────────────────

class _Step2Result extends StatelessWidget {
  const _Step2Result({required this.c});
  final LogTradeController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How did it go?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Obx(() => _SegmentedToggle(
                leftLabel: 'Win',
                rightLabel: 'Loss',
                leftIcon: Icons.trending_up,
                rightIcon: Icons.trending_down,
                isLeft: c.isWin.value,
                leftColor: AppColors.profit,
                rightColor: AppColors.loss,
                onLeftTap: () => c.isWin.value = true,
                onRightTap: () => c.isWin.value = false,
              )),
          const SizedBox(height: 24),
          Text('Result in R', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Obx(() => TextField(
                controller: c.resultController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                decoration: InputDecoration(
                  hintText: '0.00',
                  labelText: 'Result',
                  prefixText: c.isWin.value ? '+' : '−',
                  prefixStyle: TextStyle(
                    color: c.isWin.value ? AppColors.profit : AppColors.loss,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: c.isWin.value ? AppColors.profit : AppColors.loss,
                      width: 1.5,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Obx(() {
            final raw = double.tryParse(c.resultController.text) ?? 0;
            final isWin = c.isWin.value;
            final display = raw == 0 ? '—' : '${isWin ? "+" : "−"}${raw.toStringAsFixed(2)}R';
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isWin ? AppColors.profitLight : AppColors.lossLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    display,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isWin ? AppColors.profit : AppColors.loss,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Result', style: AppTextStyles.labelMedium),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Step 3: Checklist ────────────────────────────────────────────────────────

class _Step3Checklist extends StatelessWidget {
  const _Step3Checklist({required this.c});
  final LogTradeController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pre-trade checklist', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text('Be honest — this is what builds discipline.', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          Obx(() => _ChecklistRow(
                label: 'Followed my strategy',
                value: c.followedStrategy.value,
                onChanged: (v) => c.followedStrategy.value = v ?? false,
              )),
          const Divider(),
          Obx(() => _ChecklistRow(
                label: 'Risk was controlled',
                value: c.riskControlled.value,
                onChanged: (v) => c.riskControlled.value = v ?? false,
              )),
          const Divider(),
          Obx(() => _ChecklistRow(
                label: 'Valid setup',
                value: c.validSetup.value,
                onChanged: (v) => c.validSetup.value = v ?? false,
              )),
          const SizedBox(height: 24),
          Obx(() {
            final count = (c.followedStrategy.value ? 1 : 0) +
                (c.riskControlled.value ? 1 : 0) +
                (c.validSetup.value ? 1 : 0);
            final color = count == 3
                ? AppColors.profit
                : count >= 1
                    ? AppColors.warning
                    : AppColors.textTertiary;
            final bg = count == 3
                ? AppColors.profitLight
                : count >= 1
                    ? AppColors.warningLight
                    : AppColors.border;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(
                    count == 3 ? Icons.verified_rounded : Icons.pending_rounded,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$count of 3 rules followed',
                    style: AppTextStyles.titleSmall.copyWith(color: color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
            Checkbox(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ─── Step 4: Emotion & Reason ─────────────────────────────────────────────────

class _Step4EmotionReason extends StatelessWidget {
  const _Step4EmotionReason({required this.c});
  final LogTradeController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How did you feel?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          Obx(() => GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: TradeEmotion.values
                    .map((e) => _EmotionCard(
                          emotion: e,
                          isSelected: c.emotion.value == e,
                          onTap: () => c.emotion.value = e,
                        ))
                    .toList(),
              )),
          const SizedBox(height: 24),
          Text('Reason', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          TextField(
            controller: c.reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Why did you take this trade? What did you see?',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  const _EmotionCard({required this.emotion, required this.isSelected, required this.onTap});
  final TradeEmotion emotion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.black : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              emotion.label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.c});
  final LogTradeController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLast = c.currentStep.value == 3;
      final enabled = c.canProceed && !c.isLoading.value;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: ElevatedButton(
            onPressed: enabled ? c.nextStep : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.black.withValues(alpha: 0.35),
              disabledForegroundColor: AppColors.white.withValues(alpha: 0.6),
            ),
            child: c.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                  )
                : Text(isLast ? 'Log Trade' : 'Continue'),
          ),
        ),
      );
    });
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _PairChip extends StatelessWidget {
  const _PairChip({required this.pair, required this.isSelected, required this.onTap});
  final String pair;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.black : AppColors.border),
        ),
        child: Text(
          pair,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIcon,
    required this.rightIcon,
    required this.isLeft,
    required this.leftColor,
    required this.rightColor,
    required this.onLeftTap,
    required this.onRightTap,
  });

  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;
  final bool isLeft;
  final Color leftColor;
  final Color rightColor;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _ToggleSide(label: leftLabel, icon: leftIcon, color: leftColor, isActive: isLeft, isLeft: true, onTap: onLeftTap)),
          Container(width: 1, color: AppColors.border),
          Expanded(child: _ToggleSide(label: rightLabel, icon: rightIcon, color: rightColor, isActive: !isLeft, isLeft: false, onTap: onRightTap)),
        ],
      ),
    );
  }
}

class _ToggleSide extends StatelessWidget {
  const _ToggleSide({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(13) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(13),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? color : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isActive ? color : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
