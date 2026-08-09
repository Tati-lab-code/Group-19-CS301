import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class QuizProgressService {
  static const String _boxName = 'quizProgress';
  static late final Box<dynamic> _box;

  static Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    Hive.init(documentsDirectory.path);
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static Future<void> saveAttempt({
    required String category,
    required String level,
    required int score,
    required int total,
  }) async {
    final attempt = {
      'category': category,
      'level': level,
      'score': score,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    };
    await _box.add(attempt);
  }

  static List<Map<String, dynamic>> getAllAttempts() {
    final attempts = _box.values.map((entry) {
      if (entry is Map) {
        return Map<String, dynamic>.from(entry.cast<String, dynamic>());
      }
      return <String, dynamic>{};
    }).where((attempt) => attempt.isNotEmpty).toList();

    return attempts.reversed.toList();
  }

  static double getAverageScorePercent() {
    final attempts = getAllAttempts();
    if (attempts.isEmpty) return 0.0;

    final totalPercent = attempts.fold<double>(0.0, (sum, attempt) {
      final score = attempt['score'] as int? ?? 0;
      final total = attempt['total'] as int? ?? 0;
      return total > 0 ? sum + (score / total * 100.0) : sum;
    });

    return totalPercent / attempts.length;
  }

  static int getBestScorePercent() {
    final attempts = getAllAttempts();
    if (attempts.isEmpty) return 0;

    final best = attempts.map<int>((attempt) {
      final score = attempt['score'] as int? ?? 0;
      final total = attempt['total'] as int? ?? 0;
      return total > 0 ? (score / total * 100).round() : 0;
    }).fold<int>(0, (maxValue, scorePercent) => scorePercent > maxValue ? scorePercent : maxValue);

    return best;
  }
}
