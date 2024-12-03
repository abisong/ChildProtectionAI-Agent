import 'package:flutter/material.dart';
import 'dart:async';

class DigitalWellnessDemo extends StatefulWidget {
  const DigitalWellnessDemo({super.key});

  @override
  State<DigitalWellnessDemo> createState() => _DigitalWellnessDemoState();
}

class _DigitalWellnessDemoState extends State<DigitalWellnessDemo> {
  final List<WellnessActivity> _activityHistory = [];
  Timer? _activityTimer;
  bool _isActive = false;
  ActivityType _currentActivity = ActivityType.none;
  int _currentStreak = 0;
  int _wellnessScore = 70;

  final Map<ActivityType, ActivityDetails> _activityDetails = {
    ActivityType.social: ActivityDetails(
      name: 'Social Media',
      icon: Icons.people,
      color: Colors.blue,
      recommendations: [
        'Take a break and call a friend',
        'Join a family activity',
        'Write in your journal',
      ],
    ),
    ActivityType.gaming: ActivityDetails(
      name: 'Gaming',
      icon: Icons.games,
      color: Colors.purple,
      recommendations: [
        'Play an outdoor game',
        'Try a puzzle or board game',
        'Do some physical exercise',
      ],
    ),
    ActivityType.learning: ActivityDetails(
      name: 'Educational',
      icon: Icons.school,
      color: Colors.green,
      recommendations: [
        'Practice a new skill',
        'Read a book',
        'Work on a creative project',
      ],
    ),
    ActivityType.entertainment: ActivityDetails(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.orange,
      recommendations: [
        'Draw or color something',
        'Listen to music',
        'Do some crafts',
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _activityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isActive && _currentActivity != ActivityType.none) {
        _updateWellness();
      }
    });
  }

  void _updateWellness() {
    setState(() {
      // Simulate activity impact on wellness
      switch (_currentActivity) {
        case ActivityType.social:
          _currentStreak++;
          if (_currentStreak > 4) {
            _wellnessScore = _wellnessScore - 2;
            _showWellnessAlert(
              'Extended Social Media Use',
              'Consider taking a break from social media.',
            );
          }
          break;
        case ActivityType.gaming:
          _currentStreak++;
          if (_currentStreak > 3) {
            _wellnessScore = _wellnessScore - 3;
            _showWellnessAlert(
              'Extended Gaming Session',
              'Time for a break! Try some physical activity.',
            );
          }
          break;
        case ActivityType.learning:
          _wellnessScore = _wellnessScore + 1;
          if (_currentStreak > 5) {
            _showWellnessAlert(
              'Great Learning Session',
              'Take a short break to refresh your mind.',
            );
          }
          break;
        case ActivityType.entertainment:
          if (_currentStreak > 4) {
            _wellnessScore = _wellnessScore - 1;
            _showWellnessAlert(
              'Entertainment Break Needed',
              'Mix up your activities for better balance.',
            );
          }
          break;
        case ActivityType.none:
          break;
      }

      // Keep score within bounds
      _wellnessScore = _wellnessScore.clamp(0, 100);

      // Add activity to history
      _activityHistory.insert(
        0,
        WellnessActivity(
          type: _currentActivity,
          duration: _currentStreak * 3,
          timestamp: DateTime.now(),
          impact: _getActivityImpact(),
        ),
      );
    });
  }

  WellnessImpact _getActivityImpact() {
    if (_currentStreak <= 2) return WellnessImpact.good;
    if (_currentStreak <= 4) return WellnessImpact.neutral;
    return WellnessImpact.concerning;
  }

  void _showWellnessAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _wellnessScore < 50 ? Icons.warning : Icons.info,
              color: _getScoreColor(_wellnessScore),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Recommended Activities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._activityDetails[_currentActivity]!.recommendations.map((rec) =>
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentActivity = ActivityType.none;
                _currentStreak = 0;
                _isActive = false;
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Taking a break! Good choice!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.pause_circle_filled),
            label: const Text('Take a Break'),
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
            'Digital Wellness Coach',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and improve your digital well-being',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Wellness Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_wellnessScore',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(_wellnessScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _wellnessScore / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getScoreColor(_wellnessScore),
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
                    'Current Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _activityDetails.entries.map((entry) {
                      final isSelected = _currentActivity == entry.key;
                      return Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_currentActivity == entry.key) {
                                  _currentActivity = ActivityType.none;
                                  _isActive = false;
                                } else {
                                  _currentActivity = entry.key;
                                  _isActive = true;
                                }
                                _currentStreak = 0;
                              });
                            },
                            icon: Icon(
                              entry.value.icon,
                              color: isSelected
                                  ? entry.value.color
                                  : Colors.grey,
                              size: 32,
                            ),
                          ),
                          Text(
                            entry.value.name,
                            style: TextStyle(
                              color: isSelected
                                  ? entry.value.color
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _activityHistory.isEmpty
                  ? const Center(
                      child: Text('No activity recorded yet'),
                    )
                  : ListView.builder(
                      itemCount: _activityHistory.length,
                      itemBuilder: (context, index) {
                        return _buildActivityTile(_activityHistory[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(WellnessActivity activity) {
    final details = _activityDetails[activity.type]!;
    
    return ListTile(
      leading: Icon(
        details.icon,
        color: details.color,
      ),
      title: Text(details.name),
      subtitle: Text(
        '${activity.duration} seconds - ${_formatTime(activity.timestamp)}',
      ),
      trailing: Icon(
        _getImpactIcon(activity.impact),
        color: _getImpactColor(activity.impact),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getImpactIcon(WellnessImpact impact) {
    switch (impact) {
      case WellnessImpact.good:
        return Icons.sentiment_satisfied;
      case WellnessImpact.neutral:
        return Icons.sentiment_neutral;
      case WellnessImpact.concerning:
        return Icons.sentiment_dissatisfied;
    }
  }

  Color _getImpactColor(WellnessImpact impact) {
    switch (impact) {
      case WellnessImpact.good:
        return Colors.green;
      case WellnessImpact.neutral:
        return Colors.orange;
      case WellnessImpact.concerning:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }
}

enum ActivityType {
  none,
  social,
  gaming,
  learning,
  entertainment,
}

enum WellnessImpact {
  good,
  neutral,
  concerning,
}

class ActivityDetails {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> recommendations;

  ActivityDetails({
    required this.name,
    required this.icon,
    required this.color,
    required this.recommendations,
  });
}

class WellnessActivity {
  final ActivityType type;
  final int duration;
  final DateTime timestamp;
  final WellnessImpact impact;

  WellnessActivity({
    required this.type,
    required this.duration,
    required this.timestamp,
    required this.impact,
  });
}
