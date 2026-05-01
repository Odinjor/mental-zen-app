import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/firebase_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mood_picker.dart';
import 'journal_entry_screen.dart';
import 'journal_screen.dart';
import 'mood_tracker_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _firebaseService = FirebaseService();

  // Track today's mood for the home tab
  MoodLevel? _todayMood;
  bool _moodLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    try {
      final entry = await _firebaseService.getTodaysMood();
      if (mounted) {
        setState(() {
          _todayMood = entry?.moodLevel;
          _moodLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _moodLoading = false);
    }
  }

  Future<void> _saveMood(MoodLevel mood) async {
    setState(() => _todayMood = mood);
    await _firebaseService.logMood(moodScore: mood.score);
  }

  final List<Widget> _tabs = const [
    _HomeTab(),
    JournalScreen(),
    MoodTrackerScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: IndexedStack(
        index: _navIndex,
        children: _tabs,
      ),
      bottomNavigationBar: MentalZenBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─── Home tab content ─────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _firebaseService = FirebaseService();
  MoodLevel? _todayMood;
  bool _moodSaved = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'friend';
  }

  @override
  void initState() {
    super.initState();
    _checkTodayMood();
  }

  Future<void> _checkTodayMood() async {
    try {
      final entry = await _firebaseService.getTodaysMood();
      if (mounted && entry != null) {
        setState(() {
          _todayMood = entry.moodLevel;
          _moodSaved = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _onMoodSelected(MoodLevel mood) async {
    setState(() => _todayMood = mood);
    await _firebaseService.logMood(moodScore: mood.score);
    if (mounted) setState(() => _moodSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF8B949E),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_greeting, $_userName',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF8B949E),
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Mood check-in card
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sentiment_satisfied_alt_outlined,
                        color: Color(0xFF7C6FCD), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _moodSaved ? 'Today\'s mood' : 'How are you feeling?',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE6EDF3),
                      ),
                    ),
                  ],
                ),
                if (_moodSaved && _todayMood != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'You\'re feeling ${_todayMood!.label.toLowerCase()} today',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: _todayMood!.color,
                    ),
                  ),
                ] else
                  Text(
                    'Set your mood before writing',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                const SizedBox(height: 16),
                MoodPicker(
                  selected: _todayMood,
                  onSelected: _onMoodSelected,
                ),
                if (!_moodSaved) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8B949E),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Journal quick-start
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_outlined,
                        color: Color(0xFF6BCB77), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Personal journal',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE6EDF3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const JournalEntryScreen(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Today I woke up feeling…',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: const Color(0xFF8B949E),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const JournalEntryScreen(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Continue writing…',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF8B949E).withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.book_outlined,
                  label: 'Write in Journal',
                  color: const Color(0xFF7C6FCD),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  label: 'Log Mood',
                  color: const Color(0xFF6BCB77),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MoodTrackerScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}