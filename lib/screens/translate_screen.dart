import 'package:flutter/material.dart';

import '../models/phrase.dart';
import '../services/audio_service.dart';
import '../services/favorites_service.dart';
import '../services/phrasebook_service.dart';
import 'phrasebook_screen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  final _practiceLanguages = const ['Bemba', 'Nyanja', 'Tonga'];
  final _translateLanguages = const ['English', 'Bemba', 'Nyanja', 'Tonga'];
  final _translateController = TextEditingController();
  final _service = PhrasebookService();
  final _audioService = AudioService();

  late final Future<List<Phrase>> _allPhrasesFuture;
  int _selectedPracticeLanguageIndex = 0;
  int _selectedCardIndex = 0;
  bool _cardFlipped = false;

  String _fromLanguage = 'English';
  String _toLanguage = 'Bemba';
  Phrase? _translateResult;
  String? _translateMessage;
  bool _isSearching = false;

  static const Color _darkGreen = Color(0xFF1B4D2E);
  static const Color _lightGrey = Color(0xFFF2F3F5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allPhrasesFuture = _service.getAllPhrases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _translateController.dispose();
    super.dispose();
  }

  String _translationFor(Phrase phrase, String language) {
    return phrase.translations[language] ?? '';
  }

  String _pronunciationFor(Phrase phrase, String language) {
    return phrase.pronunciation[language] ?? '';
  }

  Future<void> _runTranslationSearch() async {
    final query = _translateController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _translateResult = null;
        _translateMessage = 'Type a phrase to translate.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _translateResult = null;
      _translateMessage = null;
    });

    final phrases = await _allPhrasesFuture;
    final lowerQuery = query.toLowerCase();

    // Local phrasebook lookup only: this is not a real machine translation engine.
    Phrase? match;
    for (final phrase in phrases) {
      final fromText = phrase.translations[_fromLanguage]?.toLowerCase() ?? '';
      if (fromText == lowerQuery) {
        match = phrase;
        break;
      }
    }

    if (match == null) {
      for (final phrase in phrases) {
        final fromText = phrase.translations[_fromLanguage]?.toLowerCase() ?? '';
        if (fromText.contains(lowerQuery) || lowerQuery.contains(fromText)) {
          match = phrase;
          break;
        }
      }
    }

    setState(() {
      _isSearching = false;
      if (match != null) {
        _translateResult = match;
        _translateMessage = null;
      } else {
        _translateResult = null;
        _translateMessage = 'No exact match found in the phrasebook. Try browsing categories instead.';
      }
    });
  }

  void _selectPracticeLanguage(int index) {
    setState(() {
      _selectedPracticeLanguageIndex = index;
      _selectedCardIndex = 0;
      _cardFlipped = false;
    });
  }

  void _goToCard(int nextIndex, int total) {
    setState(() {
      _selectedCardIndex = nextIndex.clamp(0, total - 1);
      _cardFlipped = false;
    });
  }

  void _toggleFavorite(Phrase phrase) {
    final isFav = FavoritesService.isFavorite(phrase.phraseId);
    if (isFav) {
      FavoritesService.removeFavorite(phrase.phraseId);
    } else {
      FavoritesService.addFavorite(phrase.phraseId);
    }
    setState(() {});
  }

  void _playPronunciation(Phrase phrase, String language) {
    final pron = _pronunciationFor(phrase, language);
    final text = pron.isNotEmpty ? pron : _translationFor(phrase, language);
    _audioService.playPronunciation(text, language);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPEAKZED', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Regional Zambian Learning Hub', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Material(
            color: _darkGreen,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade300,
              tabs: const [
                Tab(text: 'Study Flashcards'),
                Tab(text: 'Translate'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFlashcardsTab(),
                _buildTranslateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsTab() {
    return FutureBuilder<List<Phrase>>(
      future: _allPhrasesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final phrases = snapshot.data ?? [];
        if (phrases.isEmpty) {
          return const Center(child: Text('No phrases available.'));
        }

        final language = _practiceLanguages[_selectedPracticeLanguageIndex];
        final phrase = phrases[_selectedCardIndex.clamp(0, phrases.length - 1)];
        final translation = _translationFor(phrase, language);
        final pronunciation = _pronunciationFor(phrase, language);

        return Container(
          color: _lightGrey,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Flashcards Deck', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('INTERACTIVE STUDY MODE', style: TextStyle(fontSize: 12, letterSpacing: 1.2, color: Colors.black54)),
              const SizedBox(height: 12),
              const Text('select your practice language, view the English phrase and click to flip and review translations.', style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(_practiceLanguages.length, (index) {
                  final name = _practiceLanguages[index];
                  final selected = index == _selectedPracticeLanguageIndex;
                  return ChoiceChip(
                    label: Text(name, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                    selected: selected,
                    selectedColor: _darkGreen,
                    backgroundColor: Colors.white,
                    onSelected: (_) => _selectPracticeLanguage(index),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _darkGreen,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Translation($language)', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                          Text('card ${_selectedCardIndex + 1} of ${phrases.length}', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _cardFlipped = !_cardFlipped;
                            });
                          },
                          child: Center(
                            child: Text(
                              _cardFlipped ? translation : phrase.translations['English']?.toUpperCase() ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      if (_cardFlipped) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _playPronunciation(phrase, language),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Phonetic: $pronunciation',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('click card to return', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                      ],
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: _selectedCardIndex > 0 ? () => _goToCard(_selectedCardIndex - 1, phrases.length) : null,
                      child: const Text('BACK'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _darkGreen),
                      onPressed: () {
                        setState(() {
                          _cardFlipped = !_cardFlipped;
                        });
                      },
                      child: const Text('FLIP CARD'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: _selectedCardIndex < phrases.length - 1 ? () => _goToCard(_selectedCardIndex + 1, phrases.length) : null,
                      child: const Text('NEXT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTranslateTab() {
    return Container(
      color: _lightGrey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Translate from', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _translateLanguages.map((lang) {
                final selected = _fromLanguage == lang;
                return ChoiceChip(
                  label: Text(lang, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                  selected: selected,
                  selectedColor: _darkGreen,
                  backgroundColor: Colors.white,
                  onSelected: (_) {
                    setState(() {
                      _fromLanguage = lang;
                      if (_fromLanguage == _toLanguage) {
                        _toLanguage = _translateLanguages.firstWhere((item) => item != lang);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Translate to', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _translateLanguages.map((lang) {
                final selected = _toLanguage == lang;
                return ChoiceChip(
                  label: Text(lang, style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                  selected: selected,
                  selectedColor: _darkGreen,
                  backgroundColor: Colors.white,
                  onSelected: (_) {
                    if (lang == _fromLanguage) return;
                    setState(() {
                      _toLanguage = lang;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _translateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Type a phrase in $_fromLanguage',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _darkGreen),
              onPressed: _runTranslationSearch,
              child: const Text('Translate'),
            ),
            const SizedBox(height: 16),
            if (_isSearching) const Center(child: CircularProgressIndicator()),
            if (!_isSearching && _translateResult != null) _buildTranslationResult(),
            if (!_isSearching && _translateResult == null && _translateMessage != null) _buildTranslateMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationResult() {
    final phrase = _translateResult!;
    final isFavorite = FavoritesService.isFavorite(phrase.phraseId);
    final translation = _translationFor(phrase, _toLanguage);
    final pronunciation = _pronunciationFor(phrase, _toLanguage);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(translation, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Phonetic: $pronunciation', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () => _playPronunciation(phrase, _toLanguage),
                icon: const Icon(Icons.play_arrow, color: _darkGreen),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  _toggleFavorite(phrase);
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: _darkGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_translateMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        if (_translateResult == null)
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PhrasebookScreen()));
            },
            child: const Text('Browse phrasebook'),
          ),
      ],
    );
  }
}
