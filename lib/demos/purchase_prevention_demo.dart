import 'package:flutter/material.dart';

class PurchasePreventionDemo extends StatefulWidget {
  const PurchasePreventionDemo({super.key});

  @override
  State<PurchasePreventionDemo> createState() => _PurchasePreventionDemoState();
}

class _PurchasePreventionDemoState extends State<PurchasePreventionDemo> {
  final List<PurchaseAttempt> _attempts = [];
  bool _isMonitoring = false;
  bool _parentalControlEnabled = true;
  double _maxPurchaseLimit = 5.00;
  bool _requirePassword = true;
  bool _requireBiometric = true;

  // Sample in-app purchase items
  final List<PurchaseItem> _sampleItems = [
    PurchaseItem(
      name: '1000 Coins',
      price: 0.99,
      type: ItemType.currency,
      game: 'Adventure Quest',
      risk: RiskLevel.low,
    ),
    PurchaseItem(
      name: 'Premium Skin Pack',
      price: 4.99,
      type: ItemType.cosmetic,
      game: 'Battle Royale',
      risk: RiskLevel.medium,
    ),
    PurchaseItem(
      name: 'Legendary Weapon',
      price: 9.99,
      type: ItemType.powerUp,
      game: 'Dragon Warriors',
      risk: RiskLevel.high,
    ),
    PurchaseItem(
      name: 'Mystery Box',
      price: 2.99,
      type: ItemType.lootBox,
      game: 'Treasure Hunt',
      risk: RiskLevel.critical,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _simulatePurchaseAttempt();
      }
    });
  }

  void _simulatePurchaseAttempt() {
    if (!_isMonitoring) return;

    final item = _sampleItems[DateTime.now().second % _sampleItems.length];
    final analysis = _analyzePurchase(item);

    setState(() {
      _attempts.insert(
        0,
        PurchaseAttempt(
          item: item,
          timestamp: DateTime.now(),
          analysis: analysis,
        ),
      );

      if (!analysis.isAllowed) {
        _showAlert(analysis, item);
      }
    });

    // Schedule next simulation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isMonitoring) {
        _simulatePurchaseAttempt();
      }
    });
  }

  PurchaseAnalysis _analyzePurchase(PurchaseItem item) {
    if (!_parentalControlEnabled) {
      return PurchaseAnalysis(
        isAllowed: true,
        requiresAuth: false,
        warnings: [],
        recommendation: 'Parental controls disabled. Enable for better protection.',
      );
    }

    final warnings = <String>[];
    bool isAllowed = true;
    bool requiresAuth = false;

    // Check price limit
    if (item.price > _maxPurchaseLimit) {
      warnings.add('Purchase exceeds maximum limit of \$${_maxPurchaseLimit.toStringAsFixed(2)}');
      isAllowed = false;
    }

    // Check item type risks
    switch (item.type) {
      case ItemType.lootBox:
        warnings.add('Loot boxes can lead to gambling-like behavior');
        isAllowed = false;
        break;
      case ItemType.powerUp:
        warnings.add('Power-ups may create pay-to-win dependency');
        requiresAuth = true;
        break;
      case ItemType.currency:
        if (item.price >= 5.0) {
          warnings.add('Large currency purchase requires verification');
          requiresAuth = true;
        }
        break;
      case ItemType.cosmetic:
        if (item.price >= 5.0) {
          warnings.add('Expensive cosmetic item detected');
          requiresAuth = true;
        }
        break;
    }

    // Check risk level
    switch (item.risk) {
      case RiskLevel.critical:
        warnings.add('High-risk purchase type detected');
        isAllowed = false;
        break;
      case RiskLevel.high:
        warnings.add('Purchase requires parental approval');
        requiresAuth = true;
        break;
      case RiskLevel.medium:
        requiresAuth = true;
        break;
      case RiskLevel.low:
        // Allow with basic protection
        break;
    }

    String recommendation;
    if (!isAllowed) {
      recommendation = 'Purchase blocked. Parental approval required.';
    } else if (requiresAuth) {
      recommendation = 'Verification required before purchase.';
    } else {
      recommendation = 'Purchase allowed within safety limits.';
    }

    return PurchaseAnalysis(
      isAllowed: isAllowed,
      requiresAuth: requiresAuth || _requirePassword,
      warnings: warnings,
      recommendation: recommendation,
    );
  }

  void _showAlert(PurchaseAnalysis analysis, PurchaseItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              analysis.isAllowed ? Icons.warning : Icons.block,
              color: analysis.isAllowed ? Colors.orange : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('Purchase Protection'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${item.name}'),
            Text('Game: ${item.game}'),
            Text('Price: \$${item.price.toStringAsFixed(2)}'),
            Text('Type: ${item.type.toString().split('.').last}'),
            const SizedBox(height: 16),
            if (analysis.warnings.isNotEmpty) ...[
              const Text(
                'Warnings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...analysis.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            Text(
              analysis.recommendation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (analysis.requiresAuth)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showAuthenticationDialog(item);
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('Verify Purchase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  void _showAuthenticationDialog(PurchaseItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.blue),
            SizedBox(width: 8),
            Text('Parent Authentication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_requirePassword)
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Parent Password',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_requirePassword && _requireBiometric)
              const SizedBox(height: 16),
            if (_requireBiometric)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometric authentication required'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use Biometric'),
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase approved by parent'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Approve'),
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
            'In-App Purchase Prevention',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor and control in-app purchases',
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
                        'Protection Settings',
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
                            if (value) {
                              _startMonitoring();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Parental Controls'),
                    subtitle: const Text('Enable purchase restrictions'),
                    value: _parentalControlEnabled,
                    onChanged: (value) {
                      setState(() {
                        _parentalControlEnabled = value;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Maximum Purchase Limit'),
                    subtitle: Text('\$${_maxPurchaseLimit.toStringAsFixed(2)}'),
                    trailing: SizedBox(
                      width: 200,
                      child: Slider(
                        value: _maxPurchaseLimit,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        label: '\$${_maxPurchaseLimit.toStringAsFixed(2)}',
                        onChanged: (value) {
                          setState(() {
                            _maxPurchaseLimit = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Require Password'),
                    subtitle: const Text('Parent password for purchases'),
                    value: _requirePassword,
                    onChanged: (value) {
                      setState(() {
                        _requirePassword = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text('Additional security layer'),
                    value: _requireBiometric,
                    onChanged: (value) {
                      setState(() {
                        _requireBiometric = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: _attempts.isEmpty
                  ? const Center(
                      child: Text('No purchase attempts logged'),
                    )
                  : ListView.builder(
                      itemCount: _attempts.length,
                      itemBuilder: (context, index) {
                        return _buildAttemptTile(_attempts[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptTile(PurchaseAttempt attempt) {
    return ListTile(
      leading: Icon(
        attempt.analysis.isAllowed ? Icons.check_circle : Icons.block,
        color: attempt.analysis.isAllowed ? Colors.green : Colors.red,
      ),
      title: Text('${attempt.item.name} (${attempt.item.game})'),
      subtitle: Text(
        '\$${attempt.item.price.toStringAsFixed(2)} - ${_formatTime(attempt.timestamp)}',
      ),
      trailing: attempt.analysis.requiresAuth
          ? const Chip(
              label: Text(
                'Auth Required',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.blue,
            )
          : null,
      onTap: () {
        _showAlert(attempt.analysis, attempt.item);
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

enum ItemType {
  currency,
  cosmetic,
  powerUp,
  lootBox,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

class PurchaseItem {
  final String name;
  final double price;
  final ItemType type;
  final String game;
  final RiskLevel risk;

  PurchaseItem({
    required this.name,
    required this.price,
    required this.type,
    required this.game,
    required this.risk,
  });
}

class PurchaseAttempt {
  final PurchaseItem item;
  final DateTime timestamp;
  final PurchaseAnalysis analysis;

  PurchaseAttempt({
    required this.item,
    required this.timestamp,
    required this.analysis,
  });
}

class PurchaseAnalysis {
  final bool isAllowed;
  final bool requiresAuth;
  final List<String> warnings;
  final String recommendation;

  PurchaseAnalysis({
    required this.isAllowed,
    required this.requiresAuth,
    required this.warnings,
    required this.recommendation,
  });
}
