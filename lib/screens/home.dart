import 'package:discursia/db/discusia.dart';
import 'package:discursia/widgets/history.dart';
import 'package:flutter/material.dart';
import '../utilities/auth_google.dart';
import '../widgets/config.dart';
import '../widgets/eval.dart';
import '../widgets/suggest.dart';
import '../widgets/writing.dart';

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

  TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DiscusiaConfig.setState = setState;
    DiscusiaConfig.tabController = TabController(length: 5, vsync: this);
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
    final String name = GoogleAuthService.user!.displayName ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text("Discursia, $name"),
        bottom: TabBar(
          controller: DiscusiaConfig.tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: "App Setting"),
            Tab(icon: Icon(Icons.article), text: "Writing Task"),
            Tab(icon: Icon(Icons.lightbulb), text: "Suggested Answer"),
            Tab(icon: Icon(Icons.score), text: "Evaluation"),
            Tab(icon: Icon(Icons.history), text: "History"),
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
          EvalScreen(),

          // 5th Tab: Saved History
          HistoryPage(interactions: DiscusiaConfig.interactions)
        ],
      ),
    );
  }
}
