import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/quiz_question.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/language_preference_service.dart';
import '../services/pronunciation_rating_service.dart';
import '../services/quiz_service.dart';
import 'quiz_results_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String category;
  final String level;

  const QuizQuestionScreen({
    super.key,
    required this.questions,
    required this.category,
    required this.level,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  static const Color _darkGreen = Color(0xFF1B4D2E);
  static const Color _lightGrey = Color(0xFFF2F3F5);

  final QuizService _quizService = QuizService();
  final TextEditingController _answerController = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _recordingPlayer = AudioPlayer();

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;
  bool _answerSubmitted = false;
  bool _showHint = false;
  bool _isRecording = false;
  bool _isComparing = false;
  bool _showRating = false;
  bool _isStoppingRecording = false;
  Timer? _recordingTimer;

  // Free-recall specific: tracks whether the typed answer was correct,
  // once submitted, so we can show feedback before advancing.
  bool? _freeRecallCorrect;

  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;
  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _recordingPlayer.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (_isComparing) return;

    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record.'),
            ),
          );
        }
        return;
      }

      final temporaryDirectory = await getTemporaryDirectory();
      final recordingPath =
          '${temporaryDirectory.path}/speakzed_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: recordingPath,
      );

      if (!mounted) return;
      setState(() => _isRecording = true);
      _recordingTimer = Timer(const Duration(seconds: 6), () {
        if (_isRecording) _stopRecording();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start recording.')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isStoppingRecording) return;
    _isStoppingRecording = true;
    _recordingTimer?.cancel();

    try {
      final recordingPath = await _recorder.stop();
      if (mounted) setState(() => _isRecording = false);
      if (recordingPath != null && mounted) {
        await _playComparison(recordingPath);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to finish recording.')),
        );
      }
    } finally {
      _isStoppingRecording = false;
    }
  }

  Future<void> _playComparison(String recordingPath) async {
    if (!mounted) return;
    setState(() => _isComparing = true);
    var playbackCompleted = false;

    try {
      await _recordingPlayer.play(DeviceFileSource(recordingPath));
      await _recordingPlayer.onPlayerComplete.first;
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final language = LanguagePreferenceService.getLanguage();
      final nativeText = _currentQuestion.correctAnswer;
      await AudioService().playPronunciation(
        _currentQuestion.phraseId,
        nativeText,
        language,
      );
      playbackCompleted = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to play the pronunciation comparison.'),
          ),
        );
      }
    } finally {
      try {
        await File(recordingPath).delete();
      } catch (_) {
        // The temporary file is best-effort cleanup only.
      }
      if (mounted) {
        setState(() {
          _isComparing = false;
          _showRating = playbackCompleted;
        });
      }
    }
  }

  Future<void> _saveRating(int rating) async {
    final username = AuthService.getCurrentUser();
    if (username == null || username.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in to save pronunciation ratings.'),
          ),
        );
      }
      return;
    }

    final language = LanguagePreferenceService.getLanguage();
    await PronunciationRatingService.saveRating(
      username: username,
      phraseId: _currentQuestion.phraseId,
      language: language,
      rating: rating,
    );

    if (!mounted) return;
    setState(() => _showRating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pronunciation rating saved.')),
    );
  }

  void _selectOption(String option) {
    if (_answerSubmitted ||
        _currentQuestion.type != QuestionType.multipleChoice) {
      return;
    }

    setState(() {
      _selectedOption = option;
      _answerSubmitted = true;
      if (_quizService.checkAnswer(_currentQuestion, option)) {
        _score += 1;
      }
    });
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  // For free-recall: first tap of the action button checks the answer and
  // reveals feedback (does NOT advance). Second tap (button now reads NEXT)
  // moves on to the next question.
  void _submitFreeRecall() {
    final answerText = _answerController.text.trim();
    if (answerText.isEmpty) return;

    final isCorrect = _quizService.checkAnswer(_currentQuestion, answerText);
    setState(() {
      _answerSubmitted = true;
      _freeRecallCorrect = isCorrect;
      if (isCorrect) _score += 1;
    });
  }

  void _advance() {
    if (_isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultsScreen(
            correctCount: _score,
            totalCount: widget.questions.length,
            category: widget.category,
            level: widget.level,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex += 1;
      _selectedOption = null;
      _answerSubmitted = false;
      _freeRecallCorrect = null;
      _answerController.clear();
      _showHint = false;
      _showRating = false;
    });
  }

  void _onActionButtonPressed() {
    if (_currentQuestion.type == QuestionType.freeRecall && !_answerSubmitted) {
      _submitFreeRecall();
      return;
    }
    _advance();
  }

  bool get _actionEnabled {
    if (_currentQuestion.type == QuestionType.multipleChoice) {
      return _selectedOption != null;
    }
    // Free-recall: enabled once there's text (to submit), and always
    // enabled once submitted (to advance).
    return _answerSubmitted || _answerController.text.trim().isNotEmpty;
  }

  String get _actionLabel {
    if (_currentQuestion.type == QuestionType.freeRecall && !_answerSubmitted) {
      return 'CHECK ANSWER';
    }
    return _isLastQuestion ? 'SEE RESULTS' : 'NEXT';
  }

  void _handleBack() {
    final rootContext = context;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Leave quiz?'),
          content: const Text(
            "Leave quiz? Your progress on this attempt won't be saved.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(rootContext);
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPEAK ZED', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text(
              'Regional Zambian Learning Hub',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgressRow(),
                      const SizedBox(height: 16),
                      _buildQuestionCard(),
                      const SizedBox(height: 20),
                      if (_currentQuestion.type == QuestionType.multipleChoice)
                        _buildOptionsGrid(),
                      if (_currentQuestion.type == QuestionType.freeRecall)
                        _buildFreeRecallInput(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: _actionEnabled ? _onActionButtonPressed : null,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  _actionLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow() {
    final completed = _currentIndex + 1;
    final total = widget.questions.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Progress: Question $completed of $total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Score: $_score/$total',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4D2E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(_darkGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final label = _currentQuestion.type == QuestionType.multipleChoice
        ? 'TRANSLATE THE PHRASE'
        : 'TYPE YOUR ANSWER';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2E8B2E),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.questionText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    final options = _currentQuestion.options ?? [];
    const labels = ['A', 'B', 'C', 'D'];

    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final isSelected = _selectedOption == option;
        final isCorrect = option == _currentQuestion.correctAnswer;
        final isWrongSelection = _answerSubmitted && isSelected && !isCorrect;
        final showCorrect = _answerSubmitted && isCorrect;

        final borderColor = showCorrect
            ? _darkGreen
            : isWrongSelection
            ? Colors.red.shade200
            : Colors.grey.shade300;
        final backgroundColor = showCorrect
            ? Colors.green.shade50
            : isWrongSelection
            ? Colors.red.shade50
            : Colors.white;

        return GestureDetector(
          onTap: () => _selectOption(option),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: borderColor,
                width: isSelected || showCorrect ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: showCorrect
                        ? _darkGreen
                        : isWrongSelection
                        ? Colors.red
                        : Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: showCorrect || isWrongSelection
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
                if (showCorrect)
                  const Icon(Icons.check_circle, color: _darkGreen)
                else if (isWrongSelection)
                  const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFreeRecallInput() {
    final locked = _answerSubmitted;
    final isCorrect = _freeRecallCorrect == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: locked
                ? (isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: locked
                  ? (isCorrect ? _darkGreen : Colors.red.shade200)
                  : Colors.grey.shade300,
              width: locked ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _answerController,
            enabled: !locked,
            decoration: const InputDecoration(
              hintText: 'Type your answer here...',
              border: InputBorder.none,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        if (_showRating) _buildRatingOptions(),
        const SizedBox(height: 12),
        if (!locked) ...[
          Row(
            children: [
              IconButton(
                onPressed: _isComparing ? null : _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : const Color(0xFF2E8B2E),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording ? 'Recording... tap to stop' : 'or tap to record',
                style: TextStyle(
                  color: _isRecording ? Colors.red : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleHint,
            child: Row(
              children: const [
                Icon(Icons.help_outline, color: Color(0xFF2E8B2E), size: 18),
                SizedBox(width: 6),
                Text(
                  'Show hint',
                  style: TextStyle(
                    color: Color(0xFF2E8B2E),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_showHint && _currentQuestion.hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                _currentQuestion.hint!,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
        ] else
          // Feedback shown after the answer is checked.
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? _darkGreen : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'Correct!'
                      : 'Not quite — correct answer: ${_currentQuestion.correctAnswer}',
                  style: TextStyle(
                    color: isCorrect ? _darkGreen : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRatingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How did it sound?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _ratingButton(0, Icons.sentiment_dissatisfied, Colors.red),
            _ratingButton(1, Icons.sentiment_neutral, Colors.orange),
            _ratingButton(2, Icons.sentiment_satisfied, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _ratingButton(int rating, IconData icon, Color color) {
    return IconButton(
      tooltip: ['Needs work', 'Almost there', 'Sounds good'][rating],
      onPressed: () => _saveRating(rating),
      icon: Icon(icon, color: color, size: 32),
    );
  }
}
