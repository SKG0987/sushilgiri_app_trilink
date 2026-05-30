import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/auth_provider.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 3) {
      final auth = context.read<AuthProvider>();
      if (!auth.isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLoginAlert(context);
        });
      }
    }
  }

  void _showLoginAlert(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('First Login to see your profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onNavigateToTab: _onItemTapped),
          MapScreen(selectedTabIndex: _selectedIndex),
          const SettingsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(context),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final pic = user?.profilePic;

    if (pic != null && pic.isNotEmpty) {
      try {
        final bytes = base64Decode(pic.split(',').last);
        return ClipOval(
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person_rounded),
            ),
          ),
        );
      } catch (_) {
        return const Icon(Icons.person_rounded);
      }
    }
    return const Icon(Icons.person_rounded);
  }
}