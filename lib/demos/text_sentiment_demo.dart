import 'package:flutter/material.dart';

class TextSentimentDemo extends StatefulWidget {
  const TextSentimentDemo({super.key});

  @override
  State<TextSentimentDemo> createState() => _TextSentimentDemoState();
}

class _TextSentimentDemoState extends State<TextSentimentDemo> {
  final List<MessageAnalysis> _analysisHistory = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isAnalyzing = false;

  // Sentiment patterns
  final Map<SentimentType, Map<String, List<String>>> _sentimentPatterns = {
    SentimentType.harmful: {
      'offensive': ['stupid', 'dumb', 'idiot', 'loser'],
      'threatening': ['hurt', 'kill', 'fight', 'beat up'],
      'discriminatory': ['racist', 'sexist', 'hate', 'ugly'],
    },
    SentimentType.selfDestructive: {
      'depression': ['worthless', 'alone', 'hate myself', 'give up'],
      'anxiety': ['scared', 'worried', 'panic', 'afraid'],
      'suicidal': ['die', 'end it', 'no point', 'better off without'],
    },
    SentimentType.positive: {
      'supportive': ['great job', 'proud', 'amazing', 'well done'],
      'encouraging': ['keep going', 'believe', 'can do it', 'try again'],
      'friendly': ['friend', 'together', 'help', 'support'],
    },
    SentimentType.neutral: {
      'casual': ['okay', 'fine', 'normal', 'whatever'],
      'informative': ['today', 'tomorrow', 'going to', 'will be'],
      'questioning': ['what', 'when', 'where', 'how'],
    },
  };

  void _analyzeMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final message = _messageController.text;
      final analysis = _analyzeSentiment(message);
      
      setState(() {
        _analysisHistory.insert(0, analysis);
        _isAnalyzing = false;
        _messageController.clear();
      });

      if (analysis.severity != Severity.none) {
        _showAlert(analysis);
      }
    });
  }

  MessageAnalysis _analyzeSentiment(String message) {
    final detectedPatterns = <SentimentType, List<String>>{};
    final lowerMessage = message.toLowerCase();
    var severity = Severity.none;
    var recommendation = '';

    // Check for sentiment patterns
    for (var sentiment in _sentimentPatterns.entries) {
      final matches = <String>[];
      
      for (var category in sentiment.value.entries) {
        for (var pattern in category.value) {
          if (lowerMessage.contains(pattern)) {
            matches.add('${category.key}: "$pattern"');
          }
        }
      }

      if (matches.isNotEmpty) {
        detectedPatterns[sentiment.key] = matches;
      }
    }

    // Determine severity and recommendation
    if (detectedPatterns.containsKey(SentimentType.selfDestructive)) {
      severity = Severity.critical;
      recommendation = 'Immediate attention needed. This message shows signs of serious emotional distress.';
    } else if (detectedPatterns.containsKey(SentimentType.harmful)) {
      severity = Severity.high;
      recommendation = 'This message contains harmful content that should be addressed.';
    } else if (detectedPatterns.containsKey(SentimentType.positive)) {
      severity = Severity.none;
      recommendation = 'Positive and supportive message. Great communication!';
    } else {
      severity = Severity.none;
      recommendation = 'No concerning content detected.';
    }

    return MessageAnalysis(
      message: message,
      timestamp: DateTime.now(),
      detectedPatterns: detectedPatterns,
      severity: severity,
      recommendation: recommendation,
      sentiment: _calculateOverallSentiment(detectedPatterns),
    );
  }

  SentimentType _calculateOverallSentiment(
    Map<SentimentType, List<String>> patterns,
  ) {
    if (patterns.containsKey(SentimentType.selfDestructive)) {
      return SentimentType.selfDestructive;
    } else if (patterns.containsKey(SentimentType.harmful)) {
      return SentimentType.harmful;
    } else if (patterns.containsKey(SentimentType.positive)) {
      return SentimentType.positive;
    }
    return SentimentType.neutral;
  }

  void _showAlert(MessageAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForSeverity(analysis.severity),
              color: _getColorForSeverity(analysis.severity),
            ),
            const SizedBox(width: 8),
            const Text('Content Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message: ${analysis.message}'),
            const SizedBox(height: 16),
            if (analysis.detectedPatterns.isNotEmpty) ...[
              const Text(
                'Detected Patterns:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...analysis.detectedPatterns.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForSentiment(entry.key),
                          size: 16,
                          color: _getColorForSentiment(entry.key),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key.toString().split('.').last,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ...entry.value.map((pattern) => Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Text('• $pattern'),
                  )),
                ],
              )),
            ],
            const SizedBox(height: 16),
            Text(
              analysis.recommendation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (analysis.severity == Severity.critical)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Parent and counselor notified'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.priority_high),
              label: const Text('Notify Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Text Sentiment Analyzer',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze messages for emotional well-being and safety',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Enter message to analyze',
                      hintText: 'Type any message to check its emotional content...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeMessage,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: const Text('Analyze Message'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _analysisHistory.isEmpty
                  ? const Center(
                      child: Text('No messages analyzed yet'),
                    )
                  : ListView.builder(
                      itemCount: _analysisHistory.length,
                      itemBuilder: (context, index) {
                        return _buildAnalysisTile(_analysisHistory[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTile(MessageAnalysis analysis) {
    return ListTile(
      leading: Icon(
        _getIconForSentiment(analysis.sentiment),
        color: _getColorForSentiment(analysis.sentiment),
      ),
      title: Text(
        analysis.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${analysis.sentiment.toString().split('.').last} - ${_formatTime(analysis.timestamp)}',
      ),
      trailing: analysis.severity != Severity.none
          ? Chip(
              label: Text(
                analysis.severity.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getColorForSeverity(analysis.severity),
            )
          : null,
      onTap: () {
        if (analysis.severity != Severity.none) {
          _showAlert(analysis);
        }
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorForSentiment(SentimentType type) {
    switch (type) {
      case SentimentType.harmful:
        return Colors.red;
      case SentimentType.selfDestructive:
        return Colors.purple;
      case SentimentType.positive:
        return Colors.green;
      case SentimentType.neutral:
        return Colors.blue;
    }
  }

  IconData _getIconForSentiment(SentimentType type) {
    switch (type) {
      case SentimentType.harmful:
        return Icons.warning;
      case SentimentType.selfDestructive:
        return Icons.emergency;
      case SentimentType.positive:
        return Icons.sentiment_satisfied;
      case SentimentType.neutral:
        return Icons.sentiment_neutral;
    }
  }

  Color _getColorForSeverity(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Colors.red;
      case Severity.high:
        return Colors.orange;
      case Severity.none:
        return Colors.green;
    }
  }

  IconData _getIconForSeverity(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Icons.error;
      case Severity.high:
        return Icons.warning;
      case Severity.none:
        return Icons.check_circle;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

enum SentimentType {
  harmful,
  selfDestructive,
  positive,
  neutral,
}

enum Severity {
  none,
  high,
  critical,
}

class MessageAnalysis {
  final String message;
  final DateTime timestamp;
  final Map<SentimentType, List<String>> detectedPatterns;
  final Severity severity;
  final String recommendation;
  final SentimentType sentiment;

  MessageAnalysis({
    required this.message,
    required this.timestamp,
    required this.detectedPatterns,
    required this.severity,
    required this.recommendation,
    required this.sentiment,
  });
}
