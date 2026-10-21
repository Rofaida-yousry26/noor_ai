import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _language = 'English';

  static const Color _cyan = Color(0xFF52F5E5);
  static const Color _blue = Color(0xFF638BFF);

  bool get dark => widget.isDarkMode;
  Color get background => dark ? const Color(0xFF070B14) : const Color(0xFFF4F7FC);
  Color get card => dark ? const Color(0xFF0D1422) : Colors.white;
  Color get text => dark ? const Color(0xFFF1F6FF) : const Color(0xFF10233F);
  Color get muted => dark ? const Color(0xFF8391A8) : const Color(0xFF697B95);
  Color get border => dark ? const Color(0xFF1C2A40) : const Color(0xFFDCE5F0);
  Color get accent => dark ? _cyan : const Color(0xFF008F87);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _profileCard(),
            const SizedBox(height: 26),
            _sectionTitle('PREFERENCES'),
            const SizedBox(height: 12),
            _settingsCard([
              _SettingRow(
                icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                title: 'Appearance',
                subtitle: dark ? 'Dark mode' : 'Light mode',
                trailing: Switch.adaptive(
                  value: dark,
                  activeColor: accent,
                  onChanged: (value) => widget.onThemeChanged?.call(value),
                ),
                onTap: () => widget.onThemeChanged?.call(!dark),
              ),
              _divider(),
              _SettingRow(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _language,
                trailing: Icon(Icons.chevron_right_rounded, color: muted),
                onTap: _chooseLanguage,
              ),
              _divider(),
              _SettingRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Manage app notifications in device settings',
                trailing: Icon(Icons.info_outline_rounded, color: muted),
                onTap: () => _showInfo('Notifications', 'Notification preferences can be connected here when notifications are implemented.'),
              ),
            ]),
            const SizedBox(height: 26),
            _sectionTitle('APP'),
            const SizedBox(height: 12),
            _settingsCard([
              _SettingRow(
                icon: Icons.auto_awesome_rounded,
                title: 'About NOOR AI',
                subtitle: 'Your document assistant',
                trailing: Icon(Icons.chevron_right_rounded, color: muted),
                onTap: _showAbout,
              ),
              _divider(),
              _SettingRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & data',
                subtitle: 'Learn how your documents are handled',
                trailing: Icon(Icons.chevron_right_rounded, color: muted),
                onTap: () => _showInfo('Privacy & data', 'Documents are sent to the configured NOOR AI backend for indexing and question answering. Add your full privacy policy here before publishing the app.'),
              ),
              _divider(),
              _SettingRow(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                subtitle: 'Get help using NOOR AI',
                trailing: Icon(Icons.chevron_right_rounded, color: muted),
                onTap: () => _showInfo('Help & support', 'Upload a PDF from Files, then open Chat to ask questions about your documents. Answers may take a little time while the model processes your question.'),
              ),
            ]),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [_cyan, _blue]),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF07111E)),
                  ),
                  const SizedBox(height: 10),
                  Text('NOOR AI', style: TextStyle(color: text, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text('Document Assistant • Version 1.0.0', style: TextStyle(color: muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF14243A), Color(0xFF0D1422)]
              : const [Color(0xFFE0F8F6), Color(0xFFFFFFFF)],
        ),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [_cyan, _blue]),
              boxShadow: [BoxShadow(color: _cyan.withValues(alpha: .18), blurRadius: 24, spreadRadius: 2)],
            ),
            child: const Icon(Icons.person_rounded, size: 42, color: Color(0xFF07111E)),
          ),
          const SizedBox(height: 14),
          Text('Welcome to NOOR AI', textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Your personal AI-powered document assistant', textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: accent.withValues(alpha: .28)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_user_outlined, size: 15, color: accent),
              const SizedBox(width: 7),
              Text('Local profile', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.6),
      );

  Widget _settingsCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(height: 1, thickness: 1, indent: 58, endIndent: 16, color: border);

  void _chooseLanguage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Choose language', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('This selection is currently a UI preference; app-wide translation can be connected later.', style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
            const SizedBox(height: 12),
            for (final language in ['English', 'العربية'])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(language, style: TextStyle(color: text, fontWeight: FontWeight.w600)),
                trailing: _language == language ? Icon(Icons.check_circle_rounded, color: accent) : Icon(Icons.circle_outlined, color: muted),
                onTap: () {
                  setState(() => _language = language);
                  Navigator.pop(sheetContext);
                },
              ),
          ]),
        ),
      ),
    );
  }

  void _showAbout() => _showInfo(
        'About NOOR AI',
        'NOOR AI helps you upload PDF documents, index their content, and ask questions using an AI assistant. Answers can include document and page references when provided by the backend.',
      );

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: card,
        title: Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w800)),
        content: Text(message, style: TextStyle(color: muted, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Got it', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors are supplied by the parent through the nearest theme, with a clean fallback.
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      minVerticalPadding: 12,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 21),
      ),
      title: Text(title, style: TextStyle(color: theme.textTheme.titleMedium?.color, fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11, height: 1.35)),
      ),
      trailing: trailing,
    );
  }
}
