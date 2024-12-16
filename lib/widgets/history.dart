import 'package:flutter/material.dart';
import '../db/model.dart';
import './detail.dart';

class HistoryPage extends StatelessWidget {
  final List<DiscussionInteraction> interactions;

  const HistoryPage({super.key, required this.interactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Discussion History")),
      body: ListView.builder(
        itemCount: interactions.length,
        itemBuilder: (context, index) {
          final interaction = interactions[index];
          return ListTile(
            title: Text(interaction.theme),
            subtitle: Text(
                "Date: ${interaction.date.toLocal().toString().split(' ')[0]}"),
            trailing: Text(interaction.evaluation),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(interaction: interaction),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


