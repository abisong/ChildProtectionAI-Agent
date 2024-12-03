import 'package:flutter/material.dart';
import 'dart:async';

class TimeManagementDemo extends StatefulWidget {
  const TimeManagementDemo({super.key});

  @override
  State<TimeManagementDemo> createState() => _TimeManagementDemoState();
}

class _TimeManagementDemoState extends State<TimeManagementDemo> {
  final Map<String, int> _appUsage = {
    'Social Media': 0,
    'Gaming': 0,
    'Educational': 0,
    'Entertainment': 0,
  };

  final Map<String, int> _limits = {
    'Social Media': 30,
    'Gaming': 60,
    'Educational': 120,
    'Entertainment': 45,
  };

  final Map<String, Color> _appColors = {
    'Social Media': Colors.blue,
    'Gaming': Colors.red,
    'Educational': Colors.green,
    'Entertainment': Colors.orange,
  };

  Timer? _timer;
  String _activeApp = '';
  bool _isPaused = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  void _updateTime(Timer timer) {
    if (!_isPaused && _activeApp.isNotEmpty) {
      setState(() {
        _appUsage[_activeApp] = (_appUsage[_activeApp] ?? 0) + 1;
        
        // Check if limit exceeded
        if (_appUsage[_activeApp]! >= _limits[_activeApp]!) {
          _showLimitAlert(_activeApp);
          _isPaused = true;
          _activeApp = '';
        }
      });
    }
  }

  void _showLimitAlert(String app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Time Limit Reached'),
          ],
        ),
        content: Text('You have reached the time limit for $app.\nTime to take a break!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Time Management Assistant',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and manage screen time across different activities',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _appUsage.length,
              itemBuilder: (context, index) {
                String app = _appUsage.keys.elementAt(index);
                return _buildAppCard(app);
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currently Active:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _activeApp.isEmpty ? 'No active app' : _activeApp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _activeApp.isEmpty 
                          ? Colors.grey 
                          : _appColors[_activeApp],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _activeApp.isEmpty ? null : () {
                          setState(() {
                            _isPaused = !_isPaused;
                          });
                        },
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Resume' : 'Pause'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _activeApp.isEmpty ? null : () {
                          setState(() {
                            _isPaused = true;
                            _activeApp = '';
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(String app) {
    double progress = _appUsage[app]! / _limits[app]!;
    
    return Card(
      child: InkWell(
        onTap: () {
          if (_activeApp != app) {
            setState(() {
              _activeApp = app;
              _isPaused = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: _appColors[app],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      app,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: _appColors[app],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(_appUsage[app]!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${_formatTime(_limits[app]!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
