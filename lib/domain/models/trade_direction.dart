enum TradeDirection {
  buy,
  sell;

  String get label {
    switch (this) {
      case TradeDirection.buy:
        return 'Buy';
      case TradeDirection.sell:
        return 'Sell';
    }
  }

  static TradeDirection fromString(String value) {
    return TradeDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TradeDirection.buy,
    );
  }
}
