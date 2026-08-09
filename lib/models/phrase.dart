class Phrase {
  final String phraseId;
  final String category;
  final String description;
  final Map<String, String> translations;
  final Map<String, String> pronunciation;

  Phrase({
    required this.phraseId,
    required this.category,
    required this.description,
    required this.translations,
    required this.pronunciation,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) {
    final translations = Map<String, dynamic>.from(json['translations'] as Map<String, dynamic>);
    final pronunciation = Map<String, dynamic>.from(json['pronunciation'] as Map<String, dynamic>);

    return Phrase(
      phraseId: json['phraseId'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      translations: translations.map((key, value) => MapEntry(key, value as String)),
      pronunciation: pronunciation.map((key, value) => MapEntry(key, value as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phraseId': phraseId,
      'category': category,
      'description': description,
      'translations': translations,
      'pronunciation': pronunciation,
    };
  }
}
