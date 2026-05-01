import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';
import '../services/firebase_service.dart';
import '../widgets/journal_card.dart';
import 'journal_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const JournalEntryScreen()),
        ),
        backgroundColor: const Color(0xFF7C6FCD),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Journal',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6EDF3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your private thoughts & reflections',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF8B949E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<JournalEntry>>(
                stream: _firebaseService.journalEntriesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C6FCD),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong.\nPlease try again.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8B949E),
                        ),
                      ),
                    );
                  }

                  final entries = snapshot.data ?? [];

                  if (entries.isEmpty) {
                    return _EmptyJournal(
                      onWrite: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const JournalEntryScreen()),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return JournalCard(
                        entry: entry,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                JournalEntryScreen(entry: entry),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  final VoidCallback onWrite;
  const _EmptyJournal({required this.onWrite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FCD).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                color: Color(0xFF7C6FCD),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your journal is empty',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE6EDF3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start capturing your thoughts and reflections.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF8B949E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onWrite,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Write first entry',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}