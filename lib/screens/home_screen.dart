import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/language_preference_service.dart';
import 'profile_screen.dart';
import 'phrasebook_screen.dart';
import 'quiz_setup_screen.dart';
import 'translate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);
    final current = AuthService.getCurrentUser();
    final displayName = current == null ? 'Guest' : (current[0].toUpperCase() + (current.length > 1 ? current.substring(1) : '')) ;
    final selectedLanguage = LanguagePreferenceService.getLanguage();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'SPEAKZED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Regional Zambian Learning Hub',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: navigate to settings
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: lightGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $displayName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome back! Keep practicing a little every day to build confidence.',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: const Text('Daily goal progress', style: TextStyle(color: Colors.white)),
                        backgroundColor: darkGreen,
                        labelStyle: const TextStyle(color: Colors.white),
                        avatar: const Icon(Icons.track_changes, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: lightGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'SpeakZed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PhrasebookScreen()));
                      },
                      child: const Text('Explore Phrasebook'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslateScreen()));
                      },
                      child: const Text('Translator'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizSetupScreen()));
                      },
                      child: const Text('Play quiz challenge'),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _languageRow(context, 'IchiBemba', 'Bemba', selectedLanguage),
                          const SizedBox(height: 8),
                          _languageRow(context, 'ChiNyanja', 'Nyanja', selectedLanguage),
                          const SizedBox(height: 8),
                          _languageRow(context, 'ChiTonga', 'Tonga', selectedLanguage),
                          const SizedBox(height: 8),
                          _languageRow(context, 'English', 'English', selectedLanguage),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _languageRow(BuildContext context, String label, String languageKey, String selectedLanguage) {
    final isSelected = selectedLanguage == languageKey;

    return GestureDetector(
      onTap: () async {
        await LanguagePreferenceService.setLanguage(languageKey);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Display language set to $languageKey'),
            duration: const Duration(milliseconds: 700),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B4D2E) : const Color(0xFFF2F3F5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
