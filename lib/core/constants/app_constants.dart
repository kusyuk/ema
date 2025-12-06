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
  static const String elevenlabsBaseUrl = 'https://api.elevenlabs.io/v1';
  
  // Audio Settings
  static const int defaultSampleRate = 44100;
  static const int defaultBitRate = 128000;
  
  // UI Settings
  static const double minFontSize = 16.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 18.0;
  static const double minTouchTargetSize = 44.0;
}

