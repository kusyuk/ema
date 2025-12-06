import '../../core/constants/app_constants.dart';
import '../../core/constants/env_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
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
      Logger.info('Starting summarization for text (${text.length} chars)');
      
      final apiKey = EnvConstants.groqApiKey;
      Logger.info('Groq API key check: ${apiKey.isEmpty ? "MISSING" : "PRESENT (${apiKey.length} chars)"}');
      if (apiKey.isEmpty) {
        Logger.error('Groq API key not configured');
        throw const SummarizationException('Groq API key not configured');
      }

      // Create a prompt for summarization in layman's terms
      final prompt = _createSummarizationPrompt(text, language);
      Logger.info('Created summarization prompt (${prompt.length} chars)');

      Logger.info('Making API request to Groq chat/completions endpoint');
      Logger.info('Using model: llama-3.3-70b-versatile');
      
      final response = await _apiClient.post<JsonMap>(
        '${AppConstants.groqBaseUrl}/chat/completions',
        data: {
          'model': 'llama-3.3-70b-versatile', // Updated to current model (llama-3.1-70b-versatile was decommissioned)
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

      Logger.info('API request completed successfully');
      Logger.info('Response status code: ${response.statusCode}');
      
      final content = response.data?['choices']?[0]?['message']?['content'] as String?;
      Logger.info('Summary extracted: ${content != null ? "PRESENT (${content.length} chars)" : "NULL"}');
      
      if (content == null || content.isEmpty) {
        Logger.error('Empty response from Groq API');
        Logger.error('Full response: ${response.data}');
        throw const SummarizationException('Empty response from Groq API');
      }

      Logger.info('Summarization completed successfully: ${content.length} characters');
      return content.trim();
    } on AppException catch (e) {
      Logger.error('Summarization failed with AppException', error: e);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Summarization failed with unexpected error', error: e, stackTrace: stackTrace);
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
