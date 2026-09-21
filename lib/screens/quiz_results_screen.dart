import 'package:flutter/material.dart';

import '../services/quiz_progress_service.dart';
import '../services/quiz_service.dart';
import 'home_screen.dart';
import 'quiz_setup_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  final double correctCount;
  final int totalCount;
  final String category;
  final String level;

  const QuizResultsScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
    required this.category,
    required this.level,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  String getFeedbackMessage(int percentage) {
    if (percentage >= 80) {
      return 'Excellent work!';
    }
    if (percentage >= 50) {
      return 'Good effort, keep practicing!';
    }
    return 'Keep studying, you\'ll get there!';
  }

  @override
  void initState() {
    super.initState();
    QuizProgressService.saveAttempt(
      category: widget.category,
      level: widget.level,
      score: widget.correctCount,
      total: widget.totalCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = QuizService()
        .calculateScore(widget.correctCount, widget.totalCount)
        .round();
    final scoreText = widget.correctCount == widget.correctCount.roundToDouble()
      ? widget.correctCount.toStringAsFixed(0)
      : widget.correctCount.toStringAsFixed(1);
    final feedback = getFeedbackMessage(percentage);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quiz Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Quiz Results',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(27, 77, 46, 0.1),
                  ),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4D2E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                feedback,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$scoreText out of ${widget.totalCount} correct',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
                  );
                },
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
