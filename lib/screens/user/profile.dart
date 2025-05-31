import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/providers/auth_provider.dart';

class OfficerProfileScreen extends ConsumerWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryColor = Theme.of(context).primaryColor;
    final primaryColorDark =
        HSLColor.fromColor(primaryColor)
            .withLightness(
              (HSLColor.fromColor(primaryColor).lightness - 0.1).clamp(
                0.0,
                1.0,
              ),
            )
            .toColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Officer Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with government-style design
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColorDark, primaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
              child: Column(
                children: [
                  // Official emblem
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.shield, size: 48, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TRAFFIC OFFICER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Unknown Email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Profile content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Personal Information', Icons.person),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    title: 'Email Address',
                    value: user?.email ?? '-',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    title: 'Officer ID',
                    value: user?.uid ?? '-',
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    title: 'Account Status',
                    value: 'Active',
                    icon: Icons.verified_user,
                    valueColor: Colors.green[700],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('System Information', Icons.info),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    title: 'Last Login',
                    value: 'Today, ${TimeOfDay.now().format(context)}',
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    title: 'Account Created',
                    value:
                        user?.metadata.creationTime?.toString().split(' ')[0] ??
                        '-',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 32),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(authServiceProvider).signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
