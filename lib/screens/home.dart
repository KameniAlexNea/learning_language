import 'package:discursia/db/discusia.dart';
import 'package:flutter/material.dart';
import '../api/llmservice.dart';
import '../widgets/config.dart';
import '../widgets/eval.dart';
import '../widgets/suggest.dart';
import '../widgets/writing.dart';

class WritingAssistantScreen extends StatefulWidget {
  const WritingAssistantScreen({super.key});

  @override
  _WritingAssistantScreenState createState() => _WritingAssistantScreenState();
}

class _WritingAssistantScreenState extends State<WritingAssistantScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController apiKeyController = TextEditingController();

  TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DiscusiaConfig.setState = setState;
    DiscusiaConfig.tabController = TabController(length: 4, vsync: this);
    if (DiscusiaConfig.modelType == 0) {
      DiscusiaConfig.llmCall = askLLMOA;
    } else if (DiscusiaConfig.modelType == 1) {
      DiscusiaConfig.llmCall = askLLMHF;
    } else {
      DiscusiaConfig.llmCall = askLLMGroq;
    }
  }

  @override
  void dispose() {
    DiscusiaConfig.tabController.dispose();
    apiKeyController.dispose();
    responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discursia"),
        bottom: TabBar(
          controller: DiscusiaConfig.tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: "App Setting"),
            Tab(icon: Icon(Icons.article), text: "Writing Task"),
            Tab(icon: Icon(Icons.lightbulb), text: "Suggested Answer"),
            Tab(icon: Icon(Icons.score), text: "Evaluation"),
          ],
        ),
      ),
      body: TabBarView(
        controller: DiscusiaConfig.tabController,
        children: [
          // First Tab: API Key Configuration
          ConfigScreen(),

          // Second Tab: Writing Assistant Functionality
          TypingScreen(),

          // Third Tab: Suggested Answer
          SuggestScreen(),

          // Fourth Tab: Evaluation
          EvalScreen()
        ],
      ),
    );
  }
}
