class FrameSamplingPolicy {
  const FrameSamplingPolicy({
    this.interval = const Duration(milliseconds: 500),
  });

  final Duration interval;

  bool shouldProcess({
    required DateTime now,
    required DateTime? lastProcessedAt,
    required bool isProcessing,
  }) {
    if (isProcessing) {
      return false;
    }

    if (lastProcessedAt == null) {
      return true;
    }

    return now.difference(lastProcessedAt) >= interval;
  }
}
