import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/services/api_service.dart';

class FilesScreen extends StatefulWidget {
  final bool isDarkMode;

  const FilesScreen({super.key, this.isDarkMode = true});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  String? _error;
  String _query = '';
  String? _deletingName;

  bool get _dark => widget.isDarkMode;
  Color get _background => _dark ? const Color(0xFF070B14) : const Color(0xFFF4F7FC);
  Color get _panel => _dark ? const Color(0xFF0D1422) : Colors.white;
  Color get _panelLight => _dark ? const Color(0xFF121D30) : const Color(0xFFEAF1FA);
  Color get _primaryText => _dark ? const Color(0xFFF1F6FF) : const Color(0xFF10233F);
  Color get _secondaryText => _dark ? const Color(0xFF8391A8) : const Color(0xFF697B95);
  Color get _outline => _dark ? const Color(0xFF1C2A40) : const Color(0xFFDCE5F0);
  Color get _accent => _dark ? const Color(0xFF52F5E5) : const Color(0xFF008F87);
  Color get _blue => const Color(0xFF508BFF);

  List<Map<String, dynamic>> get _filteredDocuments {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _documents;
    return _documents.where((doc) {
      final name = (doc['document'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _searchController.addListener(() {
      if (mounted) setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final docs = await ApiService.getDocuments();
      if (!mounted) return;
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(String filename) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: Text('Delete document?', style: TextStyle(color: _primaryText)),
        content: Text(
          'Remove "$filename" from your library? This action cannot be undone.',
          style: TextStyle(color: _secondaryText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF7D8A))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _deletingName = filename);
    try {
      await ApiService.deleteDocument(filename);
      if (!mounted) return;
      setState(() {
        _documents.removeWhere((doc) => (doc['document'] ?? '').toString() == filename);
        _deletingName = null;
      });
      _showMessage('Document deleted.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingName = null);
      _showMessage('Could not delete document: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _dark ? const Color(0xFF182A40) : const Color(0xFF203754),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final visibleDocs = _filteredDocuments;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _primaryText,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Files', style: TextStyle(color: _primaryText, fontWeight: FontWeight.w800)),
            Text('YOUR DOCUMENT LIBRARY', style: TextStyle(color: _secondaryText, fontSize: 9, letterSpacing: 1.4)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh files',
            onPressed: _isLoading ? null : _loadDocuments,
            icon: Icon(Icons.refresh_rounded, color: _accent),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
          onRefresh: _loadDocuments,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _buildHero(),
              const SizedBox(height: 22),
              TextField(
                controller: _searchController,
                style: TextStyle(color: _primaryText),
                decoration: InputDecoration(
                  hintText: 'Search your documents...',
                  hintStyle: TextStyle(color: _secondaryText),
                  prefixIcon: Icon(Icons.search_rounded, color: _secondaryText),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _searchController.clear,
                          icon: Icon(Icons.close_rounded, color: _secondaryText),
                        ),
                  filled: true,
                  fillColor: _panel,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _outline)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _outline)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _accent, width: 1.3)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text('All documents', style: TextStyle(color: _primaryText, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(color: _accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)),
                    child: Text('${_documents.length} FILES', style: TextStyle(color: _accent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: _accent)),
                )
              else if (_error != null)
                _buildState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load your files',
                  subtitle: _error!,
                  actionLabel: 'Try again',
                  onAction: _loadDocuments,
                )
              else if (_documents.isEmpty)
                _buildState(
                  icon: Icons.folder_open_rounded,
                  title: 'Your library is empty',
                  subtitle: 'Upload a PDF from the dashboard and it will appear here.',
                )
              else if (visibleDocs.isEmpty)
                _buildState(
                  icon: Icons.search_off_rounded,
                  title: 'No matching files',
                  subtitle: 'Try a different file name.',
                  actionLabel: 'Clear search',
                  onAction: _searchController.clear,
                )
              else ...visibleDocs.map(_buildDocumentCard),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: _secondaryText, size: 16),
                  const SizedBox(width: 7),
                  Text('Your documents. Your knowledge.', style: TextStyle(color: _secondaryText, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _dark
              ? const [Color(0xFF142B43), Color(0xFF0D1829), Color(0xFF101729)]
              : const [Color(0xFFE5F3FF), Color(0xFFF9FCFF), Color(0xFFE7F8F5)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _outline),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: _accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.folder_copy_rounded, color: _accent, size: 27),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your knowledge base', style: TextStyle(color: _primaryText, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text('Browse, search and manage your uploaded PDFs.', style: TextStyle(color: _secondaryText, fontSize: 11, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final name = (doc['document'] ?? 'Unnamed document').toString();
    final chunks = doc['chunks']?.toString() ?? '—';
    final deleting = _deletingName == name;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _outline),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: deleting ? null : () => _openDocument(name),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
          Container(
            width: 48,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFFF667A).withValues(alpha: .10), borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFFF7D8A), size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _primaryText, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: _accent, size: 13),
                    const SizedBox(width: 5),
                    Text('$chunks text chunks indexed', style: TextStyle(color: _secondaryText, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          deleting
              ? SizedBox(width: 38, height: 38, child: Padding(padding: const EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: _accent)))
              : IconButton(
                  tooltip: 'Delete document',
                  onPressed: () => _deleteDocument(name),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF7D8A)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(String filename) async {
    // The backend serves the original PDF from this endpoint.
    const baseUrl = 'http://10.0.2.2:8000';
    final encodedName = Uri.encodeComponent(filename);
    final pdfUrl = '$baseUrl/file/$encodedName';

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PdfDocumentScreen(
          filename: filename,
          pdfUrl: pdfUrl,
          darkMode: _dark,
          accent: _accent,
          background: _background,
          panel: _panel,
          primaryText: _primaryText,
          secondaryText: _secondaryText,
        ),
      ),
    );
  }

  Widget _buildState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _outline)),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: _panelLight, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: _blue, size: 29),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: _primaryText, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: _secondaryText, fontSize: 11, height: 1.6)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}


