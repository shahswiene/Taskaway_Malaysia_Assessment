import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:taskaway_app/core/constants/app_constants.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  /// Generate tasks from a user description using Groq API
  static Future<List<String>> generateTasksFromDescription(String description) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'qwen-qwq-32b',  // Using the Qwen QwQ 32B model
          'messages': [
            {
              'role': 'system', 
              'content': 'You are a helpful task management assistant. '
                  'Break down complex tasks into actionable items. '
                  'Identify main tasks and subtasks from user descriptions. '
                  'Your response must be a numbered list of tasks, each on a new line.\n\n'
                  'Example format:\n'
                  '1. First task\n'
                  '2. Second task\n'
                  '3. Third task\n'
                  'Do not include any explanations or additional text.'
            },
            {
              'role': 'user',
              'content': description,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        
        // Parse the numbered list response
        final List<String> tasks = [];
        
        // Split the content by new lines and process each line
        final lines = content.split('\n');
        for (final line in lines) {
          // Look for lines that start with a number followed by a period
          final trimmedLine = line.trim();
          if (RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
            // Remove the number and period at the start
            final taskText = trimmedLine.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
            if (taskText.isNotEmpty) {
              tasks.add(taskText);
            }
          }
        }
        
        if (tasks.isEmpty) {
          // If no numbered format is found, just return all non-empty lines
          tasks.addAll(lines.where((line) => line.trim().isNotEmpty));
        }
        
        log('Generated ${tasks.length} tasks from description', name: 'GroqService');
        return tasks;
      } else {
        log('Error from Groq API: ${response.statusCode} - ${response.body}', 
            name: 'GroqService');
        throw Exception('Failed to generate tasks from Groq API');
      }
    } catch (e) {
      log('Exception in generateTasksFromDescription: $e', name: 'GroqService');
      throw Exception('Failed to process task generation: $e');
    }
  }
}
