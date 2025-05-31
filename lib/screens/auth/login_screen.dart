import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:road_accident_system/providers/auth_provider.dart';
import 'package:road_accident_system/screens/admin/admin_screen.dart';
import 'package:road_accident_system/screens/auth/register_screen.dart';
import 'package:road_accident_system/screens/user/home_screen.dart';
import 'package:road_accident_system/screens/tarura/tarura_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ref
          .read(authServiceProvider)
          .signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (user != null) {
        // Fetch user role from Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (!userDoc.exists) {
          setState(() {
            _error = 'User data not found';
            _isLoading = false;
          });
          return;
        }

        final role = userDoc.data()?['role'] ?? 'user';
        // Navigate to the appropriate home screen
        if (!mounted) return;
        switch (role) {
          case 'responder':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TaruraHomeScreen()),
            );
            break;
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminHomeScreen()),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const TrafficOfficerHomeScreen(),
              ),
            );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        top: false,
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24, 30, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo or emblem
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
                  SizedBox(height: 16),
                  Text(
                    'ROAD ACCIDENT INFORMATION SYSTEM',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ministry of Transportation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Login form
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section title
                      Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),

                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 1.5,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      // Error message
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        height: 48,
                        child:
                            _isLoading
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                      ),

                      SizedBox(height: 16),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Footer
                      Text(
                        '© 2023 Road Accident Information System',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
