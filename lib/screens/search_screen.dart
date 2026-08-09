import 'package:flutter/material.dart';

import '../models/phrase.dart';
import '../services/phrasebook_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/phrase_card.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = PhrasebookService();
  List<Phrase> _results = [];
  bool _loading = false;

  Future<void> _doSearch(String q) async {
    final term = q.trim();
    if (term.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final res = await _service.searchPhrases(term);
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);

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
        title: const Text('Search'),
      ),
      body: Container(
        color: lightGrey,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (v) => _doSearch(v),
              decoration: InputDecoration(
                hintText: 'Search for a phrase...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Builder(builder: (context) {
                if (_controller.text.trim().isEmpty) {
                  return const Center(child: Text('Search for a phrase...'));
                }
                if (_loading) return const Center(child: CircularProgressIndicator());
                if (_results.isEmpty) return const Center(child: Text('No results found.'));

                return ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return PhraseCard(phrase: _results[index], language: 'Bemba');
                  },
                );
              }),
            )
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
