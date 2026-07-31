import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/enquiry.dart';
import '../models/property.dart';
import '../services/firestore_service.dart';
import '../services/tenant_session.dart';

class TenantSavedScreen extends StatefulWidget {
  const TenantSavedScreen({super.key});

  @override
  State<TenantSavedScreen> createState() => _TenantSavedScreenState();
}

class _TenantSavedScreenState extends State<TenantSavedScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _loading = true;
  String? _error;
  String? _tenantId;
  List<_EnquiryWithProperty> _items = [];

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
      final items = <_EnquiryWithProperty>[];
      for (final enquiry in enquiries) {
        final property =
            await _firestoreService.getPropertyById(enquiry.propertyId);
        items.add(_EnquiryWithProperty(enquiry: enquiry, property: property));
      }

      if (!mounted) return;

      setState(() {
        _items = items;
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

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
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
    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    // ── List ──
    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      backgroundColor: AppTheme.primaryNavy,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _SavedPropertyCard(item: _items[index]);
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
              'Register to save properties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your tenant profile so you can save '
              'and track properties you\'re interested in.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
              ),
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
            Icon(Icons.favorite_border, size: 64, color: AppTheme.textMedium),
            const SizedBox(height: 16),
            Text(
              'You haven\'t saved any properties yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse properties and register interest to save them here',
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
                color: AppTheme.textDark,
              ),
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

class _EnquiryWithProperty {
  final Enquiry enquiry;
  final Property? property;

  _EnquiryWithProperty({required this.enquiry, this.property});
}

// ═══════════════════════════════════════════════════════════════
// Saved property card
// ═══════════════════════════════════════════════════════════════

class _SavedPropertyCard extends StatelessWidget {
  final _EnquiryWithProperty item;

  const _SavedPropertyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final property = item.property;
    final enquiry = item.enquiry;

    final statusColor = _statusColor(enquiry.status);
    final statusLabel = _statusLabel(enquiry.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (property?.id != null) {
            context.push('/properties/${property!.id}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Property thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: property != null &&
                          property.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: property.images.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.backgroundGrey,
                            child: const Icon(Icons.image,
                                color: AppTheme.textMedium),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.backgroundGrey,
                            child: const Icon(Icons.broken_image,
                                color: AppTheme.textMedium),
                          ),
                        )
                      : Container(
                          color: AppTheme.backgroundGrey,
                          child: const Icon(Icons.home,
                              color: AppTheme.textMedium),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property?.title ?? 'Property',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (property != null) ...[
                      Text(
                        '£${property.rent.toStringAsFixed(0)} pcm',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.secondaryGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(enquiry.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right,
                      color: AppTheme.textMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
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
