import 'package:discursia/screens/login.dart';
import 'package:flutter/material.dart';

import '../db/discusia.dart';
import '../db/auth_google.dart';
import 'themeselector.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  List<String> languages = [
    "English",
    "German",
    "French",
    "Italian",
    "Portuguese",
    "Hindi",
    "Spanish",
    "Thai"
  ];

  Future<void> signOut() async {
    await GoogleAuthService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // First Tab: API Key Configuration
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: DiscusiaConfig.selectedLanguage,
              onChanged: (value) {
                setState(() {
                  DiscusiaConfig.selectedLanguage = value!;
                });
              },
              items: languages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select language",
              ),
            ),
            const SizedBox(height: 10),
            ThemeSelectorScreen(),
          ],
        ),
      ),
    );
  }
}
