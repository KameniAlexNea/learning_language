class DiscussionInteraction {
  final int id; // Unique ID for each interaction
  final String theme; // The generated discussion theme
  final String userAnswer; // User's response to the theme
  final String evaluation; // Evaluation details
  final String suggestedIdea; // Evaluation details
  final DateTime date; // Timestamp for when the interaction occurred

  DiscussionInteraction({
    required this.id,
    required this.theme,
    required this.userAnswer,
    required this.evaluation,
    required this.suggestedIdea,
    required this.date,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'theme': theme,
        'userAnswer': userAnswer,
        'evaluation': evaluation,
        'suggestedIdea': suggestedIdea,
        'date': date.toIso8601String(),
      };

  // Create from JSON
  factory DiscussionInteraction.fromJson(Map<String, dynamic> json) {
    return DiscussionInteraction(
      id: json['id'],
      theme: json['theme'],
      userAnswer: json['userAnswer'],
      evaluation: json['evaluation'],
      suggestedIdea: json['suggestedIdea'],
      date: DateTime.parse(json['date']),
    );
  }
}

