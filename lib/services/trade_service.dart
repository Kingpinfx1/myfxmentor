import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/trade_model.dart';

class TradeService {
  final _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _trades(String uid) =>
      _firestore.collection('users').doc(uid).collection('trades');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<List<Trade>> watchTrades() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _trades(uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Trade.fromFirestore).toList());
  }

  Stream<String?> watchCoachingSummary() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data()?['coachingSummary'] as String?;
    });
  }

  Future<void> addTrade(Trade trade) =>
      _trades(_uid!).doc(trade.id).set(trade.toFirestore());

  Future<void> deleteTrade(String id) => _trades(_uid!).doc(id).delete();

  Future<void> deleteAllTrades() async {
    final snap = await _trades(_uid!).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> requestCoachingReview({required Map<String, dynamic> stats}) async {
    final fn = FirebaseFunctions.instance.httpsCallable('generateCoachingSummary');
    await fn.call(stats);
  }
}
