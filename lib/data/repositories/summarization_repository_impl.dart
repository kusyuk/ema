import '../../core/utils/error_handler.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/summarization_repository.dart';
import '../datasources/groq_remote_data_source.dart';

/// Implementation of summarization repository
class SummarizationRepositoryImpl implements SummarizationRepository {
  final GroqRemoteDataSource _remoteDataSource;

  SummarizationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<String>> summarizeText(String text, {String language = 'en'}) async {
    try {
      final summary = await _remoteDataSource.summarizeText(text, language: language);
      return Success(summary);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

