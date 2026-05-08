import 'package:get/get.dart';

class PremiumService extends GetxService {
  final isPremium = false.obs;

  void togglePremium() => isPremium.value = !isPremium.value;

  // Wire RevenueCat here when ready to ship:
  // Future<void> checkStatus() async {
  //   final info = await Purchases.getCustomerInfo();
  //   isPremium.value = info.entitlements.active.containsKey('pro');
  // }
}
