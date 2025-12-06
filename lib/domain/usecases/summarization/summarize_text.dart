import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../repositories/summarization_repository.dart';

/// Parameters for summarizing text
class SummarizeTextParams {
  final String text;
  final String language;

  const SummarizeTextParams({
    required this.text,
    this.language = 'en',
  });
}

/// Use case for summarizing text
class SummarizeText implements UseCase<String, SummarizeTextParams> {
  final SummarizationRepository _repository;

  SummarizeText(this._repository);

  @override
  Future<Result<String>> call(SummarizeTextParams params) async {
    return await _repository.summarizeText(
      params.text,
      language: params.language,
    );
  }
}

