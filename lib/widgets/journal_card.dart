import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(entry.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2530),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              dateStr,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFF8B949E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Title
            if (entry.title.isNotEmpty)
              Text(
                entry.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE6EDF3),
                ),
              ),
            const SizedBox(height: 6),
            // Preview
            Text(
              entry.preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF8B949E),
                height: 1.5,
              ),
            ),
            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags.map((tag) => _Tag(tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF7C6FCD).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C6FCD).withOpacity(0.4),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          color: const Color(0xFF7C6FCD),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}