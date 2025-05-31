import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:road_accident_system/providers/auth_provider.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
            icon: Icon(HugeIcons.strokeRoundedLogout02),
          ),
        ],
      ),
      body: Center(child: Text("Admin")),
    );
  }
}
