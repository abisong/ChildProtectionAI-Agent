import 'package:flutter/material.dart';
import 'dart:async';

class GamingInteractionDemo extends StatefulWidget {
  const GamingInteractionDemo({super.key});

  @override
  State<GamingInteractionDemo> createState() => _GamingInteractionDemoState();
}

class _GamingInteractionDemoState extends State<GamingInteractionDemo> {
  final List<GameChat> _chatHistory = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isAnalyzing = false;
  String _selectedGame = 'Minecraft';
  String _selectedChannel = 'Global Chat';

  final List<String> _games = [
    'Minecraft',
    'Roblox',
    'Fortnite',
    'Among Us',
  ];

  final List<String> _channels = [
    'Global Chat',
    'Team Chat',
    'Private Messages',
    'Voice Chat',
  ];

  // Keywords for content analysis
  final Map<ContentType, List<String>> _contentPatterns = {
    ContentType.inappropriate: [
      'curse',
      'swear',
      'bad words',
      'inappropriate',
    ],
    ContentType.personal: [
      'address',
      'phone',
      'school',
      'age',
      'meet',
    ],
    ContentType.bullying: [
      'noob',
      'stupid',
      'hate',
      'loser',
      'bad player',
    ],
    ContentType.scam: [
      'free',
      'robux',
      'vbucks',
      'gift card',
      'hack',
    ],
  };

  void _analyzeMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 1), () {
      final message = _messageController.text;
      final analysis = _analyzeContent(message.toLowerCase());
      
      final chat = GameChat(
        message: message,
        sender: 'Player123',
        timestamp: DateTime.now(),
        game: _selectedGame,
        channel: _selectedChannel,
        contentType: analysis.type,
        riskLevel: analysis.riskLevel,
        actionTaken: analysis.actionTaken,
      );

      setState(() {
        _chatHistory.insert(0, chat);
        _isAnalyzing = false;
        _messageController.clear();

        if (analysis.riskLevel != RiskLevel.none) {
          _showAlert(chat);
        }
      });
    });
  }

  ContentAnalysis _analyzeContent(String text) {
    ContentType type = ContentType.safe;
    RiskLevel risk = RiskLevel.none;
    String action = 'None';

    // Check for different types of content
    for (var entry in _contentPatterns.entries) {
      if (entry.value.any((pattern) => text.contains(pattern))) {
        type = entry.key;
        break;
      }
    }

    // Determine risk level and action
    switch (type) {
      case ContentType.inappropriate:
        risk = RiskLevel.high;
        action = 'Message blocked and reported';
        break;
      case ContentType.personal:
        risk = RiskLevel.high;
        action = 'Message blocked, parent notified';
        break;
      case ContentType.bullying:
        risk = RiskLevel.medium;
        action = 'Warning issued to sender';
        break;
      case ContentType.scam:
        risk = RiskLevel.medium;
        action = 'Message filtered, user warned';
        break;
      case ContentType.safe:
        risk = RiskLevel.none;
        action = 'Message allowed';
        break;
    }

    return ContentAnalysis(
      type: type,
      riskLevel: risk,
      actionTaken: action,
    );
  }

  void _showAlert(GameChat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForRiskLevel(chat.riskLevel),
              color: _getColorForRiskLevel(chat.riskLevel),
            ),
            const SizedBox(width: 8),
            const Text('Unsafe Content Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game: ${chat.game}'),
            Text('Channel: ${chat.channel}'),
            Text('Message: ${chat.message}'),
            Text('Content Type: ${chat.contentType.toString().split('.').last}'),
            Text('Risk Level: ${chat.riskLevel.toString().split('.').last}'),
            const SizedBox(height: 16),
            Text(
              'Action Taken: ${chat.actionTaken}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
            'Gaming Interaction Analyzer',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and analyze in-game chat messages for safety',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGame,
                      decoration: const InputDecoration(
                        labelText: 'Game',
                        border: OutlineInputBorder(),
                      ),
                      items: _games.map((game) {
                        return DropdownMenuItem(
                          value: game,
                          child: Text(game),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGame = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedChannel,
                      decoration: const InputDecoration(
                        labelText: 'Channel',
                        border: OutlineInputBorder(),
                      ),
                      items: _channels.map((channel) {
                        return DropdownMenuItem(
                          value: channel,
                          child: Text(channel),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedChannel = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  return _buildChatMessage(_chatHistory[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Type a message to analyze',
                    hintText: 'Try messages with words like "meet" or "free vbucks"',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _analyzeMessage(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeMessage,
                child: _isAnalyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(GameChat chat) {
    return ListTile(
      leading: Icon(
        _getIconForRiskLevel(chat.riskLevel),
        color: _getColorForRiskLevel(chat.riskLevel),
      ),
      title: Text(chat.message),
      subtitle: Text(
        '${chat.sender} - ${chat.channel} (${chat.game})',
      ),
      trailing: chat.riskLevel != RiskLevel.none
          ? Chip(
              label: Text(
                chat.riskLevel.toString().split('.').last,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getColorForRiskLevel(chat.riskLevel),
            )
          : null,
      onTap: () {
        if (chat.riskLevel != RiskLevel.none) {
          _showAlert(chat);
        }
      },
    );
  }

  Color _getColorForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.low:
        return Colors.yellow;
      case RiskLevel.none:
        return Colors.green;
    }
  }

  IconData _getIconForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.low:
        return Icons.info;
      case RiskLevel.none:
        return Icons.check_circle;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

enum ContentType {
  safe,
  inappropriate,
  personal,
  bullying,
  scam,
}

enum RiskLevel {
  none,
  low,
  medium,
  high,
}

class GameChat {
  final String message;
  final String sender;
  final DateTime timestamp;
  final String game;
  final String channel;
  final ContentType contentType;
  final RiskLevel riskLevel;
  final String actionTaken;

  GameChat({
    required this.message,
    required this.sender,
    required this.timestamp,
    required this.game,
    required this.channel,
    required this.contentType,
    required this.riskLevel,
    required this.actionTaken,
  });
}

class ContentAnalysis {
  final ContentType type;
  final RiskLevel riskLevel;
  final String actionTaken;

  ContentAnalysis({
    required this.type,
    required this.riskLevel,
    required this.actionTaken,
  });
}
