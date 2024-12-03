import 'package:flutter/material.dart';

class FriendVerificationDemo extends StatefulWidget {
  const FriendVerificationDemo({super.key});

  @override
  State<FriendVerificationDemo> createState() => _FriendVerificationDemoState();
}

class _FriendVerificationDemoState extends State<FriendVerificationDemo> {
  final List<FriendRequest> _requests = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isAnalyzing = false;

  // Verification patterns
  final Map<VerificationType, List<String>> _verificationPatterns = {
    VerificationType.suspicious: [
      'just joined',
      'new account',
      'no posts',
      'no friends',
      'private account',
    ],
    VerificationType.inconsistent: [
      'different name',
      'changed location',
      'multiple accounts',
      'varied ages',
      'conflicting info',
    ],
    VerificationType.authentic: [
      'school verified',
      'mutual friends',
      'active posts',
      'consistent info',
      'linked accounts',
    ],
  };

  // Sample profile data
  final List<Map<String, dynamic>> _sampleProfiles = [
    {
      'username': 'gamer123',
      'bio': 'Just joined! Looking for new friends to play games with.',
      'age': '13',
      'location': 'Private',
      'friends': '0',
      'posts': '0',
    },
    {
      'username': 'student_sarah',
      'bio': 'Love reading and math! Student at Lincoln Middle School.',
      'age': '12',
      'location': 'New York',
      'friends': '45',
      'posts': '23',
    },
    {
      'username': 'sports_fan99',
      'bio': 'Changed schools, looking to make new friends! Age 11-15 only.',
      'age': 'Not specified',
      'location': 'Multiple',
      'friends': '3',
      'posts': '1',
    },
  ];

