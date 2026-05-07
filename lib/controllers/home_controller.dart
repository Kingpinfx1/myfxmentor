import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../domain/models/trade_model.dart';
import '../services/trade_service.dart';

class HomeController extends GetxController {
  final _tradeService = Get.find<TradeService>();
  final _auth = Get.find<AuthController>();

  final trades = <Trade>[].obs;

  @override
  void onInit() {
    super.onInit();
    trades.bindStream(_tradeService.watchTrades());
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get firstName {
    final user = _auth.user.value;
    final name = user?.displayName ?? user?.email ?? 'Trader';
    return name.split(RegExp(r'[ @]')).first;
  }

  int get totalTrades => trades.length;

  int get wins => trades.where((t) => t.isProfit).length;

  double get winRate => totalTrades == 0 ? 0 : wins / totalTrades;

  double get disciplineScore {
    if (totalTrades == 0) return 0;
    return trades.where((t) => t.checklist.isDisciplined).length / totalTrades;
  }

  double get avgRisk {
    if (totalTrades == 0) return 0;
    return trades.map((t) => t.riskPercent).reduce((a, b) => a + b) / totalTrades;
  }

  List<Trade> get recentTrades => trades.take(3).toList();
}
