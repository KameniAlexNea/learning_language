import 'package:flutter/material.dart';
import '../db/model.dart';
import 'builder.dart';

class DetailPage extends StatelessWidget {
  final DiscussionInteraction interaction;

  const DetailPage({super.key, required this.interaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interaction Details"),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
      ),
    );
  }
}