import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';
import '../utils/image_utils.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _firestoreService.getProperties();
  }

  void _refreshData() {
    setState(() {
      _propertiesFuture = _firestoreService.getProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/properties/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.secondaryGold,
        backgroundColor: AppTheme.primaryNavy,
        onRefresh: () async {
          _refreshData();
          await _propertiesFuture;
        },
        child: FutureBuilder<List<Property>>(
          future: _propertiesFuture,
          builder: (context, snapshot) {
            // ── Loading State ──
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingShimmer();
            }

            // ── Error State ──
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final properties = snapshot.data ?? [];

            // ── Empty State ──
            if (properties.isEmpty) {
              return _buildEmptyState();
            }

            // ── Property List ──
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                return _PropertyCard(property: properties[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Loading Shimmer / Skeleton
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _ShimmerPropertyCard();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Error State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: AppTheme.primaryNavy,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load properties',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Empty State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      backgroundColor: AppTheme.primaryNavy,
      onRefresh: () async {
        _refreshData();
        await _propertiesFuture;
      },
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 72,
                      color: AppTheme.textMedium.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No properties available',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back soon for new listings.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Property Card (List Layout)
// ═══════════════════════════════════════════════════════════════
class _PropertyCard extends StatelessWidget {
  final Property property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final imagePaths = property.images.where((path) => path.isNotEmpty && !isVideoPath(path)).toList();
    final hasImage = imagePaths.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/properties/${property.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Property Image ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: hasImage
                      ? _PropertyImage(source: imagePaths.first)
                      : Container(
                          height: 180,
                          color: AppTheme.primaryNavy.withOpacity(0.08),
                          child: const Icon(
                            Icons.home_rounded,
                            size: 56,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                ),
                // ── DSS Accepted Badge ──
                if (property.available)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'DSS Accepted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ── Rent Price Badge ──
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '£${property.rent.toStringAsFixed(0)} PCM',
                      style: const TextStyle(
                        color: AppTheme.secondaryGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Property Details ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.postcode.isNotEmpty
                              ? '${property.address}, ${property.postcode}'
                              : property.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bedrooms / Bathrooms / Furnished
                  Row(
                    children: [
                      _PropertyInfoChip(
                        icon: Icons.bed_rounded,
                        label: '${property.bedrooms} Bed${property.bedrooms != 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 14),
                      _PropertyInfoChip(
                        icon: Icons.bathtub_rounded,
                        label: '${property.bathrooms} Bath${property.bathrooms != 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 14),
                      _PropertyInfoChip(
                        icon: Icons.chair_rounded,
                        label: property.furnishedStatus,
                      ),
                      const Spacer(),
                      // Rent displayed inline
                      Text(
                        '£${property.rent.toStringAsFixed(0)} PCM',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── View Details Button ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/properties/${property.id}'),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryNavy),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Property Info Chip (for bedroom/bathroom/furnished)
// ═══════════════════════════════════════════════════════════════
class _PropertyInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PropertyInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.textMedium),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shimmer / Skeleton Card (loading placeholder)
// ═══════════════════════════════════════════════════════════════
class _ShimmerPropertyCard extends StatefulWidget {
  @override
  State<_ShimmerPropertyCard> createState() => _ShimmerPropertyCardState();
}

class _ShimmerPropertyCardState extends State<_ShimmerPropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 180,
                color: AppTheme.textMedium.withOpacity(0.15 * _animation.value + 0.1),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title placeholder
                    Container(
                      height: 18,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.textMedium.withOpacity(
                            0.15 * _animation.value + 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location placeholder
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppTheme.textMedium.withOpacity(
                            0.15 * _animation.value + 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Beds placeholder
                        Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.textMedium.withOpacity(
                                0.15 * _animation.value + 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Baths placeholder
                        Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.textMedium.withOpacity(
                                0.15 * _animation.value + 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        // Price placeholder
                        Container(
                          height: 18,
                          width: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.textMedium.withOpacity(
                                0.15 * _animation.value + 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Button placeholder
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.textMedium.withOpacity(
                            0.15 * _animation.value + 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _PropertyImage extends StatelessWidget {
  final String source;
  const _PropertyImage({required this.source});
  @override
  Widget build(BuildContext context) {
    if (source.startsWith('data:')) {
      try {
        return Image.memory(base64Decode(source.substring(source.indexOf(',') + 1)), height: 180, width: double.infinity, fit: BoxFit.cover);
      } catch (_) {
        return const SizedBox(height: 180, child: Icon(Icons.image_not_supported_outlined));
      }
    }
    return Image.network(resolvePropertyImageUrl(source), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppTheme.primaryNavy.withOpacity(0.08), child: const Icon(Icons.image_not_supported_outlined)));
  }
}
