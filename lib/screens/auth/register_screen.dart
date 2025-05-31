import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:road_accident_system/screens/auth/login_screen.dart';
import 'package:road_accident_system/screens/user/home_screen.dart';
import 'package:road_accident_system/screens/tarura/tarura_dashboard.dart';
import 'package:road_accident_system/widgets/text_input.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user';
  String? _department;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_role == 'responder' && _department == null) {
      setState(() {
        _error = 'Please select a department';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await ref
          .read(authServiceProvider)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            _role,
          );
      if (user != null) {
        // Navigate to the appropriate home screen based on role
        if (!mounted) return;
        switch (_role) {
          case 'responder':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => TaruraHomeScreen()),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => TrafficOfficerHomeScreen()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with gradient background
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColor,
                  HSLColor.fromColor(Theme.of(context).primaryColor)
                      .withLightness(
                        (HSLColor.fromColor(
                                  Theme.of(context).primaryColor,
                                ).lightness -
                                0.1)
                            .clamp(0.0, 1.0),
                      )
                      .toColor(),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Register to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name field
                  TextInputField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextInputField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextInputField(
                    controller: _phoneController,
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextInputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // Role dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _role,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                      items:
                          ['user', 'tarura'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.toUpperCase()),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                    ),
                  ),

                  // Error message
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Register button
                  SizedBox(
                    height: 56,
                    child:
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                  ),

                  // Login link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
