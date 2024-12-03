import 'package:flutter/material.dart';

class MentalHealthDemo extends StatefulWidget {
  const MentalHealthDemo({super.key});

  @override
  State<MentalHealthDemo> createState() => _MentalHealthDemoState();
}

class _MentalHealthDemoState extends State<MentalHealthDemo> {
  final List<JournalEntry> _entries = [];
  final TextEditingController _entryController = TextEditingController();
  bool _isAnalyzing = false;

  // Keywords for sentiment analysis
  final Map<String, List<String>> _emotionalIndicators = {
    'anxiety': ['worried', 'nervous', 'scared', 'anxious', 'stress', 'fear'],
    'depression': ['sad', 'lonely', 'hopeless', 'tired', 'worthless', 'empty'],
    'anger': ['angry', 'mad', 'hate', 'frustrated', 'annoyed', 'upset'],
    'happiness': ['happy', 'excited', 'fun', 'great', 'wonderful', 'love'],
    'neutral': ['okay', 'fine', 'normal', 'average', 'alright'],
  };

  void _analyzeEntry() {
    if (_entryController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 1), () {
      final entry = _entryController.text;
      final analysis = _analyzeText(entry.toLowerCase());
      
      setState(() {
        _entries.add(JournalEntry(
          text: entry,
          timestamp: DateTime.now(),
          sentiment: analysis.sentiment,
          emotionalState: analysis.emotionalState,
          recommendations: analysis.recommendations,
        ));
        _isAnalyzing = false;
        _entryController.clear();

        if (analysis.requiresAttention) {
          _showAlert(analysis);
        }
      });
    });
  }

  EmotionalAnalysis _analyzeText(String text) {
    Map<String, int> emotionCounts = {};
    List<String> recommendations = [];
    bool requiresAttention = false;

    // Count emotional indicators
    for (var emotion in _emotionalIndicators.keys) {
      int count = _emotionalIndicators[emotion]!
          .where((word) => text.contains(word))
          .length;
      emotionCounts[emotion] = count;
    }

    // Determine primary emotion
    String primaryEmotion = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Generate recommendations based on emotional state
    switch (primaryEmotion) {
      case 'anxiety':
        recommendations = [
          'Try some breathing exercises',
          'Take a short break from screens',
          'Talk to a trusted friend or adult',
        ];
        requiresAttention = true;
        break;
      case 'depression':
        recommendations = [
          'Reach out to someone you trust',
          'Do something you enjoy',
          'Consider talking to a counselor',
        ];
        requiresAttention = true;
        break;
      case 'anger':
        recommendations = [
          'Take a moment to calm down',
          'Express your feelings safely',
          'Try physical activity to release tension',
        ];
        requiresAttention = true;
        break;
      case 'happiness':
        recommendations = [
          'Share your joy with others',
          'Write down what made you happy',
          'Keep up the positive activities',
        ];
        break;
      default:
        recommendations = [
          'Continue monitoring your feelings',
          'Maintain your daily routine',
          'Stay connected with friends and family',
        ];
    }

    return EmotionalAnalysis(
      sentiment: _getSentimentScore(emotionCounts),
      emotionalState: primaryEmotion,
      recommendations: recommendations,
      requiresAttention: requiresAttention,
    );
  }

  double _getSentimentScore(Map<String, int> emotionCounts) {
    int positive = emotionCounts['happiness'] ?? 0;
    int negative = (emotionCounts['anxiety'] ?? 0) +
        (emotionCounts['depression'] ?? 0) +
        (emotionCounts['anger'] ?? 0);
    int total = positive + negative + (emotionCounts['neutral'] ?? 0);

    if (total == 0) return 0.5;
    return (positive - negative + total) / (2 * total);
  }

  void _showAlert(EmotionalAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Emotional Support Needed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detected emotional state: ${analysis.emotionalState}'),
            const SizedBox(height: 16),
            const Text('Recommendations:'),
            ...analysis.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'Consider notifying a parent or guardian for support.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Acknowledge'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parent notification sent'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Notify Parent'),
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
            'Mental Health Analyzer',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Share your thoughts and feelings to get emotional support',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Text(
                      'Start journaling to track your emotional well-being',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      return _buildJournalCard(_entries[index]);
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _entryController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'How are you feeling?',
                    hintText: 'Share your thoughts and emotions...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeEntry,
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Analyze'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    Color cardColor = _getColorForEmotion(entry.emotionalState);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          _getIconForEmotion(entry.emotionalState),
          color: cardColor,
        ),
        title: Text(
          entry.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')} - '
          'Feeling ${entry.emotionalState}',
          style: TextStyle(color: cardColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.text),
                const SizedBox(height: 8),
                const Divider(),
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...entry.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForEmotion(String emotion) {
    switch (emotion) {
      case 'anxiety':
        return Colors.orange;
      case 'depression':
        return Colors.purple;
      case 'anger':
        return Colors.red;
      case 'happiness':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconForEmotion(String emotion) {
    switch (emotion) {
      case 'anxiety':
        return Icons.warning;
      case 'depression':
        return Icons.cloud;
      case 'anger':
        return Icons.flash_on;
      case 'happiness':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }
}

class JournalEntry {
  final String text;
  final DateTime timestamp;
  final double sentiment;
  final String emotionalState;
  final List<String> recommendations;

  JournalEntry({
    required this.text,
    required this.timestamp,
    required this.sentiment,
    required this.emotionalState,
    required this.recommendations,
  });
}

class EmotionalAnalysis {
  final double sentiment;
  final String emotionalState;
  final List<String> recommendations;
  final bool requiresAttention;

  EmotionalAnalysis({
    required this.sentiment,
    required this.emotionalState,
    required this.recommendations,
    required this.requiresAttention,
  });
}
