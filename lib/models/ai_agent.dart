import 'package:flutter/material.dart';

class AIAgent {
  final String title;
  final String useCase;
  final String example;
  final String application;
  final Widget Function(BuildContext) buildInteractiveDemo;
  final IconData icon;
  final Color color;

  const AIAgent({
    required this.title,
    required this.useCase,
    required this.example,
    required this.application,
    required this.buildInteractiveDemo,
    required this.icon,
    required this.color,
  });
}
