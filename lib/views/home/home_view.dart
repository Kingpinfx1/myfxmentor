import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
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
        SliverToBoxAdapter(child: _DisciplineCard(c: c)),
        SliverToBoxAdapter(child: _StatsRow(c: c)),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({required this.c});
  final HomeController c;

  @override
  Widget build(BuildContext context) {
    final score = c.disciplineScore;
    final percent = (score * 100).round();
    final color = score >= 0.7 ? AppColors.profit : score >= 0.4 ? AppColors.warning : AppColors.loss;
    final label = score >= 0.7 ? 'Strong discipline' : score >= 0.4 ? 'Needs improvement' : 'Low discipline';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discipline Score', style: AppTextStyles.labelLarge.copyWith(color: Colors.white54)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white70)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 10),
                Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _ScoreRing(score: score, color: color),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.color});
  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score,
            strokeWidth: 6,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Icon(
              score >= 0.7 ? Icons.military_tech_rounded : Icons.trending_up_rounded,
              color: color,
              size: 28,
            ),
          ),
        ],
      ),
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
