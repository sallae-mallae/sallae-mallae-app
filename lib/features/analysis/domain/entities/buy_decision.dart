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
}
