import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/insights_controller.dart';
import '../../services/premium_service.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/trade_direction.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (c.trades.isEmpty) return _EmptyState(c: c);
          return _Content(c: c);
        }),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(c: c)),
        SliverToBoxAdapter(child: _HeroCard(c: c)),
        SliverToBoxAdapter(child: _StatsRow(c: c)),
        SliverToBoxAdapter(child: _StreakCard(c: c)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('Recent Trades', style: AppTextStyles.titleMedium),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _TradeCard(trade: c.recentTrades[i]),
            childCount: c.recentTrades.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.c});
  final HomeController c;

  void _showCoachingSheet(BuildContext context) {
    final insights = Get.find<InsightsController>();
    final premium = Get.find<PremiumService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text('AI Coaching', style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (!premium.isPremium.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Pro to unlock personalised AI coaching after every trade session.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.snackbar('Coming Soon', 'Payment will be available soon!');
                        },
                        child: const Text('Upgrade to Pro'),
                      ),
                    ),
                  ],
                );
              }
              final summary = insights.coachingSummary.value;
              if (summary != null) {
                return Text(summary, style: AppTextStyles.bodyMedium.copyWith(height: 1.6));
              }
              if (insights.trades.isNotEmpty) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Text('Analysing your trades…', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                );
              }
              return Text(
                'Log your first trade to get a personalised coaching summary.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.greeting, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(c.firstName, style: AppTextStyles.displayMedium),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showCoachingSheet(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    final totalR = c.totalR;
    final rColor = totalR >= 0 ? AppColors.profit : AppColors.loss;
    final sign = totalR >= 0 ? '+' : '-';
    final abs = totalR.abs();
    final rFormatted = abs == abs.roundToDouble() ? abs.toInt().toString() : abs.toStringAsFixed(1);
    final rText = '$sign${rFormatted}R';

    final score = c.disciplineScore;
    final discColor = score >= 0.7 ? AppColors.profit : score >= 0.4 ? AppColors.warning : AppColors.loss;
    final winColor = c.winRate >= 0.5 ? AppColors.profit : AppColors.loss;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Performance', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rText,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: rColor,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Icon(
                  totalR >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 22,
                  color: rColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricRow(
                label: 'Win Rate',
                value: '${(c.winRate * 100).toStringAsFixed(0)}%',
                color: winColor,
              ),
              const SizedBox(width: 24),
              _MetricRow(
                label: 'Discipline',
                value: '${(score * 100).toStringAsFixed(0)}%',
                color: discColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(discColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatCard(label: 'Total Trades', value: '${c.totalTrades}'),
          const SizedBox(width: 12),
          _StatCard(label: 'Win Rate', value: '${(c.winRate * 100).toStringAsFixed(0)}%'),
          const SizedBox(width: 12),
          _StatCard(label: 'Avg Risk', value: '${c.avgRisk.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.statValue),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({required this.trade});
  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.direction == TradeDirection.buy;
    final dirColor = isBuy ? AppColors.profit : AppColors.loss;
    final isWin = trade.isProfit;
    final resultColor = isWin ? AppColors.profit : AppColors.loss;
    final resultBg = isWin ? AppColors.profitLight : AppColors.lossLight;
    final resultText = isWin ? '+${trade.result.toStringAsFixed(2)}R' : '${trade.result.toStringAsFixed(2)}R';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isBuy ? AppColors.profitLight : AppColors.lossLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                trade.direction.label.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dirColor, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trade.pair, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${trade.emotion.emoji} ${trade.emotion.label}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: resultBg, borderRadius: BorderRadius.circular(8)),
            child: Text(resultText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: resultColor)),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    final streak = c.currentStreak;
    final isWinStreak = streak > 0;
    final streakColor = streak > 0
        ? AppColors.profit
        : streak < 0
            ? AppColors.loss
            : AppColors.textSecondary;
    final streakLabel = streak > 0
        ? 'win streak 🔥'
        : streak < 0
            ? 'loss streak ❄️'
            : 'no streak yet';
    final isTiltRisk = streak <= -3;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Streak', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${streak.abs()}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: streakColor,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(streakLabel, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                if (isTiltRisk) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.loss.withValues(alpha: 0.10),
                      border: Border.all(color: AppColors.loss.withValues(alpha: 0.30)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.loss),
                        const SizedBox(width: 4),
                        Text('Tilt Risk', style: AppTextStyles.labelMedium.copyWith(color: AppColors.loss)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BestStat(label: 'Best win', value: '${c.bestWinStreak}'),
              const SizedBox(height: 8),
              _BestStat(label: 'Best loss', value: '${c.bestLossStreak}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BestStat extends StatelessWidget {
  const _BestStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(c: c),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 20),
                Text('No trades yet', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Log your first trade to start\ntracking your discipline.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
