import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/firebase_service.dart';
import '../widgets/mood_picker.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final _firebaseService = FirebaseService();
  final _notesCtrl = TextEditingController();

  MoodLevel? _selected;
  bool _saving = false;
  bool _todayLogged = false;
  MoodEntry? _todayEntry;
  List<MoodEntry> _weekEntries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final today = await _firebaseService.getTodaysMood();
      final week = await _firebaseService.getMoodEntries(days: 7);
      if (mounted) {
        setState(() {
          _todayEntry = today;
          _todayLogged = today != null;
          _selected = today?.moodLevel;
          _weekEntries = week;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logMood() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await _firebaseService.logMood(
        moodScore: _selected!.score,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood logged!', style: GoogleFonts.nunito()),
            backgroundColor: const Color(0xFF6BCB77),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save.', style: GoogleFonts.nunito()),
            backgroundColor: const Color(0xFFE05C5C),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7C6FCD),
                  strokeWidth: 2,
                ),
              )
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                children: [
                  // Header
                  Text(
                    'Mood tracker',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                  Text(
                    'This week',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's check-in
                  _SectionTitle("TODAY'S CHECK-IN"),
                  const SizedBox(height: 12),
                  MoodPicker(
                    selected: _selected,
                    onSelected: (mood) => setState(() => _selected = mood),
                  ),
                  const SizedBox(height: 20),

                  // Notes field
                  _SectionTitle('ADD A NOTE (OPTIONAL)'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: GoogleFonts.nunito(
                        color: const Color(0xFFE6EDF3), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: GoogleFonts.nunito(
                          color: const Color(0xFF8B949E), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF1E2530),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF7C6FCD), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_saving || _selected == null)
                          ? null
                          : _logMood,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _todayLogged ? 'Update Mood' : 'Log Mood',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // This week calendar
                  _SectionTitle('THIS WEEK'),
                  const SizedBox(height: 12),
                  _WeekCalendar(entries: _weekEntries),
                  const SizedBox(height: 24),

                  // 7-day pattern
                  _SectionTitle('7-DAY PATTERN'),
                  const SizedBox(height: 12),
                  _MoodPatternBars(entries: _weekEntries),
                ],
              ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

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

class _WeekCalendar extends StatelessWidget {
  final List<MoodEntry> entries;
  const _WeekCalendar({required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    // Build a map date→mood
    final Map<String, MoodEntry> moodByDay = {};
    for (final e in entries) {
      final key = DateFormat('yyyy-MM-dd').format(e.loggedAt);
      moodByDay[key] = e;
    }

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = days[i];
        final key = DateFormat('yyyy-MM-dd').format(day);
        final moodEntry = moodByDay[key];
        final isToday = DateFormat('yyyy-MM-dd').format(now) == key;

        Color bgColor;
        if (moodEntry != null) {
          bgColor = moodEntry.moodLevel.color;
        } else if (isToday) {
          bgColor = const Color(0xFF7C6FCD).withOpacity(0.3);
        } else {
          bgColor = const Color(0xFF1E2530);
        }

        return Column(
          children: [
            Text(
              dayLabels[day.weekday - 1],
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: const Color(0xFF8B949E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(
                        color: const Color(0xFF7C6FCD), width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: moodEntry != null
                        ? Colors.white
                        : const Color(0xFF8B949E),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _MoodPatternBars extends StatelessWidget {
  final List<MoodEntry> entries;
  const _MoodPatternBars({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Count by mood level
    final counts = {
      MoodLevel.great: 0,
      MoodLevel.good: 0,
      MoodLevel.okay: 0,
      MoodLevel.hard: 0,
    };
    for (final e in entries) {
      counts[e.moodLevel] = (counts[e.moodLevel] ?? 0) + 1;
    }

    final total = entries.isEmpty ? 1 : entries.length;

    return Column(
      children: [MoodLevel.great, MoodLevel.good, MoodLevel.okay, MoodLevel.hard]
          .map((mood) {
        final count = counts[mood] ?? 0;
        final ratio = count / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  mood.label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF8B949E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: const Color(0xFF1E2530),
                    valueColor: AlwaysStoppedAnimation<Color>(mood.color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: const Color(0xFF8B949E),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}