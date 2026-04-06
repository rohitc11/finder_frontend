import 'package:flutter/material.dart';

import '../config/user_session.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../utils/seo_meta.dart';
import '../utils/responsive.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/saved_tab.dart';
import 'tabs/search_tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex = widget.initialIndex;

  GlobalKey<SavedTabState> _savedTabKey = GlobalKey<SavedTabState>();

  List<Widget> get _tabs => [
        const HomeTab(),
        SearchTab(
          key: ValueKey('search-${UserSession.sessionVersion.value}'),
        ),
        SavedTab(key: _savedTabKey),
        ProfileTab(
          key: ValueKey('profile-${UserSession.sessionVersion.value}'),
        ),
      ];

  void _onTap(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _updatePageMeta(index);
    AppRouter.goTab(context, index);

    if (index == 2) {
      _savedTabKey.currentState?.refreshSavedItems();
    }
  }

  void _handleSessionChanged() {
    if (!mounted) return;

    _savedTabKey = GlobalKey<SavedTabState>();

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
      _updatePageMeta(_selectedIndex);

      if (_selectedIndex == 2) {
        _savedTabKey.currentState?.refreshSavedItems();
      }
    }
  }

  void _updatePageMeta(int index) {
    switch (index) {
      case 1:
        updateSeoMeta(
          title: 'Search Food Items | Finder',
          description:
              'Search iconic dishes, browse food items by place or area, and discover what to eat near you with Finder.',
          robots: 'index,follow',
        );
        removeStructuredData('finder-item-ld');
        break;
      case 2:
        updateSeoMeta(
          title: 'Saved Items | Finder',
          description:
              'Access your saved Finder items and keep track of standout dishes you want to try again.',
          robots: 'noindex,nofollow',
        );
        removeStructuredData('finder-item-ld');
        break;
      case 3:
        updateSeoMeta(
          title: 'Your Profile | Finder',
          description:
              'Manage your Finder profile, saved dishes, reviews, and contributions.',
          robots: 'noindex,nofollow',
        );
        removeStructuredData('finder-item-ld');
        break;
      case 0:
      default:
        updateSeoMeta(
          title: 'Finder | Discover Iconic Dishes Near You',
          description:
              'Search standout food items, explore top dishes, and discover what to eat near you with Finder.',
          robots: 'index,follow',
        );
        removeStructuredData('finder-item-ld');
        break;
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
  void initState() {
    super.initState();
    UserSession.sessionVersion.addListener(_handleSessionChanged);
    _updatePageMeta(_selectedIndex);
  }

  @override
  void dispose() {
    UserSession.sessionVersion.removeListener(_handleSessionChanged);
    super.dispose();
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
                useIndicator: true,
                indicatorColor: AppTheme.accentDim,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                selectedIconTheme:
                    const IconThemeData(color: AppTheme.accent),
                unselectedIconTheme:
                    const IconThemeData(color: AppTheme.pebble),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.accent,
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