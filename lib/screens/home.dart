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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Light grey background
      ),
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

          return const LoginPage();
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
    tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: 1
    );
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
    final User? currentUser = GoogleAuthService.currentUser;
    final String name = currentUser?.displayName ?? '';

    return Center( // Wrap entire Scaffold with Center
      child: ConstrainedBox( // Constrain entire content
        constraints: const BoxConstraints(maxWidth: 800),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false, // Center the title
            backgroundColor: Colors.grey[200], // White background for AppBar
            elevation: 1, // Subtle shadow
            title: Text(
              "Discursia, ${name.split(" ")[0]}",
              style: const TextStyle(color: Colors.black87), // Darker text color
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black87),
                tooltip: "Log Out",
                onPressed: () async {
                  await GoogleAuthService.signOut();
                },
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              labelColor: Colors.black87, // Dark text for selected tab
              unselectedLabelColor: Colors.black54, // Grey text for unselected tabs
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
        ),
      ),
    );
  }
}