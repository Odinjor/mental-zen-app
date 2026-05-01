import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('user-not-found')) {
      return 'No account found with that email.';
    }
    if (raw.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6FCD), Color(0xFF6BCB77)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome back',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to continue your journey',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: const Color(0xFF8B949E),
                  ),
                ),
                const SizedBox(height: 40),
                // Email
                _label('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.nunito(color: const Color(0xFFE6EDF3)),
                  decoration: _inputDecoration('you@example.com'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 20),
                // Password
                _label('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: GoogleFonts.nunito(color: const Color(0xFFE6EDF3)),
                  decoration: _inputDecoration('••••••••').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF8B949E),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 16),
                // Error
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE05C5C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFE05C5C), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFE05C5C),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF8B949E),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF7C6FCD),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF8B949E),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF1E2530),
      hintStyle: GoogleFonts.nunito(color: const Color(0xFF8B949E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7C6FCD), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE05C5C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}