import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
            },
          ),
        ],
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
      body: Column(
        children: [
          // ── KPI Cards ──
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Expanded(
                  child: _KpiCard(
                    label: 'Properties',
                    value: '0',
                    icon: Icons.home_work,
                    color: AppTheme.secondaryGold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _KpiCard(
                    label: 'Applicants',
                    value: '0',
                    icon: Icons.people,
                    color: AppTheme.successGreen,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _KpiCard(
                    label: 'Landlords',
                    value: '0',
                    icon: Icons.real_estate_agent,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _KpiCard(
                    label: 'Enquiries',
                    value: '0',
                    icon: Icons.mail,
                    color: Color(0xFFEA4335),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PropertiesTab(),
                _ApplicantsTab(),
                _LandlordsTab(),
                _SettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI Card ──
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Properties Tab ──
class _PropertiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 64, color: AppTheme.textMedium),
          const SizedBox(height: 16),
          Text(
            'No properties listed yet',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Properties submitted by landlords will appear here',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Applicants Tab ──
class _ApplicantsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: AppTheme.textMedium),
          const SizedBox(height: 16),
          Text(
            'No applicants registered',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tenant registrations will appear here',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Landlords Tab ──
class _LandlordsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.real_estate_agent, size: 64, color: AppTheme.textMedium),
          const SizedBox(height: 16),
          Text(
            'No landlords registered',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Landlord registrations will appear here',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tab ──
class _SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Analytics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('User Management'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.build),
          title: const Text('App Configuration'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('App Version'),
          subtitle: const Text('1.0.0 — DSS Lets'),
        ),
      ],
    );
  }
}
