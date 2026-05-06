import 'package:cloud_firestore/cloud_firestore.dart';
import 'trade_direction.dart';
import 'trade_emotion.dart';
import 'trade_checklist.dart';

class Trade {
  final String id;
  final String pair;
  final TradeDirection direction;
  final double lotSize;
  final double riskPercent;
  final double result;
  final String reason;
  final TradeEmotion emotion;
  final TradeChecklist checklist;
  final DateTime timestamp;

  const Trade({
    required this.id,
    required this.pair,
    required this.direction,
    required this.lotSize,
    required this.riskPercent,
    required this.result,
    required this.reason,
    required this.emotion,
    required this.checklist,
    required this.timestamp,
  });

  bool get isProfit => result >= 0;

  factory Trade.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trade(
      id: doc.id,
      pair: data['pair'] as String,
      direction: TradeDirection.fromString(data['direction'] as String),
      lotSize: (data['lotSize'] as num).toDouble(),
      riskPercent: (data['riskPercent'] as num).toDouble(),
      result: (data['result'] as num).toDouble(),
      reason: data['reason'] as String,
      emotion: TradeEmotion.fromString(data['emotion'] as String),
      checklist: TradeChecklist.fromMap(data),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'pair': pair,
        'direction': direction.name,
        'lotSize': lotSize,
        'riskPercent': riskPercent,
        'result': result,
        'reason': reason,
        'emotion': emotion.name,
        ...checklist.toMap(),
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
