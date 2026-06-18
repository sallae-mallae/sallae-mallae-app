class FrameSamplingPolicy {
  const FrameSamplingPolicy({
    // Process at most ~1 frame/sec. Running detection/OCR/quality on every
    // frame keeps the CPU/GPU busy and overheats the device; a wider interval
    // keeps the live overlay responsive enough while cutting heat.
    this.interval = const Duration(milliseconds: 1000),
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
