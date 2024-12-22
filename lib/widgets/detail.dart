import 'package:discursia/db/discusia.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../db/discussion.dart';
import '../db/model.dart';
import 'card_builder.dart';

class DetailPage extends StatelessWidget {
  final DiscussionUserInteraction interaction;

  const DetailPage({super.key, required this.interaction});

  void editAnswer(DiscussionInteraction interaction, BuildContext context) {
    DiscusiaConfig.currentTopic = interaction.theme;
    DiscusiaConfig.evaluation = interaction.evaluation;
    DiscusiaConfig.suggestedIdea = interaction.suggestedIdea;
    DiscusiaConfig.suggestedAnswer = interaction.suggestedAnswer;
    DiscusiaConfig.responseController.text = interaction.userAnswer;
    // DiscusiaConfig.tabController.animateTo(1);
    Navigator.pop(context);
  }

  void deleteAnswer(
      DiscussionUserInteraction interaction, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this answer?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final String? uid = interaction.uid;
                if (uid != null) {
                  DiscussionInteractionDBManager.deleteDiscussionInteraction(
                      uid);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final uid = DiscussionInteractionDBManager.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text("Interaction Details"),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme Section
              buildCard(context, "Theme", interaction.theme),

              SizedBox(height: 16),

              // User Answer Section
              buildCard(
                  context,
                  "${interaction.userId == uid ? "Your" : "User"} Response",
                  interaction.userAnswer),

              SizedBox(height: 16),

              // Feedback Section
              buildCard(context, "Feedback", interaction.evaluation),

              // Date Information
              SizedBox(height: 16),
              Text(
                "Date: ${interaction.createdAt.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit),
                        onPressed: () => editAnswer(interaction, context),
                      ),
                      const Text("Edit"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.delete),
                        onPressed: (interaction.userId != uid)
                            ? null
                            : () => deleteAnswer(interaction, context),
                      ),
                      const Text("Delete"),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
