import 'package:flutter/material.dart';

class StrangerInteractionDemo extends StatefulWidget {
  const StrangerInteractionDemo({super.key});

  @override
  State<StrangerInteractionDemo> createState() => _StrangerInteractionDemoState();
}

class _StrangerInteractionDemoState extends State<StrangerInteractionDemo> {
  final List<InteractionRequest> _requests = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isAnalyzing = false;

  // Risk patterns to detect
  final Map<RiskType, List<String>> _riskPatterns = {
    RiskType.personalInfo: [
      'where do you live',
      'what school',
      'how old are you',
      'phone number',
      'address',
    ],
    RiskType.meetup: [
      'meet up',
      'hang out',
      'come over',
      'meet in person',
      'lets meet',
    ],
    RiskType.grooming: [
      'secret',
      'dont tell',
      "don't tell",
      'just between us',
      'special friend',
    ],
    RiskType.manipulation: [
      'trust me',
      'no one understands',
      'your parents dont',
      'real friend',
      'only I',
    ],
  };

  final List<String> _knownContacts = [
    'Mom',
    'Dad',
    'Best Friend Sarah',
    'Cousin Mike',
    'Teacher Ms. Johnson',
  ];

  void _analyzeInteraction() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final message = _messageController.text;
      final analysis = _analyzeRisks(message);
      
      final request = InteractionRequest(
        senderName: 'Unknown User',
        message: message,
        timestamp: DateTime.now(),
        detectedRisks: analysis.detectedRisks,
        riskLevel: analysis.riskLevel,
        warnings: analysis.warnings,
        recommendation: analysis.recommendation,
      );

      setState(() {
        _requests.insert(0, request);
        _isAnalyzing = false;
        _messageController.clear();
      });

      if (analysis.riskLevel != RiskLevel.safe) {
        _showAlert(request);
      }
    });
  }

  RiskAnalysis _analyzeRisks(String message) {
    final detectedRisks = <RiskType>{};
    final warnings = <String>[];
    final lowerMessage = message.toLowerCase();

    // Check for risk patterns
    for (var entry in _riskPatterns.entries) {
      if (entry.value.any((pattern) => lowerMessage.contains(pattern))) {
        detectedRisks.add(entry.key);
        warnings.add('Detected ${entry.key.toString().split('.').last} risk pattern');
      }
    }

    // Determine risk level and recommendation
    RiskLevel riskLevel;
    String recommendation;

    if (detectedRisks.contains(RiskType.grooming) ||
        detectedRisks.contains(RiskType.meetup)) {
      riskLevel = RiskLevel.critical;
      recommendation = 'This interaction is potentially dangerous. Block user and notify parent immediately.';
    } else if (detectedRisks.contains(RiskType.personalInfo) ||
               detectedRisks.contains(RiskType.manipulation)) {
      riskLevel = RiskLevel.high;
      recommendation = 'This interaction shows concerning behavior. Avoid sharing personal information.';
    } else if (detectedRisks.isNotEmpty) {
      riskLevel = RiskLevel.moderate;
      recommendation = 'Be cautious with this interaction. Consider only chatting with known friends.';
    } else {
      riskLevel = RiskLevel.safe;
      recommendation = 'No immediate risks detected, but always be careful with unknown users.';
    }

    return RiskAnalysis(
      detectedRisks: detectedRisks,
      warnings: warnings,
      riskLevel: riskLevel,
      recommendation: recommendation,
    );
  }

  void _showAlert(InteractionRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForRiskLevel(request.riskLevel),
              color: _getColorForRiskLevel(request.riskLevel),
            ),
            const SizedBox(width: 8),
            const Text('Unsafe Interaction Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${request.senderName}'),
            const SizedBox(height: 8),
            Text('Message: ${request.message}'),
            const SizedBox(height: 16),
            if (request.detectedRisks.isNotEmpty) ...[
              const Text(
                'Detected Risks:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...request.detectedRisks.map((risk) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Icon(
                      _getIconForRiskType(risk),
                      size: 16,
                      color: _getColorForRiskLevel(request.riskLevel),
                    ),
                    const SizedBox(width: 8),
                    Text(risk.toString().split('.').last),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            Text(
              request.recommendation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  content: Text('User blocked and parent notified'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.block),
            label: const Text('Block User'),
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
            'Online Stranger Interaction Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and analyze interactions with unknown users',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Known Safe Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _knownContacts.map((contact) => Chip(
                      avatar: const Icon(
                        Icons.verified_user,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(contact),
                      backgroundColor: Colors.green,
                      labelStyle: const TextStyle(color: Colors.white),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Interaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Enter message to analyze',
                      hintText: 'Try messages like "Where do you live?" or "Let\'s meet up"',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeInteraction,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.security),
                      label: const Text('Analyze Interaction'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _requests.isEmpty
                  ? const Center(
                      child: Text('No interactions analyzed yet'),
                    )
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        return _buildInteractionTile(_requests[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionTile(InteractionRequest request) {
    return ListTile(
      leading: Icon(
        _getIconForRiskLevel(request.riskLevel),
        color: _getColorForRiskLevel(request.riskLevel),
      ),
      title: Text(request.message),
      subtitle: Text(
        '${request.senderName} - ${_formatTime(request.timestamp)}',
      ),
      trailing: request.riskLevel != RiskLevel.safe
          ? Chip(
              label: Text(
                request.riskLevel.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getColorForRiskLevel(request.riskLevel),
            )
          : null,
      onTap: () {
        if (request.riskLevel != RiskLevel.safe) {
          _showAlert(request);
        }
      },
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

  IconData _getIconForRiskType(RiskType type) {
    switch (type) {
      case RiskType.personalInfo:
        return Icons.person_off;
      case RiskType.meetup:
        return Icons.location_off;
      case RiskType.grooming:
        return Icons.warning;
      case RiskType.manipulation:
        return Icons.psychology;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

enum RiskType {
  personalInfo,
  meetup,
  grooming,
  manipulation,
}

enum RiskLevel {
  safe,
  moderate,
  high,
  critical,
}

class InteractionRequest {
  final String senderName;
  final String message;
  final DateTime timestamp;
  final Set<RiskType> detectedRisks;
  final RiskLevel riskLevel;
  final List<String> warnings;
  final String recommendation;

  InteractionRequest({
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.detectedRisks,
    required this.riskLevel,
    required this.warnings,
    required this.recommendation,
  });
}

class RiskAnalysis {
  final Set<RiskType> detectedRisks;
  final List<String> warnings;
  final RiskLevel riskLevel;
  final String recommendation;

  RiskAnalysis({
    required this.detectedRisks,
    required this.warnings,
    required this.riskLevel,
    required this.recommendation,
  });
}
