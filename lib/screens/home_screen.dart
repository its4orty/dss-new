import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  late Future<_HomeData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      _firestoreService.getFeaturedProperties(),
      _firestoreService.getDashboardStats(),
    ]);
    return _HomeData(
      properties: results[0] as List<Property>,
      stats: results[1] as Map<String, int>,
    );
  }

  void _refreshData() {
    setState(() {
      _homeDataFuture = _loadHomeData();
    });
  }

  void _showWaitlistDialog() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Join Waiting List'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email to get notified when new properties become available.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _firestoreService
                      .addToWaitlist(emailController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You\'ve been added to the waiting list!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to join: $e'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.secondaryGold,
        backgroundColor: AppTheme.primaryNavy,
        onRefresh: () async {
          _refreshData();
          // Wait for the future to settle so the indicator knows we're done
          await _homeDataFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Section ──
              _buildHeroSection(),

              const SizedBox(height: 24),

              // ── Quick Actions ──
              _buildQuickActions(),

              const SizedBox(height: 32),

              // ── Featured Properties ──
              _buildFeaturedSection(),

              const SizedBox(height: 32),

              // ── Stats Bar ──
              _buildStatsBar(),

              const SizedBox(height: 32),

              // ── Landlord CTA Banner ──
              _buildLandlordCta(),

              const SizedBox(height: 24),

              // ── Admin Access (subtle, owner-only) ──
              Center(
                child: TextButton(
                  onPressed: () => context.go('/admin'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textMedium.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              break; // already on home
            case 1:
              context.go('/properties');
              break;
            case 2:
              context.go('/contact');
              break;
            case 3:
              context.go('/tenant');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_rounded),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Hero Section
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            Color(0xFF0D2F5C),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Your Next\nHome Today',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentWhite,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse DSS-friendly properties in your area',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.accentWhite.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/properties'),
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Find Properties'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showWaitlistDialog,
                  icon: const Icon(Icons.list_alt, size: 20),
                  label: const Text('Join Waiting List'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentWhite,
                    side: const BorderSide(
                      color: AppTheme.secondaryGold,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Quick Actions
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.home_work_rounded,
                  label: 'Browse\nHomes',
                  color: AppTheme.primaryNavy,
                  onTap: () => context.go('/properties'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.person_add_rounded,
                  label: 'Register\nInterest',
                  color: AppTheme.secondaryGold,
                  iconColor: AppTheme.primaryNavy,
                  labelColor: AppTheme.primaryNavy,
                  onTap: () => context.go('/tenant'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.real_estate_agent_rounded,
                  label: 'Landlord\nServices',
                  color: AppTheme.successGreen,
                  onTap: () => context.go('/landlord/submit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.contact_support_rounded,
                  label: 'Contact\nUs',
                  color: const Color(0xFF6C63FF),
                  onTap: () => context.go('/contact'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Featured Properties
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Properties',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () => context.go('/properties'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<_HomeData>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPropertyShimmer();
            }

            // Error state
            if (snapshot.hasError) {
              return _buildErrorState(
                message: 'Could not load properties',
                onRetry: _refreshData,
              );
            }

            final properties = snapshot.data!.properties;

            // Empty state
            if (properties.isEmpty) {
              return _buildEmptyState();
            }

            // Data loaded
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  return _FeaturedPropertyCard(property: properties[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPropertyShimmer() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer image placeholder
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Location shimmer
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Price shimmer
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.accentWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: AppTheme.textMedium.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No properties yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back soon for new listings.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required String message, required VoidCallback onRetry}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.accentWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Stats Bar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsBar() {
    return FutureBuilder<_HomeData>(
      future: _homeDataFuture,
      builder: (context, snapshot) {
        // Show placeholder stats while loading or on error
        final stats = snapshot.hasData
            ? snapshot.data!.stats
            : <String, int>{
                'properties': 0,
                'tenants': 0,
                'landlords': 0,
                'enquiries': 0,
              };

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.home_work_rounded,
                value: '${stats['properties'] ?? 0}',
                label: 'Properties',
                color: AppTheme.primaryNavy,
              ),
              _StatItem(
                icon: Icons.check_circle_outline_rounded,
                value: '${stats['tenants'] ?? 0}',
                label: 'Available',
                color: AppTheme.successGreen,
              ),
              _StatItem(
                icon: Icons.description_outlined,
                value: '${stats['enquiries'] ?? 0}',
                label: 'Applications',
                color: AppTheme.secondaryGold,
              ),
              _StatItem(
                icon: Icons.list_alt_rounded,
                value: '${stats['landlords'] ?? 0}',
                label: 'Landlords',
                color: const Color(0xFF6C63FF),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Landlord CTA
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLandlordCta() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryGold, Color(0xFFE6C84A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are You a Landlord?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'List your property with DSS Lets and get guaranteed rent',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/landlord/submit'),
            icon: const Icon(Icons.add_business_rounded, size: 18),
            label: const Text('List Your Property'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryNavy,
              side: const BorderSide(
                color: AppTheme.primaryNavy,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Quick Action Card
// ═══════════════════════════════════════════════════════════════
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconColor = AppTheme.accentWhite,
    this.labelColor = AppTheme.accentWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Featured Property Card
// ═══════════════════════════════════════════════════════════════
class _FeaturedPropertyCard extends StatelessWidget {
  final Property property;

  const _FeaturedPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        property.images.isNotEmpty && property.images.first.isNotEmpty;

    return GestureDetector(
      onTap: () => context.go('/properties/${property.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.accentWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: property.images.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: AppTheme.primaryNavy.withOpacity(0.08),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: AppTheme.primaryNavy.withOpacity(0.08),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 48,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: AppTheme.primaryNavy.withOpacity(0.08),
                      child: const Icon(
                        Icons.home_rounded,
                        size: 48,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
            ),
            // Property details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textMedium),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.postcode.isNotEmpty
                              ? property.postcode
                              : property.address,
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '£${property.rent.toStringAsFixed(0)} PCM',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.bed_outlined,
                          size: 14, color: AppTheme.textMedium),
                      const SizedBox(width: 2),
                      Text(
                        '${property.bedrooms}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.bathtub_outlined,
                          size: 14, color: AppTheme.textMedium),
                      const SizedBox(width: 2),
                      Text(
                        '${property.bathrooms}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
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
// Stat Item
// ═══════════════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
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

// ═══════════════════════════════════════════════════════════════
// Home Data container
// ═══════════════════════════════════════════════════════════════
class _HomeData {
  final List<Property> properties;
  final Map<String, int> stats;

  const _HomeData({required this.properties, required this.stats});
}
