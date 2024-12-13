import 'package:flutter/material.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  // List of available themes
  final List<String> availableThemes = [
    "Philosophy",
    "Art and literature",
    "Science and technology",
    "History and culture",
    "Current events and politics",
    "Psychology and human behavior",
    "Travel and world exploration",
    "Music and performing arts",
    "Environmental sustainability",
    "Culinary arts and gastronomy",
    "Economics and global markets",
    "Spirituality and religion",
    "Film and cinema",
    "Education and lifelong learning",
    "Innovations and entrepreneurship",
    "Health and wellness",
    "Ethics and morality",
    "Sports and physical activities",
    "Fashion and design",
    "Personal development and mindfulness",
    "Architecture and urban planning",
    "Astronomy and space exploration",
    "Mythology and folklore",
    "Genealogy and ancestry",
    "Social justice and activism",
    "Artificial intelligence and machine learning",
    "Cryptocurrency and blockchain technology",
    "Military history and strategy",
    "Photography and visual storytelling",
    "Geopolitics and international relations",
    "Nature and wildlife",
    "Linguistics and language learning",
    "Classical studies and ancient civilizations",
    "Gardening and horticulture",
    "Poetry and creative writing",
    "Business strategy and leadership",
    "Comedy and satire",
    "Wine and spirits",
    "Gaming and interactive entertainment",
    "Quantum physics and advanced mathematics"
];

  // Set to keep track of selected themes
  Set<String> selectedThemes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Themes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose your areas of interest',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: availableThemes.length,
                itemBuilder: (context, index) {
                  final theme = availableThemes[index];
                  final isSelected = selectedThemes.contains(theme);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedThemes.remove(theme);
                        } else {
                          selectedThemes.add(theme);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade200
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          theme,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.blue.shade900
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedThemes.isNotEmpty
                  ? () {
                      // Handle theme selection completion
                      print('Selected Themes: $selectedThemes');
                      // Navigate to next screen or process themes
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                selectedThemes.isEmpty
                    ? 'Select at least one theme'
                    : 'Continue (${selectedThemes.length} selected)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ThemeSelectionScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
