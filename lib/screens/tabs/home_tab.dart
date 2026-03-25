import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  int _activeCat = 0;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(child: _buildHeroBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(child: _buildCategories()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(child: _buildSectionHeader('Trending Now', 'See all')),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildTrendingCards()),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(child: _buildSectionHeader('Near You', 'View map')),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildNearbyList()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'GOOD EVENING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.6,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover\nYour City',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          height: 1.05,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.charcoal,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'RC',
                      style: TextStyle(
                        color: AppTheme.snow,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.charcoal, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HERO BANNER ──────────────────────────
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.charcoal.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -40,
              bottom: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.07),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: AppTheme.snow,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hidden gems\naround you',
                        style: TextStyle(
                          color: AppTheme.snow,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _heroCTA('Explore Now'),
                          const Spacer(),
                          // Fake avatars
                          _faceStack(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCTA(String label) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                size: 14, color: AppTheme.ink),
          ],
        ),
      ),
    );
  }

  Widget _faceStack() {
    final colors = [
      const Color(0xFFFF9F0A),
      const Color(0xFF34C759),
      const Color(0xFF5E5CE6),
    ];
    return SizedBox(
      width: 60,
      height: 28,
      child: Stack(
        children: List.generate(3, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.charcoal, width: 2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── CATEGORIES ───────────────────────────
  Widget _buildCategories() {
    final cats = [
      _Cat('All',     Icons.grid_view_rounded),
      _Cat('Food',    Icons.restaurant_rounded),
      _Cat('Events',  Icons.celebration_rounded),
      _Cat('Nature',  Icons.park_rounded),
      _Cat('Art',     Icons.palette_rounded),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final active = _activeCat == i;
          return GestureDetector(
            onTap: () => setState(() => _activeCat = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? AppTheme.ink : AppTheme.snow,
                borderRadius: BorderRadius.circular(10),
                boxShadow: active ? AppTheme.shadowMd : AppTheme.shadowXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cats[i].icon,
                    size: 15,
                    color: active ? AppTheme.snow : AppTheme.stone,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    cats[i].label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? AppTheme.snow : AppTheme.stone,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SECTION HEADER ──────────────────────
  Widget _buildSectionHeader(String title, String cta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            cta,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── TRENDING CARDS ──────────────────────
  Widget _buildTrendingCards() {
    final cards = [
      _Trend('Sunrise Café', 'Coffee & Brunch', '4.8', '340 m',
          const Color(0xFFFF9F0A), Icons.local_cafe_rounded),
      _Trend('Rooftop Bar', 'Cocktails & View', '4.9', '1.1 km',
          const Color(0xFF5E5CE6), Icons.wine_bar_rounded),
      _Trend('Art Gallery', 'Contemporary Art', '4.7', '0.8 km',
          const Color(0xFF34C759), Icons.palette_rounded),
    ];

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _trendCard(cards[i]),
      ),
    );
  }

  Widget _trendCard(_Trend t) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored image stand-in
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: t.color.withValues(alpha: 0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.color.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Center(
                  child: Icon(t.icon, size: 40, color: t.color),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.snow,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.shadowXs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 11, color: Color(0xFFFF9F0A)),
                        const SizedBox(width: 3),
                        Text(
                          t.rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  t.sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.stone,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppTheme.pebble),
                    const SizedBox(width: 3),
                    Text(
                      t.dist,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.pebble,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── NEARBY LIST ─────────────────────────
  Widget _buildNearbyList() {
    final items = [
      _Near('Green Park', 'Outdoor · Free', '0.4 km', Icons.park_rounded,
          const Color(0xFF34C759)),
      _Near('Farmers Market', 'Shopping · Weekend', '0.9 km',
          Icons.storefront_rounded, const Color(0xFFFF9F0A)),
      _Near('Jazz Night', 'Music · Fri 8 PM', '1.3 km',
          Icons.music_note_rounded, const Color(0xFF5E5CE6)),
      _Near('Morning Yoga', 'Wellness · 7 AM', '1.8 km',
          Icons.self_improvement_rounded, AppTheme.accent),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _nearTile(items[i]),
    );
  }

  Widget _nearTile(_Near n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: n.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(n.icon, color: n.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  n.sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.stone,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                n.dist,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.silver, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────

class _Cat {
  final String label;
  final IconData icon;
  _Cat(this.label, this.icon);
}

class _Trend {
  final String name, sub, rating, dist;
  final Color color;
  final IconData icon;
  _Trend(this.name, this.sub, this.rating, this.dist, this.color, this.icon);
}

class _Near {
  final String name, sub, dist;
  final IconData icon;
  final Color color;
  _Near(this.name, this.sub, this.dist, this.icon, this.color);
}

