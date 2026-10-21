import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import '../files/files_screen.dart';
import '../sources/sources_screen.dart';
import '../profile/profile_screen.dart';

import '../../core/services/document_service.dart';

import '../../core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({super.key});

  @override

  State<DashboardScreen> createState() => _DashboardScreenState();

}

class _DashboardScreenState extends State<DashboardScreen> {

  int selectedTab = 0;

  bool isDarkMode = true;

  bool isUploading = false;

  bool isLoadingDocuments = true;

  String? documentsError;

  List<Map<String, dynamic>> documents = [];

  @override

  void initState() {

    super.initState();

    _loadDocuments();

  }

  Future<void> _loadDocuments() async {

    if (mounted) {

      setState(() {

        isLoadingDocuments = true;

        documentsError = null;

      });

    }

    try {

      final result = await ApiService.getDocuments();

      if (!mounted) return;

      setState(() {

        documents = result;

        isLoadingDocuments = false;

      });

    } catch (error) {

      if (!mounted) return;

      setState(() {

        documentsError = error.toString();

        isLoadingDocuments = false;

      });

    }

  }

  Color get bg =>

      isDarkMode ? const Color(0xFF070B14) : const Color(0xFFF4F7FC);

  Color get panel => isDarkMode ? const Color(0xFF0D1422) : Colors.white;

  Color get panelLight =>

      isDarkMode ? const Color(0xFF121D30) : const Color(0xFFEAF1FA);

  Color get primaryText =>

      isDarkMode ? const Color(0xFFF1F6FF) : const Color(0xFF10233F);

  Color get secondaryText =>

      isDarkMode ? const Color(0xFF8391A8) : const Color(0xFF697B95);

  Color get outline =>

      isDarkMode ? const Color(0xFF1C2A40) : const Color(0xFFDCE5F0);

  Color get accent =>

      isDarkMode ? const Color(0xFF52F5E5) : const Color(0xFF008F87);

  Color get blue => const Color(0xFF508BFF);

  Color get violet => const Color(0xFF9B8AFF);

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: bg,

      body: Stack(

        children: [

          Positioned(

            top: -100,

            right: -100,

            child: _AmbientGlow(

              size: 280,

              color: isDarkMode

                  ? const Color(0xFF102B61)

                  : const Color(0xFFBBD5FF),

              opacity: isDarkMode ? 0.22 : 0.35,

            ),

          ),

          Positioned(

            top: 300,

            left: -150,

            child: _AmbientGlow(

              size: 280,

              color: isDarkMode

                  ? const Color(0xFF073D46)

                  : const Color(0xFFBCEFE8),

              opacity: isDarkMode ? 0.2 : 0.35,

            ),

          ),

          SafeArea(

            child: Column(

              children: [

                Expanded(

                  child: CustomScrollView(

                    physics: const BouncingScrollPhysics(),

                    slivers: [

                      SliverPadding(

                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),

                        sliver: SliverList(

                          delegate: SliverChildListDelegate([

                            _buildHeader(),

                            const SizedBox(height: 36),

                            _buildWelcome(),

                            const SizedBox(height: 27),

                            _buildAIStatus(),

                            const SizedBox(height: 25),

                            _buildUploadCard(),

                            const SizedBox(height: 30),

                            _buildStats(),

                            const SizedBox(height: 32),

                            _buildSectionTitle('Explore', 'YOUR AI WORKSPACE'),

                            const SizedBox(height: 16),

                            _buildActions(),

                            const SizedBox(height: 32),

                            _buildSectionTitle(

                              'Recent documents',

                              'YOUR LIBRARY',

                            ),

                            const SizedBox(height: 16),

                            _buildEmptyDocuments(),

                            const SizedBox(height: 22),

                            _buildFooter(),

                          ]),

                        ),

                      ),

                    ],

                  ),

                ),

                _buildNavigation(),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Future<void> _uploadDocument() async {

    if (isUploading) return;

    setState(() => isUploading = true);

    try {

      final result = await DocumentService.pickAndUploadPdf();

      if (!mounted) return;

      if (result == null) return; // The user cancelled file selection.

      await _loadDocuments();

      if (!mounted) return;

      _message('PDF uploaded successfully.');

    } catch (error) {

      if (!mounted) return;

      _message('Upload failed: $error');

    } finally {

      if (mounted) {

        setState(() => isUploading = false);

      }

    }

  }

  Widget _buildHeader() {

    return Row(

      children: [

        Container(

          width: 47,

          height: 47,

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(15),

            gradient: LinearGradient(colors: [accent, blue]),

            boxShadow: [

              BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 22),

            ],

          ),

          child: Icon(Icons.all_inclusive_rounded, color: bg, size: 30),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                'NOOR AI',

                style: TextStyle(

                  color: primaryText,

                  fontSize: 19,

                  fontWeight: FontWeight.w900,

                  letterSpacing: 2.5,

                ),

              ),

              const SizedBox(height: 3),

              Text(

                'INTELLIGENCE, REDEFINED',

                style: TextStyle(

                  color: secondaryText,

                  fontSize: 8,

                  letterSpacing: 1.4,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ],

          ),

        ),

        _iconButton(

          Icons.notifications_none_rounded,

          () => _message('Notifications coming soon.'),

        ),

        const SizedBox(width: 8),

        _iconButton(

          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,

          () {

            setState(() => isDarkMode = !isDarkMode);

          },

        ),

        const SizedBox(width: 8),

        Container(

          width: 42,

          height: 42,

          decoration: BoxDecoration(

            color: panelLight,

            shape: BoxShape.circle,

            border: Border.all(color: outline),

          ),

          child: Center(

            child: Text(

              'R',

              style: TextStyle(

                color: accent,

                fontWeight: FontWeight.w800,

                fontSize: 17,

              ),

            ),

          ),

        ),

      ],

    );

  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {

    return Material(

      color: panel,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(14),

        side: BorderSide(color: outline),

      ),

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(14),

        child: SizedBox(

          width: 40,

          height: 42,

          child: Icon(icon, color: primaryText, size: 20),

        ),

      ),

    );

  }

