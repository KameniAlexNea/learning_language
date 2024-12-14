import 'package:flutter_dotenv/flutter_dotenv.dart';

final hfApiKey = dotenv.env['hfApiKey'] ?? '';
final openAIApiKey = dotenv.env['openAIApiKey'] ?? '';
final groqApiKey = dotenv.env['groqApiKey'] ?? '';

final String openaiUrl = dotenv.env['openaiUrl'] ?? '';
final String openAiModel = dotenv.env['openAiModel'] ?? '';

final String groqApiUrl = dotenv.env['groqApiUrl'] ?? '';
final String gropModel = dotenv.env['gropModel'] ?? '';

final String hfModelName = dotenv.env['hfModelName'] ?? '';

String get hfLink =>
    "https://api-inference.huggingface.co/models/${hfModelName}/v1/chat/completions";
