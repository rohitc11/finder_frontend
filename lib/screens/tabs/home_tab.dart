// Removed dart:ui import
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
    ));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _header(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                _searchBar(),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                _heroBanner(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _categoryRow(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _sectionTitle('Popular Near You'),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _popularCards(),
                const SliverToBoxAdapter(child: SizedBox(height: 36)),
                _sectionTitle('Recent Activity'),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _recentList(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _header() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Evening',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.midGray,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Finder',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.black,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _avatar(),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text(
          'R',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SEARCH
  // ─────────────────────────────────────────

  Widget _searchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: AppTheme.midGray, size: 21),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Search places, events, people…',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.midGray,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HERO BANNER
  // ─────────────────────────────────────────

  Widget _heroBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 168,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.accentShadow(0.25),
          ),
          child: Stack(
            children: [
              // Soft overlay circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✨  NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Discover hidden\ngems around you',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore trending spots nearby',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  CATEGORIES
  // ─────────────────────────────────────────

  Widget _categoryRow() {
    final categories = [
      _Cat('All', Icons.grid_view_rounded, true),
      _Cat('Food', Icons.restaurant_rounded, false),
      _Cat('Events', Icons.celebration_rounded, false),
      _Cat('Places', Icons.place_rounded, false),
      _Cat('People', Icons.people_rounded, false),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final c = categories[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: c.active ? AppTheme.black : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: c.active ? [] : AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Icon(c.icon,
                      size: 15,
                      color: c.active ? Colors.white : AppTheme.gray),
                  const SizedBox(width: 7),
                  Text(
                    c.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.active ? Colors.white : AppTheme.gray,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SECTION TITLE
  // ─────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'See all',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  POPULAR CARDS
  // ─────────────────────────────────────────

  Widget _popularCards() {
    final items = [
      _Place('Sunrise Café', 'Coffee & Brunch', '4.8', '0.3 km',
          Icons.local_cafe_rounded, AppTheme.accent),
      _Place('Art Gallery', 'Exhibition', '4.9', '1.2 km',
          Icons.palette_rounded, const Color(0xFF8B5CF6)),
      _Place('Green Park', 'Outdoor', '4.7', '0.8 km',
          Icons.park_rounded, const Color(0xFF10B981)),
      _Place('Tech Meetup', 'Event', '4.6', '2.5 km',
          Icons.laptop_mac_rounded, AppTheme.black),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 210,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, idx) => _placeCard(items[idx]),
        ),
      ),
    );
  }

  Widget _placeCard(_Place p) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(p.icon, color: p.color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.black,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            p.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.midGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFBBF24), size: 15),
              const SizedBox(width: 3),
              Text(
                p.rating,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
              const Spacer(),
              Text(
                p.distance,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.midGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  RECENT LIST
  // ─────────────────────────────────────────

  Widget _recentList() {
    final items = [
      _Activity('Morning Yoga', 'Wellness · Today, 7 AM',
          Icons.self_improvement_rounded, const Color(0xFF06B6D4)),
      _Activity('Book Club', 'Social · Mar 25',
          Icons.menu_book_rounded, const Color(0xFF8B5CF6)),
      _Activity('Farmers Market', 'Shopping · Sat 9 AM',
          Icons.storefront_rounded, const Color(0xFF10B981)),
      _Activity('Jazz Night', 'Music · This Friday',
          Icons.music_note_rounded, AppTheme.accent),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _activityTile(items[i]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _activityTile(_Activity a) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(a.icon, color: a.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.midGray,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.lightGray, size: 22),
        ],
      ),
    );
  }

  // Bottom nav removed as it's now in MainScreen
}

// ─── Models ──────────────────────────────

class _Cat {
  final String label;
  final IconData icon;
  final bool active;
  _Cat(this.label, this.icon, this.active);
}

class _Place {
  final String title, subtitle, rating, distance;
  final IconData icon;
  final Color color;
  _Place(this.title, this.subtitle, this.rating, this.distance, this.icon,
      this.color);
}

class _Activity {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  _Activity(this.title, this.subtitle, this.icon, this.color);
}
