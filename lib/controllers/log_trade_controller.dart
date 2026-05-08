import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/trade_model.dart';
import '../domain/models/trade_direction.dart';
import '../domain/models/trade_emotion.dart';
import '../domain/models/trade_checklist.dart';
import '../services/trade_service.dart';
import '../services/premium_service.dart';
import 'insights_controller.dart';

class LogTradeController extends GetxController {
  static const commonPairs = ['EURUSD', 'GBPUSD', 'USDJPY', 'XAUUSD', 'USDCAD', 'AUDUSD', 'GBPJPY'];

  // Step navigation
  final currentStep = 0.obs;
  late final PageController pageController;

  // Reactive tick — text controllers increment this so Obx rebuilds on keystrokes
  final _formTick = 0.obs;

  // Step 1 — Trade Details
  final pairController = TextEditingController();
  final pair = ''.obs;
  final direction = TradeDirection.buy.obs;
  final lotSizeController = TextEditingController();
  final riskController = TextEditingController();

  // Step 2 — Result
  final isWin = true.obs;
  final resultController = TextEditingController();

  // Step 3 — Checklist
  final followedStrategy = false.obs;
  final riskControlled = false.obs;
  final validSetup = false.obs;

  // Step 4 — Emotion & Reason
  final emotion = TradeEmotion.calm.obs;
  final reasonController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    pairController.addListener(() {
      pair.value = pairController.text.trim();
      _formTick.value++;
    });
    lotSizeController.addListener(() => _formTick.value++);
    riskController.addListener(() => _formTick.value++);
    resultController.addListener(() => _formTick.value++);
    reasonController.addListener(() => _formTick.value++);
  }

  @override
  void onClose() {
    pageController.dispose();
    pairController.dispose();
    lotSizeController.dispose();
    riskController.dispose();
    resultController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  bool get canProceed {
    // ignore: unused_local_variable — read to subscribe Obx to _formTick
    final _ = _formTick.value;
    switch (currentStep.value) {
      case 0:
        return pair.value.isNotEmpty &&
            (double.tryParse(lotSizeController.text) ?? 0) > 0 &&
            (double.tryParse(riskController.text) ?? 0) > 0;
      case 1:
        return (double.tryParse(resultController.text) ?? 0) > 0;
      case 2:
        return true;
      case 3:
        return reasonController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void selectPair(String p) {
    pairController.text = p;
    pair.value = p;
  }

  void nextStep() {
    if (!canProceed) return;
    if (currentStep.value < 3) {
      currentStep.value++;
      pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  Future<void> _submit() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final raw = double.parse(resultController.text);
      final trade = Trade(
        id: const Uuid().v4(),
        pair: pair.value.toUpperCase(),
        direction: direction.value,
        lotSize: double.parse(lotSizeController.text),
        riskPercent: double.parse(riskController.text),
        result: isWin.value ? raw : -raw,
        reason: reasonController.text.trim(),
        emotion: emotion.value,
        checklist: TradeChecklist(
          followedStrategy: followedStrategy.value,
          riskControlled: riskControlled.value,
          validSetup: validSetup.value,
        ),
        timestamp: DateTime.now(),
      );
      final tradeService = Get.find<TradeService>();
      await tradeService.addTrade(trade);

      if (Get.find<PremiumService>().isPremium.value) {
        final insights = Get.find<InsightsController>();
        unawaited(tradeService.requestCoachingReview(stats: {
          'totalTrades': insights.totalTrades,
          'winRate': (insights.winRate * 100).round(),
          'disciplineScore': (insights.disciplineScore * 100).round(),
          'winRateByEmotion': insights.winRateByEmotion
              .map((k, v) => MapEntry(k.name, (v * 100).round())),
          'winRateByPair': insights.winRateByPair
              .map((k, v) => MapEntry(k, (v * 100).round())),
        }));
      }

      Get.back();
      Get.snackbar(
        'Trade Logged',
        '${trade.pair} ${trade.direction.label} · ${trade.isProfit ? "+" : ""}${trade.result.toStringAsFixed(2)}R',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to save trade. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class LogTradeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LogTradeController>(LogTradeController());
  }
}
