import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/phrase.dart';

class PhrasebookService {
  static const String _phraseAssetPath = 'assets/data/phrases.json';
  List<Phrase>? _cachedPhrases;

  Future<List<Phrase>> _loadPhrases() async {
    if (_cachedPhrases != null) {
      return _cachedPhrases!;
    }

    final jsonString = await rootBundle.loadString(_phraseAssetPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    _cachedPhrases = decoded
        .map((entry) => Phrase.fromJson(entry as Map<String, dynamic>))
        .toList();

    return _cachedPhrases!;
  }

  Future<List<Phrase>> getAllPhrases() => _loadPhrases();

  Future<List<Phrase>> getPhrasesByCategory(String category) async {
    final phrases = await _loadPhrases();
    final lowerCategory = category.toLowerCase();
    return phrases
        .where((phrase) => phrase.category.toLowerCase() == lowerCategory)
        .toList();
  }

  Future<List<String>> getCategories() async {
    final phrases = await _loadPhrases();
    final categories = phrases.map((phrase) => phrase.category).toSet().toList();
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  Future<List<Phrase>> searchPhrases(String keyword) async {
    final phrases = await _loadPhrases();
    final lowerKeyword = keyword.toLowerCase();
    return phrases.where((phrase) {
      return phrase.translations.values
          .any((translation) => translation.toLowerCase().contains(lowerKeyword));
    }).toList();
  }
}
