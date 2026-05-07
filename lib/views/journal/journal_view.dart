import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/journal_controller.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/trade_direction.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class JournalView extends StatelessWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<JournalController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text('Journal', style: AppTextStyles.displayMedium),
            ),
            Expanded(
              child: Obx(() {
                if (c.trades.isEmpty) return const _EmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: c.trades.length,
                  itemBuilder: (_, i) => _TradeCard(
                    trade: c.trades[i],
                    onTap: () => _openDetail(c.trades[i], c),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Trade trade, JournalController c) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TradeDetail(trade: trade, c: c),
    );
  }
}

// ─── Trade Card ───────────────────────────────────────────────────────────────

class _TradeCard extends StatelessWidget {
  const _TradeCard({required this.trade, required this.onTap});
  final Trade trade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.direction == TradeDirection.buy;
    final isWin = trade.isProfit;
    final dirColor = isBuy ? AppColors.profit : AppColors.loss;
    final resultColor = isWin ? AppColors.profit : AppColors.loss;
    final resultBg = isWin ? AppColors.profitLight : AppColors.lossLight;
    final resultText = '${isWin ? "+" : ""}${trade.result.toStringAsFixed(2)}R';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Direction badge
            Container(
              width: 48,
              height: 48,
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
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(trade.pair, style: AppTextStyles.titleSmall),
                      const SizedBox(width: 8),
                      Text(trade.emotion.emoji, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('MMM d, yyyy · HH:mm').format(trade.timestamp),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Result + discipline
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: resultBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(resultText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: resultColor)),
                ),
                const SizedBox(height: 4),
                Icon(
                  trade.checklist.isDisciplined ? Icons.verified_rounded : Icons.remove_circle_outline,
                  size: 14,
                  color: trade.checklist.isDisciplined ? AppColors.profit : AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trade Detail ─────────────────────────────────────────────────────────────

class _TradeDetail extends StatelessWidget {
  const _TradeDetail({required this.trade, required this.c});
  final Trade trade;
  final JournalController c;

  @override
  Widget build(BuildContext context) {
    final isWin = trade.isProfit;
    final isBuy = trade.direction == TradeDirection.buy;
    final resultColor = isWin ? AppColors.profit : AppColors.loss;
    final dirColor = isBuy ? AppColors.profit : AppColors.loss;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trade.pair, style: AppTextStyles.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM d, yyyy · HH:mm').format(trade.timestamp),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, color: AppColors.loss),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Result hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isWin ? AppColors.profitLight : AppColors.lossLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${isWin ? "+" : ""}${trade.result.toStringAsFixed(2)}R',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: resultColor, letterSpacing: -1),
                        ),
                        const SizedBox(height: 4),
                        Text(isWin ? 'Profit' : 'Loss', style: AppTextStyles.labelMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Trade details
                  _SectionTitle('Trade Details'),
                  const SizedBox(height: 12),
                  _DetailCard(children: [
                    _DetailRow('Direction', trade.direction.label,
                        valueColor: dirColor),
                    const Divider(height: 1),
                    _DetailRow('Lot Size', trade.lotSize.toString()),
                    const Divider(height: 1),
                    _DetailRow('Risk', '${trade.riskPercent.toStringAsFixed(1)}%'),
                  ]),
                  const SizedBox(height: 20),
                  // Emotion & Reason
                  _SectionTitle('Mindset'),
                  const SizedBox(height: 12),
                  _DetailCard(children: [
                    _DetailRow('Emotion', '${trade.emotion.emoji} ${trade.emotion.label}'),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(trade.reason, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Checklist
                  _SectionTitle('Checklist'),
                  const SizedBox(height: 12),
                  _DetailCard(children: [
                    _CheckRow('Followed my strategy', trade.checklist.followedStrategy),
                    const Divider(height: 1),
                    _CheckRow('Risk was controlled', trade.checklist.riskControlled),
                    const Divider(height: 1),
                    _CheckRow('Valid setup', trade.checklist.validSetup),
                  ]),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      trade.checklist.isDisciplined ? '✓ Disciplined trade' : '${trade.checklist.checkedCount}/3 rules followed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: trade.checklist.isDisciplined ? AppColors.profit : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete trade?'),
        content: const Text('This trade will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await c.deleteTrade(trade.id);
      Get.back();
    }
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

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
            child: const Icon(Icons.book_outlined, size: 32, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('No trades yet', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text('Your logged trades will appear here.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary));
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.labelLarge.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow(this.label, this.checked);
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: checked ? AppColors.profit : AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
