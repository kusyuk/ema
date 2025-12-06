/// Repository interface for summarization
abstract class SummarizationRepository {
  Future<String> summarizeText(String text, {String language = 'en'});
}