  void _analyzeProfile() {
    if (_usernameController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 2), () {
      final username = _usernameController.text;
      final bio = _bioController.text;
      
      // Get random sample profile data
      final profileData = _sampleProfiles[DateTime.now().second % _sampleProfiles.length];
      final analysis = _verifyProfile(username, bio, profileData);

      setState(() {
        _requests.insert(
          0,
          FriendRequest(
            username: username,
            bio: bio,
            profileData: profileData,
            timestamp: DateTime.now(),
            verificationTypes: analysis.verificationTypes,
            trustScore: analysis.trustScore,
            warnings: analysis.warnings,
            recommendation: analysis.recommendation,
          ),
        );
        _isAnalyzing = false;
        _usernameController.clear();
        _bioController.clear();
      });

      if (analysis.trustScore < 0.7) {
        _showAlert(analysis, username, profileData);
      }
    });
  }

  ProfileVerification _verifyProfile(
    String username,
    String bio,
    Map<String, dynamic> profileData,
  ) {
    final detectedTypes = <VerificationType>{};
    final warnings = <String>[];
    double trustScore = 1.0;

    // Check profile data
    if (int.tryParse(profileData['friends'] ?? '') == 0) {
      detectedTypes.add(VerificationType.suspicious);
      warnings.add('No friends or connections');
      trustScore -= 0.3;
    }

    if (int.tryParse(profileData['posts'] ?? '') == 0) {
      detectedTypes.add(VerificationType.suspicious);
      warnings.add('No activity or posts');
      trustScore -= 0.2;
    }

    if (profileData['location'] == 'Private' || 
        profileData['location'] == 'Multiple') {
      detectedTypes.add(VerificationType.inconsistent);
      warnings.add('Location information is suspicious');
      trustScore -= 0.2;
    }

    if (profileData['age'] == 'Not specified') {
      detectedTypes.add(VerificationType.suspicious);
      warnings.add('Age information missing');
      trustScore -= 0.1;
    }

    // Check bio for verification patterns
    final lowerBio = bio.toLowerCase();
    for (var entry in _verificationPatterns.entries) {
      if (entry.value.any((pattern) => lowerBio.contains(pattern))) {
        detectedTypes.add(entry.key);
        if (entry.key != VerificationType.authentic) {
          trustScore -= 0.15;
        }
      }
    }

    // Determine recommendation
    String recommendation;
    if (trustScore < 0.4) {
      recommendation = 'High risk profile. Reject friend request and report.';
    } else if (trustScore < 0.7) {
      recommendation = 'Suspicious profile. Request additional verification.';
    } else if (trustScore < 0.9) {
      recommendation = 'Mostly safe profile. Verify with mutual friends.';
    } else {
      recommendation = 'Safe profile. Accept friend request.';
    }

    return ProfileVerification(
      verificationTypes: detectedTypes,
      warnings: warnings,
      trustScore: trustScore,
      recommendation: recommendation,
    );
  }

  void _showAlert(
    ProfileVerification verification,
    String username,
    Map<String, dynamic> profileData,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForTrustScore(verification.trustScore),
              color: _getColorForTrustScore(verification.trustScore),
            ),
            const SizedBox(width: 8),
            const Text('Profile Verification Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username'),
            const SizedBox(height: 8),
            Text('Trust Score: ${(verification.trustScore * 100).round()}%'),
            const SizedBox(height: 16),
            const Text(
              'Profile Information:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...profileData.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('${entry.key}: ${entry.value}'),
            )),
            if (verification.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...verification.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            Text(
              verification.recommendation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (verification.trustScore < 0.4)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile reported and blocked'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.block),
              label: const Text('Block & Report'),
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
            'Friend Verification Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Verify the authenticity of friend requests and profiles',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter the profile username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Profile Bio',
                      hintText: 'Enter or paste the profile bio...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeProfile,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_user),
                    label: const Text('Verify Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _requests.isEmpty
                  ? const Center(
                      child: Text('No profiles verified yet'),
                    )
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestTile(_requests[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(FriendRequest request) {
    return ListTile(
      leading: Icon(
        _getIconForTrustScore(request.trustScore),
        color: _getColorForTrustScore(request.trustScore),
      ),
      title: Text(request.username),
      subtitle: Text(
        'Trust Score: ${(request.trustScore * 100).round()}% - ${_formatTime(request.timestamp)}',
      ),
      trailing: request.trustScore < 0.7
          ? Chip(
              label: Text(
                request.trustScore < 0.4 ? 'High Risk' : 'Suspicious',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getColorForTrustScore(request.trustScore),
            )
          : null,
      onTap: () {
        if (request.trustScore < 0.7) {
          _showAlert(
            ProfileVerification(
              verificationTypes: request.verificationTypes,
              warnings: request.warnings,
              trustScore: request.trustScore,
              recommendation: request.recommendation,
            ),
            request.username,
            request.profileData,
          );
        }
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorForTrustScore(double score) {
    if (score < 0.4) return Colors.red;
    if (score < 0.7) return Colors.orange;
    if (score < 0.9) return Colors.yellow.shade700;
    return Colors.green;
  }

  IconData _getIconForTrustScore(double score) {
    if (score < 0.4) return Icons.error;
    if (score < 0.7) return Icons.warning;
    if (score < 0.9) return Icons.info;
    return Icons.verified_user;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

enum VerificationType {
  suspicious,
  inconsistent,
  authentic,
}

class FriendRequest {
  final String username;
  final String bio;
  final Map<String, dynamic> profileData;
  final DateTime timestamp;
  final Set<VerificationType> verificationTypes;
  final double trustScore;
  final List<String> warnings;
  final String recommendation;

  FriendRequest({
    required this.username,
    required this.bio,
    required this.profileData,
    required this.timestamp,
    required this.verificationTypes,
    required this.trustScore,
    required this.warnings,
    required this.recommendation,
  });
}

class ProfileVerification {
  final Set<VerificationType> verificationTypes;
  final List<String> warnings;
  final double trustScore;
  final String recommendation;

  ProfileVerification({
    required this.verificationTypes,
    required this.warnings,
    required this.trustScore,
    required this.recommendation,
  });
}
