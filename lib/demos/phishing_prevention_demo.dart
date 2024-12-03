import 'package:flutter/material.dart';

class PhishingPreventionDemo extends StatefulWidget {
  const PhishingPreventionDemo({super.key});

  @override
  State<PhishingPreventionDemo> createState() => _PhishingPreventionDemoState();
}

class _PhishingPreventionDemoState extends State<PhishingPreventionDemo> {
  final List<PhishingAttempt> _attempts = [];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAnalyzing = false;

  // Phishing detection patterns
  final Map<PhishingType, List<String>> _phishingPatterns = {
    PhishingType.urgency: [
      'urgent',
      'immediate action',
      'account suspended',
      'security alert',
      'limited time',
    ],
    PhishingType.credentials: [
      'verify password',
      'confirm account',
      'login details',
      'update information',
      'security check',
    ],
    PhishingType.financial: [
      'free robux',
      'win prize',
      'gift card',
      'claim reward',
      'lottery winner',
    ],
    PhishingType.personal: [
      'social security',
      'credit card',
      'bank account',
      'personal details',
      'billing information',
    ],
  };

  // Common legitimate domains
  final List<String> _safeDomains = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'school.edu',
  ];

  void _analyzeEmail() {
    if (_emailController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final analysis = _analyzePhishing(
        _emailController.text,
        _subjectController.text,
        _contentController.text,
      );

      final attempt = PhishingAttempt(
        senderEmail: _emailController.text,
        subject: _subjectController.text,
        content: _contentController.text,
        timestamp: DateTime.now(),
        detectedTypes: analysis.detectedTypes,
        riskLevel: analysis.riskLevel,
        warnings: analysis.warnings,
        recommendation: analysis.recommendation,
      );

      setState(() {
        _attempts.insert(0, attempt);
        _isAnalyzing = false;
        _emailController.clear();
        _subjectController.clear();
        _contentController.clear();
      });

      if (analysis.riskLevel != RiskLevel.safe) {
        _showAlert(attempt);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email appears to be safe'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  PhishingAnalysis _analyzePhishing(
    String email,
    String subject,
    String content,
  ) {
    final detectedTypes = <PhishingType>{};
    final warnings = <String>[];
    final lowerContent = '$subject\n$content'.toLowerCase();

    // Check sender domain
    final emailDomain = email.split('@').length > 1 ? email.split('@')[1] : '';
    if (!_safeDomains.contains(emailDomain)) {
      warnings.add('Sender domain is not recognized as safe');
    }

    // Check for spelling/grammar mistakes (simplified)
    if (content.contains('  ') || content.contains('..')) {
      warnings.add('Unusual formatting or potential grammar issues detected');
    }

    // Check for phishing patterns
    for (var entry in _phishingPatterns.entries) {
      if (entry.value.any((pattern) => lowerContent.contains(pattern))) {
        detectedTypes.add(entry.key);
      }
    }

    // Determine risk level and recommendation
    RiskLevel riskLevel;
    String recommendation;

    if (detectedTypes.length >= 3) {
      riskLevel = RiskLevel.critical;
      recommendation = 'This is likely a phishing attempt. Do not respond or click any links.';
    } else if (detectedTypes.length == 2) {
      riskLevel = RiskLevel.high;
      recommendation = 'Multiple suspicious elements detected. Avoid interacting with this email.';
    } else if (detectedTypes.length == 1) {
      riskLevel = RiskLevel.moderate;
      recommendation = 'Some suspicious content detected. Be cautious and verify with a parent.';
    } else if (warnings.isNotEmpty) {
      riskLevel = RiskLevel.low;
      recommendation = 'Minor concerns detected. Review carefully before proceeding.';
    } else {
      riskLevel = RiskLevel.safe;
      recommendation = 'No suspicious elements detected.';
    }

    return PhishingAnalysis(
      detectedTypes: detectedTypes,
      warnings: warnings,
      riskLevel: riskLevel,
      recommendation: recommendation,
    );
  }

  void _showAlert(PhishingAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForRiskLevel(attempt.riskLevel),
              color: _getColorForRiskLevel(attempt.riskLevel),
            ),
            const SizedBox(width: 8),
            const Text('Phishing Risk Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${attempt.senderEmail}'),
            Text('Subject: ${attempt.subject}'),
            const Divider(),
            if (attempt.detectedTypes.isNotEmpty) ...[
              const Text(
                'Suspicious Elements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...attempt.detectedTypes.map((type) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Icon(_getIconForPhishingType(type), size: 16),
                    const SizedBox(width: 8),
                    Text(type.toString().split('.').last),
                  ],
                ),
              )),
            ],
            if (attempt.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...attempt.warnings.map((warning) => const Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('warning')),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            Text(
              attempt.recommendation,
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
                  content: Text('Parent notified about suspicious email'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.notification_important),
            label: const Text('Notify Parent'),
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
            'Phishing Prevention Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze emails and messages for potential phishing attempts',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Sender Email',
                      hintText: 'Enter the email address of the sender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Enter the email subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Email Content',
                      hintText: 'Paste the email content here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeEmail,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.security),
                    label: const Text('Analyze Email'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _attempts.isEmpty
                  ? const Center(
                      child: Text('No phishing attempts analyzed yet'),
                    )
                  : ListView.builder(
                      itemCount: _attempts.length,
                      itemBuilder: (context, index) {
                        return _buildAttemptTile(_attempts[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptTile(PhishingAttempt attempt) {
    return ListTile(
      leading: Icon(
        _getIconForRiskLevel(attempt.riskLevel),
        color: _getColorForRiskLevel(attempt.riskLevel),
      ),
      title: Text(
        attempt.subject.isEmpty ? attempt.senderEmail : attempt.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${attempt.senderEmail} - ${_formatTime(attempt.timestamp)}',
      ),
      trailing: Chip(
        label: Text(
          attempt.riskLevel.toString().split('.').last,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: _getColorForRiskLevel(attempt.riskLevel),
      ),
      onTap: () => _showAlert(attempt),
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
      case RiskLevel.low:
        return Colors.blue;
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
      case RiskLevel.low:
        return Icons.help;
      case RiskLevel.safe:
        return Icons.check_circle;
    }
  }

  IconData _getIconForPhishingType(PhishingType type) {
    switch (type) {
      case PhishingType.urgency:
        return Icons.timer;
      case PhishingType.credentials:
        return Icons.lock;
      case PhishingType.financial:
        return Icons.attach_money;
      case PhishingType.personal:
        return Icons.person;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

enum PhishingType {
  urgency,
  credentials,
  financial,
  personal,
}

enum RiskLevel {
  safe,
  low,
  moderate,
  high,
  critical,
}

class PhishingAttempt {
  final String senderEmail;
  final String subject;
  final String content;
  final DateTime timestamp;
  final Set<PhishingType> detectedTypes;
  final List<String> warnings;
  final RiskLevel riskLevel;
  final String recommendation;

  PhishingAttempt({
    required this.senderEmail,
    required this.subject,
    required this.content,
    required this.timestamp,
    required this.detectedTypes,
    required this.warnings,
    required this.riskLevel,
    required this.recommendation,
  });
}

class PhishingAnalysis {
  final Set<PhishingType> detectedTypes;
  final List<String> warnings;
  final RiskLevel riskLevel;
  final String recommendation;

  PhishingAnalysis({
    required this.detectedTypes,
    required this.warnings,
    required this.riskLevel,
    required this.recommendation,
  });
}
