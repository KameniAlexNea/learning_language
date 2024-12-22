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
  int _currentPage = 0;
  static const int _itemsPerPage = 7;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscussionUserInteraction> _filterInteractions(
      List<DiscussionUserInteraction> interactions) {
    if (_searchQuery.isEmpty) return interactions;

    // Split search query into words and remove empty strings
    final searchWords = _searchQuery
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    if (searchWords.isEmpty) return interactions;

    // Calculate threshold (50% of search words)
    final threshold = (searchWords.length / 2).ceil();

    return interactions.where((interaction) {
      final theme = interaction.theme.toLowerCase();
      // Count how many search words are found in the theme
      int matchedWords =
          searchWords.where((word) => theme.contains(word)).length;
      // Return true if at least 50% of search words are found
      return matchedWords >= threshold;
    }).toList();
  }

  List<DiscussionUserInteraction> _paginateInteractions(
      List<DiscussionUserInteraction> interactions) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= interactions.length) return [];
    return interactions.sublist(
        startIndex, endIndex.clamp(0, interactions.length));
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
                            _currentPage =
                                0; // Reset to first page when clearing search
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage =
                      0; // Reset to first page when search query changes
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

                final filteredInteractions =
                    _filterInteractions(snapshot.data!);
                final paginatedInteractions =
                    _paginateInteractions(filteredInteractions);
                final totalPages =
                    (filteredInteractions.length / _itemsPerPage).ceil();

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

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: paginatedInteractions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final interaction = paginatedInteractions[index];
                          final globalIndex =
                              _currentPage * _itemsPerPage + index;
                          return ListTile(
                            title: buildCard(context, "Topic $globalIndex",
                                interaction.theme),
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
                                  builder: (context) =>
                                      DetailPage(interaction: interaction),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text(
                              '${_currentPage + 1} / $totalPages',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
