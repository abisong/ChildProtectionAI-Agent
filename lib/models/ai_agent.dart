import 'package:flutter/material.dart';

class AIAgent {
  final String title;
  final String useCase;
  final String example;
  final String application;
  final Widget Function(BuildContext) buildInteractiveDemo;
  final IconData icon;
  final Color color;

  AIAgent({
    required this.title,
    required this.useCase,
    required this.example,
    required this.application,
    required this.buildInteractiveDemo,
    this.icon = Icons.security,
    this.color = Colors.blue,
  });
}
