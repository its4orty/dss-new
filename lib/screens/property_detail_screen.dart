import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Image Gallery Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primaryNavy.withOpacity(0.1),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.home,
                        size: 80,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    // Image gallery placeholder
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '1 / 5',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? AppTheme.errorRed : AppTheme.accentWhite,
                ),
                onPressed: () => setState(() => _isSaved = !_isSaved),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppTheme.accentWhite),
                onPressed: () {
                  // TODO: Implement share
                },
              ),
            ],
          ),

          // ── Property Details ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Property Details',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '£950',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Text(
                            '/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sample Address, Sample Postcode',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 16),

                  // ── Key Details Row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DetailChip(icon: Icons.bed, label: '3 Bedrooms'),
                      _DetailChip(icon: Icons.bathtub, label: '2 Bathrooms'),
                      _DetailChip(icon: Icons.square_foot, label: 'Furnished'),
                      _DetailChip(icon: Icons.calendar_today, label: 'Available'),
                    ],
                  ),
                  const Divider(height: 32),

                  // ── Description ──
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a placeholder description for the property. '
                    'Full property details, features, and descriptions will be '
                    'displayed here once connected to Firestore. '
                    'The description will cover key selling points, '
                    'local amenities, transport links, and more.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Features ──
                  Text(
                    'Key Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Central Heating',
                      'Double Glazing',
                      'Garden',
                      'Parking',
                      'Close to Transport',
                      'Modern Kitchen',
                    ].map((feature) {
                      return Chip(
                        label: Text(feature),
                        avatar: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/tenant'),
                          icon: const Icon(Icons.send),
                          label: const Text('Register Interest'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/contact'),
                          icon: const Icon(Icons.phone),
                          label: const Text('Contact Us'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryNavy, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
        ),
      ],
    );
  }
}
