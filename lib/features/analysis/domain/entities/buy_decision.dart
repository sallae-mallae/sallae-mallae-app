enum BuyDecision { buy, hold, avoid, unknown }

extension BuyDecisionMapper on BuyDecision {
  static BuyDecision fromVerdict(String? verdict) {
    return switch (verdict) {
      'buy' => BuyDecision.buy,
      'maybe' => BuyDecision.hold,
      'no' => BuyDecision.avoid,
      _ => BuyDecision.unknown,
    };
  }

  /// Forces a friendlier label for the ambiguous "hold" verdict; null means use
  /// the server/result label as-is.
  String? get forcedLabel => this == BuyDecision.hold ? '애매하긴해' : null;
}
