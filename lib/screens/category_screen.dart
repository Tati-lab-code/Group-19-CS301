import 'package:flutter/material.dart';

import '../models/phrase.dart';
import '../services/phrasebook_service.dart';
import '../widgets/phrase_card.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);

    final service = PhrasebookService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(categoryName),
      ),
      body: Container(
        color: lightGrey,
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Phrase>>(
          future: service.getPhrasesByCategory(categoryName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }

            final phrases = snapshot.data ?? [];
            return ListView.separated(
              itemCount: phrases.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = phrases[index];
                return PhraseCard(phrase: p, language: 'Bemba');
              },
            );
          },
        ),
      ),
    );
  }
}
