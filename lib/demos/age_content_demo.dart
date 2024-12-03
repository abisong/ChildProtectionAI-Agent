import 'package:flutter/material.dart';

class AgeContentDemo extends StatefulWidget {
  const AgeContentDemo({super.key});

  @override
  State<AgeContentDemo> createState() => _AgeContentDemoState();
}

class _AgeContentDemoState extends State<AgeContentDemo> {
  final List<ContentAnalysis> _analysisHistory = [];
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAnalyzing = false;
  int _selectedAge = 10;

  // Age-based content categories
  final Map<ContentCategory, Map<String, int>> _ageRestrictions = {
    ContentCategory.violence: {
      'mild': 7,
      'moderate': 13,
      'intense': 16,
    },
    ContentCategory.language: {
      'clean': 0,
      'mild': 9,
      'moderate': 13,
      'strong': 16,
    },
    ContentCategory.themes: {
      'children': 0,
      'teen': 13,
      'mature': 16,
    },
    ContentCategory.social: {
      'supervised': 7,
      'moderated': 13,
      'unrestricted': 16,
    },
  };

  // Content keywords for analysis
  final Map<ContentCategory, Map<String, List<String>>> _contentPatterns = {
    ContentCategory.violence: {
      'mild': ['conflict', 'fight', 'battle'],
      'moderate': ['weapon', 'blood', 'injury'],
      'intense': ['gore', 'death', 'kill'],
    },
    ContentCategory.language: {
      'clean': ['hello', 'good', 'nice'],
      'mild': ['stupid', 'dumb', 'idiot'],
      'moderate': ['curse', 'swear'],
      'strong': ['profanity', 'explicit'],
    },
    ContentCategory.themes: {
      'children': ['cartoon', 'fun', 'play'],
      'teen': ['romance', 'drama', 'relationship'],
      'mature': ['drugs', 'alcohol', 'violence'],
    },
    ContentCategory.social: {
      'supervised': ['moderated', 'family', 'kids'],
      'moderated': ['chat', 'comments', 'social'],
      'unrestricted': ['anonymous', 'public', 'unrestricted'],
    },
  };

  void _analyzeContent() {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final url = _urlController.text;
      final content = _contentController.text;
      final analysis = _analyzeAgeAppropriate(content);

      setState(() {
        _analysisHistory.insert(
          0,
          ContentAnalysis(
            url: url,
            content: content,
            timestamp: DateTime.now(),
            categories: analysis.categories,
            minimumAge: analysis.minimumAge,
            warnings: analysis.warnings,
            isAllowed: analysis.minimumAge <= _selectedAge,
          ),
        );
        _isAnalyzing = false;
        _urlController.clear();
        _contentController.clear();
      });

      if (!analysis.isAllowed) {
        _showAlert(analysis);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Content is age-appropriate'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  AgeAnalysis _analyzeAgeAppropriate(String content) {
    final detectedCategories = <ContentCategory, String>{};
    final warnings = <String>[];
    int highestAge = 0;
    final lowerContent = content.toLowerCase();

    // Check content against patterns
    for (var category in _contentPatterns.entries) {
      for (var level in category.value.entries) {
        if (level.value.any((pattern) => lowerContent.contains(pattern))) {
          detectedCategories[category.key] = level.key;
          final requiredAge = _ageRestrictions[category.key]![level.key] ?? 0;
          if (requiredAge > highestAge) {
            highestAge = requiredAge;
          }
          if (requiredAge > _selectedAge) {
            warnings.add(
              '${category.key.toString().split('.').last} content requires age $requiredAge+',
            );
          }
        }
      }
    }

    return AgeAnalysis(
      categories: detectedCategories,
      minimumAge: highestAge,
      warnings: warnings,
      isAllowed: highestAge <= _selectedAge,
    );
  }

  void _showAlert(AgeAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Age-Inappropriate Content'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minimum Age Required: ${analysis.minimumAge}+'),
            Text('Current Age Setting: $_selectedAge'),
            const SizedBox(height: 16),
            const Text(
              'Content Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...analysis.categories.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  Icon(
                    _getIconForCategory(entry.key),
                    size: 16,
                    color: _getColorForCategory(entry.key),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key.toString().split('.').last}: ${entry.value}',
                  ),
                ],
              ),
            )),
            if (analysis.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...analysis.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content blocked and parent notified'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.block),
            label: const Text('Block Content'),
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
            'Age-Inappropriate Content Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze content for age-appropriateness',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Child\'s Age: '),
                      Expanded(
                        child: Slider(
                          value: _selectedAge.toDouble(),
                          min: 5,
                          max: 17,
                          divisions: 12,
                          label: '$_selectedAge years',
                          onChanged: (value) {
                            setState(() {
                              _selectedAge = value.round();
                            });
                          },
                        ),
                      ),
                      Text(
                        '$_selectedAge years',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL or Source',
                      hintText: 'Enter the content source or URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Content to Analyze',
                      hintText: 'Enter or paste content to check...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeContent,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.security),
                    label: const Text('Analyze Content'),
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
                      child: Text('No content analyzed yet'),
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

  Widget _buildAnalysisTile(ContentAnalysis analysis) {
    return ListTile(
      leading: Icon(
        analysis.isAllowed ? Icons.check_circle : Icons.block,
        color: analysis.isAllowed ? Colors.green : Colors.red,
      ),
      title: Text(
        analysis.url.isEmpty ? 'Content Analysis' : analysis.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Age ${analysis.minimumAge}+ - ${_formatTime(analysis.timestamp)}',
      ),
      trailing: Wrap(
        spacing: 4,
        children: analysis.categories.keys.map((category) {
          return Icon(
            _getIconForCategory(category),
            size: 16,
            color: _getColorForCategory(category),
          );
        }).toList(),
      ),
      onTap: () => _showAlert(AgeAnalysis(
        categories: analysis.categories,
        minimumAge: analysis.minimumAge,
        warnings: const [],
        isAllowed: analysis.isAllowed,
      )),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForCategory(ContentCategory category) {
    switch (category) {
      case ContentCategory.violence:
        return Icons.warning;
      case ContentCategory.language:
        return Icons.message;
      case ContentCategory.themes:
        return Icons.theater_comedy;
      case ContentCategory.social:
        return Icons.people;
    }
  }

  Color _getColorForCategory(ContentCategory category) {
    switch (category) {
      case ContentCategory.violence:
        return Colors.red;
      case ContentCategory.language:
        return Colors.orange;
      case ContentCategory.themes:
        return Colors.purple;
      case ContentCategory.social:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

enum ContentCategory {
  violence,
  language,
  themes,
  social,
}

class ContentAnalysis {
  final String url;
  final String content;
  final DateTime timestamp;
  final Map<ContentCategory, String> categories;
  final int minimumAge;
  final List<String> warnings;
  final bool isAllowed;

  ContentAnalysis({
    required this.url,
    required this.content,
    required this.timestamp,
    required this.categories,
    required this.minimumAge,
    required this.warnings,
    required this.isAllowed,
  });
}

class AgeAnalysis {
  final Map<ContentCategory, String> categories;
  final int minimumAge;
  final List<String> warnings;
  final bool isAllowed;

  AgeAnalysis({
    required this.categories,
    required this.minimumAge,
    required this.warnings,
    required this.isAllowed,
  });
}
