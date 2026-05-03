import 'package:flutter/material.dart';

import '../models/summary_result.dart';
import '../services/openrouter_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _controller = TextEditingController();
  final _service = OpenRouterService();
  SummaryResult? _result;
  String? _errorText;
  bool _isLoading = false;

  Future<void> _onSummarizePressed() async {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorText = 'Please enter some text first.';
        _result = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final result = await _service.summarize(text: input);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = null;
        _errorText = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Text Summarizer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputPanel(
              controller: _controller,
              isLoading: _isLoading,
              onSummarizePressed: _onSummarizePressed,
            ),
            const SizedBox(height: 16),
            ResultPanel(
              result: _result,
              errorText: _errorText,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget 1: input area + action button.
class InputPanel extends StatelessWidget {
  const InputPanel({
    required this.controller,
    required this.isLoading,
    required this.onSummarizePressed,
    super.key,
  });

  final TextEditingController controller;
  final bool isLoading;
  final Future<void> Function() onSummarizePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Input text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSummarizePressed,
            child: const Text('Generate title + summary'),
          ),
        ),
      ],
    );
  }
}

// Widget 2: output area for title/summary or errors.
class ResultPanel extends StatelessWidget {
  const ResultPanel({
    required this.result,
    required this.errorText,
    required this.isLoading,
    super.key,
  });

  final SummaryResult? result;
  final String? errorText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorText != null) {
      return Text(errorText!, style: const TextStyle(color: Colors.red));
    }

    if (result == null) {
      return const Text('Result will appear here.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result!.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(result!.summary),
          ],
        ),
      ),
    );
  }
}
