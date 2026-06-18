enum AppInputMode { text, voice }

/// User-configurable app settings persisted on the device.
class AppSettings {
  const AppSettings({
    required this.defaultInputMode,
    required this.voiceAutoSend,
    required this.photoServerSave,
    required this.aiModel,
  });

  const AppSettings.defaults()
    : defaultInputMode = AppInputMode.text,
      voiceAutoSend = true,
      photoServerSave = false,
      aiModel = '';

  final AppInputMode defaultInputMode;

  /// Whether a recognized voice question is submitted automatically.
  final bool voiceAutoSend;

  /// Whether the analyzed image is saved on the server (analyze `save_image`).
  final bool photoServerSave;

  /// Optional Gemini model override (analyze `ai_model`); empty = server default.
  final String aiModel;

  AppSettings copyWith({
    AppInputMode? defaultInputMode,
    bool? voiceAutoSend,
    bool? photoServerSave,
    String? aiModel,
  }) {
    return AppSettings(
      defaultInputMode: defaultInputMode ?? this.defaultInputMode,
      voiceAutoSend: voiceAutoSend ?? this.voiceAutoSend,
      photoServerSave: photoServerSave ?? this.photoServerSave,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}
