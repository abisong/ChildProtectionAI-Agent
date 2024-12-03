import 'package:flutter/material.dart';

class PrivacyAgentDemo extends StatefulWidget {
  const PrivacyAgentDemo({super.key});

  @override
  State<PrivacyAgentDemo> createState() => _PrivacyAgentDemoState();
}

class _PrivacyAgentDemoState extends State<PrivacyAgentDemo> {
  final List<PrivacyIncident> _incidents = [];
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _platformController = TextEditingController();
  bool _isAnalyzing = false;

  // Privacy patterns to detect
  final Map<PrivacyType, List<String>> _privacyPatterns = {
    PrivacyType.personalInfo: [
      r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',  // Phone numbers
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  // Email
      r'\b\d{5}(?:[-\s]\d{4})?\b',  // ZIP codes
    ],
    PrivacyType.location: [
      'address',
      'street',
      'avenue',
      'school',
      'live',
      'neighborhood',
    ],
    PrivacyType.identity: [
      'password',
      'username',
      'full name',
      'birth',
      'age',
      'grade',
    ],
    PrivacyType.financial: [
      'credit card',
      'bank',
      'money',
      'account',
      'payment',
    ],
  };

  void _analyzeContent() {
    if (_contentController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 1), () {
      final content = _contentController.text;
      final platform = _platformController.text.isEmpty 
          ? 'Unknown Platform' 
          : _platformController.text;
      
      final analysis = _analyzePrivacy(content);

      if (analysis.detectedTypes.isNotEmpty) {
        final incident = PrivacyIncident(
          content: content,
          platform: platform,
          timestamp: DateTime.now(),
          detectedTypes: analysis.detectedTypes,
          riskLevel: analysis.riskLevel,
          recommendation: analysis.recommendation,
        );

        setState(() {
          _incidents.insert(0, incident);
          _isAnalyzing = false;
          _contentController.clear();
          _platformController.clear();
        });

        _showAlert(incident);
      } else {
        setState(() {
          _isAnalyzing = false;
          _contentController.clear();
          _platformController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No privacy concerns detected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  PrivacyAnalysis _analyzePrivacy(String content) {
    final detectedTypes = <PrivacyType>{};
    final lowerContent = content.toLowerCase();

    // Check for each privacy type
    for (var entry in _privacyPatterns.entries) {
      for (var pattern in entry.value) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(lowerContent)) {
          detectedTypes.add(entry.key);
          break;
        }
      }
    }

    if (detectedTypes.isEmpty) {
      return PrivacyAnalysis(
        detectedTypes: detectedTypes,
        riskLevel: RiskLevel.safe,
        recommendation: 'Content is safe to share',
      );
    }

    // Determine risk level and recommendation
    RiskLevel riskLevel;
    String recommendation;

    if (detectedTypes.length >= 3) {
      riskLevel = RiskLevel.critical;
      recommendation = 'Multiple types of personal information detected. Do not share this content!';
    } else if (detectedTypes.length == 2) {
      riskLevel = RiskLevel.high;
      recommendation = 'Several pieces of personal information found. Consider removing sensitive details.';
    } else {
      riskLevel = RiskLevel.moderate;
      recommendation = 'Personal information detected. Be careful about sharing this information.';
    }

    return PrivacyAnalysis(
      detectedTypes: detectedTypes,
      riskLevel: riskLevel,
      recommendation: recommendation,
    );
  }

  void _showAlert(PrivacyIncident incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForRiskLevel(incident.riskLevel),
              color: _getColorForRiskLevel(incident.riskLevel),
            ),
            const SizedBox(width: 8),
            const Text('Privacy Risk Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: ${incident.platform}'),
            const SizedBox(height: 8),
            const Text('Detected Information Types:'),
            ...incident.detectedTypes.map((type) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  Icon(_getIconForPrivacyType(type), size: 16),
                  const SizedBox(width: 8),
                  Text(type.toString().split('.').last),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Text(
              incident.recommendation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Edit Content'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content blocked from being shared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Block Sharing'),
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
            'Personal Data Privacy Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze content for personal information before sharing',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _platformController,
                    decoration: const InputDecoration(
                      labelText: 'Platform or Website',
                      hintText: 'e.g., Social Media, Chat App, Forum',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Content to Analyze',
                      hintText: 'Type or paste content to check for personal information...',
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
                    label: const Text('Analyze Privacy Risk'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _incidents.isEmpty
                  ? const Center(
                      child: Text('No privacy incidents detected yet'),
                    )
                  : ListView.builder(
                      itemCount: _incidents.length,
                      itemBuilder: (context, index) {
                        return _buildIncidentTile(_incidents[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentTile(PrivacyIncident incident) {
    return ListTile(
      leading: Icon(
        _getIconForRiskLevel(incident.riskLevel),
        color: _getColorForRiskLevel(incident.riskLevel),
      ),
      title: Text(
        incident.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${incident.platform} - ${_formatTime(incident.timestamp)}',
      ),
      trailing: Chip(
        label: Text(
          incident.riskLevel.toString().split('.').last,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: _getColorForRiskLevel(incident.riskLevel),
      ),
      onTap: () => _showAlert(incident),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return Colors.red;
      case RiskLevel.high:
        return Colors.orange;
      case RiskLevel.moderate:
        return Colors.yellow.shade700;
      case RiskLevel.safe:
        return Colors.green;
    }
  }

  IconData _getIconForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return Icons.error;
      case RiskLevel.high:
        return Icons.warning;
      case RiskLevel.moderate:
        return Icons.info;
      case RiskLevel.safe:
        return Icons.check_circle;
    }
  }

  IconData _getIconForPrivacyType(PrivacyType type) {
    switch (type) {
      case PrivacyType.personalInfo:
        return Icons.person;
      case PrivacyType.location:
        return Icons.location_on;
      case PrivacyType.identity:
        return Icons.badge;
      case PrivacyType.financial:
        return Icons.attach_money;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _platformController.dispose();
    super.dispose();
  }
}

enum PrivacyType {
  personalInfo,
  location,
  identity,
  financial,
}

enum RiskLevel {
  safe,
  moderate,
  high,
  critical,
}

class PrivacyIncident {
  final String content;
  final String platform;
  final DateTime timestamp;
  final Set<PrivacyType> detectedTypes;
  final RiskLevel riskLevel;
  final String recommendation;

  PrivacyIncident({
    required this.content,
    required this.platform,
    required this.timestamp,
    required this.detectedTypes,
    required this.riskLevel,
    required this.recommendation,
  });
}

class PrivacyAnalysis {
  final Set<PrivacyType> detectedTypes;
  final RiskLevel riskLevel;
  final String recommendation;

  PrivacyAnalysis({
    required this.detectedTypes,
    required this.riskLevel,
    required this.recommendation,
  });
}
