import 'package:flutter/material.dart';

import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/phrasebook_screen.dart';
import '../screens/search_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const Color _darkGreen = Color(0xFF1B4D2E);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: _darkGreen,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == currentIndex) return;

        Widget destination;
        switch (index) {
          case 0:
            destination = const HomeScreen();
            break;
          case 1:
            destination = const PhrasebookScreen();
            break;
          case 2:
            destination = const FavoritesScreen();
            break;
          case 3:
            destination = const SearchScreen();
            break;
          default:
            return;
        }

        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Book'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }
}
