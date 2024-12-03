import 'package:flutter/material.dart';
import 'dart:async';

class GeolocationDemo extends StatefulWidget {
  const GeolocationDemo({super.key});

  @override
  State<GeolocationDemo> createState() => _GeolocationDemoState();
}

class _GeolocationDemoState extends State<GeolocationDemo> {
  final List<SafeZone> _safeZones = [
    SafeZone(
      name: 'Home',
      address: '123 Home Street',
      type: LocationType.home,
      isActive: true,
    ),
    SafeZone(
      name: 'School',
      address: '456 School Avenue',
      type: LocationType.school,
      isActive: true,
    ),
    SafeZone(
      name: 'Library',
      address: '789 Library Road',
      type: LocationType.library,
      isActive: true,
    ),
  ];

  final List<LocationActivity> _activities = [];
  Timer? _activityTimer;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _isMonitoring = true;
    _activityTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isMonitoring) {
        _simulateNewActivity();
      }
    });
  }

  void _simulateNewActivity() {
    final random = DateTime.now().millisecond % 3;
    final locations = [
      LocationActivity(
        location: 'Unknown Location',
        address: '999 Strange Street',
        timestamp: DateTime.now(),
        isInSafeZone: false,
        deviceType: 'Mobile Phone',
        browserType: 'Web Browser',
      ),
      LocationActivity(
        location: _safeZones[0].name,
        address: _safeZones[0].address,
        timestamp: DateTime.now(),
        isInSafeZone: true,
        deviceType: 'Laptop',
        browserType: 'Chrome',
      ),
      LocationActivity(
        location: _safeZones[1].name,
        address: _safeZones[1].address,
        timestamp: DateTime.now(),
        isInSafeZone: true,
        deviceType: 'Tablet',
        browserType: 'Safari',
      ),
    ];

    setState(() {
      _activities.insert(0, locations[random]);
      if (!locations[random].isInSafeZone) {
        _showAlert(locations[random]);
      }
    });
  }

  void _showAlert(LocationActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Unsafe Location Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${activity.location}'),
            Text('Address: ${activity.address}'),
            Text('Device: ${activity.deviceType}'),
            Text('Browser: ${activity.browserType}'),
            Text('Time: ${_formatTime(activity.timestamp)}'),
            const SizedBox(height: 16),
            const Text(
              'Device is being used outside of designated safe zones!',
              style: TextStyle(color: Colors.red),
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
              _showAddSafeZoneDialog(activity);
            },
            child: const Text('Add to Safe Zones'),
          ),
        ],
      ),
    );
  }

  void _showAddSafeZoneDialog(LocationActivity activity) {
    final nameController = TextEditingController(text: activity.location);
    LocationType selectedType = LocationType.other;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Safe Zone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LocationType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Location Type',
                border: OutlineInputBorder(),
              ),
              items: LocationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _safeZones.add(SafeZone(
                  name: nameController.text,
                  address: activity.address,
                  type: selectedType,
                  isActive: true,
                ));
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New safe zone added'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Geolocation Agent',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor device usage locations and manage safe zones',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Safe Zones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isMonitoring,
                        onChanged: (value) {
                          setState(() {
                            _isMonitoring = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _safeZones.map((zone) {
                      return Chip(
                        avatar: Icon(
                          _getIconForLocationType(zone.type),
                          size: 16,
                          color: zone.isActive ? Colors.white : Colors.grey,
                        ),
                        label: Text(zone.name),
                        backgroundColor:
                            zone.isActive ? Colors.blue : Colors.grey[300],
                        labelStyle: TextStyle(
                          color: zone.isActive ? Colors.white : Colors.grey[600],
                        ),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16,
                          color: zone.isActive ? Colors.white : Colors.grey,
                        ),
                        onDeleted: () {
                          setState(() {
                            _safeZones.remove(zone);
                          });
                        },
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
              child: ListView.builder(
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return ListTile(
                    leading: Icon(
                      activity.isInSafeZone
                          ? Icons.check_circle
                          : Icons.warning,
                      color: activity.isInSafeZone ? Colors.green : Colors.red,
                    ),
                    title: Text(activity.location),
                    subtitle: Text(
                      '${activity.deviceType} - ${_formatTime(activity.timestamp)}',
                    ),
                    trailing: activity.isInSafeZone
                        ? const Icon(
                            Icons.verified_user,
                            color: Colors.green,
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_location),
                            color: Colors.orange,
                            onPressed: () => _showAddSafeZoneDialog(activity),
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLocationType(LocationType type) {
    switch (type) {
      case LocationType.home:
        return Icons.home;
      case LocationType.school:
        return Icons.school;
      case LocationType.library:
        return Icons.local_library;
      case LocationType.other:
        return Icons.location_on;
    }
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }
}

enum LocationType {
  home,
  school,
  library,
  other,
}

class SafeZone {
  final String name;
  final String address;
  final LocationType type;
  final bool isActive;

  SafeZone({
    required this.name,
    required this.address,
    required this.type,
    required this.isActive,
  });
}

class LocationActivity {
  final String location;
  final String address;
  final DateTime timestamp;
  final bool isInSafeZone;
  final String deviceType;
  final String browserType;

  LocationActivity({
    required this.location,
    required this.address,
    required this.timestamp,
    required this.isInSafeZone,
    required this.deviceType,
    required this.browserType,
  });
}
