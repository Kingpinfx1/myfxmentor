import 'package:get/get.dart';
import '../domain/models/trade_emotion.dart';
import '../domain/models/trade_model.dart';
import '../services/trade_service.dart';

class InsightsController extends GetxController {
  final _tradeService = Get.find<TradeService>();
  final trades = <Trade>[].obs;
  final coachingSummary = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    trades.bindStream(_tradeService.watchTrades());
    coachingSummary.bindStream(_tradeService.watchCoachingSummary());
  }

  int get totalTrades => trades.length;

  double get winRate {
    if (trades.isEmpty) return 0;
    return trades.where((t) => t.isProfit).length / trades.length;
  }

  double get disciplineScore {
    if (trades.isEmpty) return 0;
    return trades.where((t) => t.checklist.isDisciplined).length / trades.length;
  }

  double get totalR => trades.fold(0.0, (sum, t) => sum + t.result);

  Map<String, double> get winRateByPair {
    final Map<String, List<Trade>> byPair = {};
    for (final t in trades) {
      byPair.putIfAbsent(t.pair, () => []).add(t);
    }
    final sorted = byPair.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return {
      for (final e in sorted.take(7))
        e.key: e.value.where((t) => t.isProfit).length / e.value.length,
    };
  }

  Map<TradeEmotion, double> get winRateByEmotion {
    final Map<TradeEmotion, List<Trade>> byEmotion = {
      for (final e in TradeEmotion.values) e: [],
    };
    for (final t in trades) {
      byEmotion[t.emotion]!.add(t);
    }
    return {
      for (final e in TradeEmotion.values)
        if (byEmotion[e]!.isNotEmpty)
          e: byEmotion[e]!.where((t) => t.isProfit).length / byEmotion[e]!.length,
    };
  }

  int get disciplinedCount => trades.where((t) => t.checklist.isDisciplined).length;
  int get undisciplinedCount => trades.where((t) => !t.checklist.isDisciplined).length;

  double get disciplinedWinRate {
    final list = trades.where((t) => t.checklist.isDisciplined).toList();
    if (list.isEmpty) return 0;
    return list.where((t) => t.isProfit).length / list.length;
  }

  double get undisciplinedWinRate {
    final list = trades.where((t) => !t.checklist.isDisciplined).toList();
    if (list.isEmpty) return 0;
    return list.where((t) => t.isProfit).length / list.length;
  }

  /// Returns (x, y) pairs for cumulative R, sorted by timestamp.
  /// The view converts these to FlSpot to keep fl_chart out of the controller.
  List<(double, double)> get cumulativeResult {
    final sorted = [...trades]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    double cumulative = 0;
    return [
      for (int i = 0; i < sorted.length; i++)
        (i.toDouble(), cumulative += sorted[i].result),
    ];
  }
}
