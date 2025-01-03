class DiscussionInteraction {
  String? uid;
  final String theme;
  final String userAnswer;
  final String evaluation;
  final String suggestedIdea;
  final String suggestedAnswer;

  DiscussionInteraction({
    required this.theme,
    required this.userAnswer,
    required this.evaluation,
    required this.suggestedIdea,
    required this.suggestedAnswer,
    this.uid,
  });

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'userAnswer': userAnswer,
        'evaluation': evaluation,
        'suggestedIdea': suggestedIdea,
        'suggestedAnswer': suggestedAnswer,
      };

  static DiscussionInteraction fromJson(Map<String, dynamic> json) {
    try {
      return DiscussionInteraction(
        theme: json['theme'] ?? '',
        uid: json['uid'] ?? '',
        userAnswer: json['userAnswer'] ?? '',
        evaluation: json['evaluation'] ?? '',
        suggestedIdea: json['suggestedIdea'] ?? '',
        suggestedAnswer: json['suggestedAnswer'] ?? '',
      );
    } catch (e) {
      throw FormatException('Error parsing DiscussionInteraction: $e');
    }
  }
}

class DiscussionUserInteraction extends DiscussionInteraction {
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscussionUserInteraction({
    required this.userId,
    required super.theme,
    required super.userAnswer,
    required super.evaluation,
    required super.suggestedIdea,
    required super.suggestedAnswer,
    DateTime? createdAt,
    DateTime? updatedAt,
    super.uid,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static DiscussionUserInteraction fromJson(String docid, Map<String, dynamic> json) {
    try {
      return DiscussionUserInteraction(
        theme: json['theme'] ?? '',
        userAnswer: json['userAnswer'] ?? '',
        evaluation: json['evaluation'] ?? '',
        suggestedIdea: json['suggestedIdea'] ?? '',
        suggestedAnswer: json['suggestedAnswer'] ?? '',
        userId: json['userId'] ?? '',
        createdAt: json['createdAt']?.toDate(),
        updatedAt: json['updatedAt']?.toDate(),
        uid: docid,
      );
    } catch (e) {
      throw FormatException('Error parsing DiscussionUserInteraction: $e');
    }
  }
}
