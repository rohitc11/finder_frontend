import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late final List<AnimationController> _rippleControllers;

  @override
  void initState() {
    super.initState();
    _rippleControllers = List.generate(
      4,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _rippleControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _rippleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int idx) {
    if (_selectedIndex == idx) return;
    HapticFeedback.selectionClick();
    _rippleControllers[_selectedIndex].reverse();
    setState(() => _selectedIndex = idx);
    _rippleControllers[idx].forward(from: 0);
  }

  final List<Widget> _tabs = const [
    HomeTab(),
    SearchTab(),
    Center(child: Text('Saved')),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ─────────────────────────────────────────
  //  BOTTOM NAV — Full-width frosted bar
  // ─────────────────────────────────────────
  Widget _bottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.snow.withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(
                color: AppTheme.silver.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _navItem(0, Icons.home_rounded,           Icons.home_outlined,           'Home'),
                  _navItem(1, Icons.search_rounded,         Icons.search_rounded,          'Explore'),
                  _navItem(2, Icons.bookmark_rounded,       Icons.bookmark_border_rounded, 'Saved'),
                  _navItem(3, Icons.person_rounded,         Icons.person_outline_rounded,  'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData activeIcon, IconData inactiveIcon, String label) {
    final selected = _selectedIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(idx),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _rippleControllers[idx],
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Active indicator dot above icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: selected ? 20 : 0,
                  height: selected ? 3 : 0,
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  selected ? activeIcon : inactiveIcon,
                  size: 22,
                  color: selected ? AppTheme.ink : AppTheme.pebble,
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? AppTheme.ink : AppTheme.pebble,
                    letterSpacing: 0.1,
                    fontFamily: 'Inter',
                  ),
                  child: Text(label),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
