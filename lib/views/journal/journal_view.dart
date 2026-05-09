import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/journal_controller.dart';
import '../../domain/models/trade_model.dart';
import '../../domain/models/trade_direction.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/premium_service.dart';
import '../common/paywall_sheet.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text('Journal', style: AppTextStyles.displayMedium),
            ),
            _FilterBar(c: c),
            Expanded(
              child: Obx(() {
                if (c.trades.isEmpty) return const _EmptyState();
                final filtered = c.filteredTrades;
                if (filtered.isEmpty) return _FilteredEmptyState(c: c);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _TradeCard(
                    trade: filtered[i],
                    onTap: () => _openDetail(filtered[i], c),
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

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.c});
  final JournalController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPremium = Get.find<PremiumService>().isPremium.value;

      if (!isPremium) {
        return GestureDetector(
          onTap: () => PaywallSheet.showAsModal(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _LockedChip('Date'),
                  const SizedBox(width: 8),
                  _LockedChip('Direction'),
                  const SizedBox(width: 8),
                  _LockedChip('Result'),
                  const SizedBox(width: 8),
                  _LockedChip('Pair'),
                ],
              ),
            ),
          ),
        );
      }

      return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Date filter
                _FilterChip(
                  label: _dateLabel(c.filterDate.value),
                  isActive: c.filterDate.value != 'all',
                  onTap: () => _showDatePicker(context, c),
                ),
                const SizedBox(width: 8),
                // Direction filter
                _FilterChip(
                  label: _directionLabel(c.filterDirection.value),
                  isActive: c.filterDirection.value != 'all',
                  onTap: () => _showDirectionPicker(context, c),
                ),
                const SizedBox(width: 8),
                // Result filter
                _FilterChip(
                  label: _resultLabel(c.filterResult.value),
                  isActive: c.filterResult.value != 'all',
                  onTap: () => _showResultPicker(context, c),
                ),
                const SizedBox(width: 8),
                // Pair filter
                _FilterChip(
                  label: c.filterPair.value.isEmpty ? 'Pair' : c.filterPair.value,
                  isActive: c.filterPair.value.isNotEmpty,
                  onTap: () => _showPairPicker(context, c),
                ),
              ],
            ),
          ),
        );
    });
  }

  String _dateLabel(String v) {
    switch (v) {
      case 'week': return 'This Week';
      case 'month': return 'This Month';
      case '30days': return 'Last 30 Days';
      default: return 'Date';
    }
  }

  String _directionLabel(String v) {
    switch (v) {
      case 'buy': return 'Buy';
      case 'sell': return 'Sell';
      default: return 'Direction';
    }
  }

  String _resultLabel(String v) {
    switch (v) {
      case 'wins': return 'Wins';
      case 'losses': return 'Losses';
      default: return 'Result';
    }
  }

  void _showDatePicker(BuildContext ctx, JournalController c) {
    _showPickerSheet(
      ctx,
      title: 'Date Range',
      options: const [
        ('All Time', 'all'),
        ('This Week', 'week'),
        ('This Month', 'month'),
        ('Last 30 Days', '30days'),
      ],
      current: c.filterDate.value,
      onSelect: (v) => c.filterDate.value = v,
    );
  }

  void _showDirectionPicker(BuildContext ctx, JournalController c) {
    _showPickerSheet(
      ctx,
      title: 'Direction',
      options: const [
        ('All', 'all'),
        ('Buy', 'buy'),
        ('Sell', 'sell'),
      ],
      current: c.filterDirection.value,
      onSelect: (v) => c.filterDirection.value = v,
    );
  }

  void _showResultPicker(BuildContext ctx, JournalController c) {
    _showPickerSheet(
      ctx,
      title: 'Result',
      options: const [
        ('All', 'all'),
        ('Wins Only', 'wins'),
        ('Losses Only', 'losses'),
      ],
      current: c.filterResult.value,
      onSelect: (v) => c.filterResult.value = v,
    );
  }

  void _showPairPicker(BuildContext ctx, JournalController c) {
    final pairs = c.uniquePairs;
    _showPickerSheet(
      ctx,
      title: 'Pair',
      options: [('All Pairs', ''), ...pairs.map((p) => (p, p))],
      current: c.filterPair.value,
      onSelect: (v) => c.filterPair.value = v,
    );
  }

  void _showPickerSheet(
    BuildContext ctx, {
    required String title,
    required List<(String, String)> options,
    required String current,
    required void Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title, style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: 8),
            ...options.map((opt) {
              final isSelected = opt.$2 == current;
              return ListTile(
                title: Text(opt.$1, style: AppTextStyles.bodyMedium),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, size: 20)
                    : null,
                onTap: () {
                  onSelect(opt.$2);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.textPrimary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? Colors.white : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedChip extends StatelessWidget {
  const _LockedChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
          const SizedBox(width: 4),
          const Icon(Icons.lock_outline, size: 13, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

// ─── Filtered Empty State ─────────────────────────────────────────────────────

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.c});
  final JournalController c;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list_off_rounded, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('No trades match your filters', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: c.clearFilters,
            child: const Text('Clear filters'),
          ),
        ],
      ),
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
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
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
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
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
                  _SectionTitle('Trade Details'),
                  const SizedBox(height: 12),
                  _DetailCard(children: [
                    _DetailRow('Direction', trade.direction.label, valueColor: dirColor),
                    const Divider(height: 1),
                    _DetailRow('Lot Size', trade.lotSize.toString()),
                    const Divider(height: 1),
                    _DetailRow('Risk', '${trade.riskPercent.toStringAsFixed(1)}%'),
                  ]),
                  const SizedBox(height: 20),
                  _SectionTitle('Mindset'),
                  const SizedBox(height: 12),
                  _DetailCard(children: [
                    _DetailRow('Emotion', '${trade.emotion.emoji} ${trade.emotion.label}'),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(trade.reason, style: AppTextStyles.bodyMedium, textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
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
