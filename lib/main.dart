import 'package:flutter/material.dart';
import 'dart:io';
import 'prompts.dart';
import 'llmservice.dart';
import 'builder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  dotenv.load(fileName: ".env");
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

  late Prompts prompts = Prompts("English");
  late TabController _tabController;
  late Function llmCall;
  final modelType = 2; // 0: OpenAI, 1: HF, 2: Groq

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    // _loadSavedCredentials();
    if (modelType == 0) {
      llmCall = askLLMOA;
    } else if (modelType == 1) {
      llmCall = askLLMHF;
    } else {
      llmCall = askLLMGroq;
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
        final response = await llmCall(prompts.getGenerateTopicsMessages, 500);

        setState(() {
          currentTopic = response ?? "No topic generated.";
          errorMessage = "";
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
      final response = await llmCall(
          prompts.getEvaluateResponseMessages(
              currentTopic, responseController.text),
          1000);

      setState(() {
        evaluation = response ?? "No evaluation generated.";
        errorMessage = "";
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
      final response =
          await llmCall(prompts.getSuggestedAnswerMessages(currentTopic), 1000);

      setState(() {
        suggestedAnswer = response ?? "No suggestion generated.";
        errorMessage = "";
        // Switch to the Suggested Answer tab
        if (response != null) {
          _tabController.animateTo(2);
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
      final response =
          await llmCall(prompts.getSuggestedIdeaMessages(currentTopic), 1000);

      setState(() {
        suggestedIdea = response ?? "No suggestion idea.";
        errorMessage = "";
        // Switch to the Suggested Answer tab
        if (response != null) _tabController.animateTo(2);
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
                      // await saveCredentials();
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
