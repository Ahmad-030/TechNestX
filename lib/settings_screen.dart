import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:technestx/task_provider.dart';

import 'app_theme.dart';
import 'webview_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
      final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
      final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
      final subColor = isDark ? AppTheme.darkSubText : AppTheme.lightSubText;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          title: Text('Settings', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: textColor)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // App identity
            Center(
              child: Column(
                children: [
                  const Text('🪺', style: TextStyle(fontSize: 60)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 8),
                  Text('TaskNestX', style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 22)),
                  Text('v1.0.0 • ZaraGamesHub', style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 12)),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 30),

            // Theme section
            _SectionTitle(text: 'Appearance', color: subColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _ThemeTile(
                    label: 'Dark Mode',
                    emoji: '🌙',
                    selected: isDark,
                    onTap: () => provider.setTheme('dark'),
                    textColor: textColor,
                    subColor: subColor,
                  ),
                  Divider(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  _ThemeTile(
                    label: 'Light Mode',
                    emoji: '☀️',
                    selected: !isDark,
                    onTap: () => provider.setTheme('light'),
                    textColor: textColor,
                    subColor: subColor,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Info section
            _SectionTitle(text: 'Information', color: subColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _SettingsTile(
                    emoji: '🔒',
                    label: 'Privacy Policy',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WebViewScreen(title: 'Privacy Policy', assetPath: 'assets/html/privacy_policy.html'))),
                  ),
                  Divider(height: 1, color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  _SettingsTile(
                    emoji: 'ℹ️',
                    label: 'About TaskNestX',
                    textColor: textColor,
                    subColor: subColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WebViewScreen(title: 'About', assetPath: 'assets/html/about.html'))),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Danger zone
            _SectionTitle(text: 'Data', color: subColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
              child: _SettingsTile(
                emoji: '🗑️',
                label: 'Reset All Data',
                textColor: const Color(0xFFEF476F),
                subColor: subColor,
                onTap: () => _showResetDialog(context, provider),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),

            Center(
              child: Text('Made with ❤️ by ZaraGamesHub\nzarakhangpc@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subColor, fontFamily: 'Outfit', fontSize: 12, height: 1.6)),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  void _showResetDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset All Data', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: const Text('This will delete all tasks, points, badges, and streaks. This cannot be undone.', style: TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await provider.resetData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('All data has been reset.', style: TextStyle(fontFamily: 'Outfit')),
                  backgroundColor: Color(0xFFEF476F),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: const Text('Reset', style: TextStyle(color: Color(0xFFEF476F), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: TextStyle(color: color, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2));
}

class _SettingsTile extends StatelessWidget {
  final String emoji, label;
  final Color textColor, subColor;
  final VoidCallback onTap;

  const _SettingsTile({required this.emoji, required this.label, required this.textColor, required this.subColor, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Text(emoji, style: const TextStyle(fontSize: 22)),
    title: Text(label, style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
    trailing: Icon(Icons.arrow_forward_ios_rounded, color: subColor, size: 16),
  );
}

class _ThemeTile extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final Color textColor, subColor;
  final VoidCallback onTap;

  const _ThemeTile({required this.emoji, required this.label, required this.selected, required this.textColor, required this.subColor, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Text(emoji, style: const TextStyle(fontSize: 22)),
    title: Text(label, style: TextStyle(color: textColor, fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
    trailing: selected
        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF6B35))
        : Icon(Icons.radio_button_unchecked_rounded, color: subColor),
  );
}