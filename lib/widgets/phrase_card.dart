import 'package:flutter/material.dart';

import '../models/phrase.dart';
import '../services/favorites_service.dart';
import '../services/audio_service.dart';

class PhraseCard extends StatefulWidget {
  final Phrase phrase;
  final String language;

  const PhraseCard({super.key, required this.phrase, required this.language});

  @override
  State<PhraseCard> createState() => _PhraseCardState();
}

class _PhraseCardState extends State<PhraseCard> {
  late bool _isFavorite;
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.isFavorite(widget.phrase.phraseId);
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await FavoritesService.addFavorite(widget.phrase.phraseId);
    } else {
      await FavoritesService.removeFavorite(widget.phrase.phraseId);
    }
  }

  String _lookup(Map<String, String> map, String language) {
    // case-insensitive key lookup
    final key = map.keys.firstWhere(
      (k) => k.toLowerCase() == language.toLowerCase(),
      orElse: () => '',
    );
    if (key.isEmpty) return '';
    return map[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);

    final eng = _lookup(widget.phrase.translations, 'English');
    final local = _lookup(widget.phrase.translations, widget.language);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Chip(
                label: Text(
                  widget.phrase.category,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                backgroundColor: lightGrey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              eng,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.phrase.description,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: darkGreen,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final toSpeak = local.isNotEmpty ? local : eng;
                        await _audioService.playPronunciation(
                          widget.phrase.phraseId,
                          toSpeak,
                          widget.language,
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
