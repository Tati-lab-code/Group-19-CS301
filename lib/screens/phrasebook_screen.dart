import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import '../services/phrasebook_service.dart';
import 'category_screen.dart';

class PhrasebookScreen extends StatelessWidget {
  const PhrasebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);

    final service = PhrasebookService();

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
        title: const Text('Phrasebook'),
      ),
      body: Container(
        color: lightGrey,
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<String>>(
          future: service.getCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }

            final categories = snapshot.data ?? [];
            return ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final name = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(categoryName: name)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
