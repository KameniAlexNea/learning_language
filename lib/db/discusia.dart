import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import '../utilities/prompts.dart';
import '../api/llmservice.dart';
import 'model.dart';

class DiscusiaConfig {
  static late prefs.SharedPreferences _prefs;
  
  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await prefs.SharedPreferences.getInstance();
    await _loadSavedState();
  }

  // Private storage keys
  static const String _topicKey = 'current_topic';
  static const String _evaluationKey = 'evaluation';
  static const String _suggestedAnswerKey = 'suggested_answer';
  static const String _suggestedIdeaKey = 'suggested_idea';
  static const String _errorMessageKey = 'error_message';

  // Getters and setters with persistence
  static String _errorMessage = "";
  static String get errorMessage => _errorMessage;
  static set errorMessage(String value) {
    _errorMessage = value;
    _prefs.setString(_errorMessageKey, value);
  }

  static String _currentTopic = "";
  static String get currentTopic => _currentTopic;
  static set currentTopic(String value) {
    _currentTopic = value;
    _prefs.setString(_topicKey, value);
  }

  static String _evaluation = "";
  static String get evaluation => _evaluation;
  static set evaluation(String value) {
    _evaluation = value;
    _prefs.setString(_evaluationKey, value);
  }

  static String _suggestedAnswer = "";
  static String get suggestedAnswer => _suggestedAnswer;
  static set suggestedAnswer(String value) {
    _suggestedAnswer = value;
    _prefs.setString(_suggestedAnswerKey, value);
  }

  static String _suggestedIdea = "";
  static String get suggestedIdea => _suggestedIdea;
  static set suggestedIdea(String value) {
    _suggestedIdea = value;
    _prefs.setString(_suggestedIdeaKey, value);
  }

  // Load saved state from SharedPreferences
  static Future<void> _loadSavedState() async {
    _errorMessage = _prefs.getString(_errorMessageKey) ?? "";
    _currentTopic = _prefs.getString(_topicKey) ?? "";
    _evaluation = _prefs.getString(_evaluationKey) ?? "";
    _suggestedAnswer = _prefs.getString(_suggestedAnswerKey) ?? "";
    _suggestedIdea = _prefs.getString(_suggestedIdeaKey) ?? "";
  }

  // Rest of your existing code...
  static bool isGeneratingTopic = false;
  static bool isEvaluatingResponse = false;
  static bool isGettingSuggestedAnswer = false;
  static bool isGettingSuggestedIdea = false;
  static bool isSavingState = false;

  static String selectedLanguage = "English";
  static Prompts get prompts => Prompts(selectedLanguage);

  static Function get llmCall =>
      modelType == 0 ? askLLMOA : (modelType == 1 ? askLLMHF : askLLMGroq);
  static final modelType = 2;
  static final TextEditingController responseController = TextEditingController();

  static List<DiscussionUserInteraction> interactions = [];

  static void clearInterface({bool withTopic = false}) {
    errorMessage = "";
    evaluation = "";
    suggestedAnswer = "";
    suggestedIdea = "";

    isEvaluatingResponse = false;
    isGettingSuggestedAnswer = false;
    isGettingSuggestedIdea = false;
    isSavingState = false;

    responseController.text = "";
    if (withTopic) {
      currentTopic = "";
      isGeneratingTopic = false;
    }
  }

  // Add a method to clear stored data
  static Future<void> clearStoredData() async {
    await _prefs.clear();
    clearInterface(withTopic: true);
  }
}