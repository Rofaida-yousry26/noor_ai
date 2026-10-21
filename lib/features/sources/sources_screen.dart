import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';

/// Shows the actual file/page citations returned with NOOR AI answers.
/// Citations are available for this app session only; persistent history needs
/// backend storage, which is not part of the current API.
class SourcesScreen extends StatefulWidget {
  final bool isDarkMode;
  const SourcesScreen({super.key, this.isDarkMode = true});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  final TextEditingController _search = TextEditingController();
  bool get _dark => widget.isDarkMode;
  Color get _bg => _dark ? const Color(0xFF070B14) : const Color(0xFFF4F7FC);
  Color get _panel => _dark ? const Color(0xFF0D1422) : Colors.white;
  Color get _text => _dark ? const Color(0xFFF1F6FF) : const Color(0xFF10233F);
  Color get _muted => _dark ? const Color(0xFF8391A8) : const Color(0xFF697B95);
  Color get _line => _dark ? const Color(0xFF1C2A40) : const Color(0xFFDCE5F0);
  Color get _accent => _dark ? const Color(0xFF52F5E5) : const Color(0xFF008F87);

  List<Map<String, dynamic>> get _filtered {
    final query = _search.text.trim().toLowerCase();
    final citations = ChatScreen.savedCitations;
    if (query.isEmpty) return citations;
    return citations.where((item) {
      return (item['document'] ?? '').toString().toLowerCase().contains(query) ||
          (item['question'] ?? '').toString().toLowerCase().contains(query) ||
          (item['page'] ?? '').toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _search.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citations = _filtered;
    final allCitations = ChatScreen.savedCitations;
    final uniqueDocuments = allCitations.map((e) => (e['document'] ?? '').toString()).toSet().length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: Row(children: [
          Icon(Icons.travel_explore_rounded, color: _accent),
          const SizedBox(width: 10),
          const Text('Sources & References', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Refresh citations',
            onPressed: _refresh,
            icon: Icon(Icons.refresh_rounded, color: _accent),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('ANSWER EVIDENCE', style: TextStyle(color: _accent, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Sources used by AI', style: TextStyle(color: _text, fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('The exact PDFs and page numbers returned with your NOOR AI answers.', style: TextStyle(color: _muted, height: 1.6)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _stat(Icons.format_quote_rounded, '${allCitations.length}', 'Citations')),
              const SizedBox(width: 12),
              Expanded(child: _stat(Icons.picture_as_pdf_rounded, '$uniqueDocuments', 'PDFs cited')),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              style: TextStyle(color: _text),
              decoration: InputDecoration(
                hintText: 'Search by PDF, question, or page...',
                hintStyle: TextStyle(color: _muted),
                prefixIcon: Icon(Icons.search_rounded, color: _muted),
                filled: true,
                fillColor: _panel,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _accent)),
              ),
            ),
            const SizedBox(height: 18),
            if (citations.isEmpty)
              _emptyState(allCitations.isEmpty)
            else ...[
              Row(children: [
                Text('CITATIONS FROM ANSWERS', style: TextStyle(color: _muted, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${citations.length} refs', style: TextStyle(color: _muted, fontSize: 11)),
              ]),
              const SizedBox(height: 10),
              ...citations.map(_citationCard),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, color: _accent, size: 19),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'These references come from actual AI responses and remain available while the app is running. They are cleared when the app is fully restarted because chat history is not yet saved by the backend.',
                  style: TextStyle(color: _muted, height: 1.5, fontSize: 11),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _citationCard(Map<String, dynamic> item) {
    final document = (item['document'] ?? 'Document').toString();
    final page = item['page'];
    final question = (item['question'] ?? '').toString();
    final createdAt = item['createdAt'];
    final time = createdAt is DateTime
        ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 48, decoration: BoxDecoration(color: _accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.picture_as_pdf_rounded, color: _accent, size: 23)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(document, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 7),
            Text(time, style: TextStyle(color: _muted, fontSize: 10)),
          ])),
          if (page != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(color: _accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
            child: Text('PAGE $page', style: TextStyle(color: _accent, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ]),
        if (question.isNotEmpty) ...[
          const SizedBox(height: 13),
          Divider(color: _line, height: 1),
          const SizedBox(height: 10),
          Text('QUESTION', style: TextStyle(color: _accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 5),
          Text(question, style: TextStyle(color: _text, fontSize: 12, height: 1.5)),
        ],
      ]),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(17), border: Border.all(color: _line)),
    child: Row(children: [
      Icon(icon, color: _accent, size: 22),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(color: _text, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: _muted, fontSize: 10)),
      ])),
    ]),
  );

  Widget _emptyState(bool noHistory) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
    child: Column(children: [
      Icon(noHistory ? Icons.menu_book_outlined : Icons.search_off_rounded, color: _accent, size: 38),
      const SizedBox(height: 12),
      Text(noHistory ? 'No citations yet' : 'No matching references', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      Text(
        noHistory ? 'Ask NOOR AI a question about your PDFs. When the backend returns source pages, they will appear here.' : 'Try searching with another PDF name, question, or page number.',
        textAlign: TextAlign.center,
        style: TextStyle(color: _muted, height: 1.5, fontSize: 12),
      ),
    ]),
  );
}
