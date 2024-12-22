import 'package:flutter/material.dart';
import '../db/model.dart';
import './detail.dart';
import 'card_builder.dart';

class HistoryPage extends StatefulWidget {
  final Stream<List<DiscussionUserInteraction>> interactions;

  const HistoryPage({super.key, required this.interactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscussionUserInteraction> _filterInteractions(List<DiscussionUserInteraction> interactions) {
    if (_searchQuery.isEmpty) return interactions;
    return interactions.where((interaction) =>
      interaction.theme.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion History"),
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by theme...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DiscussionUserInteraction>>(
              stream: widget.interactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "An error occurred ${snapshot.error}",
                      style: const TextStyle(fontSize: 18, color: Colors.red),
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

                final filteredInteractions = _filterInteractions(snapshot.data!);

                if (filteredInteractions.isEmpty) {
                  return Center(
                    child: Text(
                      "No matches found for '$_searchQuery'",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredInteractions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final interaction = filteredInteractions[index];
                    return ListTile(
                      title: buildCard(
                        context, "Topic $index", interaction.theme),
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
          ),
        ],
      ),
    );
  }
}