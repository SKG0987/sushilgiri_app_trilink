import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAboutApp(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'About App',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'This is the app made as the assignment for the internship selection round. '
          'This app is developed by Sushil Giri.',
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDeveloper(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.code_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'About Developer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _devRow(context, Icons.person_rounded, 'Name', 'Sushil Giri'),
            const SizedBox(height: 8),
            _devRow(context, Icons.work_rounded, 'Role', 'Flutter Developer'),
            const SizedBox(height: 8),
            _devRow(
              context,
              Icons.call_rounded,
              'Phone',
              '9866720830',
              onTap: () => launchUrl(Uri.parse('tel:9866720830')),
            ),
            const SizedBox(height: 8),
            _devRow(
              context,
              Icons.email_rounded,
              'Email',
              'thesushilgiri0987@gmail.com',
              onTap: () => launchUrl(Uri.parse('mailto:thesushilgiri0987@gmail.com')),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _devRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: onTap != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  decoration:
                      onTap != null ? TextDecoration.underline : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.dark_mode_rounded,
                          color: Color(0xFF4F46E5),
                        ),
                        title: Text(
                          'Dark Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeTrackColor: const Color(0xFF4F46E5),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF4F46E5),
                        ),
                        title: Text(
                          'About App',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        onTap: () => _showAboutApp(context),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.code_rounded,
                          color: Color(0xFF4F46E5),
                        ),
                        title: Text(
                          'About Developer',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        onTap: () => _showAboutDeveloper(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}