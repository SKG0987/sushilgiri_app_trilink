import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'api_screen.dart';
import 'todo_screen.dart';
import '../services/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    final name = auth.currentUser?.name ?? '';
                    final firstName = name.isNotEmpty ? name.split(' ').first : '';
                    final displayName = firstName.isNotEmpty ? firstName : 'User';
                    final pic = auth.currentUser?.profilePic;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi $displayName!',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Flutter Internship\nAssignment',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: pic != null
                              ? (pic.startsWith('data:')
                                  ? MemoryImage(base64Decode(pic.split(',').last))
                                  : NetworkImage(pic) as ImageProvider)
                              : null,
                          child: pic == null
                              ? Icon(Icons.person_rounded, size: 36, color: Colors.white.withOpacity(0.7))
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any task to navigate to it',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              _TaskButton(
                taskNumber: 1,
                title: 'Profile Page Design',
                subtitle: 'Login required to view profile',
                icon: Icons.person_rounded,
                color: const Color(0xFF0EA5E9),
                isRequired: true,
                onTap: () => onNavigateToTab?.call(4),
              ),
              const SizedBox(height: 12),
              _TaskButton(
                taskNumber: 2,
                title: 'Login Page',
                subtitle: 'Login or create a new account',
                icon: Icons.lock_rounded,
                color: const Color(0xFF10B981),
                isRequired: true,
                onTap: () => onNavigateToTab?.call(4),
              ),
              const SizedBox(height: 12),
              _TaskButton(
                taskNumber: 3,
                title: 'API Integration',
                subtitle: 'JSONPlaceholder posts with ListView',
                icon: Icons.cloud_download_rounded,
                color: const Color(0xFFF59E0B),
                isRequired: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _TaskButton(
                taskNumber: 4,
                title: 'To-Do CRUD App',
                subtitle: 'Full CRUD with Supabase backend',
                icon: Icons.checklist_rounded,
                color: const Color(0xFFEF4444),
                isRequired: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodoScreen()),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskButton extends StatelessWidget {
  final int taskNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isRequired;
  final VoidCallback onTap;

  const _TaskButton({
    required this.taskNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isRequired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Task $taskNumber',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isRequired
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isRequired ? 'Required' : 'Bonus',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isRequired
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFCA8A04),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
