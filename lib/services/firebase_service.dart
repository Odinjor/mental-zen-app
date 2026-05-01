import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';
import '../models/user_profile.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return user.uid;
  }

  DocumentReference get _profileRef => _db.collection('users').doc(_uid);

  CollectionReference _journalRef() =>
      _db.collection('users').doc(_uid).collection('journal_entries');

  CollectionReference _moodRef() =>
      _db.collection('users').doc(_uid).collection('mood_logs');

  // ─── User Profile ─────────────────────────────────────────────────────────

  Future<void> createUserProfile(UserProfile profile) async {
    await _profileRef.set(profile.toFirestore());
  }

  Future<UserProfile?> getUserProfile() async {
    final doc = await _profileRef.get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _profileRef.update(profile.toFirestore());
  }

  // ─── Journal Entries ──────────────────────────────────────────────────────

  Stream<List<JournalEntry>> journalEntriesStream() {
    return _journalRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => JournalEntry.fromFirestore(d)).toList(),
        );
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final snap = await _journalRef()
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => JournalEntry.fromFirestore(d)).toList();
  }

  Future<JournalEntry> createJournalEntry({
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: _uuid.v4(),
      title: title,
      body: body,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    await _journalRef().doc(entry.id).set(entry.toFirestore());
    return entry;
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now());
    await _journalRef().doc(entry.id).update(updated.toFirestore());
  }

  Future<void> deleteJournalEntry(String entryId) async {
    await _journalRef().doc(entryId).delete();
  }

  // ─── Mood Logs ────────────────────────────────────────────────────────────

  Stream<List<MoodEntry>> moodEntriesStream({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _moodRef()
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => MoodEntry.fromFirestore(d)).toList(),
        );
  }

  Future<List<MoodEntry>> getMoodEntries({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snap = await _moodRef()
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('loggedAt', descending: true)
        .get();
    return snap.docs.map((d) => MoodEntry.fromFirestore(d)).toList();
  }

  Future<MoodEntry?> getTodaysMood() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _moodRef()
        .where(
          'loggedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return MoodEntry.fromFirestore(snap.docs.first);
  }

  Future<MoodEntry> logMood({required int moodScore, String? notes}) async {
    final entry = MoodEntry(
      id: _uuid.v4(),
      moodScore: moodScore,
      notes: notes,
      loggedAt: DateTime.now(),
    );
    await _moodRef().doc(entry.id).set(entry.toFirestore());
    return entry;
  }

  // ─── Insights Helpers ─────────────────────────────────────────────────────

  /// Returns the number of consecutive days the user has journaled up to today.
  Future<int> getJournalingStreak() async {
    final entries = await getJournalEntries();
    if (entries.isEmpty) return 0;

    final dates =
        entries
            .map(
              (e) => DateTime(
                e.createdAt.year,
                e.createdAt.month,
                e.createdAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime check = DateTime.now();
    check = DateTime(check.year, check.month, check.day);

    for (final date in dates) {
      if (date == check || date == check.subtract(const Duration(days: 1))) {
        streak++;
        check = date;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns all tags and their usage counts from the last [days] entries.
  Future<Map<String, int>> getTopTags({int days = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snap = await _journalRef()
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .get();

    final counts = <String, int>{};
    for (final doc in snap.docs) {
      final entry = JournalEntry.fromFirestore(doc);
      for (final tag in entry.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }
}
