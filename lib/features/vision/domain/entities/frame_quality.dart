enum ShakeStatus { stable, slight, shaking, unknown }

class FrameQuality {
  const FrameQuality({
    required this.brightnessScore,
    required this.blurScore,
    required this.focusScore,
    required this.shakeStatus,
    required this.isReadable,
  });

  const FrameQuality.unknown()
    : brightnessScore = 0,
      blurScore = 0,
      focusScore = 0,
      shakeStatus = ShakeStatus.unknown,
      isReadable = false;

  final double brightnessScore;
  final double blurScore;
  final double focusScore;
  final ShakeStatus shakeStatus;
  final bool isReadable;

  bool get isBrightEnough => brightnessScore >= 0.45;

  bool get isSharpEnough => blurScore >= 0.55 && focusScore >= 0.55;

  bool get isStable =>
      shakeStatus == ShakeStatus.stable || shakeStatus == ShakeStatus.slight;

  bool get canAnalyzeText => isReadable && isBrightEnough && isSharpEnough;

  bool get canSuggestCapture => canAnalyzeText && isStable;

  FrameQuality copyWith({
    double? brightnessScore,
    double? blurScore,
    double? focusScore,
    ShakeStatus? shakeStatus,
    bool? isReadable,
  }) {
    return FrameQuality(
      brightnessScore: brightnessScore ?? this.brightnessScore,
      blurScore: blurScore ?? this.blurScore,
      focusScore: focusScore ?? this.focusScore,
      shakeStatus: shakeStatus ?? this.shakeStatus,
      isReadable: isReadable ?? this.isReadable,
    );
  }
}
