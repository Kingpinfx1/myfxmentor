import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/trade_service.dart';

class ProfileController extends GetxController {
  final _auth = Get.find<AuthController>();
  final _tradeService = Get.find<TradeService>();

  String get displayName {
    final user = _auth.user.value;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Trader';
  }

  String get email => _auth.user.value?.email ?? '';

  String get initial => displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

  Future<void> updateDisplayName(String name) async {
    await _auth.user.value?.updateDisplayName(name);
    await _refreshUser();
  }

  Future<void> updateEmail(String newEmail) async {
    await _auth.user.value?.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.user.value;
    if (user == null || user.email == null) throw FirebaseAuthException(code: 'no-user');
    final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() => _auth.logout();

  Future<void> deleteAllTrades() async {
    await _tradeService.deleteAllTrades();
  }

  Future<void> deleteAccount(String password) async {
    final user = _auth.user.value;
    if (user == null || user.email == null) throw FirebaseAuthException(code: 'no-user');
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);
    await _tradeService.deleteAllTrades();
    await user.delete();
  }

  Future<void> _refreshUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    _auth.user.value = FirebaseAuth.instance.currentUser;
  }
}
