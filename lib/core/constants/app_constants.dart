/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'EMA';
  static const String appVersion = '0.1.0';

  // Storage
  static const String hiveBoxName = 'ema_storage';
  static const String audioStoragePath = 'recordings';
  
  // API Configuration
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  // Deprecated: ElevenLabs no longer used (migrated to Groq)
  // static const String elevenlabsBaseUrl = 'https://api.elevenlabs.io/v1';
  
  // Audio Settings
  // Optimized settings for speech transcription (reduces file size and API quota usage)
  static const int optimizedSampleRate = 16000; // Sufficient for speech, reduces file size by ~63%
  static const int optimizedBitRate = 64000; // Reduces file size by ~50%
  
  // Legacy settings (kept for backward compatibility if needed)
  static const int defaultSampleRate = 44100;
  static const int defaultBitRate = 128000;
  
  // Recording limits
  static const Duration maxRecordingDuration = Duration(minutes: 5); // Maximum recording duration
  static const Duration recordingWarningThreshold = Duration(minutes: 4); // Warn when approaching limit
  
  // UI Settings
  static const double minFontSize = 16.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 18.0;
  static const double minTouchTargetSize = 44.0;
}

