import '../../core/constants/app_constants.dart';
import '../../core/constants/env_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/file_storage.dart';
import '../../core/utils/logger.dart';
import '../utils/typedefs.dart';
// FormData and MultipartFile are exported from api_client.dart

/// Remote data source for Groq Transcription API
abstract class GroqTranscriptionRemoteDataSource {
  Future<String> transcribeAudio(String audioFilePath);
}

/// Implementation of Groq transcription remote data source
class GroqTranscriptionRemoteDataSourceImpl implements GroqTranscriptionRemoteDataSource {
  final ApiClient _apiClient;

  GroqTranscriptionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      Logger.info('Starting Groq transcription for file: $audioFilePath');
      
      // Check API key
      final apiKey = EnvConstants.groqApiKey;
      Logger.info('Groq API key check: ${apiKey.isEmpty ? "MISSING" : "PRESENT (${apiKey.length} chars)"}');
      if (apiKey.isEmpty) {
        Logger.error('Groq API key not configured');
        Logger.error('Please ensure GROQ_API_KEY is set in .env file');
        throw const TranscriptionException('Groq API key not configured. Please check your .env file.');
      }

      // Read audio file
      Logger.info('Getting audio file from storage...');
      final audioFile = FileStorage.getAudioFile(audioFilePath);
      Logger.info('Audio file path: ${audioFile.path}');
      
      Logger.info('Checking if audio file exists...');
      final fileExists = await audioFile.exists();
      Logger.info('File exists: $fileExists');
      if (!fileExists) {
        Logger.error('Audio file not found at path: ${audioFile.path}');
        throw TranscriptionException('Audio file not found: ${audioFile.path}');
      }

      // Get file size
      final fileSize = await audioFile.length();
      final fileSizeKB = fileSize / 1024;
      Logger.info('Audio file size: $fileSize bytes (${fileSizeKB.toStringAsFixed(2)} KB)');
      
      // Check if file size is reasonable (warn if > 25MB, which is Groq's limit)
      if (fileSizeKB > 25000) {
        Logger.warning('File size is very large (${fileSizeKB.toStringAsFixed(2)} KB). Groq has a 25MB limit per file.');
      }

      Logger.info('Reading audio file bytes...');
      final audioBytes = await audioFile.readAsBytes();
      Logger.info('Audio bytes read: ${audioBytes.length} bytes');

      Logger.info('Creating multipart form data...');
      final fileName = audioFile.path.split('/').last;
      Logger.info('Filename for upload: $fileName');
      
      // Create multipart form data for Groq API
      // Groq uses OpenAI-compatible API format
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioBytes,
          filename: fileName,
        ),
        'model': 'whisper-large-v3', // Use high-accuracy Whisper model
        // Optional: 'language' parameter can be added if known
        // Optional: 'prompt' parameter for context
        // Optional: 'response_format' for structured output
      });
      Logger.info('Form data created successfully');

      // Make API request to Groq transcription endpoint
      // Groq uses OpenAI-compatible endpoint: /v1/audio/transcriptions
      final apiUrl = '${AppConstants.groqBaseUrl}/audio/transcriptions';
      Logger.info('Making API request to: $apiUrl');
      Logger.info('Using model: whisper-large-v3');
      Logger.info('Request timeout: 5 minutes');
      
      try {
        final response = await _apiClient.post<JsonMap>(
          apiUrl,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
            },
            contentType: 'multipart/form-data',
            receiveTimeout: const Duration(minutes: 5), // Transcription can take time
          ),
        );
        
        Logger.info('API request completed successfully');
        Logger.info('Response status code: ${response.statusCode}');
        Logger.info('Response data type: ${response.data.runtimeType}');
        Logger.info('Response data: ${response.data}');

        // Extract transcription from response
        // Groq/OpenAI format: { "text": "transcribed text here" }
        final transcription = response.data?['text'] as String?;
        Logger.info('Transcription extracted: ${transcription != null ? "PRESENT (${transcription.length} chars)" : "NULL"}');
        
        if (transcription == null || transcription.isEmpty) {
          Logger.error('Empty transcription response from Groq');
          Logger.error('Full response: ${response.data}');
          throw TranscriptionException('Empty transcription response from Groq. Response: ${response.data}');
        }

        Logger.info('Transcription completed successfully: ${transcription.length} characters');
        return transcription.trim();
      } on AppException catch (e) {
        Logger.error('API request failed with AppException', error: e);
        rethrow;
      } catch (e, stackTrace) {
        Logger.error('API request failed with unexpected error', error: e, stackTrace: stackTrace);
        throw TranscriptionException('API request failed: ${e.toString()}');
      }
    } on AppException catch (e) {
      Logger.error('Transcription failed with AppException', error: e);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Transcription failed with unexpected error', error: e, stackTrace: stackTrace);
      throw TranscriptionException('Failed to transcribe audio: ${e.toString()}');
    }
  }
}

