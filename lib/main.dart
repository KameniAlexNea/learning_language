import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'prompts.dart';

void main() {
  runApp(const WritingAssistantApp());
}

class WritingAssistantApp extends StatelessWidget {
  const WritingAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WritingAssistantScreen(),
    );
  }
}

// Create a class to manage local storage
class LocalStorage {
  static Future<File> _getLocalFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  static Future<void> saveData(String key, String value) async {
    final file = await _getLocalFile('app_settings.json');

    // Read existing data
    Map<String, dynamic> data = {};
    if (await file.exists()) {
      String contents = await file.readAsString();
      data = json.decode(contents);
    }

    // Update data
    data[key] = value;

    // Write back to file
    await file.writeAsString(json.encode(data));
  }

  static Future<String?> readData(String key) async {
    final file = await _getLocalFile('app_settings.json');

    if (await file.exists()) {
      String contents = await file.readAsString();
      Map<String, dynamic> data = json.decode(contents);
      return data[key];
    }

    return null;
  }
}

class WritingAssistantScreen extends StatefulWidget {
  const WritingAssistantScreen({super.key});

  @override
  _WritingAssistantScreenState createState() => _WritingAssistantScreenState();
}

class _WritingAssistantScreenState extends State<WritingAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController apiKeyController = TextEditingController();
  String selectedLanguage = "English"; // Default language
  String errorMessage = "";
  String currentTopic = "";
  String evaluation = "";
  String suggestedAnswer = "";
  String suggestedIdea = "";
  TextEditingController responseController = TextEditingController();

  bool isGeneratingTopic = false;
  bool isEvaluatingResponse = false;
  bool isGettingSuggestedAnswer = false;
  bool isGettingSuggestedIdea = false;
  bool _obscureApiKey = true;

  late Prompts prompts = Prompts("English");
  late TabController _tabController;

  final String openaiUrl = "https://api.openai.com/v1/chat/completions";
  String openaiApiKey = ""; // For holding the API key temporarily

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedApiKey = await LocalStorage.readData('openai_api_key');
      final savedLanguage = await LocalStorage.readData('selected_language');

      setState(() {
        if (savedApiKey != null) {
          openaiApiKey = savedApiKey;
          apiKeyController.text = savedApiKey;
        }
        if (savedLanguage != null) {
          selectedLanguage = savedLanguage;
          prompts = Prompts(selectedLanguage);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading credentials: $e');
      }
    }
  }

  Future<void> _saveCredentials() async {
    try {
      await LocalStorage.saveData(
          'openai_api_key', apiKeyController.text.trim());
      await LocalStorage.saveData('selected_language', selectedLanguage);

      setState(() {
        openaiApiKey = apiKeyController.text.trim();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving credentials: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    apiKeyController.dispose();
    responseController.dispose();
    super.dispose();
  }

  Future<void> generateTopic() async {
    try {
      if (openaiApiKey.isEmpty) {
        setState(() {
          errorMessage = "OpenAI key cannot be empty";
        });
        return;
      }
      setState(() => isGeneratingTopic = true);
      try {
        final response = await http
            .post(
              Uri.parse(openaiUrl),
              headers: {
                "Authorization": "Bearer $openaiApiKey",
                "Content-Type": "application/json",
              },
              body: utf8.encode(jsonEncode({
                "model": prompts.MODEL_NAME,
                "messages": [
                  {"role": "system", "content": prompts.systemPrompt},
                ],
                "max_tokens": 500,
                "temperature": 0.7,
              })),
            )
            .timeout(const Duration(seconds: 60));

        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          if (response.statusCode == 200) {
            currentTopic = data['choices'][0]['message']['content'] ??
                "No topic generated.";
            errorMessage = "";
          } else {
            final errorData = jsonDecode(response.body);
            setState(() {
              errorMessage = errorData['error']['message'] ??
                  "HTTP ${response.statusCode}: Failed to generate topic.";
            });
          }
        });
      } on SocketException catch (e) {
        setState(() {
          errorMessage = "Network error: ${e.message}";
        });
      } catch (e) {
        setState(() {
          errorMessage = "An unexpected error occurred: $e";
        });
      }
    } finally {
      setState(() => isGeneratingTopic = false);
    }
  }

  Future<void> evaluateResponse() async {
    if (openaiApiKey.isEmpty) {
      setState(() {
        errorMessage = "OpenAI key cannot be empty";
      });
      return;
    }
    if (currentTopic.isEmpty) {
      setState(() {
        errorMessage = "Current topic cannot be empty.";
      });
      return;
    }
    setState(() => isEvaluatingResponse = true);
    try {
      final response = await http.post(
        Uri.parse(openaiUrl),
        headers: {
          "Authorization": "Bearer $openaiApiKey",
          "Content-Type": "application/json",
        },
        body: utf8.encode(jsonEncode({
          "model": prompts.MODEL_NAME,
          "messages": [
            {"role": "system", "content": prompts.systemPrompt},
            {"role": "assistant", "content": currentTopic},
            {
              "role": "user",
              "content":
                  "${prompts.evaluationPrompt}\n\nResponse: ${responseController.text}"
            },
          ],
          "max_tokens": 1000,
          "temperature": 0.7,
        })),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        if (response.statusCode == 200) {
          evaluation = data['choices'][0]['message']['content'] ??
              "No evaluation generated.";
          errorMessage = "";
        } else {
          errorMessage =
              data['error']['message'] ?? "Failed to evaluate response.";
        }
      });
    } finally {
      setState(() => isEvaluatingResponse = false);
    }
  }

  Future<void> getSuggestedAnswer() async {
    if (openaiApiKey.isEmpty) {
      setState(() {
        errorMessage = "OpenAI key cannot be empty";
      });
      return;
    }
    if (currentTopic.isEmpty) {
      setState(() {
        errorMessage = "Current topic cannot be empty.";
      });
      return;
    }
    setState(() => isGettingSuggestedAnswer = true);
    try {
      final response = await http.post(
        Uri.parse(openaiUrl),
        headers: {
          "Authorization": "Bearer $openaiApiKey",
          "Content-Type": "application/json",
        },
        body: utf8.encode(jsonEncode({
          "model": prompts.MODEL_NAME,
          "messages": [
            {"role": "system", "content": prompts.answerSystemPrompt},
            {"role": "user", "content": "Topic:\n\n $currentTopic"},
            {"role": "system", "content": prompts.answerPrompt}
          ],
          "max_tokens": 1000,
          "temperature": 0.7,
        })),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        if (response.statusCode == 200) {
          suggestedAnswer = data['choices'][0]['message']['content'] ??
              "No suggestion generated.";
          errorMessage = "";
          // Switch to the Suggested Answer tab
          _tabController.animateTo(2);
        } else {
          errorMessage =
              data['error']['message'] ?? "Failed to generate suggestion.";
        }
      });
    } finally {
      setState(() => isGettingSuggestedAnswer = false);
    }
  }

  Future<void> getSuggestedIdea() async {
    if (openaiApiKey.isEmpty) {
      setState(() {
        errorMessage = "OpenAI key cannot be empty";
      });
      return;
    }
    if (currentTopic.isEmpty) {
      setState(() {
        errorMessage = "Current topic cannot be empty.";
      });
      return;
    }
    setState(() => isGettingSuggestedIdea = true);
    try {
      final response = await http.post(
        Uri.parse(openaiUrl),
        headers: {
          "Authorization": "Bearer $openaiApiKey",
          "Content-Type": "application/json",
        },
        body: utf8.encode(jsonEncode({
          "model": prompts.MODEL_NAME,
          "messages": [
            {"role": "system", "content": prompts.answerSystemPrompt},
            {"role": "user", "content": "Topic:\n\n $currentTopic"},
            {"role": "system", "content": prompts.ideaPrompt}
          ],
          "max_tokens": 1000,
          "temperature": 0.0,
        })),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        if (response.statusCode == 200) {
          suggestedIdea =
              data['choices'][0]['message']['content'] ?? "No suggestion idea.";
          errorMessage = "";
          // Switch to the Suggested Answer tab
          _tabController.animateTo(2);
        } else {
          errorMessage =
              data['error']['message'] ?? "Failed to generate ideas.";
        }
      });
    } finally {
      setState(() => isGettingSuggestedIdea = false);
    }
  }

  Widget buildCard(String title, String content, {Color? backgroundColor}) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: content));
        // Optionally show a message to the user after copying
        // You can integrate a snackbar or toast here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content copied to clipboard!')),
        );
      },
      child: Card(
        color: backgroundColor ?? Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Writing Assistant"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.key), text: "API Key"),
            Tab(icon: Icon(Icons.article), text: "Writing Task"),
            Tab(icon: Icon(Icons.lightbulb), text: "Suggested Answer"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First Tab: API Key Configuration
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "OpenAI API Key",
                      suffixIcon: IconButton(
                        icon: Icon(_obscureApiKey
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                        prompts = Prompts(selectedLanguage);
                      });
                    },
                    items: ["English", "French", "Spanish"]
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
                  ElevatedButton(
                    onPressed: () async {
                      await _saveCredentials();
                      // Switch to the Writing Task tab
                      _tabController.animateTo(1);
                    },
                    child: const Text("Save API Key & Language"),
                  ),
                ],
              ),
            ),
          ),

          // Second Tab: Writing Assistant Functionality
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isGeneratingTopic ? null : generateTopic,
                    child: isGeneratingTopic
                        ? const CircularProgressIndicator()
                        : const Text("Generate New Topic"),
                  ),
                  if (errorMessage.isNotEmpty)
                    Text(
                      "Error: $errorMessage",
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 10),
                  buildCard("Current Topic", currentTopic),
                  const SizedBox(height: 10),
                  TextField(
                    controller: responseController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Write your response here",
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isEvaluatingResponse ? null : evaluateResponse,
                    child: isEvaluatingResponse
                        ? const CircularProgressIndicator()
                        : const Text("Evaluate Response"),
                  ),
                  buildCard("Evaluation", evaluation),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isGettingSuggestedIdea ? null : getSuggestedIdea,
                    child: isGettingSuggestedIdea
                        ? const CircularProgressIndicator()
                        : const Text("Suggest Idea"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        isGettingSuggestedAnswer ? null : getSuggestedAnswer,
                    child: isGettingSuggestedAnswer
                        ? const CircularProgressIndicator()
                        : const Text("Suggest an Answer"),
                  ),
                ],
              ),
            ),
          ),

          // Third Tab: Suggested Answer
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildCard("Current Topic", currentTopic),
                  const SizedBox(height: 10),
                  buildCard("Suggested Ideas", suggestedIdea),
                  const SizedBox(height: 10),
                  buildCard("Suggested Answer", suggestedAnswer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
