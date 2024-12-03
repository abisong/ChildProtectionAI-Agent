import 'package:flutter/material.dart';

class ContentFilteringDemo extends StatefulWidget {
  const ContentFilteringDemo({super.key});

  @override
  State<ContentFilteringDemo> createState() => _ContentFilteringDemoState();
}

class _ContentFilteringDemoState extends State<ContentFilteringDemo> {
  final TextEditingController _urlController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  void _analyzeContent() {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final url = _urlController.text.toLowerCase();
      setState(() {
        _isLoading = false;
        if (url.contains('game') || url.contains('education')) {
          _result = '✅ Safe content detected: Educational or gaming content';
        } else if (url.contains('violence') || url.contains('adult')) {
          _result = '❌ Unsafe content detected: Contains inappropriate material';
        } else {
          _result = '🔍 Content appears neutral: No harmful content detected';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Content Filtering Demo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Enter URL or content to analyze',
              hintText: 'e.g., educational-game.com or violence-content.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeContent,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Analyze Content'),
          ),
          const SizedBox(height: 16),
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
