import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../models/search_result_model.dart';
import '../../models/suggestion_model.dart';
import '../../services/bucket_list_service.dart';
import '../../services/location_service.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../item_detail_screen.dart';
import '../contributions/suggest_item_screen.dart';

/// Search tab of the application.
///
/// Responsibility:
/// - accepts user search query
/// - shows autocomplete suggestions from backend
/// - triggers backend smart search
/// - renders search results in a clean and minimal way
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  bool _showSuggestions = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final SearchService _searchService = SearchService();
  final BucketListService _bucketListService = BucketListService();

  Timer? _debounce;

  bool _isLoading = false;
  bool _hasSearched = false;

  List<SuggestionModel> _suggestions = [];
  List<SearchResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Toggles bookmark state for a search result item.
  Future<void> _toggleBookmark(SearchResultModel result) async {
    if (!UserSession.isLoggedIn) {
      final bool? loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      if (loggedIn != true) {
        return;
      }
    }

    final int index =
    _results.indexWhere((element) => element.itemId == result.itemId);

    if (index == -1) return;

    final bool oldValue = _results[index].isBookmarked;
    final bool newValue = !oldValue;

    setState(() {
      _results[index] = SearchResultModel(
        itemId: _results[index].itemId,
        itemName: _results[index].itemName,
        restaurantId: _results[index].restaurantId,
        restaurantName: _results[index].restaurantName,
        city: _results[index].city,
        areaName: _results[index].areaName,
        avgItemRating: _results[index].avgItemRating,
        ratingCount: _results[index].ratingCount,
        distanceInKm: _results[index].distanceInKm,
        isBookmarked: newValue,
      );
    });

    try {
      if (newValue) {
        await _bucketListService.addToBucketList(result.itemId);
      } else {
        await _bucketListService.removeFromBucketList(result.itemId);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _results[index] = SearchResultModel(
          itemId: _results[index].itemId,
          itemName: _results[index].itemName,
          restaurantId: _results[index].restaurantId,
          restaurantName: _results[index].restaurantName,
          city: _results[index].city,
          areaName: _results[index].areaName,
          avgItemRating: _results[index].avgItemRating,
          ratingCount: _results[index].ratingCount,
          distanceInKm: _results[index].distanceInKm,
          isBookmarked: oldValue,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update bookmark. Please try again.'),
        ),
      );
    }
  }

  void _onSearchTextChanged() {
    setState(() {});

    final query = _searchController.text.trim();

    if (query.length < 2) {
      _debounce?.cancel();

      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _showSuggestions = true;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _loadSuggestions(query);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final suggestions = await _searchService.fetchSuggestions(query);

      if (!mounted) return;

      setState(() {
        _suggestions = suggestions;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _performSearch(String query) async {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    _debounce?.cancel();
    _searchFocusNode.unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _showSuggestions = false;
      _suggestions = [];
    });

    try {
      double? latitude;
      double? longitude;

      if (LocationService.hasNearMeIntent(trimmedQuery)) {
        final AppLocationResult? location =
        await LocationService.getCurrentLocationWithAddress();

        if (location == null) {
          if (!mounted) return;

          setState(() {
            _results = [];
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please enable current location for nearby search, or search by city/area.',
              ),
            ),
          );
          return;
        }

        latitude = location.latitude;
        longitude = location.longitude;
      }

      final List<SearchResultModel> results =
      await _searchService.fetchSmartSearch(
        query: trimmedQuery,
        userId: UserSession.userId,
        latitude: latitude,
        longitude: longitude,
        radiusInKm: 5.0,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete search. Please try again.'),
        ),
      );
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _hasSearched = false;
      _isLoading = false;
      _showSuggestions = false;
      _suggestions = [];
      _results = [];
    });

    _searchFocusNode.requestFocus();
  }

  void _onSuggestionTap(SuggestionModel suggestion) {
    final valueToSearch = suggestion.canonicalValue ?? suggestion.displayText;

    _searchController.text = valueToSearch;

    setState(() {
      _showSuggestions = false;
    });

    _performSearch(valueToSearch);
  }

  void _onQuickSearchTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();

            setState(() {
              _showSuggestions = false;
            });
          },
          child: Column(
            children: [
              _buildSearchHeader(context),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return centeredContent(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 54,
          decoration: BoxDecoration(
            color: AppTheme.snow,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.shadowSm,
          ),
        child: Row(
          children: [
            if (_hasSearched)
              GestureDetector(
                onTap: _clearSearch,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.ink,
                ),
              )
            else
              const Icon(
                Icons.search_rounded,
                color: AppTheme.pebble,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.ink,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search food, item, area...',
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.pebble,
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_showSuggestions &&
        _suggestions.isNotEmpty &&
        _searchFocusNode.hasFocus) {
      return _buildSuggestionsList();
    }

    if (_hasSearched) {
      if (_results.isEmpty) {
        return _buildEmptyState(context);
      }

      return _buildResultsList();
    }

    return _buildDiscoverView(context);
  }

  Widget _buildDiscoverView(BuildContext context) {
    final quickSearches = [
      'Best pani puri',
      'Khaman near me',
      'Fafda Jalebi',
      'Navrangpura food',
      'Law Garden snacks',
      'Must try in Ahmedabad',
    ];

    return SingleChildScrollView(
      child: centeredContent(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(
            'Search smarter',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find the dishes worth trying around you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickSearches
                .map(
                  (query) => InkWell(
                onTap: () => _onQuickSearchTap(query),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.snow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.silver),
                  ),
                  child: Text(
                    query,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.accent,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];

        return InkWell(
          onTap: () => _onSuggestionTap(suggestion),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowXs,
            ),
            child: Row(
              children: [
                const Icon(Icons.north_west_rounded, color: AppTheme.pebble),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    suggestion.displayText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if ((suggestion.secondaryText ?? '').trim().isNotEmpty)
                  Text(
                    suggestion.secondaryText!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.stone,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = _results[index];

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(summary: result),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowXs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.offWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.itemName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.restaurantName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [result.areaName, result.city]
                            .where((e) => e.trim().isNotEmpty)
                            .join(', '),
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
                    GestureDetector(
                      onTap: () => _toggleBookmark(result),
                      child: Icon(
                        result.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: result.isBookmarked
                            ? AppTheme.accent
                            : AppTheme.pebble,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (result.avgItemRating != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFF9F0A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.avgItemRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final query = _searchController.text.trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 46,
              color: AppTheme.pebble,
            ),
            const SizedBox(height: 12),
            Text(
              'No matching items found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another item, area, or nearby search. If this dish deserves to be here, you can suggest it.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.stone,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SuggestItemScreen(
                        initialItemName: query,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.snow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_circle_rounded),
                label: const Text(
                  'Suggest this item',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}