  Widget _buildWelcome() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            Container(

              width: 7,

              height: 7,

              decoration: BoxDecoration(

                color: accent,

                shape: BoxShape.circle,

                boxShadow: [

                  BoxShadow(

                    color: accent.withValues(alpha: 0.65),

                    blurRadius: 8,

                  ),

                ],

              ),

            ),

            const SizedBox(width: 9),

            Text(

              'YOUR PERSONAL AI SPACE',

              style: TextStyle(

                color: accent,

                fontSize: 10,

                letterSpacing: 2,

                fontWeight: FontWeight.w700,

              ),

            ),

          ],

        ),

        const SizedBox(height: 17),

        Text(

          'Think deeper.',

          style: TextStyle(

            color: primaryText,

            fontSize: 36,

            height: 1.15,

            fontWeight: FontWeight.w800,

            letterSpacing: -1.3,

          ),

        ),

        Text(

          'Know more.',

          style: TextStyle(

            color: accent,

            fontSize: 36,

            height: 1.1,

            fontWeight: FontWeight.w800,

            letterSpacing: -1.3,

          ),

        ),

        const SizedBox(height: 14),

        Text(

          'Turn your documents into knowledge.\nAsk questions. Discover the answers.',

          style: TextStyle(color: secondaryText, fontSize: 13, height: 1.8),

        ),

      ],

    );

  }

  Widget _buildAIStatus() {

    final statusBg = isDarkMode

        ? const Color(0xFF0D2027)

        : const Color(0xFFE5F8F5);

    final statusBorder = isDarkMode

        ? const Color(0xFF17443F)

        : const Color(0xFFB9E8DF);

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

      decoration: BoxDecoration(

        color: statusBg,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: statusBorder),

      ),

      child: Row(

        children: [

          Icon(Icons.auto_awesome, color: accent, size: 18),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              'Your intelligent workspace',

              style: TextStyle(

                color: primaryText,

                fontSize: 12,

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(

              color: accent.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(7),

            ),

            child: Text(

              'AI POWERED',

              style: TextStyle(

                color: accent,

                fontSize: 8,

                fontWeight: FontWeight.w800,

                letterSpacing: 1,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildUploadCard() {

    final uploadGradient = isDarkMode

        ? const [Color(0xFF142B43), Color(0xFF0D1829), Color(0xFF101729)]

        : const [Color(0xFFE5F3FF), Color(0xFFF9FCFF), Color(0xFFE7F8F5)];

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: uploadGradient,

        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(

          color: isDarkMode ? const Color(0xFF29445F) : const Color(0xFFD0E2F3),

        ),

        boxShadow: [

          BoxShadow(

            color: blue.withValues(alpha: isDarkMode ? 0.07 : 0.09),

            blurRadius: 28,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                width: 55,

                height: 55,

                decoration: BoxDecoration(

                  color: accent.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(17),

                  border: Border.all(color: accent.withValues(alpha: 0.22)),

                ),

                child: Icon(

                  Icons.document_scanner_outlined,

                  color: accent,

                  size: 27,

                ),

              ),

              const Spacer(),

              Icon(

                Icons.auto_awesome,

                color: isDarkMode

                    ? const Color(0xFF426AAB)

                    : const Color(0xFF86A9D8),

                size: 22,

              ),

            ],

          ),

          const SizedBox(height: 24),

          Text(

            'Bring your documents\nto life.',

            style: TextStyle(

              color: primaryText,

              fontSize: 23,

              height: 1.35,

              fontWeight: FontWeight.w800,

              letterSpacing: -0.5,

            ),

          ),

          const SizedBox(height: 10),

          Text(

            'Upload a PDF and let AI help you understand what matters.',

            style: TextStyle(color: secondaryText, fontSize: 12, height: 1.8),

          ),

          const SizedBox(height: 23),

          SizedBox(

            width: double.infinity,

            child: DecoratedBox(

              decoration: BoxDecoration(

                gradient: LinearGradient(

                  colors: [

                    accent,

                    isDarkMode

                        ? const Color(0xFF7DEBDD)

                        : const Color(0xFF68D8CA),

                  ],

                ),

                borderRadius: BorderRadius.circular(14),

                boxShadow: [

                  BoxShadow(

                    color: accent.withValues(alpha: 0.17),

                    blurRadius: 17,

                  ),

                ],

              ),

              child: ElevatedButton.icon(

                onPressed: isUploading ? null : _uploadDocument,

                icon: Icon(

                  Icons.add_rounded,

                  color: isDarkMode ? bg : Colors.white,

                ),

                label: Text(

                  isUploading ? 'Uploading...' : 'Upload a document',

                  style: TextStyle(

                    color: isDarkMode ? bg : Colors.white,

                    fontWeight: FontWeight.w800,

                    fontSize: 14,

                  ),

                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.transparent,

                  foregroundColor: primaryText,

                  shadowColor: Colors.transparent,

                  minimumSize: const Size.fromHeight(52),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(14),

                  ),

                ),

              ),

            ),

          ),

          const SizedBox(height: 12),

          Center(

            child: Text(

              'PDF FORMAT  •  AI DOCUMENT ANALYSIS',

              style: TextStyle(

                color: secondaryText,

                fontSize: 8,

                letterSpacing: 1.2,

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildStats() {

    return Row(

      children: [

        Expanded(

          child: _statCard(

            icon: Icons.description_outlined,

            value: documents.length.toString().padLeft(2, '0'),

            label: 'Documents',

            color: accent,

          ),

        ),

        const SizedBox(width: 11),

        Expanded(

          child: _statCard(

            icon: Icons.forum_outlined,

            value: '00',

            label: 'Conversations',

            color: blue,

          ),

        ),

        const SizedBox(width: 11),

        Expanded(

          child: _statCard(

            icon: Icons.psychology_outlined,

            value: 'AI',

            label: 'Assistant',

            color: violet,

          ),

        ),

      ],

    );

  }

  Widget _statCard({

    required IconData icon,

    required String value,

    required String label,

    required Color color,

  }) {

    return Container(

      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),

      decoration: BoxDecoration(

        color: panel,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: outline),

      ),

      child: Column(

        children: [

          Icon(icon, color: color, size: 21),

          const SizedBox(height: 13),

          Text(

            value,

            style: TextStyle(

              color: primaryText,

              fontSize: 21,

              fontWeight: FontWeight.w800,

            ),

          ),

          const SizedBox(height: 5),

          Text(

            label,

            textAlign: TextAlign.center,

            maxLines: 2,

            style: TextStyle(color: secondaryText, fontSize: 9),

          ),

        ],

      ),

    );

  }

  Widget _buildSectionTitle(String title, String subtitle) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          subtitle,

          style: TextStyle(

            color: accent,

            fontSize: 9,

            fontWeight: FontWeight.w700,

            letterSpacing: 2,

          ),

        ),

        const SizedBox(height: 8),

        Text(

          title,

          style: TextStyle(

            color: primaryText,

            fontSize: 21,

            fontWeight: FontWeight.w800,

            letterSpacing: -0.4,

          ),

        ),

      ],

    );

  }

  Widget _buildActions() {

    return Column(

      children: [

        Row(

          children: [

            Expanded(

              child: _actionCard(

                icon: Icons.forum_rounded,

                title: 'Ask your AI',

                subtitle: 'Chat with your PDFs',

                color: accent,

               onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(
                        isDarkMode: isDarkMode,
                        onThemeChanged: (value) {
                          if (mounted) setState(() => isDarkMode = value);
                        },
                      ),
                    ),
                  );
                },

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: _actionCard(

                icon: Icons.folder_open_rounded,

                title: 'My library',

                subtitle: '${documents.length} saved files',

                color: blue,

                onTap: _loadDocuments,

              ),

            ),

          ],

        ),

        const SizedBox(height: 12),

        Row(

          children: [

            Expanded(

              child: _actionCard(

                icon: Icons.travel_explore_rounded,

                title: 'Explore sources',

                subtitle: 'Trace AI answers',

                color: violet,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => SourcesScreen(isDarkMode: isDarkMode),
                    ),
                  );
                },

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: _actionCard(

                icon: Icons.translate_rounded,

                title: 'Languages',

                subtitle: 'Arabic & English',

                color: const Color(0xFFFFB84D),

                onTap: () => _message('Language settings are coming next.'),

              ),

            ),

          ],

        ),

      ],

    );

  }

  Widget _actionCard({

    required IconData icon,

    required String title,

    required String subtitle,

    required Color color,

    required VoidCallback onTap,

  }) {

    return Material(

      color: panel,

      borderRadius: BorderRadius.circular(19),

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(19),

        child: Container(

          constraints: const BoxConstraints(minHeight: 145),

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(19),

            border: Border.all(color: outline),

          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(

                width: 43,

                height: 43,

                decoration: BoxDecoration(

                  color: color.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(color: color.withValues(alpha: 0.18)),

                ),

                child: Icon(icon, color: color, size: 22),

              ),

              const SizedBox(height: 17),

              Text(

                title,

                style: TextStyle(

                  color: primaryText,

                  fontSize: 13,

                  fontWeight: FontWeight.w700,

                ),

              ),

              const SizedBox(height: 6),

              Text(

                subtitle,

                style: TextStyle(

                  color: secondaryText,

                  fontSize: 10,

                  height: 1.5,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _buildEmptyDocuments() {

    if (isLoadingDocuments) {

      return Container(

        width: double.infinity,

        padding: const EdgeInsets.all(28),

        decoration: BoxDecoration(

          color: panel,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: outline),

        ),

        child: Center(

          child: Column(

            children: [

              CircularProgressIndicator(color: accent),

              const SizedBox(height: 14),

              Text(

                'Loading your documents...',

                style: TextStyle(color: secondaryText),

              ),

            ],

          ),

        ),

      );

    }

    if (documentsError != null) {

      return Container(

        width: double.infinity,

        padding: const EdgeInsets.all(22),

        decoration: BoxDecoration(

          color: panel,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: outline),

        ),

        child: Column(

          children: [

            Icon(Icons.cloud_off_rounded, color: secondaryText, size: 34),

            const SizedBox(height: 12),

            Text(

              'Could not load documents',

              style: TextStyle(color: primaryText, fontWeight: FontWeight.w700),

            ),

            const SizedBox(height: 8),

            Text(

              documentsError!,

              textAlign: TextAlign.center,

              style: TextStyle(color: secondaryText, fontSize: 11),

            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(

              onPressed: _loadDocuments,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try again'),

            ),

          ],

        ),

      );

    }

    if (documents.isEmpty) {

      return Container(

        width: double.infinity,

        padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 20),

        decoration: BoxDecoration(

          color: panel,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: outline),

        ),

        child: Column(

          children: [

            Container(

              width: 62,

              height: 62,

              decoration: BoxDecoration(

                color: panelLight,

                borderRadius: BorderRadius.circular(20),

              ),

              child: Icon(Icons.folder_copy_outlined, color: accent, size: 30),

            ),

            const SizedBox(height: 17),

            Text(

              'Your workspace is waiting',

              style: TextStyle(

                color: primaryText,

                fontWeight: FontWeight.w700,

                fontSize: 15,

              ),

            ),

            const SizedBox(height: 8),

            Text(

              'Your uploaded documents will appear here.\nStart by adding your first PDF.',

              textAlign: TextAlign.center,

              style: TextStyle(color: secondaryText, fontSize: 11, height: 1.8),

            ),

            const SizedBox(height: 17),

            OutlinedButton(

              onPressed: isUploading ? null : _uploadDocument,

              style: OutlinedButton.styleFrom(

                foregroundColor: accent,

                side: BorderSide(color: outline),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(12),

                ),

              ),

              child: const Text('Add first document'),

            ),

          ],

        ),

      );

    }

    return Column(

      children: [

        Row(

          children: [

            Expanded(

              child: Text(

                '${documents.length} document${documents.length == 1 ? '' : 's'} in your library',

                style: TextStyle(color: secondaryText, fontSize: 11),

              ),

            ),

            IconButton(

              tooltip: 'Refresh documents',

              onPressed: _loadDocuments,

              icon: Icon(Icons.refresh_rounded, color: accent),

            ),

          ],

        ),

        ...documents.map((doc) {

          final name = (doc['document'] ?? 'Unnamed document').toString();

          final chunks = doc['chunks']?.toString() ?? '—';

          return Container(

            margin: const EdgeInsets.only(bottom: 10),

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

            decoration: BoxDecoration(

              color: panel,

              borderRadius: BorderRadius.circular(17),

              border: Border.all(color: outline),

            ),

            child: Row(

              children: [

                Container(

                  width: 44,

                  height: 44,

                  decoration: BoxDecoration(

                    color: accent.withValues(alpha: 0.1),

                    borderRadius: BorderRadius.circular(13),

                  ),

                  child: Icon(Icons.picture_as_pdf_rounded, color: accent),

                ),

                const SizedBox(width: 12),

                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        name,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(

                          color: primaryText,

                          fontSize: 12,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

                      const SizedBox(height: 5),

                      Text(

                        '$chunks text chunks indexed',

                        style: TextStyle(color: secondaryText, fontSize: 10),

                      ),

                    ],

                  ),

                ),

                IconButton(

                  tooltip: 'Delete document',

                  onPressed: () => _confirmDeleteDocument(name),

                  icon: Icon(

                    Icons.delete_outline_rounded,

                    color: isDarkMode

                        ? const Color(0xFFFF7D8A)

                        : const Color(0xFFC43D52),

                  ),

                ),

              ],

            ),

          );

        }),

      ],

    );

  }

  Future<void> _confirmDeleteDocument(String filename) async {

    final confirmed = await showDialog<bool>(

      context: context,

      builder: (dialogContext) => AlertDialog(

        backgroundColor: panel,

        title: Text('Delete document?', style: TextStyle(color: primaryText)),

        content: Text(

          'Remove "$filename" from your library?',

          style: TextStyle(color: secondaryText),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(dialogContext, false),

            child: const Text('Cancel'),

          ),

          TextButton(

            onPressed: () => Navigator.pop(dialogContext, true),

            child: const Text('Delete'),

          ),

        ],

      ),

    );

    if (confirmed != true) return;

    try {

      await ApiService.deleteDocument(filename);

      if (!mounted) return;

      await _loadDocuments();

      if (mounted) _message('Document deleted.');

    } catch (error) {

      if (mounted) _message('Could not delete document: $error');

    }

  }

  Widget _buildFooter() {

    return Row(

      children: [

        Icon(Icons.shield_outlined, color: accent, size: 19),

        const SizedBox(width: 10),

        Expanded(

          child: Text(

            'Your documents. Your knowledge. Your space.',

            style: TextStyle(color: secondaryText, fontSize: 10),

          ),

        ),

        Text(

          'NOOR AI',

          style: TextStyle(

            color: accent.withValues(alpha: 0.9),

            fontWeight: FontWeight.w800,

            fontSize: 10,

            letterSpacing: 1.2,

          ),

        ),

      ],

    );

  }

  Widget _buildNavigation() {

    const items = [

      (Icons.grid_view_rounded, 'Home'),

      (Icons.folder_outlined, 'Files'),

      (Icons.forum_outlined, 'Chat'),

      (Icons.travel_explore_outlined, 'Sources'),

      (Icons.person_outline_rounded, 'Profile'),

    ];

    return Container(

      decoration: BoxDecoration(

        color: panel,

        border: Border(top: BorderSide(color: outline)),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.03),

            blurRadius: 12,

          ),

        ],

      ),

      padding: EdgeInsets.fromLTRB(

        7,

        12,

        7,

        MediaQuery.of(context).padding.bottom + 10,

      ),

      child: Row(

        children: List.generate(items.length, (index) {

          final item = items[index];

          final active = selectedTab == index;

          return Expanded(

            child: GestureDetector(

              onTap: () async {
                if (index == 0) {
                  if (selectedTab != 0) setState(() => selectedTab = 0);
                  return;
                }

                // Keep the selected item in sync while a page is open, then
                // restore Home when that page is popped.
                setState(() => selectedTab = index);
                try {
                  if (index == 1) {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => FilesScreen(isDarkMode: isDarkMode),
                      ),
                    );
                  } else if (index == 2) {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(
                          isDarkMode: isDarkMode,
                          onThemeChanged: (value) {
                            if (mounted) setState(() => isDarkMode = value);
                          },
                        ),
                      ),
                    );
                  } else if (index == 3) {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SourcesScreen(isDarkMode: isDarkMode),
                      ),
                    );
                  } else if (index == 4) {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(
                          isDarkMode: isDarkMode,
                          onThemeChanged: (value) {
                            if (mounted) setState(() => isDarkMode = value);
                          },
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => selectedTab = 0);
                }
              },

              child: AnimatedContainer(

                duration: const Duration(milliseconds: 200),

                padding: const EdgeInsets.symmetric(vertical: 8),

                decoration: BoxDecoration(

                  color: active

                      ? accent.withValues(alpha: 0.1)

                      : Colors.transparent,

                  borderRadius: BorderRadius.circular(14),

                ),

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Icon(

                      item.$1,

                      size: 21,

                      color: active ? accent : secondaryText,

                    ),

                    const SizedBox(height: 6),

                    Text(

                      item.$2,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(

                        fontSize: 9,

                        color: active ? accent : secondaryText,

                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,

                      ),

                    ),

                  ],

                ),

              ),

            ),

          );

        }),

      ),

    );

  }

  void _message(String message) {

    ScaffoldMessenger.of(context)

      ..hideCurrentSnackBar()

      ..showSnackBar(

        SnackBar(

          content: Text(message),

          behavior: SnackBarBehavior.floating,

          backgroundColor: isDarkMode

              ? const Color(0xFF182A40)

              : const Color(0xFF203754),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(14),

          ),

        ),

      );

  }

}

class _AmbientGlow extends StatelessWidget {

  final double size;

  final Color color;

  final double opacity;

  const _AmbientGlow({

    required this.size,

    required this.color,

    required this.opacity,

  });

  @override

  Widget build(BuildContext context) {

    return IgnorePointer(

      child: Container(

        width: size,

        height: size,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          boxShadow: [

            BoxShadow(

              color: color.withValues(alpha: opacity),

              blurRadius: size * 0.7,

              spreadRadius: size * 0.12,

            ),

          ],

        ),

      ),

    );

  }

}