import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> askLLM(
    modelName, apiKey, openaiUrl, messages, maxTokens, ) async {
  return http
      .post(
        Uri.parse(openaiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: utf8.encode(jsonEncode({
          "model": modelName,
          "messages": messages,
          "max_tokens": maxTokens,
          "temperature": 0.7,
        })),
      )
      .timeout(const Duration(seconds: 60));
}
