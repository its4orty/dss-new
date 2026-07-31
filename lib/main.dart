import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAA6brbuHJTd8L6qI-t5pNWF9IrJ4c_PdI',
        authDomain: 'dss-lets.firebaseapp.com',
        projectId: 'dss-lets',
        storageBucket: 'dss-lets.firebasestorage.app',
        messagingSenderId: '287229322339',
        appId: '1:287229322339:web:5e8c60cef8a07b54e64456',
        measurementId: 'G-MB5PFHXZFC',
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const DSSApp());
}

class DSSApp extends StatelessWidget {
  const DSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DSS Lets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
