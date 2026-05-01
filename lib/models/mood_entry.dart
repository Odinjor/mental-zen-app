import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MoodLevel { hard, okay, good, great }

extension MoodLevelX on MoodLevel {
  String get label {
    switch (this) {
      case MoodLevel.great:
        return 'Great';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.okay:
        return 'Okay';
      case MoodLevel.hard:
        return 'Hard';
    }
  }

  int get score {
    switch (this) {
      case MoodLevel.great:
        return 4;
      case MoodLevel.good:
        return 3;
      case MoodLevel.okay:
        return 2;
      case MoodLevel.hard:
        return 1;
    }
  }

  Color get color {
    switch (this) {
      case MoodLevel.great:
        return const Color(0xFF6BCB77);
      case MoodLevel.good:
        return const Color(0xFF7C6FCD);
      case MoodLevel.okay:
        return const Color(0xFFE8A838);
      case MoodLevel.hard:
        return const Color(0xFFE05C5C);
    }
  }

  static MoodLevel fromScore(int score) {
    switch (score) {
      case 4:
        return MoodLevel.great;
      case 3:
        return MoodLevel.good;
      case 2:
        return MoodLevel.okay;
      default:
        return MoodLevel.hard;
    }
  }
}

class MoodEntry {
  final String id;
  final int moodScore; // 1–4 matching MoodLevel
  final String? notes;
  final DateTime loggedAt;

  const MoodEntry({
    required this.id,
    required this.moodScore,
    this.notes,
    required this.loggedAt,
  });

  MoodLevel get moodLevel => MoodLevelX.fromScore(moodScore);

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      moodScore: data['moodScore'] ?? 3,
      notes: data['notes'] as String?,
      loggedAt: (data['loggedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'moodScore': moodScore,
      if (notes != null) 'notes': notes,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }
}