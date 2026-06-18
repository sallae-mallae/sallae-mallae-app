/// A text-to-speech voice option (platform voice name + locale).
class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  factory TtsVoice.fromMap(Map<dynamic, dynamic> map) {
    return TtsVoice(
      name: map['name']?.toString() ?? '',
      locale: map['locale']?.toString() ?? '',
    );
  }

  Map<String, String> toTtsMap() => {'name': name, 'locale': locale};

  @override
  bool operator ==(Object other) =>
      other is TtsVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);
}
