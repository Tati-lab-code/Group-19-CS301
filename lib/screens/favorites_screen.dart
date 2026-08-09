import 'package:flutter/material.dart';

import '../models/phrase.dart';
import '../services/phrasebook_service.dart';
import '../services/favorites_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import '../widgets/phrase_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);

    final service = PhrasebookService();
    final favIds = FavoritesService.getFavoriteIds();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(backgroundColor: Colors.white24, child: const Icon(Icons.person, color: Colors.white)),
          ),
        ),
        title: const Text('Favorites'),
      ),
      body: Container(
        color: lightGrey,
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Phrase>>(
          future: service.getAllPhrases(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }

            final all = snapshot.data ?? [];
            final favorites = all.where((p) => favIds.contains(p.phraseId)).toList();

            if (favorites.isEmpty) {
              return const Center(
                child: Text('No favorites yet — tap the heart icon on any phrase to save it here.'),
              );
            }

            return ListView.separated(
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return PhraseCard(phrase: favorites[index], language: 'Bemba');
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
