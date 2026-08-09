import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/quiz_progress_service.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _initials(String username) {
    if (username.isEmpty) return '';
    final parts = username.split(RegExp(r'[\s._-]')).where((s) => s.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B4D2E);
    const lightGrey = Color(0xFFF2F3F5);
    const cardLight = Color(0xFF2E8B2E);
    const statLight = Color(0xFFBFEBCF);

    final current = AuthService.getCurrentUser();
    if (current == null) {
      // No user — redirect to sign-in
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final profile = AuthService.getUserProfile(current);
    final email = profile?.email ?? '';

    final attempts = QuizProgressService.getAllAttempts();
    final lessons = attempts.length;
    final points = attempts.fold<int>(0, (sum, a) => sum + (a['score'] as int? ?? 0)) * 10;
    final distinctDays = <String>{};
    for (final a in attempts) {
      final dateStr = a['date'] as String? ?? '';
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        distinctDays.add('${dt.year}-${dt.month}-${dt.day}');
      } catch (_) {}
    }
    final daysStreak = distinctDays.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('SPEAKZED', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Regional Zambian Learning Hub', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(16.0)),
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: cardLight,
                    child: Text(_initials(current), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(current.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Active member · $email', style: TextStyle(color: Colors.green.shade100)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _statBox(lessons.toString(), 'Lessons')),
                      const SizedBox(width: 8),
                      Expanded(child: _statBox(daysStreak.toString(), 'Days streak')),
                      const SizedBox(width: 8),
                      Expanded(child: _statBox(points.toString(), 'Points')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: lightGrey, borderRadius: BorderRadius.circular(12.0)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('My Profile Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                    tileColor: Colors.white,
                    onTap: () {
                      // TODO: Implement Profile Overview
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Profile Settings'),
                    onTap: () {
                      // TODO: Profile Settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Help And Support'),
                    onTap: () {
                      // TODO: Help & Support
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await AuthService.logOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String number, String label) {
    return Container(
      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
