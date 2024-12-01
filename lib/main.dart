import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
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

class WritingAssistantScreen extends StatefulWidget {
  const WritingAssistantScreen({super.key});

  @override
  _WritingAssistantScreenState createState() => _WritingAssistantScreenState();
}

class _WritingAssistantScreenState extends State<WritingAssistantScreen> {
  final TextEditingController apiKeyController = TextEditingController();
  String selectedLanguage = "English"; // Default language
  String currentTopic = "";
  String errorMessage = "";
  String evaluation = "";
  String suggestedAnswer = "";
  TextEditingController responseController = TextEditingController();

  bool isGeneratingTopic = false;
  bool isEvaluatingResponse = false;
  bool isGettingSuggestedAnswer = false;

  late Prompts prompts = Prompts("English");

  final String openaiUrl = "https://api.openai.com/v1/chat/completions";
  String openaiApiKey = ""; // For holding the API key temporarily

  Future<void> generateTopic() async {
    setState(() => isGeneratingTopic = true);
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
          ],
          "max_tokens": 500,
          "temperature": 0.7,
        })),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        if (response.statusCode == 200) {
          currentTopic =
              data['choices'][0]['message']['content'] ?? "No topic generated.";
          errorMessage = "";
        } else {
          errorMessage =
              data['error']['message'] ?? "Failed to generate topic.";
        }
      });
    } finally {
      setState(() => isGeneratingTopic = false);
    }
  }

  Future<void> evaluateResponse() async {
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
        } else {
          errorMessage =
              data['error']['message'] ?? "Failed to generate suggestion.";
        }
      });
    } finally {
      setState(() => isGettingSuggestedAnswer = false);
    }
  }

  Widget buildCard(String title, String content, {Color? backgroundColor}) {
    return Card(
      color: backgroundColor ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Writing Assistant"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "OpenAI API Key",
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
                onPressed: () {
                  setState(() {
                    openaiApiKey = apiKeyController.text.trim();
                  });
                },
                child: const Text("Save API Key & Language"),
              ),
              const SizedBox(height: 20),
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
                onPressed: isGettingSuggestedAnswer ? null : getSuggestedAnswer,
                child: isGettingSuggestedAnswer
                    ? const CircularProgressIndicator()
                    : const Text("Suggest an Answer"),
              ),
              buildCard("Suggested Answer", suggestedAnswer),
            ],
          ),
        ),
      ),
    );
  }
}
