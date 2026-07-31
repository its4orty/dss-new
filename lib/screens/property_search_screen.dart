import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.accentWhite),
          decoration: const InputDecoration(
            hintText: 'Search by area, postcode, or keyword...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: AppTheme.textMedium),
                  const SizedBox(height: 16),
                  Text(
                    'Search for properties',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter an area, postcode, or keyword',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.home, color: AppTheme.primaryNavy),
                    title: Text('Result ${index + 1} — "$_query"'),
                    subtitle: const Text('Placeholder search result'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/properties/search-$index'),
                  ),
                );
              },
            ),
    );
  }
}
