import 'dart:math';

import '../models/phrase.dart';
import '../models/quiz_question.dart';
import 'language_preference_service.dart';
import 'phrasebook_service.dart';

class QuizService {
  final PhrasebookService _phrasebookService = PhrasebookService();
  final Random _random = Random();

  Future<List<QuizQuestion>> generateQuiz(String category, String level) async {
    final selectedLanguage = LanguagePreferenceService.getLanguage();
    final count = _questionCountForLevel(level);
    final phrases = category.toLowerCase() == 'all'
        ? await _phrasebookService.getAllPhrases()
        : await _phrasebookService.getPhrasesByCategory(category);

    if (phrases.isEmpty) return [];

    final selected = List<Phrase>.from(phrases);
    selected.shuffle(_random);
    final quizPhrases = selected.take(min(count, selected.length)).toList();

    final allEnglishTranslations = phrases
        .map((phrase) => phrase.translations['English'] ?? '')
        .where((translation) => translation.isNotEmpty)
        .toSet()
        .toList();

    final questions = <QuizQuestion>[];
    for (var i = 0; i < quizPhrases.length; i++) {
      final phrase = quizPhrases[i];
      if (i.isEven) {
        questions.add(
          _buildMultipleChoiceQuestion(
            phrase,
            allEnglishTranslations,
            selectedLanguage,
          ),
        );
      } else {
        questions.add(_buildFreeRecallQuestion(phrase, selectedLanguage));
      }
    }

    return questions;
  }

  bool checkAnswer(QuizQuestion question, String userAnswer) {
    if (question.type == QuestionType.multipleChoice) {
      return userAnswer == question.correctAnswer;
    }

    String normalize(String value) {
      final trimmed = value.trim();
      final stripped = trimmed.replaceAll(RegExp(r'^[!?.,]+|[!?.,]+\$'), '');
      final collapsed = stripped.replaceAll(RegExp(r'\s+'), ' ');
      return collapsed.toLowerCase();
    }

    return normalize(userAnswer) == normalize(question.correctAnswer);
  }

  double calculateScore(double correctCount, int totalCount) {
    if (totalCount <= 0) return 0.0;
    return (correctCount / totalCount) * 100.0;
  }

  int _questionCountForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 5;
      case 'intermediate':
        return 10;
      case 'advanced':
        return 10;
      default:
        return 5;
    }
  }

  QuizQuestion _buildMultipleChoiceQuestion(
    Phrase phrase,
    List<String> allEnglishTranslations,
    String selectedLanguage,
  ) {
    final correctAnswer = phrase.translations['English'] ?? '';
    final wrongOptions = allEnglishTranslations
        .where(
          (translation) =>
              translation.isNotEmpty && translation != correctAnswer,
        )
        .toList();

    wrongOptions.shuffle(_random);
    final options = [correctAnswer, ...wrongOptions.take(3)].toList();
    options.shuffle(_random);

    return QuizQuestion(
      phraseId: phrase.phraseId,
      type: QuestionType.multipleChoice,
      questionText:
          "What does '${phrase.translations[selectedLanguage] ?? ''}' mean in English?",
      options: options,
      correctAnswer: correctAnswer,
      hint: phrase.getPronunciation(selectedLanguage),
    );
  }

  QuizQuestion _buildFreeRecallQuestion(
    Phrase phrase,
    String selectedLanguage,
  ) {
    final correctAnswer = phrase.translations[selectedLanguage] ?? '';

    return QuizQuestion(
      phraseId: phrase.phraseId,
      type: QuestionType.freeRecall,
      questionText:
          "How do you say '${phrase.translations['English'] ?? ''}' in $selectedLanguage?",
      options: null,
      correctAnswer: correctAnswer,
      hint: phrase.getPronunciation(selectedLanguage),
    );
  }
}
