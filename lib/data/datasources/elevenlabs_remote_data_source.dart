import '../../core/constants/app_constants.dart';
import '../../core/constants/env_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/file_storage.dart';
import '../../core/utils/logger.dart';
import '../utils/typedefs.dart';

/// Remote data source for ElevenLabs API
abstract class ElevenLabsRemoteDataSource {
  Future<String> transcribeAudio(String audioFilePath);
}

/// Implementation of ElevenLabs remote data source
class ElevenLabsRemoteDataSourceImpl implements ElevenLabsRemoteDataSource {
  final ApiClient _apiClient;

  ElevenLabsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      final apiKey = EnvConstants.elevenlabsApiKey;
      if (apiKey.isEmpty) {
        throw const TranscriptionException('ElevenLabs API key not configured');
      }

      // Read audio file
      final audioFile = FileStorage.getAudioFile(audioFilePath);
      if (!await audioFile.exists()) {
        throw const TranscriptionException('Audio file not found');
      }

      final audioBytes = await audioFile.readAsBytes();
      Logger.info('Uploading audio file for transcription: ${audioFile.path}');

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioBytes,
          filename: audioFile.path.split('/').last,
        ),
        'model': 'eleven_multilingual_v2', // Use multilingual model
      });

      // Make API request to ElevenLabs transcription endpoint
      final response = await _apiClient.post<JsonMap>(
        '${AppConstants.elevenlabsBaseUrl}/speech-to-text',
        data: formData,
        options: Options(
          headers: {
            'xi-api-key': apiKey,
          },
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(minutes: 5), // Transcription can take time
        ),
      );

      // Extract transcription from response
      final transcription = response.data?['text'] as String?;
      if (transcription == null || transcription.isEmpty) {
        throw const TranscriptionException('Empty transcription response from ElevenLabs');
      }

      Logger.info('Transcription completed successfully');
      return transcription.trim();
    } on AppException {
      rethrow;
    } catch (e) {
      Logger.error('Transcription failed', error: e);
      throw TranscriptionException('Failed to transcribe audio: ${e.toString()}');
    }
  }
}
