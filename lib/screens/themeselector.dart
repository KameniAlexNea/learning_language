import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

import '../utilities/storage_manager.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  _ThemeSelectorScreenState createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
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
    final savedThemes = PreferencesManager.instance.loadThemes();
    setState(() {
      selectedThemes.addAll(savedThemes);
    });
  }

  Future<void> _savePreferences() async {
    PreferencesManager.instance.saveThemes(selectedThemes.toList());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved!')),
    );
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
    if (input.isEmpty || (input.length < 3)) {
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
            Expanded(
              child: TextField(
                controller: themeController,
                decoration: InputDecoration(
                  labelText: 'Add Custom Theme',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.edit),
                ),
                onChanged: suggestClosestTheme,
                onSubmitted: (_) => addCustomTheme(),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton.icon(
              onPressed: addCustomTheme,
              icon: Icon(Icons.add),
              label: Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
        if (suggestedTheme.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Did you mean: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => toggleSelection(suggestedTheme),
                  child: Chip(
                    label: Text(
                      suggestedTheme,
                      style: TextStyle(color: Colors.blue),
                    ),
                    backgroundColor: Colors.blue[50],
                    avatar: Icon(Icons.add, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 16.0),
        Flexible(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
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
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [Colors.blueAccent, Colors.blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                    color: isSelected ? null : Colors.grey[200],
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
