import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class AIService {
  static Future<List<Question>> generateQuestions(
      String topic, int count, String difficulty) async {
    final url =
        Uri.parse('https://ai-flashcard-backend.vercel.app/api/generate');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic,
        'count': count,
        'difficulty': difficulty,
      }),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((q) => Question.fromJson(q)).toList();
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }
}
