import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_similarity/string_similarity.dart';


class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  ThemeSelectorScreenState createState() => ThemeSelectorScreenState();
}

class ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  final List<String> themes = [
    'Informatic',
    'Science',
    'Biology',
    'Sport',
    'Life',
    'Balance',
  ];

  final Set<String> selectedThemes = {};
  final TextEditingController themeController = TextEditingController();
  String suggestedTheme = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemes = prefs.getStringList('selectedThemes') ?? [];
    setState(() {
      selectedThemes.addAll(savedThemes);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedThemes', selectedThemes.toList());
  }

  void toggleSelection(String themeName) {
    setState(() {
      if (selectedThemes.contains(themeName)) {
        selectedThemes.remove(themeName);
      } else {
        selectedThemes.add(themeName);
      }
    });
    _savePreferences();
  }

  void addCustomTheme() {
    final newTheme = themeController.text.trim();
    if (newTheme.isNotEmpty && !themes.contains(newTheme)) {
      setState(() {
        themes.add(newTheme);
        selectedThemes.add(newTheme);
      });
    }
    themeController.clear();
    setState(() {
      suggestedTheme = '';
    });
    _savePreferences();
  }

  void suggestClosestTheme(String input) {
    if (input.isEmpty) {
      setState(() {
        suggestedTheme = '';
      });
      return;
    }

    final result = StringSimilarity.findBestMatch(input, themes);
    setState(() {
      suggestedTheme = result.bestMatch.target ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _savePreferences,
              child: Text('Save Preferences'),
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: themeController,
                decoration: InputDecoration(
                  labelText: 'Add Custom Theme',
                  border: OutlineInputBorder(),
                ),
                onChanged: suggestClosestTheme,
                onSubmitted: (_) => addCustomTheme(),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: addCustomTheme,
              child: Text('Add'),
            ),
          ],
        ),
        if (suggestedTheme.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () => toggleSelection(suggestedTheme),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Did you mean: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    suggestedTheme,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 16.0),
        Flexible(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: themes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isSelected = selectedThemes.contains(theme);

              return GestureDetector(
                onTap: () => toggleSelection(theme),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      theme,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
