import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Environment variables constants
class EnvConstants {
  EnvConstants._();

  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  // Deprecated: ElevenLabs no longer used (migrated to Groq)
  // static String get elevenlabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  
  /// Load environment variables
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      Logger.info('Environment variables loaded successfully');
    } catch (e) {
      // If .env file is not found, log error but don't crash
      // This allows the app to run in development even if .env is missing
      Logger.warning('Could not load .env file: $e');
      // In production, you might want to throw here or use default values
    }
  }
}

