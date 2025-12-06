/// TTS settings entity
class TtsSettings {
  final String language;
  final double rate;
  final double pitch;

  const TtsSettings({
    required this.language,
    required this.rate,
    required this.pitch,
  });

  TtsSettings copyWith({
    String? language,
    double? rate,
    double? pitch,
  }) {
    return TtsSettings(
      language: language ?? this.language,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
    );
  }

  Map<String, dynamic> toMap() => {
        'language': language,
        'rate': rate,
        'pitch': pitch,
      };

  factory TtsSettings.fromMap(Map<dynamic, dynamic> map) {
    return TtsSettings(
      language: (map['language'] ?? 'en-US') as String,
      rate: (map['rate'] ?? 0.95).toDouble(),
      pitch: (map['pitch'] ?? 1.0).toDouble(),
    );
  }

  static const defaults = TtsSettings(
    language: 'en-US',
    rate: 0.95,
    pitch: 1.0,
  );
}


