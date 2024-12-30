import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import '../utilities/storage_manager.dart';
import '../utilities/topic_management.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  _ThemeSelectorScreenState createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen>
    with SingleTickerProviderStateMixin {
  final List<String> themes = [];

  final Set<String> selectedThemes = {};
  final TextEditingController themeController = TextEditingController();
  String suggestedTheme = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    themeController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final savedThemes = PreferencesManager.instance.loadThemes();
      setState(() {
        selectedThemes.addAll(savedThemes);
      });
    } catch (e) {
      _showError('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      await PreferencesManager.instance.saveThemes(selectedThemes.toList());
      _showSuccess('Preferences saved!');
    } catch (e) {
      _showError('Error saving preferences: $e');
    }
  }

  void _showError(String message) {
    showError(context, message);
  }

  void _showSuccess(String message) {
    showSuccess(context, message);
  }

  bool _isValidTheme(String theme) {
    // Match 2-20 characters, including Unicode letters, numbers, and spaces,
    // but ensure the theme is not entirely numeric.
    return theme.length >= 2 &&
        theme.length <= 20 &&
        RegExp(r'^[\p{L}\p{N}\s]+$', unicode: true).hasMatch(theme) &&
        !RegExp(r'^\d+$').hasMatch(theme);
  }

  void toggleSelection(String themeName) {
    setState(() {
      if (selectedThemes.contains(themeName)) {
        selectedThemes.remove(themeName);
        _animationController.reverse();
      } else {
        selectedThemes.add(themeName);
        _animationController.forward();
      }
    });
    _savePreferences();
  }

  void addCustomTheme() {
    final newTheme = themeController.text.trim();
    if (newTheme.isNotEmpty &&
        !themes.contains(newTheme) &&
        _isValidTheme(newTheme)) {
      setState(() {
        themes.add(newTheme);
        selectedThemes.add(newTheme);
      });
      _savePreferences();
    } else {
      _showError('Invalid theme name. Use 2-20 alphanumeric characters.');
    }
    themeController.clear();
    setState(() {
      suggestedTheme = '';
    });
  }

  void suggestClosestTheme(String input) {
    if (input.isEmpty || (input.length < 3) || themes.isEmpty) {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchBar(),
          if (suggestedTheme.isNotEmpty) _buildSuggestion(),
          const SizedBox(height: 16.0),
          _buildThemeGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: themeController,
            decoration: InputDecoration(
              labelText: 'Add Custom Theme',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
            onChanged: suggestClosestTheme,
            onSubmitted: (_) => addCustomTheme(),
          ),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton.icon(
          onPressed: addCustomTheme,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Did you mean: ',
              style: TextStyle(fontWeight: FontWeight.w500)),
          GestureDetector(
            onTap: () => toggleSelection(suggestedTheme),
            child: Chip(
              label: Text(
                suggestedTheme,
                style: const TextStyle(color: Colors.blue),
              ),
              backgroundColor: Colors.blue[50],
              avatar: const Icon(Icons.add, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid() {
    return Flexible(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:
                    MediaQuery.of(context).size.width < 600 ? 150 : 200,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: themes.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => _buildThemeTile(themes[index]),
            ),
    );
  }

  Widget _buildThemeTile(String theme) {
    final isSelected = selectedThemes.contains(theme);

    return Semantics(
      label: 'Select $theme theme',
      selected: isSelected,
      child: Tooltip(
        message: 'Add $theme theme',
        child: GestureDetector(
          onTap: () => toggleSelection(theme),
          child: Hero(
            tag: 'theme_$theme',
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: isSelected ? _scaleAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255.0 * .1).round()),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Error Boundary Widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    };
    return child;
  }
}
