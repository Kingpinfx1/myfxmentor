class TradeChecklist {
  final bool followedStrategy;
  final bool riskControlled;
  final bool validSetup;

  const TradeChecklist({
    required this.followedStrategy,
    required this.riskControlled,
    required this.validSetup,
  });

  const TradeChecklist.empty()
      : followedStrategy = false,
        riskControlled = false,
        validSetup = false;

  bool get isDisciplined => followedStrategy && riskControlled && validSetup;

  int get checkedCount =>
      (followedStrategy ? 1 : 0) + (riskControlled ? 1 : 0) + (validSetup ? 1 : 0);

  TradeChecklist copyWith({
    bool? followedStrategy,
    bool? riskControlled,
    bool? validSetup,
  }) {
    return TradeChecklist(
      followedStrategy: followedStrategy ?? this.followedStrategy,
      riskControlled: riskControlled ?? this.riskControlled,
      validSetup: validSetup ?? this.validSetup,
    );
  }

  Map<String, dynamic> toMap() => {
        'checklistStrategy': followedStrategy,
        'checklistRisk': riskControlled,
        'checklistSetup': validSetup,
      };

  factory TradeChecklist.fromMap(Map<String, dynamic> map) => TradeChecklist(
        followedStrategy: (map['checklistStrategy'] as bool?) ?? false,
        riskControlled: (map['checklistRisk'] as bool?) ?? false,
        validSetup: (map['checklistSetup'] as bool?) ?? false,
      );
}
