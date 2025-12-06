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
      Logger.info(
        'Groq API key check: ${apiKey.isEmpty ? "MISSING" : "PRESENT (${apiKey.length} chars)"}',
      );
      if (apiKey.isEmpty) {
        Logger.error('Groq API key not configured');
        throw const SummarizationException('Groq API key not configured');
      }

      final prompt = _createSummarizationPrompt(text, language);
      Logger.info('Created summarization prompt (${prompt.length} chars)');

      Logger.info('Making API request to Groq chat/completions endpoint');
      Logger.info('Using model: llama-3.3-70b-versatile');

      final response = await _apiClient.post<JsonMap>(
        '${AppConstants.groqBaseUrl}/chat/completions',
        data: {
          'model':
              'llama-3.3-70b-versatile', // Updated to current model (llama-3.1-70b-versatile was decommissioned)
          'messages': [
            {'role': 'system', 'content': _buildSystemPrompt(language)},
            {'role': 'user', 'content': prompt},
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

      final content =
          response.data?['choices']?[0]?['message']?['content'] as String?;
      Logger.info(
        'Summary extracted: ${content != null ? "PRESENT (${content.length} chars)" : "NULL"}',
      );

      if (content == null || content.isEmpty) {
        Logger.error('Empty response from Groq API');
        Logger.error('Full response: ${response.data}');
        throw const SummarizationException('Empty response from Groq API');
      }

      Logger.info(
        'Summarization completed successfully: ${content.length} characters',
      );
      return content.trim();
    } on AppException catch (e) {
      Logger.error('Summarization failed with AppException', error: e);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Summarization failed with unexpected error',
        error: e,
        stackTrace: stackTrace,
      );
      throw SummarizationException('Failed to summarize text: ${e.toString()}');
    }
  }

  /// Build the strict system prompt
  String _buildSystemPrompt(String language) {
    final languageTag = language.isNotEmpty ? language : 'en';
    return '''
You are an expert Health Summary Assistant designed for patients with low health literacy, especially elderly users. The summary must be empathetic, reassuring, positive, and strictly non-technical. Use a kind, supportive tone. Write the final summary at a Grade 4 (Primary School) reading level. Avoid all medical jargon. If a medical term must be used, follow it immediately with a simple explanation in parentheses. The entire response MUST be in [$languageTag].''';
  }

  /// Create a prompt for summarization
  String _createSummarizationPrompt(String text, String language) {
    return '''
INSTRUCTIONS:

Your task is to summarize the following medical consultation transcript. 
You must extract and output the information using the three specific sections below. 
DO NOT include any introductions, conclusions, or conversational fluff. 
ONLY output the content for the three structured sections.

TRANSCRIPT:

<<< $text >>>

OUTPUT FORMAT:

1. My Visit Today (What Happened?)

* In 1-2 simple sentences, summarize the main problem or reason for the visit.
* Identify the confirmed or suspected diagnosis (use simple language).

2. My Action Plan (What Do I Need to Do?)

* Create a numbered list of **3 to 5 clear, immediate steps** the patient must take.
    1.  [Example: Take this new pill once a day.]
    2.  [Example: Walk for 10 minutes every day.]
    3.  [Example: Finish all the antibiotics.]

3. Next Appointment (When Do I Come Back?)

* Extract the exact date and time mentioned by the doctor. If not mentioned, state: "Please call the clinic to book your next visit."
* Extract the reason for the next visit (e.g., Blood test review).

END RESPONSE:

***''';
  }
}
