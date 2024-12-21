import 'package:discursia/widgets/history.dart';
import 'package:flutter/material.dart';
import '../db/auth_google.dart';
import '../db/discussion.dart';
import '../widgets/config.dart';
import '../widgets/eval.dart';
import '../widgets/suggest.dart';
import '../widgets/writing.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class WritingAssistantApp extends StatelessWidget {
  const WritingAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: GoogleAuthService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return const WritingAssistantScreen();
          }

          // Return login screen if user is not authenticated
          return const LoginPage(); // You'll need to create this
        },
      ),
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
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    apiKeyController.dispose();
    responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user using the new method
    final User? currentUser = GoogleAuthService.currentUser;
    final String name = currentUser?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Discursia, $name"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleAuthService.signOut();
              // Navigation will be handled automatically by StreamBuilder
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
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
        controller: tabController,
        children: [
          ConfigScreen(),
          TypingScreen(tabController: tabController),
          SuggestScreen(),
          EvalScreen(),
          HistoryPage(
            interactions:
                DiscussionInteractionDBManager.getUserDiscussionInteractions(),
          ),
        ],
      ),
    );
  }
}
