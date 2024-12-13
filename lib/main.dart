import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'prompts.dart';
import 'llmservice.dart';
import 'local_storage.dart';
import 'builder.dart';

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

class WritingAssistantScreen extends StatefulWidget {
  const WritingAssistantScreen({super.key});

  @override
  _WritingAssistantScreenState createState() => _WritingAssistantScreenState();
}

class _WritingAssistantScreenState extends State<WritingAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController apiKeyController = TextEditingController();
  String selectedLanguage = "English"; // Default language
  List<String> languages = ["English", "French", "Spanish"];
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

  Future<void> saveCredentials() async {
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

  bool checkEmptyOpenAI() {
    if (openaiApiKey.isEmpty) {
      setState(() {
        errorMessage = "OpenAI key cannot be empty";
      });
      return false;
    }
    return true;
  }

  bool checkCurrentTopicNotEmpty() {
    if (currentTopic.isEmpty) {
      setState(() {
        errorMessage =
            "Current topic cannot be empty. Please, first generate a topic";
      });
      return false;
    }
    return true;
  }

  Future<void> generateTopic() async {
    try {
      if (!checkEmptyOpenAI()) {
        return;
      }
      setState(() => isGeneratingTopic = true);
      try {
        final response = await askLLM(
            prompts.MODEL_NAME, prompts.getGenerateTopicsMessages, 500);

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
    if (!checkEmptyOpenAI() || !checkCurrentTopicNotEmpty()) {
      return;
    }
    setState(() => isEvaluatingResponse = true);
    try {
      final response = await askLLM(
          prompts.MODEL_NAME,
          prompts.getEvaluateResponseMessages(
              currentTopic, responseController.text),
          1000);

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
    if (!checkEmptyOpenAI() || !checkCurrentTopicNotEmpty()) {
      return;
    }
    setState(() => isGettingSuggestedAnswer = true);
    try {
      final response = await askLLM(prompts.MODEL_NAME,
          prompts.getSuggestedAnswerMessages(currentTopic), 1000);

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
    if (!checkEmptyOpenAI() || !checkCurrentTopicNotEmpty()) {
      return;
    }
    setState(() => isGettingSuggestedIdea = true);
    try {
      final response = await askLLM(prompts.MODEL_NAME,
          prompts.getSuggestedIdeaMessages(currentTopic), 1000);

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
                  ElevatedButton(
                    onPressed: () async {
                      await saveCredentials();
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
                  buildCard(context, "Current Topic", currentTopic),
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
                  buildCard(context, "Evaluation", evaluation),
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
                  buildCard(context, "Current Topic", currentTopic),
                  const SizedBox(height: 10),
                  buildCard(context, "Suggested Ideas", suggestedIdea),
                  const SizedBox(height: 10),
                  buildCard(context, "Suggested Answer", suggestedAnswer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
