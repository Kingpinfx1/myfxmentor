enum TradeEmotion {
  calm,
  confident,
  fearful,
  greedy;

  String get label {
    switch (this) {
      case TradeEmotion.calm:
        return 'Calm';
      case TradeEmotion.confident:
        return 'Confident';
      case TradeEmotion.fearful:
        return 'Fearful';
      case TradeEmotion.greedy:
        return 'Greedy';
    }
  }

  String get emoji {
    switch (this) {
      case TradeEmotion.calm:
        return '😌';
      case TradeEmotion.confident:
        return '💪';
      case TradeEmotion.fearful:
        return '😨';
      case TradeEmotion.greedy:
        return '🤑';
    }
  }

  static TradeEmotion fromString(String value) {
    return TradeEmotion.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TradeEmotion.calm,
    );
  }
}
