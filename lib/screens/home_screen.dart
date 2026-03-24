import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Start on Search Tab (index 1) as requested
  int _selectedIndex = 1;

  final List<Widget> _tabs = [
    const HomeTab(),
    const SearchTab(),
    const Center(child: Text('Saved (Coming Soon)')),
    const Center(child: Text('Profile (Coming Soon)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      extendBody: true,
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ─────────────────────────────────────────
  //  BOTTOM NAV — Glassmorphism
  // ─────────────────────────────────────────
  Widget _bottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: AppTheme.shadowLg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(Icons.home_rounded, 'Home', 0),
                _navItem(Icons.explore_rounded, 'Explore', 1),
                _navItem(Icons.favorite_rounded, 'Saved', 2),
                _navItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx) {
    final selected = _selectedIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.diagonal3Values(
                  selected ? 1.1 : 1.0, selected ? 1.1 : 1.0, 1.0),
              child: Icon(
                icon,
                size: 23,
                color: selected ? AppTheme.accent : AppTheme.midGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.accent : AppTheme.midGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
