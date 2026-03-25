import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  bool _hasSearched = false;
  bool _loading = false;
  int _activeFilter = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    if (q.trim().isEmpty) return;
    _focus.unfocus();
    setState(() {
      _loading = true;
      _hasSearched = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _loading = false);
        _fadeCtrl.forward(from: 0);
      }
    });
  }

  void _clear() {
    _ctrl.clear();
    setState(() {
      _hasSearched = false;
      _activeFilter = 0;
    });
    _fadeCtrl.reset();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_hasSearched) _buildSearchHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _hasSearched
                    ? _buildResults()
                    : _buildDiscover(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SEARCH HEADER ───────────────────────
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppTheme.shadowMd,
        ),
        child: Row(
          children: [
            if (_hasSearched) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _clear,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.fog,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: AppTheme.ink),
                ),
              ),
            ] else ...[
              const SizedBox(width: 18),
              const Icon(Icons.search_rounded,
                  size: 20, color: AppTheme.stone),
            ],
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Restaurants, events, people…',
                  hintStyle: TextStyle(
                    color: AppTheme.pebble,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_ctrl.text.isNotEmpty) ...[
              GestureDetector(
                onTap: _clear,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.silver,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 12, color: AppTheme.snow),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.tune_rounded,
                      size: 20, color: AppTheme.stone),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── DISCOVER (initial) ──────────────────
  Widget _buildDiscover() {
    return SingleChildScrollView(
      key: const ValueKey('discover'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ──
          const SizedBox(height: 52),
          Center(
            child: Text(
              'Finder',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                letterSpacing: -3,
                height: 1,
                color: AppTheme.ink,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // ── Inline search bar ──
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.shadowMd,
            ),
            child: Row(
              children: [
                const SizedBox(width: 18),
                const Icon(Icons.search_rounded,
                    size: 20, color: AppTheme.stone),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w500,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: 'Restaurants, events, people…',
                      hintStyle: TextStyle(
                        color: AppTheme.pebble,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_ctrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _ctrl.clear();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppTheme.silver,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 12, color: AppTheme.snow),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.tune_rounded,
                          size: 20, color: AppTheme.stone),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Quick suggestions
          Text(
            'Quick searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.stone,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip('Best gol gappas', Icons.search_rounded),
              _chip('Coffee shops', Icons.local_cafe_rounded),
              _chip('Live music tonight', Icons.music_note_rounded),
              _chip('Sunset spots', Icons.wb_sunny_rounded),
              _chip('Vegetarian', Icons.eco_rounded),
              _chip('Open now', Icons.access_time_rounded),
            ],
          ),
          const SizedBox(height: 32),
          // Trending categories
          Text(
            'Trending',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ..._trendingCategories(),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        _ctrl.text = label;
        _search(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppTheme.shadowXs,
          border: Border.all(
              color: AppTheme.silver.withValues(alpha: 0.6), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.stone),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _trendingCategories() {
    final cats = [
      _TrendCat('Street Food', '320+ spots', Icons.fastfood_rounded,
          const Color(0xFFFF9F0A)),
      _TrendCat('Live Music', '80+ events', Icons.music_note_rounded,
          const Color(0xFF5E5CE6)),
      _TrendCat('Cafés', '160+ places', Icons.local_cafe_rounded,
          AppTheme.accent),
      _TrendCat('Markets', '45+ listings', Icons.storefront_rounded,
          const Color(0xFF34C759)),
    ];
    return cats.map((c) => _trendCatTile(c)).toList();
  }

  Widget _trendCatTile(_TrendCat c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(c.icon, color: c.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                      letterSpacing: -0.2,
                    )),
                const SizedBox(height: 2),
                Text(c.count,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.stone,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppTheme.silver),
        ],
      ),
    );
  }

  // ─── RESULTS VIEW ────────────────────────
  Widget _buildResults() {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _activeFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _activeFilter == i ? AppTheme.ink : AppTheme.snow,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _activeFilter == i
                      ? AppTheme.shadowMd
                      : AppTheme.shadowXs,
                  border: _activeFilter == i
                      ? null
                      : Border.all(
                          color: AppTheme.silver.withValues(alpha: 0.6)),
                ),
                child: Center(
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _activeFilter == i
                          ? AppTheme.snow
                          : AppTheme.stone,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '${_mockResults.length} results found',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.stone,
                ),
          ),
        ),
        const SizedBox(height: 14),
        // List
        Expanded(
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.accent,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Finding results…',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.stone),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    itemCount: _mockResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _resultCard(_mockResults[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _resultCard(_SearchResult r) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 150,
            color: r.color.withValues(alpha: 0.1),
            child: Stack(
              children: [
                Center(child: Icon(r.icon, size: 48, color: r.color)),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.snow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFFF9F0A)),
                        const SizedBox(width: 4),
                        Text(
                          r.rating,
                          style: const TextStyle(
                            fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.stone,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.fog,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        r.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppTheme.pebble),
                    const SizedBox(width: 2),
                    Text(
                      r.distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.pebble,
                        fontWeight: FontWeight.w500,
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
}

// ─── Filters ─────────────────────────────

const List<String> _filters = [
  'Best Match',
  'Open Now',
  'Nearest',
  'Top Rated',
  'Price',
];

// ─── Models ──────────────────────────────

class _TrendCat {
  final String name, count;
  final IconData icon;
  final Color color;
  _TrendCat(this.name, this.count, this.icon, this.color);
}

class _SearchResult {
  final String name, description, rating, distance, category;
  final Color color;
  final IconData icon;
  _SearchResult(this.name, this.description, this.rating, this.distance,
      this.category, this.color, this.icon);
}

final List<_SearchResult> _mockResults = [
  _SearchResult(
    'Raju Chaat Bhandar',
    'Famous for spicy street-style pani puri and crispy suji puris.',
    '4.8',
    '1.2 km',
    'Street Food',
    const Color(0xFFFF9F0A),
    Icons.fastfood_rounded,
  ),
  _SearchResult(
    'Bikanerwala',
    'Hygienic and perfectly balanced tangy water with family seating.',
    '4.5',
    '3.5 km',
    'Sweets & Snacks',
    AppTheme.accent,
    Icons.storefront_rounded,
  ),
  _SearchResult(
    'Sharma Ji Gol Gappe',
    'Known for 6 different flavors ranging from sweet to extra spicy.',
    '4.9',
    '0.8 km',
    'Street Cart',
    const Color(0xFF34C759),
    Icons.local_dining_rounded,
  ),
  _SearchResult(
    'Haldiram\'s',
    'Premium quality stuffed gol gappas with sweet curd and chutney.',
    '4.3',
    '4.1 km',
    'Restaurant',
    const Color(0xFF5E5CE6),
    Icons.restaurant_rounded,
  ),
];

