import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mood_entry.dart';
import '../services/firebase_service.dart';
import '../widgets/insight_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _firebaseService = FirebaseService();

  List<MoodEntry> _moodEntries = [];
  int _streak = 0;
  Map<String, int> _tags = {};
  bool _loading = true;
  int _chartDays = 7;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final entries = await _firebaseService.getMoodEntries(days: _chartDays);
      final streak = await _firebaseService.getJournalingStreak();
      final tags = await _firebaseService.getTopTags(days: 7);
      if (mounted) {
        setState(() {
          _moodEntries = entries;
          _streak = streak;
          _tags = tags;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _trendMessage() {
    if (_moodEntries.length < 2) {
      return 'Keep logging your mood to see trends.';
    }
    final recent =
        _moodEntries.take(3).map((e) => e.moodScore).reduce((a, b) => a + b) /
            3;
    final older = _moodEntries.skip(3).take(3).isEmpty
        ? recent
        : _moodEntries
                .skip(3)
                .take(3)
                .map((e) => e.moodScore)
                .reduce((a, b) => a + b) /
            3;

    if (recent > older) {
      return 'Your mood has improved vs last week. Keep it up!';
    } else if (recent < older) {
      return 'Your mood has dipped slightly. Be gentle with yourself.';
    }
    return 'Your mood has been steady. Consistency is great!';
  }

  String _streakMessage() {
    if (_streak == 0) return 'Start journaling to build your streak!';
    if (_streak == 1) return "You journaled today. Great start!";
    return "You've journaled $_streak days in a row. Tomorrow is your chance to extend it!";
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 24),
                children: [
                  // Header
                  Text(
                    'Insights',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                  Text(
                    'Last $_chartDays days',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trend card
                  _TrendCard(message: _trendMessage()),
                  const SizedBox(height: 16),

                  // Mood chart
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mood over time',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE6EDF3),
                              ),
                            ),
                            // Day selector
                            Row(
                              children: [7, 30].map((d) {
                                final isSelected = _chartDays == d;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _chartDays = d;
                                      _loading = true;
                                    });
                                    _loadData();
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF7C6FCD)
                                          : const Color(0xFF7C6FCD)
                                              .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${d}d',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF7C6FCD),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InsightChart(
                          entries: _moodEntries,
                          days: _chartDays,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Suggested actions
                  _SectionHeader('SUGGESTED ACTIONS'),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFE8A838),
                    title: 'Keep your streak going',
                    body: _streakMessage(),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.air_rounded,
                    color: const Color(0xFF6BCB77),
                    title: 'Try a breathing exercise',
                    body:
                        'Taking 5 minutes to breathe mindfully can shift your mood.',
                  ),
                  const SizedBox(height: 20),

                  // Mood tags
                  if (_tags.isNotEmpty) ...[
                    _SectionHeader('MOOD TAGS THIS WEEK'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.entries
                          .toList()
                          .sorted((a, b) => b.value.compareTo(a.value))
                          .take(8)
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C6FCD)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF7C6FCD)
                                      .withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                e.key,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: const Color(0xFF7C6FCD),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Privacy note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 12, color: Color(0xFF8B949E)),
                      const SizedBox(width: 6),
                      Text(
                        'All insights processed on device. No data leaves your account.',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: const Color(0xFF8B949E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TrendCard extends StatelessWidget {
  final String message;
  const _TrendCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C6FCD).withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFF7C6FCD).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded,
              color: Color(0xFF7C6FCD), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trend shift detected',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C6FCD),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFFE6EDF3),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE6EDF3),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF8B949E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to sort map entries
extension _SortedEntries<K, V> on List<MapEntry<K, V>> {
  List<MapEntry<K, V>> sorted(int Function(MapEntry<K, V>, MapEntry<K, V>) compare) {
    return [...this]..sort(compare);
  }
}