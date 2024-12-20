import 'package:flutter/material.dart';
import '../db/model.dart';
import './detail.dart';
import 'card_builder.dart';

class HistoryPage extends StatelessWidget {
  final List<DiscussionInteraction> interactions;

  const HistoryPage({super.key, required this.interactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion History"),
        elevation: 1,
      ),
      body: interactions.isEmpty 
        ? Center(
            child: Text(
              "No discussion history yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          )
        : ListView.separated(
            itemCount: interactions.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final interaction = interactions[index];
              return ListTile(
                title: buildCard(
                        context, "Topic $index", interaction.theme),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: ${interaction.date.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
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