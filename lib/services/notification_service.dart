import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> init(String uid) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (token != null) await _saveToken(uid, token);

    _messaging.onTokenRefresh.listen((t) => _saveToken(uid, t));

    // Show foreground notifications as a snackbar
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        Get.snackbar(
          n.title ?? 'MyFX Mentor',
          n.body ?? '',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.black,
          colorText: Colors.white,
          borderRadius: 14,
        );
      }
    });
  }

  Future<void> _saveToken(String uid, String token) =>
      _firestore.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
}
