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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Step 1: Send OTP
  Future<void> _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await _authService.verifyPhoneNumber(
      phoneNumber:
          "+977${_phoneController.text.trim()}", // Hardcoded Nepal code for hackathon simplicity
      codeSent: (verificationId, resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("OTP Sent!")));
        }
      },
      verificationFailed: (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification Failed: ${e.message}")),
          );
        }
      },
      verificationCompleted: (credential) async {
        // Auto-resolve (Android only sometimes)
        // For simplicity, we usually let user enter code manually in this UI
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Step 2: Verify OTP & Login
  Future<void> _signInWithOTP() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);

    String? error = await _authService.signInWithOTP(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? "Farmer"
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? "Nepal"
          : _locationController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        // Success handled by StreamBuilder in main.dart
      }
    }
  }

  Future<void> _guestLogin() async {
    setState(() => _isLoading = true);
    await _authService.signInAnonymously();
    if (mounted) setState(() => _isLoading = false);
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
            children: [
              Icon(Icons.lock_open, size: 60, color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                "SajiloKheti Login",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_codeSent) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          "Full Name",
                          Icons.person,
                          context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration(
                          "Location",
                          Icons.location_on,
                          context,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          "Mobile Number (Example: 9812345678)",
                          Icons.phone,
                          context,
                        ),
                        validator: (val) =>
                            val!.length < 10 ? "Enter valid number" : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyPhone,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Send OTP"),
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          "Enter OTP",
                          Icons.message,
                          context,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithOTP,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Verify & Login"),
                        ),
                      ),
                    ],

                    const Divider(height: 40),
                    TextButton.icon(
                      icon: const Icon(Icons.person_outline),
                      label: const Text("Continue as Guest (Anonymous)"),
                      onPressed: _isLoading ? null : _guestLogin,
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
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
