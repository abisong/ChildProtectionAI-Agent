import 'package:flutter/material.dart';
import 'models/ai_agent.dart';
import 'demos/content_filtering_demo.dart';
import 'demos/cyberbullying_detector_demo.dart';
import 'demos/parental_alert_demo.dart';
import 'demos/time_management_demo.dart';
import 'demos/educational_content_demo.dart';
import 'demos/mental_health_demo.dart';
import 'demos/geolocation_demo.dart';
import 'demos/gaming_interaction_demo.dart';
import 'demos/privacy_agent_demo.dart';
import 'demos/phishing_prevention_demo.dart';
import 'demos/age_content_demo.dart';
import 'demos/digital_wellness_demo.dart';
import 'demos/stranger_interaction_demo.dart';
import 'demos/text_sentiment_demo.dart';
import 'demos/suspicious_activity_demo.dart';
import 'demos/friend_verification_demo.dart';
import 'demos/purchase_prevention_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child Protection AI Agents',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            letterSpacing: 0.1,
            height: 1.5,
          ),
        ),
      ),
      home: const AgentsGridView(),
    );
  }
}

class AgentsGridView extends StatelessWidget {
  const AgentsGridView({super.key});

  List<AIAgent> get agents => [
        AIAgent(
          title: "Content Filtering Agent",
          useCase: "Blocks harmful or explicit content",
          example: "An AI agent that analyzes incoming website or video content and filters out inappropriate content",
          application: "Real-time monitoring of a child's browser or streaming platform to ensure safety",
          buildInteractiveDemo: (context) => const ContentFilteringDemo(),
          icon: Icons.security,
          color: Colors.blue,
        ),
        AIAgent(
          title: "Cyberbullying Detector",
          useCase: "Identifies signs of cyberbullying in chat messages or social media",
          example: "Alerts parents or guardians if it detects bullying language used towards or by the child",
          application: "Used on messaging apps to prevent negative interactions and support anti-bullying",
          buildInteractiveDemo: (context) => const CyberbullyingDetectorDemo(),
          icon: Icons.message,
          color: Colors.red,
        ),
        AIAgent(
          title: "Parental Alert Agent",
          useCase: "Notifies parents of risky interactions",
          example: "Sends alerts when unfamiliar or suspicious adults interact with the child",
          application: "Deployed on social platforms to flag unsolicited contact from strangers",
          buildInteractiveDemo: (context) => const ParentalAlertDemo(),
          icon: Icons.warning,
          color: Colors.orange,
        ),
        AIAgent(
          title: "Time Management Assistant",
          useCase: "Manages online time to avoid overuse",
          example: "An AI that suggests taking a break if a child has been browsing or gaming for too long",
          application: "Keeps screen time balanced across apps and activities",
          buildInteractiveDemo: (context) => const TimeManagementDemo(),
          icon: Icons.timer,
          color: Colors.purple,
        ),
        AIAgent(
          title: "Educational Content Recommender",
          useCase: "Suggests child-friendly educational materials",
          example: "Recommends interactive math or science videos based on browsing history",
          application: "Promotes learning and distracts from potentially unsafe content",
          buildInteractiveDemo: (context) => const EducationalContentDemo(),
          icon: Icons.school,
          color: Colors.green,
        ),
        AIAgent(
          title: "Mental Health Analyzer",
          useCase: "Detects changes in emotional tone",
          example: "Analyzes text messages and online posts for signs of anxiety or depression",
          application: "Helps in early intervention by prompting guardians to have a conversation if concerning trends arise",
          buildInteractiveDemo: (context) => const MentalHealthDemo(),
          icon: Icons.psychology,
          color: Colors.pink,
        ),
        AIAgent(
          title: "Geolocation Agent",
          useCase: "Tracks digital device usage location",
          example: "Alerts parents if the child tries to access the internet from unfamiliar locations",
          application: "Assists in ensuring kids are only browsing safely within known places like home or school",
          buildInteractiveDemo: (context) => const GeolocationDemo(),
          icon: Icons.location_on,
          color: Colors.teal,
        ),
        AIAgent(
          title: "Gaming Interaction Analyzer",
          useCase: "Monitors chats within games",
          example: "Identifies abusive language or risky content in in-game chats",
          application: "Used in multiplayer games to maintain a healthy gaming environment",
          buildInteractiveDemo: (context) => const GamingInteractionDemo(),
          icon: Icons.games,
          color: Colors.indigo,
        ),
        AIAgent(
          title: "Personal Data Privacy Agent",
          useCase: "Prevents oversharing of personal information",
          example: "Alerts a child if they attempt to share their home address or phone number online",
          application: "Social media safety, preventing doxxing or inadvertent data leakage",
          buildInteractiveDemo: (context) => const PrivacyAgentDemo(),
          icon: Icons.privacy_tip,
          color: Colors.deepPurple,
        ),
        AIAgent(
          title: "Phishing Prevention Agent",
          useCase: "Detects phishing attempts targeted at children",
          example: "Analyzes emails for phishing characteristics, notifying parents if found",
          application: "Prevents children from accessing malicious links that can compromise safety",
          buildInteractiveDemo: (context) => const PhishingPreventionDemo(),
          icon: Icons.phishing,
          color: Colors.brown,
        ),
        AIAgent(
          title: "Age-Inappropriate Content Agent",
          useCase: "Analyzes and restricts access to content beyond a child's age level",
          example: "Blocks mature YouTube content while allowing child-friendly cartoons",
          application: "Browser add-on for video-sharing platforms",
          buildInteractiveDemo: (context) => const AgeContentDemo(),
          icon: Icons.block,
          color: Colors.deepOrange,
        ),
        AIAgent(
          title: "Digital Wellness Coach",
          useCase: "Helps children maintain healthy digital habits",
          example: "Recommends activities like a puzzle game after extended social media use",
          application: "Encourages a mix of digital learning, socializing, and play",
          buildInteractiveDemo: (context) => const DigitalWellnessDemo(),
          icon: Icons.self_improvement,
          color: Colors.cyan,
        ),
        AIAgent(
          title: "Online Stranger Interaction Agent",
          useCase: "Monitors friend requests and chats with unfamiliar people",
          example: "Flags interaction from unknown profiles and asks for parental approval",
          application: "Safeguards social networking",
          buildInteractiveDemo: (context) => const StrangerInteractionDemo(),
          icon: Icons.person_off,
          color: Colors.amber,
        ),
        AIAgent(
          title: "Text Sentiment Analyzer",
          useCase: "Evaluates sentiment of messages exchanged by children",
          example: "Flags harmful, offensive, or self-destructive content",
          application: "Implemented in chat apps to protect emotional well-being",
          buildInteractiveDemo: (context) => const TextSentimentDemo(),
          icon: Icons.sentiment_satisfied,
          color: Colors.lightGreen,
        ),
        AIAgent(
          title: "Suspicious Activity Monitor",
          useCase: "Looks for activities indicating risky behavior",
          example: "Identifies searches related to meeting strangers",
          application: "Prevents unsafe online meetings",
          buildInteractiveDemo: (context) => const SuspiciousActivityDemo(),
          icon: Icons.visibility,
          color: Colors.deepPurple.shade300,
        ),
        AIAgent(
          title: "Friend Verification Agent",
          useCase: "Validates the identity of online friends",
          example: "Verifies social media profiles to determine legitimacy",
          application: "Reduces catfishing and fake friendships",
          buildInteractiveDemo: (context) => const FriendVerificationDemo(),
          icon: Icons.verified_user,
          color: Colors.blue.shade300,
        ),
        AIAgent(
          title: "In-App Purchase Prevention Agent",
          useCase: "Restricts unauthorized in-app purchases",
          example: "Uses facial recognition or password prompts for purchases",
          application: "Prevents accidental or manipulative spending",
          buildInteractiveDemo: (context) => const PurchasePreventionDemo(),
          icon: Icons.attach_money,
          color: Colors.green.shade700,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Child Protection AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 1;
          if (constraints.maxWidth > 1400) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 1000) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 2;
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 1400 ? 120 : 
                           constraints.maxWidth > 1000 ? 80 : 
                           constraints.maxWidth > 600 ? 40 : 16,
                vertical: 24,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.1,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: agents.length,
              itemBuilder: (context, index) {
                return AgentCard(agent: agents[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class AgentCard extends StatelessWidget {
  final AIAgent agent;

  const AgentCard({super.key, required this.agent});

  void _openDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: agent.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(agent.icon, color: agent.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        agent.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: agent.buildInteractiveDemo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Hero(
          tag: agent.title,
          child: Card(
            elevation: 0,
            child: InkWell(
              onTap: () => _openDemo(context),
              borderRadius: BorderRadius.circular(16),
              hoverColor: agent.color.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: agent.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            agent.icon,
                            color: agent.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: agent.color,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Tooltip(
                                message: agent.useCase,
                                child: Text(
                                  agent.useCase,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection(context, 'Example', agent.example),
                            const SizedBox(height: 12),
                            _buildSection(context, 'Application', agent.application),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: FilledButton.icon(
                        onPressed: () => _openDemo(context),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Try Demo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: agent.color,
                          minimumSize: const Size(double.infinity, 48),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Tooltip(
          message: content,
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
