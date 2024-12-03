import 'package:flutter/material.dart';

class EducationalContentDemo extends StatefulWidget {
  const EducationalContentDemo({super.key});

  @override
  State<EducationalContentDemo> createState() => _EducationalContentDemoState();
}

class _EducationalContentDemoState extends State<EducationalContentDemo> {
  String _selectedAgeGroup = '6-8';
  String _selectedSubject = 'Math';
  String _selectedInterest = 'Science';
  bool _isLoading = false;
  List<ContentRecommendation> _recommendations = [];

  final List<String> _ageGroups = ['4-5', '6-8', '9-11', '12-14', '15-17'];
  final List<String> _subjects = ['Math', 'Science', 'History', 'Language', 'Art'];
  final List<String> _interests = [
    'Science',
    'Space',
    'Animals',
    'Nature',
    'Technology',
    'Music',
    'Sports',
  ];

  void _generateRecommendations() {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI recommendation generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _recommendations = _getRecommendations();
      });
    });
  }

  List<ContentRecommendation> _getRecommendations() {
    // Simulated AI recommendations based on selected criteria
    final recommendations = <ContentRecommendation>[];
    
    if (_selectedSubject == 'Math') {
      recommendations.add(
        ContentRecommendation(
          title: 'Interactive Math Adventure',
          description: 'Learn math concepts through fun puzzles and games',
          type: 'Interactive Game',
          rating: 4.8,
          ageGroup: _selectedAgeGroup,
          subject: _selectedSubject,
          icon: Icons.games,
          color: Colors.blue,
        ),
      );
    }

    if (_selectedInterest == 'Science') {
      recommendations.add(
        ContentRecommendation(
          title: 'Science Explorer Videos',
          description: 'Educational videos about fascinating science experiments',
          type: 'Video Series',
          rating: 4.9,
          ageGroup: _selectedAgeGroup,
          subject: 'Science',
          icon: Icons.video_library,
          color: Colors.green,
        ),
      );
    }

    recommendations.addAll([
      ContentRecommendation(
        title: 'Virtual Museum Tour',
        description: 'Explore historical artifacts and learn about different cultures',
        type: 'Interactive Experience',
        rating: 4.7,
        ageGroup: _selectedAgeGroup,
        subject: 'History',
        icon: Icons.museum,
        color: Colors.brown,
      ),
      ContentRecommendation(
        title: 'Creative Art Studio',
        description: 'Learn drawing and painting techniques through guided tutorials',
        type: 'Art Tutorial',
        rating: 4.6,
        ageGroup: _selectedAgeGroup,
        subject: 'Art',
        icon: Icons.palette,
        color: Colors.purple,
      ),
    ]);

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Educational Content Recommender',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Get personalized educational content recommendations',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Age Group',
                          _ageGroups,
                          _selectedAgeGroup,
                          (value) => setState(() => _selectedAgeGroup = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Subject',
                          _subjects,
                          _selectedSubject,
                          (value) => setState(() => _selectedSubject = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Interest',
                          _interests,
                          _selectedInterest,
                          (value) => setState(() => _selectedInterest = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateRecommendations,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Get Recommendations'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _recommendations.isEmpty
                ? Center(
                    child: Text(
                      'Select your preferences and click "Get Recommendations"',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      return _buildRecommendationCard(_recommendations[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildRecommendationCard(ContentRecommendation recommendation) {
    return Card(
      child: InkWell(
        onTap: () => _showContentDetails(recommendation),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    recommendation.icon,
                    color: recommendation.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          recommendation.type,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                recommendation.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Age: ${recommendation.ageGroup}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContentDetails(ContentRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              recommendation.icon,
              color: recommendation.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(recommendation.title),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 16),
            Text('Type: ${recommendation.type}'),
            Text('Subject: ${recommendation.subject}'),
            Text('Age Group: ${recommendation.ageGroup}'),
            Row(
              children: [
                const Text('Rating: '),
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                Text(' ${recommendation.rating}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content added to learning playlist'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add to Playlist'),
          ),
        ],
      ),
    );
  }
}

class ContentRecommendation {
  final String title;
  final String description;
  final String type;
  final double rating;
  final String ageGroup;
  final String subject;
  final IconData icon;
  final Color color;

  ContentRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.rating,
    required this.ageGroup,
    required this.subject,
    required this.icon,
    required this.color,
  });
}
