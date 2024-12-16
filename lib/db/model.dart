class DiscussionInteraction {
  static int _nextId = 1; // Private static variable to track the next ID

  final int id; // Unique ID for each interaction
  final String theme; // The generated discussion theme
  final String userAnswer; // User's response to the theme
  final String evaluation; // Evaluation details
  final String suggestedIdea; // Suggested idea
  final String suggestedAnswer; // Suggested answer
  final DateTime date; // Timestamp for when the interaction occurred

  DiscussionInteraction({
    int? id, // Optional ID parameter
    required this.theme,
    required this.userAnswer,
    required this.evaluation,
    required this.suggestedIdea,
    required this.suggestedAnswer,
    DateTime? date, // Optional date parameter
  })  : id = id ?? _nextId++, // Use provided ID or auto-increment
        date = date ?? DateTime.now(); // Use provided date or current date

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'theme': theme,
        'userAnswer': userAnswer,
        'evaluation': evaluation,
        'suggestedIdea': suggestedIdea,
        'suggestedAnswer': suggestedAnswer,
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
      suggestedAnswer: json['suggestedAnswer'],
      date: DateTime.parse(json['date']),
    );
  }
}
