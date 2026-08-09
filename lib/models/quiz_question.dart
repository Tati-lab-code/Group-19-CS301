enum QuestionType { multipleChoice, freeRecall }

class QuizQuestion {
  final String phraseId;
  final QuestionType type;
  final String questionText;
  final List<String>? options;
  final String correctAnswer;
  final String? hint;

  QuizQuestion({
    required this.phraseId,
    required this.type,
    required this.questionText,
    this.options,
    required this.correctAnswer,
    this.hint,
  });
}
