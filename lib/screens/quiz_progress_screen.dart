import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/quiz_progress_service.dart';

class QuizProgressScreen extends StatefulWidget {
  const QuizProgressScreen({super.key});

  @override
  State<QuizProgressScreen> createState() => _QuizProgressScreenState();
}

class _QuizProgressScreenState extends State<QuizProgressScreen> {
  static const Color _darkGreen = Color(0xFF1B4D2E);

  late final List<Map<String, dynamic>> _attempts;
  late final int _averageScore;
  late final int _bestScore;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final attempts = QuizProgressService.getAllAttempts();
    _attempts = attempts;
    _averageScore = QuizProgressService.getAverageScorePercent().round();
    _bestScore = QuizProgressService.getBestScorePercent();
  }

  String _formatDate(String isoDate) {
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat.yMMMd().format(parsed);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard('Average Score', '$_averageScore%')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Best Score', '$_bestScore%')),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _attempts.isEmpty
                    ? const Center(
                        child: Text(
                          'No quiz attempts yet — play a quiz to see your progress here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _attempts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final attempt = _attempts[index];
                          final category = attempt['category'] as String? ?? 'All';
                          final level = attempt['level'] as String? ?? 'Beginner';
                          final score = attempt['score'] as int? ?? 0;
                          final total = attempt['total'] as int? ?? 0;
                          final percent = total > 0 ? (score / total * 100).round() : 0;
                          final date = _formatDate(attempt['date'] as String? ?? '');

                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                const BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '$percent%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D2E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Level: $level'),
                                const SizedBox(height: 8),
                                Text('$score/$total correct', style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 8),
                                Text(date, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4D2E))),
        ],
      ),
    );
  }
}
