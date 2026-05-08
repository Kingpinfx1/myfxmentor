import 'package:get/get.dart';
import '../domain/models/trade_direction.dart';
import '../domain/models/trade_model.dart';
import '../services/trade_service.dart';

class JournalController extends GetxController {
  final _tradeService = Get.find<TradeService>();

  final trades = <Trade>[].obs;

  final filterDate = 'all'.obs;      // 'all' | 'week' | 'month' | '30days'
  final filterDirection = 'all'.obs; // 'all' | 'buy' | 'sell'
  final filterResult = 'all'.obs;    // 'all' | 'wins' | 'losses'
  final filterPair = ''.obs;         // '' = all, else specific pair

  @override
  void onInit() {
    super.onInit();
    trades.bindStream(_tradeService.watchTrades());
  }

  List<Trade> get filteredTrades {
    final now = DateTime.now();
    return trades.where((t) {
      if (filterDate.value == 'week' &&
          t.timestamp.isBefore(now.subtract(const Duration(days: 7)))) return false;
      if (filterDate.value == 'month' &&
          (t.timestamp.month != now.month || t.timestamp.year != now.year)) return false;
      if (filterDate.value == '30days' &&
          t.timestamp.isBefore(now.subtract(const Duration(days: 30)))) return false;
      if (filterDirection.value == 'buy' && t.direction != TradeDirection.buy) return false;
      if (filterDirection.value == 'sell' && t.direction != TradeDirection.sell) return false;
      if (filterResult.value == 'wins' && !t.isProfit) return false;
      if (filterResult.value == 'losses' && t.isProfit) return false;
      if (filterPair.value.isNotEmpty && t.pair != filterPair.value) return false;
      return true;
    }).toList();
  }

  List<String> get uniquePairs =>
      trades.map((t) => t.pair).toSet().toList()..sort();

  bool get hasActiveFilter =>
      filterDate.value != 'all' ||
      filterDirection.value != 'all' ||
      filterResult.value != 'all' ||
      filterPair.value.isNotEmpty;

  void clearFilters() {
    filterDate.value = 'all';
    filterDirection.value = 'all';
    filterResult.value = 'all';
    filterPair.value = '';
  }

  Future<void> deleteTrade(String id) => _tradeService.deleteTrade(id);
}
