class Phrase {
  final String phraseId;
  final String category;
  final String description;
  final Map<String, String> translations;
  final Map<String, String?> pronunciation;

  Phrase({
    required this.phraseId,
    required this.category,
    required this.description,
    required this.translations,
    required this.pronunciation,
  });

  factory Phrase.fromJson(Map<String, dynamic> json) {
    final phraseId = json['phraseId'];
    if (phraseId is! String || phraseId.isEmpty) {
      throw FormatException(
        'Missing or invalid phraseId in phrase record: $json',
      );
    }

    final categoryValue = json['category'];
    final category = categoryValue is String ? categoryValue : '';

    final translationsValue = json['translations'];
    if (translationsValue is! Map) {
      throw FormatException(
        'Missing or invalid translations in phrase record: $json',
      );
    }
    final translations = Map<String, dynamic>.from(translationsValue);
    final pronunciation = Map<String, dynamic>.from(
      (json['pronunciation'] as Map?) ?? <String, dynamic>{},
    );

    return Phrase(
      phraseId: phraseId,
      category: category,
      description: json['description'] as String? ?? '',
      translations: translations.map((key, value) {
        if (value == null) return MapEntry(key, '');
        if (value is String) return MapEntry(key, value);
        throw FormatException(
          'Invalid translation value for "$key" in phrase record: $json',
        );
      }),
      pronunciation: pronunciation.map(
        (key, value) => MapEntry(key, value as String?),
      ),
    );
  }

  String getPronunciation(String language) {
    final key = pronunciation.keys.firstWhere(
      (key) => key.toLowerCase() == language.toLowerCase(),
      orElse: () => '',
    );
    return pronunciation[key] ?? '';
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
