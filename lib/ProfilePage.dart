import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.profile),
        backgroundColor: Colors.green,
        actions: [
          DropdownButton<Locale>(
            value: Localizations.localeOf(context),
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.white),
            onChanged: (Locale? locale) {
              if (locale != null) {
                MyApp.setLocale(context, locale);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English'),),
              DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? Text(local.notSignedIn)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text("${local.email}: ${user.email}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Text(local.viewHistory),
            ),
          ],
        ),
      ),
    );
  }
}
