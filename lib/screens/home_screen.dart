import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/saved_tab.dart';
import 'tabs/search_tab.dart';

/// Main app shell screen.
///
/// Responsibility:
/// - holds bottom navigation
/// - switches between main tabs
/// - preserves tab state using IndexedStack
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected bottom navigation tab index.
  int _selectedIndex = 0;

  /// Key used to access SavedTab state and trigger refresh when needed.
  final GlobalKey<SavedTabState> _savedTabKey = GlobalKey<SavedTabState>();

  /// Main tabs of the application.
  ///
  /// Order must match bottom navigation items.
  late final List<Widget> _tabs = [
    const HomeTab(),
    const SearchTab(),
    SavedTab(key: _savedTabKey),
    const ProfileTab(),
  ];

  /// Handles bottom navigation tab change.
  ///
  /// Also refreshes bucket list when user opens the Bucket List tab.
  void _onTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Refresh bucket list whenever user opens that tab.
    if (index == 2) {
      _savedTabKey.currentState?.refreshSavedItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Builds the bottom navigation bar.
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.ink,
      unselectedItemColor: AppTheme.pebble,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border_rounded),
          activeIcon: Icon(Icons.bookmark_rounded),
          label: 'Bucket List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}