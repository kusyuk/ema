import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables constants
class EnvConstants {
  EnvConstants._();

  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get elevenlabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  
  /// Load environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}

