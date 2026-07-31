import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class TenantSavedScreen extends StatelessWidget {
  const TenantSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppTheme.textMedium),
            const SizedBox(height: 16),
            Text(
              'No saved properties yet',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse properties and tap the heart icon to save them',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMedium.withOpacity(0.7),
              ),
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
}
