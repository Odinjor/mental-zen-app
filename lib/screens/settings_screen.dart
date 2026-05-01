import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _firebaseService.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2530),
        title: Text(
          'Sign out?',
          style: GoogleFonts.playfairDisplay(color: const Color(0xFFE6EDF3)),
        ),
        content: Text(
          'You can sign back in anytime.',
          style: GoogleFonts.nunito(color: const Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF8B949E))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign Out',
                style: GoogleFonts.nunito(
                    color: const Color(0xFFE05C5C),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName =
        _profile?.displayName ?? user?.displayName ?? 'Your name';
    final email = _profile?.email ?? user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8B949E), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.nunito(
            color: const Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF7C6FCD), strokeWidth: 2))
          : ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              children: [
                // Avatar + name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C6FCD), Color(0xFF6BCB77)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE6EDF3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF8B949E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Account
                _SectionLabel('ACCOUNT'),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Display name',
                  subtitle: displayName,
                  onTap: () => _editDisplayName(displayName),
                ),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: email,
                ),
                const SizedBox(height: 20),

                // Section: Preferences
                _SectionLabel('PREFERENCES'),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Reminders',
                  subtitle: 'Manage daily check-in alerts',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy',
                  subtitle: 'Your data is private and secure',
                ),
                const SizedBox(height: 20),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE05C5C),
                      side: const BorderSide(color: Color(0xFFE05C5C)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      'Sign Out',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Mental Zen • v1.0.0',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _editDisplayName(String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2530),
        title: Text(
          'Update name',
          style: GoogleFonts.playfairDisplay(color: const Color(0xFFE6EDF3)),
        ),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.nunito(color: const Color(0xFFE6EDF3)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0D1117),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: const Color(0xFF8B949E))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text('Save',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF7C6FCD),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || _profile == null) return;
    await FirebaseAuth.instance.currentUser?.updateDisplayName(result);
    await _firebaseService
        .updateUserProfile(_profile!.copyWith(displayName: result));
    await _loadProfile();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF8B949E),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2530),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B949E), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF8B949E), size: 20),
          ],
        ),
      ),
    );
  }
}