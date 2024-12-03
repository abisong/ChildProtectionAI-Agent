import 'package:flutter/material.dart';
import 'dart:async';

class SuspiciousActivityDemo extends StatefulWidget {
  const SuspiciousActivityDemo({super.key});

  @override
  State<SuspiciousActivityDemo> createState() => _SuspiciousActivityDemoState();
}

class _SuspiciousActivityDemoState extends State<SuspiciousActivityDemo> {
  final List<ActivityLog> _activityLogs = [];
  Timer? _activityTimer;
  bool _isMonitoring = false;

  // Activity patterns to monitor
  final Map<ActivityCategory, List<String>> _suspiciousPatterns = {
    ActivityCategory.search: [
      'how to hack',
      'bypass parental control',
      'fake id',
      'cheat codes',
      'free coins',
    ],
    ActivityCategory.communication: [
      'secret chat',
      'hidden messages',
      'private meeting',
      'anonymous chat',
      'secret friend',
    ],
    ActivityCategory.downloads: [
      'cracked games',
      'free movies',
      'mod apk',
      'password cracker',
      'proxy bypass',
    ],
    ActivityCategory.sharing: [
      'share location',
      'send photo',
      'video call',
      'live stream',
      'meet up',
    ],
  };

  // Sample activities to simulate monitoring
  final List<String> _sampleActivities = [
    'Searched for "how to get free robux"',
    'Downloaded "game_mod.apk"',
    'Visited "secret-chat.com"',
    'Searched for "how to hide apps"',
    'Installed "VPN Master"',
    'Searched for "bypass school wifi"',
    'Joined "Anonymous Chat Room"',
    'Downloaded "password.txt"',
    'Searched for "meet new friends online"',
    'Installed "Hidden Calculator"',
  ];

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _isMonitoring = true;
    _activityTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isMonitoring) {
        _simulateActivity();
      }
    });
  }

  void _simulateActivity() {
    final activity = _sampleActivities[DateTime.now().second % _sampleActivities.length];
    final analysis = _analyzeActivity(activity);

    setState(() {
      _activityLogs.insert(
        0,
        ActivityLog(
          activity: activity,
          timestamp: DateTime.now(),
          category: analysis.category,
          riskLevel: analysis.riskLevel,
          recommendation: analysis.recommendation,
        ),
      );

      if (analysis.riskLevel != RiskLevel.safe) {
        _showAlert(analysis, activity);
      }
    });
  }

  ActivityAnalysis _analyzeActivity(String activity) {
    final lowerActivity = activity.toLowerCase();
    ActivityCategory? detectedCategory;
    RiskLevel riskLevel = RiskLevel.safe;
    String recommendation = 'Activity appears safe';

    // Check for suspicious patterns
    for (var entry in _suspiciousPatterns.entries) {
      if (entry.value.any((pattern) => lowerActivity.contains(pattern))) {
        detectedCategory = entry.key;
        break;
      }
    }

    if (detectedCategory != null) {
      switch (detectedCategory) {
        case ActivityCategory.search:
          riskLevel = RiskLevel.moderate;
          recommendation = 'Suspicious search patterns detected. Monitor browsing activity.';
          break;
        case ActivityCategory.communication:
          riskLevel = RiskLevel.high;
          recommendation = 'Potentially unsafe communication attempt. Review chat history.';
          break;
        case ActivityCategory.downloads:
          riskLevel = RiskLevel.critical;
          recommendation = 'Dangerous download activity detected. Check device for malware.';
          break;
        case ActivityCategory.sharing:
          riskLevel = RiskLevel.high;
          recommendation = 'Risky information sharing detected. Review privacy settings.';
          break;
        case ActivityCategory.general:
          riskLevel = RiskLevel.safe;
          recommendation = 'General activity with no immediate concerns.';
          break;
      }
    }

    return ActivityAnalysis(
      category: detectedCategory ?? ActivityCategory.general,
      riskLevel: riskLevel,
      recommendation: recommendation,
    );
  }

  void _showAlert(ActivityAnalysis analysis, String activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForRiskLevel(analysis.riskLevel),
              color: _getColorForRiskLevel(analysis.riskLevel),
            ),
            const SizedBox(width: 8),
            const Text('Suspicious Activity'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity: $activity'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getIconForCategory(analysis.category),
                  size: 16,
                  color: _getColorForCategory(analysis.category),
                ),
                const SizedBox(width: 8),
                Text(
                  'Category: ${analysis.category.toString().split('.').last}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
            child: const Text('Monitor'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Parent notified of suspicious activity'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.warning),
            label: const Text('Alert Parent'),
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
            'Suspicious Activity Monitor',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and detect potentially risky online activities',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Activity Monitor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isMonitoring,
                        onChanged: (value) {
                          setState(() {
                            _isMonitoring = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isMonitoring
                        ? 'Actively monitoring for suspicious activities...'
                        : 'Monitoring paused',
                    style: TextStyle(
                      color: _isMonitoring ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _activityLogs.isEmpty
                  ? const Center(
                      child: Text('No activities logged yet'),
                    )
                  : ListView.builder(
                      itemCount: _activityLogs.length,
                      itemBuilder: (context, index) {
                        return _buildActivityTile(_activityLogs[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityLog log) {
    return ListTile(
      leading: Icon(
        _getIconForCategory(log.category),
        color: _getColorForCategory(log.category),
      ),
      title: Text(log.activity),
      subtitle: Text(
        '${log.category.toString().split('.').last} - ${_formatTime(log.timestamp)}',
      ),
      trailing: log.riskLevel != RiskLevel.safe
          ? Chip(
              label: Text(
                log.riskLevel.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getColorForRiskLevel(log.riskLevel),
            )
          : null,
      onTap: () {
        if (log.riskLevel != RiskLevel.safe) {
          _showAlert(
            ActivityAnalysis(
              category: log.category,
              riskLevel: log.riskLevel,
              recommendation: log.recommendation,
            ),
            log.activity,
          );
        }
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorForCategory(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.search:
        return Colors.blue;
      case ActivityCategory.communication:
        return Colors.orange;
      case ActivityCategory.downloads:
        return Colors.red;
      case ActivityCategory.sharing:
        return Colors.purple;
      case ActivityCategory.general:
        return Colors.grey;
    }
  }

  IconData _getIconForCategory(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.search:
        return Icons.search;
      case ActivityCategory.communication:
        return Icons.chat;
      case ActivityCategory.downloads:
        return Icons.download;
      case ActivityCategory.sharing:
        return Icons.share;
      case ActivityCategory.general:
        return Icons.devices;
    }
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

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }
}

enum ActivityCategory {
  search,
  communication,
  downloads,
  sharing,
  general,
}

enum RiskLevel {
  safe,
  moderate,
  high,
  critical,
}

class ActivityLog {
  final String activity;
  final DateTime timestamp;
  final ActivityCategory category;
  final RiskLevel riskLevel;
  final String recommendation;

  ActivityLog({
    required this.activity,
    required this.timestamp,
    required this.category,
    required this.riskLevel,
    required this.recommendation,
  });
}

class ActivityAnalysis {
  final ActivityCategory category;
  final RiskLevel riskLevel;
  final String recommendation;

  ActivityAnalysis({
    required this.category,
    required this.riskLevel,
    required this.recommendation,
  });
}
