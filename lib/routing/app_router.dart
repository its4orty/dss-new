import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/property_list_screen.dart';
import '../screens/property_search_screen.dart';
import '../screens/property_detail_screen.dart';
import '../screens/tenant_registration_screen.dart';
import '../screens/tenant_saved_screen.dart';
import '../screens/tenant_applications_screen.dart';
import '../screens/landlord_submission_screen.dart';
import '../screens/landlord_photos_screen.dart';
import '../screens/landlord_management_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/admin_login_screen.dart';
import '../admin/admin_dashboard.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/properties',
      name: 'properties',
      builder: (context, state) => const PropertyListScreen(),
    ),
    GoRoute(
      path: '/properties/search',
      name: 'propertySearch',
      builder: (context, state) => const PropertySearchScreen(),
    ),
    GoRoute(
      path: '/properties/:id',
      name: 'propertyDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PropertyDetailScreen(propertyId: id);
      },
    ),
    GoRoute(
      path: '/tenant',
      name: 'tenantRegistration',
      builder: (context, state) => const TenantRegistrationScreen(),
    ),
    GoRoute(
      path: '/tenant/saved',
      name: 'tenantSaved',
      builder: (context, state) => const TenantSavedScreen(),
    ),
    GoRoute(
      path: '/tenant/applications',
      name: 'tenantApplications',
      builder: (context, state) => const TenantApplicationsScreen(),
    ),
    GoRoute(
      path: '/landlord/submit',
      name: 'landlordSubmit',
      builder: (context, state) => const LandlordSubmissionScreen(),
    ),
    GoRoute(
      path: '/landlord/photos',
      name: 'landlordPhotos',
      builder: (context, state) {
        final propertyId = state.extra as String? ?? '';
        return LandlordPhotosScreen(propertyId: propertyId);
      },
    ),
    GoRoute(
      path: '/landlord/management',
      name: 'landlordManagement',
      builder: (context, state) => const LandlordManagementScreen(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/admin/login',
      name: 'adminLogin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      redirect: (context, state) {
        if (FirebaseAuth.instance.currentUser == null) {
          return '/admin/login';
        }
        return null;
      },
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
