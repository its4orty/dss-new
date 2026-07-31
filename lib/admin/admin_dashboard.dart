import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/property.dart';
import '../models/enquiry.dart';
import '../models/landlord.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  // KPI state
  Map<String, int>? _stats;
  bool _statsLoading = true;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _statsLoading = true;
      _statsError = null;
    });
    try {
      final stats = await _firestoreService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _statsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = e.toString();
          _statsLoading = false;
        });
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // Status helpers
  // ────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF6C63FF);
      case 'contacted':
        return AppTheme.secondaryGold;
      case 'viewed':
        return const Color(0xFF17A2B8);
      case 'accepted':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textMedium;
    }
  }

  String _statusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  // ────────────────────────────────────────────────────────────
  // Build
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.secondaryGold,
          labelColor: AppTheme.accentWhite,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Applicants'),
            Tab(text: 'Landlords'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.secondaryGold,
        onRefresh: () async {
          await _loadStats();
        },
        child: Column(
          children: [
            // ── KPI Cards Row ──
            _buildKpiSection(),

            // ── Tab Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PropertiesTab(firestoreService: _firestoreService),
                  _ApplicantsTab(firestoreService: _firestoreService),
                  _LandlordsTab(firestoreService: _firestoreService),
                  const _SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // KPI Section
  // ────────────────────────────────────────────────────────────

  Widget _buildKpiSection() {
    if (_statsLoading) {
      return Container(
        color: AppTheme.primaryNavy,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => _KpiSkeleton(),
          ),
        ),
      );
    }

    if (_statsError != null) {
      return Container(
        color: AppTheme.primaryNavy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Failed to load stats',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _loadStats,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryGold,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final s = _stats!;
    final kpis = [
      _KpiData(
        icon: Icons.home_work_rounded,
        label: 'Total\nProperties',
        value: s['totalProperties'] ?? 0,
        color: AppTheme.secondaryGold,
      ),
      _KpiData(
        icon: Icons.check_circle_outline,
        label: 'Available',
        value: s['availableProperties'] ?? 0,
        color: AppTheme.successGreen,
      ),
      _KpiData(
        icon: Icons.person_add_rounded,
        label: 'New\nApplications',
        value: s['newApplications'] ?? 0,
        color: const Color(0xFF6C63FF),
      ),
      _KpiData(
        icon: Icons.schedule_rounded,
        label: 'Waiting\nList',
        value: s['waitingListCount'] ?? 0,
        color: const Color(0xFF17A2B8),
      ),
      _KpiData(
        icon: Icons.business_rounded,
        label: 'New\nLandlords',
        value: s['newLandlords'] ?? 0,
        color: const Color(0xFFE67E22),
      ),
      _KpiData(
        icon: Icons.trending_up_rounded,
        label: 'Monthly\nLeads',
        value: s['monthlyLeads'] ?? 0,
        color: const Color(0xFFEA4335),
      ),
    ];

    return Container(
      color: AppTheme.primaryNavy,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kpis.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => _KpiCard(data: kpis[i]),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// KPI Data Model
// ────────────────────────────────────────────────────────────────

class _KpiData {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  const _KpiData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ────────────────────────────────────────────────────────────────
// KPI Card
// ────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data.color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            data.value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: data.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: const TextStyle(fontSize: 10, color: Colors.white70, height: 1.2),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 30, height: 18, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 6),
          Container(width: 60, height: 10, color: Colors.white.withOpacity(0.08)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TAB: Properties
// ════════════════════════════════════════════════════════════════

class _PropertiesTab extends StatefulWidget {
  final FirestoreService firestoreService;
  const _PropertiesTab({required this.firestoreService});

  @override
  State<_PropertiesTab> createState() => _PropertiesTabState();
}

class _PropertiesTabState extends State<_PropertiesTab> {
  List<Property>? _properties;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final props = await widget.firestoreService.getProperties();
      if (mounted) setState(() { _properties = props; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleAvailability(Property p) async {
    try {
      await widget.firestoreService.togglePropertyAvailability(p.id!, !p.available);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(p.available ? 'Marked unavailable' : 'Marked available'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _deleteProperty(Property p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Property?'),
        content: Text('Are you sure you want to delete "${p.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.firestoreService.deleteProperty(p.id!);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${p.title}" deleted'), backgroundColor: AppTheme.successGreen, behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy));
    }
    if (_error != null) {
      return _buildErrorState(_error!, _load);
    }
    if (_properties == null || _properties!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.home_work_rounded,
        title: 'No properties listed yet',
        subtitle: 'Properties submitted by landlords will appear here',
      );
    }

    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _properties!.length,
        itemBuilder: (_, i) {
          final p = _properties![i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.available
                              ? AppTheme.successGreen.withOpacity(0.1)
                              : AppTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.available ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.available ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(p.address, style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                  const SizedBox(height: 4),
                  Text(
                    '£${p.rent.toStringAsFixed(0)}/month • ${p.bedrooms} bed • ${p.bathrooms} bath',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(p.available ? Icons.visibility_off : Icons.visibility, size: 18),
                        label: Text(p.available ? 'Mark Unavailable' : 'Mark Available'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.primaryNavy),
                        onPressed: () => _toggleAvailability(p),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
                        onPressed: () => _deleteProperty(p),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TAB: Applicants
// ════════════════════════════════════════════════════════════════

class _ApplicantsTab extends StatefulWidget {
  final FirestoreService firestoreService;
  const _ApplicantsTab({required this.firestoreService});

  @override
  State<_ApplicantsTab> createState() => _ApplicantsTabState();
}

class _ApplicantsTabState extends State<_ApplicantsTab> {
  List<Enquiry>? _enquiries;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final enquiries = await widget.firestoreService.getAllEnquiries();
      if (mounted) setState(() { _enquiries = enquiries; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateStatus(Enquiry enquiry, String newStatus) async {
    try {
      await widget.firestoreService.updateEnquiryStatus(enquiry.id!, newStatus);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_statusLabel(newStatus)}'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  String _statusLabel(String s) => s[0].toUpperCase() + s.substring(1);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new': return const Color(0xFF6C63FF);
      case 'contacted': return AppTheme.secondaryGold;
      case 'viewed': return const Color(0xFF17A2B8);
      case 'accepted': return AppTheme.successGreen;
      case 'rejected': return AppTheme.errorRed;
      default: return AppTheme.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy));
    }
    if (_error != null) {
      return _buildErrorState(_error!, _load);
    }
    if (_enquiries == null || _enquiries!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No applicants registered',
        subtitle: 'Tenant registrations and enquiries will appear here',
      );
    }

    final statusOptions = ['new', 'contacted', 'viewed', 'accepted', 'rejected'];

    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _enquiries!.length,
        itemBuilder: (_, i) {
          final e = _enquiries![i];
          final createdAtStr = e.createdAt != null
              ? '${e.createdAt!.day}/${e.createdAt!.month}/${e.createdAt!.year}'
              : '—';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enquiry #${e.id?.substring(0, 6) ?? '—'}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(e.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(e.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(e.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tenant ID: ${e.tenantId}',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                  ),
                  Text(
                    'Property ID: ${e.propertyId}',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
                  ),
                  Text(
                    'Date: $createdAtStr',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMedium.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Status: ', style: TextStyle(fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.textMedium.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: statusOptions.contains(e.status) ? e.status : 'new',
                            isDense: true,
                            style: TextStyle(fontSize: 13, color: AppTheme.textDark),
                            items: statusOptions.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(_statusLabel(s)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null && v != e.status) {
                                _updateStatus(e, v);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TAB: Landlords
// ════════════════════════════════════════════════════════════════

class _LandlordsTab extends StatefulWidget {
  final FirestoreService firestoreService;
  const _LandlordsTab({required this.firestoreService});

  @override
  State<_LandlordsTab> createState() => _LandlordsTabState();
}

class _LandlordsTabState extends State<_LandlordsTab> {
  List<Landlord>? _landlords;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final landlords = await widget.firestoreService.getAllLandlords();
      if (mounted) setState(() { _landlords = landlords; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy));
    }
    if (_error != null) {
      return _buildErrorState(_error!, _load);
    }
    if (_landlords == null || _landlords!.isEmpty) {
      return _buildEmptyState(
        icon: Icons.real_estate_agent_rounded,
        title: 'No landlords registered',
        subtitle: 'Landlord registrations will appear here',
      );
    }

    return RefreshIndicator(
      color: AppTheme.secondaryGold,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _landlords!.length,
        itemBuilder: (_, i) {
          final l = _landlords![i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: AppTheme.primaryNavy, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text(l.email, style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${l.propertyCount} ${l.propertyCount == 1 ? 'property' : 'properties'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (l.phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: AppTheme.textMedium),
                        const SizedBox(width: 6),
                        Text(l.phone, style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TAB: Settings
// ════════════════════════════════════════════════════════════════

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // ── Branding ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'DSS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DSS Lets',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Housing Rental Platform',
                  style: TextStyle(fontSize: 13, color: AppTheme.accentWhite.withOpacity(0.7)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppTheme.secondaryGold),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── About ──
        const _SettingsListTile(
          icon: Icons.info_outline,
          title: 'App Version',
          subtitle: '1.0.0 — DSS Lets',
        ),
        const _SettingsListTile(
          icon: Icons.build_outlined,
          title: 'App Configuration',
          subtitle: 'Manage platform settings',
        ),

        const Divider(height: 32),

        // ── Actions ──
        _SettingsActionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Clear Cache',
          iconColor: AppTheme.secondaryGold,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cache cleared'),
                backgroundColor: AppTheme.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _SettingsActionTile(
          icon: Icons.logout,
          title: 'Sign Out',
          iconColor: AppTheme.errorRed,
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Sign Out?'),
                content: const Text('Are you sure you want to sign out of the admin dashboard?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await FirebaseAuth.instance.signOut();
                      if (ctx.mounted) {
                        context.go('/admin/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // ── Footer ──
        Center(
          child: Text(
            '© 2026 DSS Lets. All rights reserved.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMedium.withOpacity(0.6)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Shared Empty / Error Helpers
// ────────────────────────────────────────────────────────────────

Widget _buildEmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 36, color: AppTheme.textMedium),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: AppTheme.textMedium, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: AppTheme.textMedium.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(String error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: AppTheme.textMedium.withOpacity(0.8)),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            onPressed: onRetry,
          ),
        ],
      ),
    ),
  );
}

// ────────────────────────────────────────────────────────────────
// Settings tile widgets
// ────────────────────────────────────────────────────────────────

class _SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingsListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryNavy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textMedium)),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: iconColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
