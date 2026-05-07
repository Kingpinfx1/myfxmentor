import 'package:get/get.dart';
import '../domain/models/trade_model.dart';
import '../services/trade_service.dart';

class JournalController extends GetxController {
  final _tradeService = Get.find<TradeService>();

  final trades = <Trade>[].obs;

  @override
  void onInit() {
    super.onInit();
    trades.bindStream(_tradeService.watchTrades());
  }

  Future<void> deleteTrade(String id) => _tradeService.deleteTrade(id);
}
