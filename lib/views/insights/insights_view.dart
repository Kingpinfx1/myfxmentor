import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/insights_controller.dart';
import '../../domain/models/trade_emotion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/premium_service.dart';
import '../common/paywall_sheet.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<InsightsController>();
    final premium = Get.find<PremiumService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (!premium.isPremium.value) return const PaywallSheet(isModal: false);
          if (c.trades.isEmpty) return const _EmptyState();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text('Insights', style: AppTextStyles.displayMedium),
                ),
              ),
              SliverToBoxAdapter(child: _AiCoachingCard(c: c)),
              SliverToBoxAdapter(child: _SummaryRow(c: c)),
              SliverToBoxAdapter(child: _SectionHeader('Pair Performance')),
              SliverToBoxAdapter(child: _PairBarChart(c: c)),
              SliverToBoxAdapter(child: _SectionHeader('Result Over Time')),
              SliverToBoxAdapter(child: _CumulativeLineChart(c: c)),
              SliverToBoxAdapter(child: _SectionHeader('Mindset vs Outcome')),
              SliverToBoxAdapter(child: _EmotionBreakdown(c: c)),
              SliverToBoxAdapter(child: _SectionHeader('Discipline Impact')),
              SliverToBoxAdapter(child: _DisciplineComparison(c: c)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        }),
      ),
    );
  }
}

// ─── AI Coaching Card ─────────────────────────────────────────────────────────

class _AiCoachingCard extends StatelessWidget {
  const _AiCoachingCard({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    final isPremium = Get.find<PremiumService>().isPremium.value;

    if (!isPremium) {
      return GestureDetector(
        onTap: () => PaywallSheet.showAsModal(context),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.lock_outline, size: 20, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Coaching', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 2),
                    Text('Upgrade to Pro for personalised insights', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
            ],
          ),
        ),
      );
    }

    return Obx(() {
      final summary = c.coachingSummary.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: summary != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✦', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(summary, style: AppTextStyles.bodyMedium)),
                ],
              )
            : Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 12),
                  Text('Analysing your trades…', style: AppTextStyles.bodySmall),
                ],
              ),
      );
    });
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    final totalR = c.totalR;
    final rColor = totalR >= 0 ? AppColors.profit : AppColors.loss;
    final rAbs = totalR.abs();
    final rFormatted = rAbs == rAbs.roundToDouble() ? rAbs.toInt().toString() : rAbs.toStringAsFixed(1);
    final rText = '${totalR >= 0 ? "+" : "-"}${rFormatted}R';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _SummaryChip(label: 'Total R', value: rText, valueColor: rColor),
          const SizedBox(width: 10),
          _SummaryChip(label: 'Win Rate', value: '${(c.winRate * 100).toStringAsFixed(0)}%'),
          const SizedBox(width: 10),
          _SummaryChip(label: 'Discipline', value: '${(c.disciplineScore * 100).toStringAsFixed(0)}%'),
          const SizedBox(width: 10),
          _SummaryChip(label: 'Trades', value: '${c.totalTrades}'),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: AppTextStyles.labelLarge.copyWith(color: valueColor ?? AppColors.textPrimary)),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title, style: AppTextStyles.titleMedium),
    );
  }
}

// ─── Pair Bar Chart ───────────────────────────────────────────────────────────

class _PairBarChart extends StatelessWidget {
  const _PairBarChart({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    final data = c.winRateByPair;
    if (data.isEmpty) return const SizedBox.shrink();

    final pairs = data.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: BarChart(
          BarChartData(
            maxY: 100,
            barGroups: [
              for (int i = 0; i < pairs.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[pairs[i]]! * 100,
                      color: data[pairs[i]]! >= 0.5 ? AppColors.profit : AppColors.loss,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= pairs.length) return const SizedBox.shrink();
                    final pair = pairs[i];
                    final short = pair.length > 6 ? pair.substring(0, 6) : pair;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        short,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Cumulative Line Chart ────────────────────────────────────────────────────

class _CumulativeLineChart extends StatelessWidget {
  const _CumulativeLineChart({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    final raw = c.cumulativeResult;
    if (raw.isEmpty) return const SizedBox.shrink();

    final spots = raw.map((p) => FlSpot(p.$1, p.$2)).toList();
    final lastY = raw.last.$2;
    final lineColor = lastY >= 0 ? AppColors.profit : AppColors.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: lineColor,
                isCurved: spots.length > 2,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, _) => spot == spots.first || spot == spots.last,
                  getDotPainter: (spot, _, __, x) => FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 0,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [lineColor.withValues(alpha: 0.2), lineColor.withValues(alpha: 0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            titlesData: const FlTitlesData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map((s) => LineTooltipItem(
                          '${s.y >= 0 ? "+" : ""}${s.y.toStringAsFixed(2)}R',
                          TextStyle(color: lineColor, fontWeight: FontWeight.w700, fontSize: 12),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Emotion Breakdown ────────────────────────────────────────────────────────

class _EmotionBreakdown extends StatelessWidget {
  const _EmotionBreakdown({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    final data = c.winRateByEmotion;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            for (int i = 0; i < TradeEmotion.values.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _EmotionRow(
                emotion: TradeEmotion.values[i],
                winRate: data[TradeEmotion.values[i]],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmotionRow extends StatelessWidget {
  const _EmotionRow({required this.emotion, required this.winRate});
  final TradeEmotion emotion;
  final double? winRate;

  @override
  Widget build(BuildContext context) {
    final rate = winRate ?? 0.0;
    final hasData = winRate != null;
    final barColor = rate >= 0.6 ? AppColors.profit : rate >= 0.4 ? AppColors.warning : AppColors.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(emotion.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(emotion.label, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: hasData
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  )
                : Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              hasData ? '${(rate * 100).toStringAsFixed(0)}%' : '—',
              style: AppTextStyles.labelLarge.copyWith(
                color: hasData ? barColor : AppColors.textTertiary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Discipline Comparison ────────────────────────────────────────────────────

class _DisciplineComparison extends StatelessWidget {
  const _DisciplineComparison({required this.c});
  final InsightsController c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _DisciplineCard(
              label: 'Disciplined',
              winRate: c.disciplinedWinRate,
              count: c.disciplinedCount,
              bg: AppColors.profitLight,
              color: AppColors.profit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DisciplineCard(
              label: 'Undisciplined',
              winRate: c.undisciplinedWinRate,
              count: c.undisciplinedCount,
              bg: AppColors.lossLight,
              color: AppColors.loss,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({
    required this.label,
    required this.winRate,
    required this.count,
    required this.bg,
    required this.color,
  });
  final String label;
  final double winRate;
  final int count;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count == 0 ? '—' : '${(winRate * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color, letterSpacing: -1, height: 1),
          ),
          const SizedBox(height: 4),
          Text('win rate', style: AppTextStyles.bodySmall.copyWith(color: color.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Text(
            '$count trade${count == 1 ? "" : "s"}',
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.bar_chart_outlined, size: 32, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('No trades yet', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text('Log some trades to see your analytics.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