class _PdfDocumentScreen extends StatefulWidget {
  final String filename;
  final String pdfUrl;
  final bool darkMode;
  final Color accent;
  final Color background;
  final Color panel;
  final Color primaryText;
  final Color secondaryText;

  const _PdfDocumentScreen({
    required this.filename,
    required this.pdfUrl,
    required this.darkMode,
    required this.accent,
    required this.background,
    required this.panel,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  State<_PdfDocumentScreen> createState() => _PdfDocumentScreenState();
}

class _PdfDocumentScreenState extends State<_PdfDocumentScreen> {
  bool _loading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.background,
      appBar: AppBar(
        backgroundColor: widget.background,
        foregroundColor: widget.primaryText,
        elevation: 0,
        title: Text(
          widget.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload PDF',
            onPressed: () => setState(() {
              _loading = true;
              _error = null;
            }),
            icon: Icon(Icons.refresh_rounded, color: widget.accent),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error == null)
            SfPdfViewer.network(
              widget.pdfUrl,
              key: ValueKey('${widget.pdfUrl}-$_loading'),
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
              onDocumentLoaded: (_) {
                if (mounted) setState(() => _loading = false);
              },
              onDocumentLoadFailed: (details) {
                if (!mounted) return;
                setState(() {
                  _loading = false;
                  _error = details.description;
                });
              },
            ),
          if (_loading && _error == null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: widget.accent),
                    const SizedBox(height: 12),
                    Text('Opening PDF...', style: TextStyle(color: widget.primaryText)),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 48, color: widget.secondaryText),
                    const SizedBox(height: 14),
                    Text(
                      'Could not open this PDF',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: widget.primaryText, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_error\n\nMake sure the FastAPI server is running and the PDF still exists in the uploads folder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: widget.secondaryText, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => setState(() {
                        _loading = true;
                        _error = null;
                      }),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
