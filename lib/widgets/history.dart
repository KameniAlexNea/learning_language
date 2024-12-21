import 'package:flutter/material.dart';
import '../db/discussion.dart';
import '../db/model.dart';
import './detail.dart';
import 'card_builder.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiscussionUserInteraction>> _interactionsFuture;

  @override
  void initState() {
    super.initState();
    _interactionsFuture = _initializeInteractions();
  }

  Future<List<DiscussionUserInteraction>> _initializeInteractions() async {
    final interactions = <DiscussionUserInteraction>[];
    await for (var action in DiscussionInteractionDBManager.getUserDiscussionInteractions()) {
      interactions.addAll(action);
    }
    return interactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion History"),
        elevation: 1,
      ),
      body: FutureBuilder<List<DiscussionUserInteraction>>(
        future: _interactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred ${snapshot.error}",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No discussion history yet",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final interactions = snapshot.data!;
          return ListView.separated(
            itemCount: interactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final interaction = interactions[index];
              return ListTile(
                title: buildCard(context, "Topic $index", interaction.theme),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: ${interaction.createdAt.toLocal().toString().split(' ')[0]}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
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
          );
        },
      ),
    );
  }
}
