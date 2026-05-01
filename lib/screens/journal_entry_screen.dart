import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/journal_entry.dart';
import '../services/firebase_service.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry; // null = create mode

  const JournalEntryScreen({super.key, this.entry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _tagCtrl;
  List<String> _tags = [];
  bool _saving = false;
  bool _deleting = false;

  final _firebaseService = FirebaseService();

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.entry?.body ?? '');
    _tagCtrl = TextEditingController();
    _tags = List.from(widget.entry?.tags ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Write something first',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: const Color(0xFF1E2530),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final updated = widget.entry!.copyWith(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          tags: _tags,
        );
        await _firebaseService.updateJournalEntry(updated);
      } else {
        await _firebaseService.createJournalEntry(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          tags: _tags,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save. Please try again.',
                style: GoogleFonts.nunito()),
            backgroundColor: const Color(0xFFE05C5C),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2530),
        title: Text(
          'Delete entry?',
          style: GoogleFonts.playfairDisplay(color: const Color(0xFFE6EDF3)),
        ),
        content: Text(
          'This cannot be undone.',
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
            child: Text('Delete',
                style: GoogleFonts.nunito(color: const Color(0xFFE05C5C))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await _firebaseService.deleteJournalEntry(widget.entry!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: Color(0xFF8B949E), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit entry' : 'New entry',
          style: GoogleFonts.nunito(
            color: const Color(0xFFE6EDF3),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deleting ? null : _delete,
              icon: _deleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFE05C5C)))
                  : const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFE05C5C), size: 22),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF7C6FCD)))
                  : Text(
                      'Save',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF7C6FCD),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            // Title
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE6EDF3),
              ),
              decoration: InputDecoration(
                hintText: 'Title (optional)',
                hintStyle: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  color: const Color(0xFF8B949E).withOpacity(0.6),
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: const Color(0xFF2A3240), thickness: 1),
            const SizedBox(height: 16),

            // Body
            TextField(
              controller: _bodyCtrl,
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: const Color(0xFFE6EDF3),
                height: 1.7,
              ),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 15,
                  color: const Color(0xFF8B949E).withOpacity(0.6),
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Tags section
            Text(
              'TAGS',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8B949E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    onSubmitted: (_) => _addTag(),
                    style: GoogleFonts.nunito(
                        color: const Color(0xFFE6EDF3), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a tag…',
                      hintStyle: GoogleFonts.nunito(
                          color: const Color(0xFF8B949E), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF1E2530),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addTag,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6FCD).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Color(0xFF7C6FCD), size: 22),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map(
                      (tag) => InputChip(
                        label: Text(
                          tag,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF7C6FCD),
                          ),
                        ),
                        deleteIconColor: const Color(0xFF7C6FCD),
                        backgroundColor:
                            const Color(0xFF7C6FCD).withOpacity(0.15),
                        side: BorderSide(
                          color: const Color(0xFF7C6FCD).withOpacity(0.4),
                        ),
                        onDeleted: () =>
                            setState(() => _tags.remove(tag)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}