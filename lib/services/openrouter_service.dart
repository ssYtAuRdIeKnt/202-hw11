import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/summary_result.dart';

class OpenRouterService {
  static const String _apiKey = String.fromEnvironment('OPENROUTER_API_KEY');
  static const String _endpoint = String.fromEnvironment('OPENROUTER_ENDPOINT');
  static const String _model = String.fromEnvironment('OPENROUTER_MODEL');

  Future<SummaryResult> summarize({required String text}) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'OPENROUTER_API_KEY is missing. Run with --dart-define=OPENROUTER_API_KEY=...',
      );
    }
    if (_endpoint.isEmpty) {
      throw Exception(
        'OPENROUTER_ENDPOINT is missing. Example: --dart-define=OPENROUTER_ENDPOINT=https://openrouter.ai/api/v1/chat/completions',
      );
    }
    if (_model.isEmpty) {
      throw Exception(
        'OPENROUTER_MODEL is missing. Example: --dart-define=OPENROUTER_MODEL=openai/gpt-4.1-mini',
      );
    }

    final requestBody = {
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You summarize user text. Return only JSON with "title" and "summary".',
        },
        {'role': 'user', 'content': text},
      ],
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'summary_response',
          'strict': true,
          'schema': SummaryResult.schema,
        },
      },
      'temperature': 0.2,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: const {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Response root must be a JSON object.');
    }

    // 1) If API already returns {title, summary} directly, use it as-is.
    // 2) If API wraps payload, extract JSON from the first choice.
    final resultJson = _extractSummaryJson(decoded);
    return SummaryResult.fromJson(resultJson);
  }

  Map<String, dynamic> _extractSummaryJson(Map<String, dynamic> root) {
    if (_looksLikeSummary(root)) {
      return root;
    }

    final choices = root['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map<String, dynamic>) {
        final message = first['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is String && content.trim().isNotEmpty) {
            final parsed = jsonDecode(content);
            if (parsed is Map<String, dynamic>) {
              return parsed;
            }
          }
          if (content is Map<String, dynamic>) {
            return content;
          }
        }
      }
    }

    throw const FormatException(
      'Could not extract {title, summary} from response.',
    );
  }

  bool _looksLikeSummary(Map<String, dynamic> json) {
    return json.containsKey('title') && json.containsKey('summary');
  }
}
