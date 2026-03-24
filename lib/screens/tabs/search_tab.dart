import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  bool _hasSearched = false;
  bool _isLoading = false;
// Removed _query

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    
    // Auto-focus on search if we wanted, but let's let the user tap it
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate network request
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _hasSearched ? _buildResultsView() : _buildInitialView(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  INITIAL VIEW (Google-like)
  // ─────────────────────────────────────────
  Widget _buildInitialView() {
    return Center(
      key: const ValueKey('initial'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Finder',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 48,
                    color: AppTheme.black,
                    letterSpacing: -2,
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.shadowMd,
                border: Border.all(color: AppTheme.lightGray.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppTheme.midGray, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Search places, events, food...',
                        hintStyle: TextStyle(
                          color: AppTheme.midGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, color: AppTheme.midGray, size: 20),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickChip('best gol gappas near me'),
                _buildQuickChip('Coffee shops'),
                _buildQuickChip('Live music tonight'),
              ],
            ),
            const SizedBox(height: 80), // Offset for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: AppTheme.lightGray.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 14, color: AppTheme.gray),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  RESULTS VIEW
  // ─────────────────────────────────────────
  Widget _buildResultsView() {
    return Column(
      key: const ValueKey('results'),
      children: [
        // Top search bar (Sticky)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasSearched = false;
                    _searchController.clear();
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppTheme.black, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppTheme.midGray, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _performSearch,
                          style: const TextStyle(fontSize: 15, color: AppTheme.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: const Icon(Icons.close_rounded, color: AppTheme.midGray, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter chips row
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip('Top Rated', true),
              const SizedBox(width: 8),
              _buildFilterChip('Open Now', false),
              const SizedBox(width: 8),
              _buildFilterChip('Distance', false),
              const SizedBox(width: 8),
              _buildFilterChip('Price', false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Results List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // padding for nav bar
                    physics: const BouncingScrollPhysics(),
                    itemCount: _mockResults.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildResultCard(_mockResults[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.black : AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? null : Border.all(color: AppTheme.lightGray),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppTheme.white : AppTheme.gray,
        ),
      ),
    );
  }

  Widget _buildResultCard(_SearchResult item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: AppTheme.lightGray.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.lightGray,
                child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.midGray),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFF10B981), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            item.rating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppTheme.midGray, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${item.distance} • ${item.category}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.midGray,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Open Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
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

// Mock Data Models
class _SearchResult {
  final String name;
  final String description;
  final String rating;
  final String distance;
  final String category;
  final String imageUrl;

  _SearchResult(this.name, this.description, this.rating, this.distance, this.category, this.imageUrl);
}

final List<_SearchResult> _mockResults = [
  _SearchResult(
    'Raju Chaat Bhandar',
    'Famous for highly spicy street style spicy water and crispy suji puris.',
    '4.8',
    '1.2 km',
    'Street Food',
    'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&q=80&w=600',
  ),
  _SearchResult(
    'Bikanerwala',
    'Hygienic and perfectly balanced tangy water with family seating.',
    '4.5',
    '3.5 km',
    'Sweets & Snacks',
    'https://images.unsplash.com/photo-1596450514735-a131acfce16b?auto=format&fit=crop&q=80&w=600',
  ),
  _SearchResult(
    'Sharma Ji Gol Gappe',
    'Known for 6 different flavors of water ranging from sweet to extra spicy.',
    '4.9',
    '0.8 km',
    'Street Cart',
    'https://images.unsplash.com/photo-1626784365511-b0622fa57276?auto=format&fit=crop&q=80&w=600',
  ),
  _SearchResult(
    'Haldiram\'s',
    'Premium quality hygienic stuffed gol gappas with sweet curd and chutney.',
    '4.3',
    '4.1 km',
    'Restaurant',
    'https://images.unsplash.com/photo-1606491956689-2ea866880c84?auto=format&fit=crop&q=80&w=600',
  ),
];
