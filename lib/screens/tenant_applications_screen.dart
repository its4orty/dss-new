import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/enquiry.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';
import '../services/tenant_session.dart';

class TenantApplicationsScreen extends StatefulWidget {
  const TenantApplicationsScreen({super.key});

  @override
  State<TenantApplicationsScreen> createState() =>
      _TenantApplicationsScreenState();
}

class _TenantApplicationsScreenState extends State<TenantApplicationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _loading = true;
  String? _error;
  String? _tenantId;
  List<_ApplicationWithProperty> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tenantId = await TenantSession.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        setState(() {
          _tenantId = null;
          _loading = false;
        });
        return;
      }

      _tenantId = tenantId;
      final enquiries =
          await _firestoreService.getEnquiriesForTenant(tenantId);

      // Fetch property details for each enquiry
      final apps = <_ApplicationWithProperty>[];
      for (final enquiry in enquiries) {
        final property =
            await _firestoreService.getPropertyById(enquiry.propertyId);
        apps.add(
            _ApplicationWithProperty(enquiry: enquiry, property: property));
      }

      // Sort by date (newest first)
      apps.sort((a, b) {
        final aDate = a.enquiry.createdAt ?? DateTime(2000);
        final bDate = b.enquiry.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        _applications = apps;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Status helpers ────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF2196F3); // blue
      case 'contacted':
        return AppTheme.secondaryGold;
      case 'viewed':
        return AppTheme.successGreen;
      case 'accepted':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textMedium;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'viewed':
        return 'Viewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Loading ──
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Error ──
    if (_error != null) {
      return _buildErrorState();
    }

    // ── No tenant registered ──
    if (_tenantId == null) {
      return _buildNoTenantState();
    }

    // ── Empty ──
    if (_applications.isEmpty) {
      return _buildEmptyState();
    }

    // ── List ──
    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      backgroundColor: AppTheme.primaryNavy,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          return _ApplicationCard(application: _applications[index]);
        },
      ),
    );
  }

  // ── No Tenant Registered ──────────────────────────────────

  Widget _buildNoTenantState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: AppTheme.textMedium),
            const SizedBox(height: 16),
            Text(
              'Register to track applications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your tenant profile first, then register '
              'interest in properties to see your applications here.',
              style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/tenant'),
              icon: const Icon(Icons.person_add),
              label: const Text('Register Now'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: AppTheme.textMedium),
            const SizedBox(height: 16),
            Text(
              'No applications yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register interest in a property to see your applications here',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/properties'),
              icon: const Icon(Icons.search),
              label: const Text('Browse Properties'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Data wrapper
// ═══════════════════════════════════════════════════════════════

class _ApplicationWithProperty {
  final Enquiry enquiry;
  final Property? property;

  _ApplicationWithProperty({required this.enquiry, this.property});
}

// ═══════════════════════════════════════════════════════════════
// Application card
// ═══════════════════════════════════════════════════════════════

class _ApplicationCard extends StatelessWidget {
  final _ApplicationWithProperty application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final property = application.property;
    final enquiry = application.enquiry;

    final statusColor = _statusColor(enquiry.status);
    final statusLabel = _statusLabel(enquiry.status);
    final dateStr = _formatDate(enquiry.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (property?.id != null) {
            context.push('/properties/${property!.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: property != null && property.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.images.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.backgroundGrey,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.backgroundGrey,
                          child: const Icon(Icons.broken_image,
                              size: 48, color: AppTheme.textMedium),
                        ),
                      )
                    : Container(
                        color: AppTheme.backgroundGrey,
                        child: const Icon(Icons.home,
                            size: 48, color: AppTheme.textMedium),
                      ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property?.title ?? 'Property',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Address
                  if (property != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppTheme.textMedium),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Rent + date row
                  Row(
                    children: [
                      if (property != null)
                        Text(
                          '£${property.rent.toStringAsFixed(0)} pcm',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppTheme.secondaryGold,
                          ),
                        ),
                      const Spacer(),
                      if (dateStr.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: AppTheme.textMedium),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF2196F3);
      case 'contacted':
        return AppTheme.secondaryGold;
      case 'viewed':
        return AppTheme.successGreen;
      case 'accepted':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textMedium;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'viewed':
        return 'Viewed';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
