import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error;
    if (_isLogin) {
      error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      error = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 60,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Sajilokheti",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? "Welcome Back!" : "Create Account",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          "Full Name",
                          Icons.person,
                          context,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Enter your name" : null,
                        style: GoogleFonts.outfit(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration(
                          "Location (e.g. Chitwan)",
                          Icons.location_on,
                          context,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Enter your location" : null,
                        style: GoogleFonts.outfit(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        "Email",
                        Icons.email,
                        context,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.contains('@') ? null : "Enter a valid email",
                      style: GoogleFonts.outfit(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _inputDecoration(
                        "Password",
                        Icons.lock,
                        context,
                      ),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? "Password must be 6+ chars"
                          : null,
                      style: GoogleFonts.outfit(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isLogin ? "Login" : "Sign Up",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Login",
                        style: GoogleFonts.outfit(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
      ),
      prefixIcon: Icon(icon, color: colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? colorScheme.surface
          : Colors.grey[50],
    );
  }
}
