import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _service;
  AuthController(this._service);

  final user = Rxn<User>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_service.authStateChanges());
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _service.login(email, password);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading.value = true;
      await _service.register(email, password);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() => _service.logout();

  Future<void> resetPassword(String email) => _service.resetPassword(email);
}
