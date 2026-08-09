import 'package:flutter/material.dart';

import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/phrasebook_screen.dart';
import 'screens/search_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/favorites_service.dart';
import 'services/quiz_progress_service.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesService.init();
  await AuthService.init();
  await QuizProgressService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakZed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D2E)),
        useMaterial3: true,
      ),
      home: AuthService.getCurrentUser() != null ? const HomeScreen() : const WelcomeScreen(),
      routes: {
        '/phrasebook': (_) => const PhrasebookScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/search': (_) => const SearchScreen(),
      },
    );
  }
}
