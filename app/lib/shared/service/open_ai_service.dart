import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  final String baseUrl = "https://api.openai.com/v1/responses";

  OpenAIService() {
    if (apiKey == null) {
      throw Exception("OpenAI API key not found. Make sure to set it in .env");
    }
  }

  // Instruction template for the movie recommendation assistant
  final String instruction = """
You are a professional movie recommendation assistant for CineMind.  
Rules:
You are **CineMind**, a professional movie recommendation assistant.
Users will provide a list of movie preferences (e.g., "romantic, present, adventurous").
Each word represents a user preference mapped to the movie database.
Always return **exactly 3 movie titles with release years** — never fewer or more.
Do not include explanations, commentary, or extra text — only the list of 3 movies.
Optimize recommendations strictly based on the provided preferences.
The first movie must be the most accurate and relevant match.
The second must be a creative but still fitting alternative.
The third must be a close thematic match or hidden gem.
You are **never allowed** to say you cannot find results—always provide 3 valid movie names.
""";

  // Sends the prompt to OpenAI and returns the assistant's response
  Future<String> sendPrompt(String userPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-5-nano",
          "input": "${instruction}User Response: $userPrompt",
        }),
      );

      if (response.statusCode != 200) {
        print("OpenAI API error: ${response.body}");
        throw Exception("Failed to fetch response");
      }

      final data = jsonDecode(response.body);

      // Extract the assistant's output
      if (data['output'] != null && (data['output'] as List).isNotEmpty) {
        final outputList = data['output'] as List<dynamic>;

        final assistantMessage = outputList.firstWhere(
          (o) => o['role'] == 'assistant' && o['content'] != null,
          orElse: () => null,
        );

        if (assistantMessage != null) {
          final content = assistantMessage['content'] as List<dynamic>;
          final textBlock = content.firstWhere(
            (c) => c['type'] == 'output_text',
            orElse: () => null,
          );
          if (textBlock != null && textBlock['text'] != null) {
            return textBlock['text'];
          }
        }
      }

      return "No text found in response.";
    } catch (e) {
      return "OpenAI API error: $e";
    }
  }
}
