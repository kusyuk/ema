import '../../core/utils/result.dart';

/// Repository interface for summarization
abstract class SummarizationRepository {
  Future<Result<String>> summarizeText(String text, {String language = 'en'});
}

