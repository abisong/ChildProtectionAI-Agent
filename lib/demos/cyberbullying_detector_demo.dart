import 'package:flutter/material.dart';

class CyberbullyingDetectorDemo extends StatefulWidget {
  const CyberbullyingDetectorDemo({super.key});

  @override
  State<CyberbullyingDetectorDemo> createState() => _CyberbullyingDetectorDemoState();
}

class _CyberbullyingDetectorDemoState extends State<CyberbullyingDetectorDemo> {
  final TextEditingController _messageController = TextEditingController();
  String _analysis = '';
  bool _isAnalyzing = false;
  final List<Message> _chatHistory = [];

  void _analyzeMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _chatHistory.add(Message(
        text: _messageController.text,
        isSent: true,
        timestamp: DateTime.now(),
      ));
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 1), () {
      final message = _messageController.text.toLowerCase();
      String result;
      Color alertColor;

      if (message.contains('stupid') || 
          message.contains('hate') || 
          message.contains('ugly')) {
        result = '🚨 Bullying detected: Message contains harmful language';
        alertColor = Colors.red;
      } else if (message.contains('nice') || 
                 message.contains('friend') || 
                 message.contains('happy')) {
        result = '💚 Positive message: Friendly and supportive content';
        alertColor = Colors.green;
      } else {
        result = '✓ Neutral message: No concerning content detected';
        alertColor = Colors.blue;
      }

      setState(() {
        _isAnalyzing = false;
        _analysis = result;
        _chatHistory.add(Message(
          text: result,
          isSent: false,
          timestamp: DateTime.now(),
          color: alertColor,
        ));
        _messageController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cyberbullying Detector Demo',
            style: Theme.of(context).textTheme.titleLarge,
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
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final message = _chatHistory[index];
                  return MessageBubble(message: message);
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
                    hintText: 'Enter any message to check for bullying content',
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class Message {
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final Color? color;

  Message({
    required this.text,
    required this.isSent,
    required this.timestamp,
    this.color,
  });
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.color ?? 
                (message.isSent ? Colors.blue : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isSent || message.color != null 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: message.isSent || message.color != null 
                    ? Colors.white70 
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
