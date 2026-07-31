import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<Property?> _propertyFuture;
  late PageController _pageController;

  int _currentImageIndex = 0;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _propertyFuture = _firestoreService.getPropertyById(widget.propertyId);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _propertyFuture = _firestoreService.getPropertyById(widget.propertyId);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // URL Launch helpers
  // ═══════════════════════════════════════════════════════════════
  Future<void> _callDssLets() async {
    const phoneNumber = 'tel:+441202000000';
    try {
      final uri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open phone dialer'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _whatsAppDssLets() async {
    // wa.me link with DSS Lets phone number
    const whatsappUrl = 'https://wa.me/441202000000?text=Hi%20DSS%20Lets,%20I%20am%20interested%20in%20a%20property.';
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Property?>(
      future: _propertyFuture,
      builder: (context, snapshot) {
        // ── Loading State ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: _buildLoadingShimmer(),
          );
        }

        // ── Error State ──
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final property = snapshot.data;

        // ── Not Found State ──
        if (property == null) {
          return _buildNotFoundState();
        }

        // ── Main Property Detail Content ──
        return _buildDetailContent(property);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Main Detail Content
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDetailContent(Property property) {
    final hasImages = property.images.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
      slivers: [
        // ── Image Gallery Header ──
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppTheme.primaryNavy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.accentWhite),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/properties');
              }
            },
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
                // Share functionality — placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: hasImages
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      // ── PageView for images ──
                      PageView.builder(
                        controller: _pageController,
                        itemCount: property.images.length,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final image = property.images[index];
                          if (image.startsWith('data:')) {
                            try {
                              return Image.memory(
                                base64Decode(image.substring(image.indexOf(',') + 1)),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 64),
                              );
                            } catch (_) {
                              return const Icon(Icons.image_not_supported_outlined, size: 64);
                            }
                          }
                          return CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.primaryNavy.withOpacity(0.08),
                              child: const Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.primaryNavy.withOpacity(0.08),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 64,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          );
                        },
                      ),

                      // ── Image count indicator ──
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1} / ${property.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: AppTheme.primaryNavy.withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 80,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
          ),
        ),

        // ── Property Details Body ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + Price ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '£${property.rent.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryGold,
                          ),
                        ),
                        Text(
                          'PCM',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ── Address ──
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppTheme.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.address}, ${property.postcode}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Availability Badge ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: property.available
                            ? AppTheme.successGreen.withOpacity(0.15)
                            : AppTheme.errorRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: property.available
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            property.available
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 16,
                            color: property.available
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            property.available ? 'Available' : 'Not Available',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: property.available
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (property.available)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: AppTheme.primaryNavy),
                            SizedBox(width: 4),
                            Text(
                              'DSS Accepted',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Key Details Grid ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textMedium.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.bed_rounded,
                          label: 'Bedrooms',
                          value: '${property.bedrooms}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.textMedium.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.bathtub_rounded,
                          label: 'Bathrooms',
                          value: '${property.bathrooms}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.textMedium.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.chair_rounded,
                          label: 'Furnished',
                          value: property.furnishedStatus,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Rent & Deposit Row ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textMedium.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Rent',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '£${property.rent.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.textMedium.withOpacity(0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deposit',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              property.deposit != null
                                  ? '£${property.deposit!.toStringAsFixed(0)}'
                                  : 'On request',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Description ──
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  property.description.isNotEmpty
                      ? property.description
                      : 'No description available for this property.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Action Buttons ──
                // Register Interest
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/tenant'),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Register Interest'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Call & WhatsApp row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _callDssLets,
                        icon: const Icon(Icons.phone_rounded, size: 20),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _whatsAppDssLets,
                        icon: const Icon(Icons.chat_rounded, size: 20),
                        label: const Text('WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF25D366),
                          side: const BorderSide(
                            color: Color(0xFF25D366),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    ),
    ); // Scaffold close
  }

  // ═══════════════════════════════════════════════════════════════
  // Loading Shimmer
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLoadingShimmer() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppTheme.primaryNavy,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppTheme.primaryNavy.withOpacity(0.08),
              child: const Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Title skeleton
                Container(
                  height: 24,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Address skeleton
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                // Badge skeletons
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.textMedium.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 28,
                      width: 110,
                      decoration: BoxDecoration(
                        color: AppTheme.textMedium.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Key details skeleton
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                // Rent/deposit skeleton
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                // Description title skeleton
                Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Description lines skeleton
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.textMedium.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                // Button skeleton
                Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGold.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.textMedium.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.textMedium.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Error State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/properties');
            }
          },
        ),
      ),
      body: Center(
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
                'Failed to load property',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/properties');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Not Found State
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNotFoundState() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/properties');
            }
          },
        ),
      ),
      body: Center(
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
                'Property not found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This property may have been removed or the link is invalid.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/properties'),
                icon: const Icon(Icons.home_work_outlined),
                label: const Text('Browse Properties'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Detail Tile (key details grid item)
// ═══════════════════════════════════════════════════════════════
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryNavy, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }
}
