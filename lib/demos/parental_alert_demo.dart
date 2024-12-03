import 'package:flutter/material.dart';

class ParentalAlertDemo extends StatefulWidget {
  const ParentalAlertDemo({super.key});

  @override
  State<ParentalAlertDemo> createState() => _ParentalAlertDemoState();
}

class _ParentalAlertDemoState extends State<ParentalAlertDemo> {
  final List<Interaction> _interactions = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isProcessing = false;

  // Suspicious patterns to detect
  final List<String> _suspiciousPatterns = [
    'meet',
    'address',
    'phone',
    'secret',
    'dont tell',
    "don't tell",
    'private',
    'age',
    'alone',
  ];

  void _addInteraction() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(milliseconds: 800), () {
      final message = _messageController.text;
      final lowerMessage = message.toLowerCase();
      
      // Check for suspicious content
      bool isSuspicious = _suspiciousPatterns.any((pattern) => 
        lowerMessage.contains(pattern));
      
      // Create interaction
      final interaction = Interaction(
        message: message,
        timestamp: DateTime.now(),
        sender: "Unknown User",
        isSuspicious: isSuspicious,
        riskLevel: isSuspicious ? _calculateRiskLevel(lowerMessage) : RiskLevel.safe,
      );

      setState(() {
        _interactions.add(interaction);
        _isProcessing = false;
        _messageController.clear();

        // Show alert if suspicious
        if (isSuspicious) {
          _showAlert(interaction);
        }
      });
    });
  }

  RiskLevel _calculateRiskLevel(String message) {
    int suspiciousCount = _suspiciousPatterns
        .where((pattern) => message.contains(pattern))
        .length;

    if (suspiciousCount >= 3) return RiskLevel.high;
    if (suspiciousCount >= 2) return RiskLevel.medium;
    return RiskLevel.low;
  }

  void _showAlert(Interaction interaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: interaction.riskLevel.color,
            ),
            const SizedBox(width: 8),
            const Text('Suspicious Activity Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Level: ${interaction.riskLevel.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Message: ${interaction.message}'),
            const SizedBox(height: 8),
            Text('Sender: ${interaction.sender}'),
            const SizedBox(height: 8),
            Text('Time: ${interaction.timestamp.hour}:${interaction.timestamp.minute}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Acknowledge'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Block User'),
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
            'Parental Alert Demo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Simulate chat messages to test the parental alert system',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _interactions.length,
                itemBuilder: (context, index) {
                  final interaction = _interactions[index];
                  return InteractionTile(interaction: interaction);
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
                    hintText: 'Try messages with words like "meet" or "address"',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addInteraction(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isProcessing ? null : _addInteraction,
                child: _isProcessing
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

enum RiskLevel {
  safe(Colors.green),
  low(Colors.yellow),
  medium(Colors.orange),
  high(Colors.red);

  final Color color;
  const RiskLevel(this.color);
}

class Interaction {
  final String message;
  final DateTime timestamp;
  final String sender;
  final bool isSuspicious;
  final RiskLevel riskLevel;

  Interaction({
    required this.message,
    required this.timestamp,
    required this.sender,
    required this.isSuspicious,
    required this.riskLevel,
  });
}

class InteractionTile extends StatelessWidget {
  final Interaction interaction;

  const InteractionTile({
    super.key,
    required this.interaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: interaction.isSuspicious 
            ? interaction.riskLevel.color.withOpacity(0.1)
            : Colors.grey.shade50,
        border: Border.all(
          color: interaction.isSuspicious 
              ? interaction.riskLevel.color
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                interaction.sender,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (interaction.isSuspicious)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: interaction.riskLevel.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.riskLevel.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(interaction.message),
          const SizedBox(height: 4),
          Text(
            '${interaction.timestamp.hour}:${interaction.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
