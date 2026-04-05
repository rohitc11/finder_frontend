import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/saved_tab.dart';
import 'tabs/search_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<SavedTabState> _savedTabKey = GlobalKey<SavedTabState>();

  late final List<Widget> _tabs = [
    const HomeTab(),
    const SearchTab(),
    SavedTab(key: _savedTabKey),
    const ProfileTab(),
  ];

  void _onTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _savedTabKey.currentState?.refreshSavedItems();
    }
  }

  ThemeData _navigationTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    return baseTheme.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = isDesktop(context);
    final navigationTheme = _navigationTheme(context);

    final bottomNav = Theme(
      data: navigationTheme,
      child: BottomNavigationBar(
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
      ),
    );

    final content = IndexedStack(
      index: _selectedIndex,
      children: _tabs,
    );

    if (wide) {
      return Scaffold(
        backgroundColor: AppTheme.fog,
        body: Row(
          children: [
            Theme(
              data: navigationTheme,
              child: NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme:
                    const IconThemeData(color: AppTheme.ink),
                unselectedIconTheme:
                    const IconThemeData(color: AppTheme.pebble),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppTheme.pebble,
                  fontSize: 12,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: Text('Search'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bookmark_border_rounded),
                    selectedIcon: Icon(Icons.bookmark_rounded),
                    label: Text('Bucket List'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: content,
      bottomNavigationBar: bottomNav,
    );
  }
}