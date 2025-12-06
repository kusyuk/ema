import '../../core/constants/app_constants.dart';
import '../../core/constants/env_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../utils/typedefs.dart';

/// Remote data source for Groq API
abstract class GroqRemoteDataSource {
  Future<String> summarizeText(String text, {String language = 'en'});
}

/// Implementation of Groq remote data source
class GroqRemoteDataSourceImpl implements GroqRemoteDataSource {
  final ApiClient _apiClient;

  GroqRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> summarizeText(String text, {String language = 'en'}) async {
    try {
      final apiKey = EnvConstants.groqApiKey;
      if (apiKey.isEmpty) {
        throw const SummarizationException('Groq API key not configured');
      }

      // Create a prompt for summarization in layman's terms
      final prompt = _createSummarizationPrompt(text, language);

      final response = await _apiClient.post<JsonMap>(
        '${AppConstants.groqBaseUrl}/chat/completions',
        data: {
          'model': 'llama-3.1-70b-versatile', // Using a powerful model
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful medical assistant that explains medical information in simple, easy-to-understand language for elderly patients. Always use layman\'s terms and avoid technical jargon.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final content = response.data?['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const SummarizationException('Empty response from Groq API');
      }

      return content.trim();
    } on AppException {
      rethrow;
    } catch (e) {
      throw SummarizationException('Failed to summarize text: ${e.toString()}');
    }
  }

  /// Create a prompt for summarization
  String _createSummarizationPrompt(String text, String language) {
    final languageInstruction = language != 'en' 
        ? ' Please respond in $language.'
        : '';
    
    return '''Please summarize the following medical consultation transcript in simple, easy-to-understand language for an elderly patient. 

Focus on:
1. The main diagnosis or condition (in simple terms)
2. Treatment plan or recommendations
3. Any medications mentioned
4. Follow-up instructions or next steps
5. Important dates or appointments mentioned

Use everyday language and avoid medical jargon. If you must use a medical term, explain it in simple words.$languageInstruction

Transcript:
$text''';
  }
}
