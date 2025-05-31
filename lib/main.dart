import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/firebase_options.dart';
import 'package:road_accident_system/providers/auth_provider.dart';
import 'package:road_accident_system/screens/admin/admin_screen.dart';
import 'package:road_accident_system/screens/tarura/tarura_dashboard.dart';
import 'package:road_accident_system/screens/user/home_screen.dart';
import 'package:road_accident_system/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: RoadAccidentApp()));
}

class RoadAccidentApp extends ConsumerWidget {
  const RoadAccidentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Road Accident Information System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ref
          .watch(authStateProvider)
          .when(
            data: (user) {
              if (user == null) return const LoginScreen();
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      !snapshot.data!.exists) {
                    // Handle missing or invalid user data by redirecting to login
                    return const LoginScreen();
                  }
                  final role = snapshot.data!['role'] ?? 'user';
                  switch (role) {
                    case 'tarura':
                      return const TaruraHomeScreen();
                    case 'admin':
                      return const AdminHomeScreen();
                    default:
                      return const TrafficOfficerHomeScreen();
                  }
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('Error loading auth state')),
          ),
    );
  }
}
