import 'package:flutter/material.dart';

import '../services/phrasebook_service.dart';
import '../services/quiz_service.dart';
import 'quiz_progress_screen.dart';
import 'quiz_question_screen.dart';
import 'profile_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  static const Color _darkGreen = Color(0xFF1B4D2E);
  static const Color _buttonGreen = Color(0xFF2E8B2E);

  final PhrasebookService _phrasebookService = PhrasebookService();
  final QuizService _quizService = QuizService();

  String _selectedCategory = 'All';
  String _selectedLevel = 'Beginner';
  List<String> _categories = ['All'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _phrasebookService.getCategories();
    setState(() {
      _categories = ['All', ...categories];
    });
  }

  Future<void> _showCategoryPicker() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map((category) {
              return ListTile(
                title: Text(category),
                onTap: () => Navigator.pop(context, category),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selection != null) {
      setState(() {
        _selectedCategory = selection;
      });
    }
  }

  Future<void> _showLevelPicker() async {
    final levels = ['Beginner', 'Intermediate'];
    final selection = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: levels.map((level) {
              return ListTile(
                title: Text(level),
                onTap: () => Navigator.pop(context, level),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selection != null) {
      setState(() {
        _selectedLevel = selection;
      });
    }
  }

  Future<void> _startQuiz() async {
    setState(() {
      _isLoading = true;
    });

    final quizQuestions = await _quizService.generateQuiz(_selectedCategory, _selectedLevel);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(
          questions: quizQuestions,
          category: _selectedCategory,
          level: _selectedLevel,
        ),
      ),
    );
  }

  void _showProgressPlaceholder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizProgressScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _darkGreen,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(backgroundColor: Colors.white24, child: const Icon(Icons.person, color: Colors.white)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPEAK ZED', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Regional Zambian Learning Hub', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'QUIZ CHALLENGE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _buildSelectionButton(
                label: 'Category: $_selectedCategory',
                onPressed: _showCategoryPicker,
              ),
              const SizedBox(height: 16),
              _buildSelectionButton(
                label: 'Level: $_selectedLevel',
                onPressed: _showLevelPicker,
              ),
              const Spacer(),
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: _isLoading ? null : _startQuiz,
                      child: const Text('START'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: _showProgressPlaceholder,
                      child: const Text('View Progress'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
