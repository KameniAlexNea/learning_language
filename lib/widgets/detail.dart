import 'package:discursia/db/discusia.dart';
import 'package:flutter/material.dart';
import '../db/model.dart';
import 'builder.dart';

class DetailPage extends StatelessWidget {
  final DiscussionInteraction interaction;

  const DetailPage({super.key, required this.interaction});

  void editAnswer(DiscussionInteraction interaction) {
    DiscusiaConfig.setState(() {
      DiscusiaConfig.currentTopic = interaction.theme;
      DiscusiaConfig.evaluation = interaction.evaluation;
      DiscusiaConfig.suggestedIdea = interaction.suggestedIdea;
      DiscusiaConfig.suggestedAnswer = interaction.suggestedAnswer;
      DiscusiaConfig.responseController.text = interaction.userAnswer;
    });
    DiscusiaConfig.tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
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
              buildCard(context, "Your Response", interaction.userAnswer),

              SizedBox(height: 16),

              // Feedback Section
              buildCard(context, "Feedback", interaction.evaluation),

              // Date Information
              SizedBox(height: 16),
              Text(
                "Date: ${interaction.date.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => editAnswer(interaction),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Edit your response',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
