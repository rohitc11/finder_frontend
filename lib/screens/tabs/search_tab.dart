import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/search_result_model.dart';
import '../../models/suggestion_model.dart';
import '../../services/search_service.dart';
import '../../services/bucket_list_service.dart';
import '../../config/user_session.dart';
import '../item_detail_screen.dart';

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
  /// Whether suggestion list should currently be shown.
  ///
  /// This becomes true while user is typing a new query.
  bool _showSuggestions = false;

  /// Controller for the main search text field.
  final TextEditingController _searchController = TextEditingController();

  /// Focus node used to manage keyboard focus.
  final FocusNode _searchFocusNode = FocusNode();

  /// Service responsible for backend search APIs.
  final SearchService _searchService = SearchService();

  /// Service responsible for bookmark add/remove APIs.
  final BucketListService _bucketListService = BucketListService();

  /// Debounce timer for autocomplete API calls.
  ///
  /// Why:
  /// - avoids hitting backend on every keystroke immediately
  /// - improves performance
  /// - gives smoother UX
  Timer? _debounce;

  /// Whether a search API call is currently running.
  bool _isLoading = false;

  /// Whether the user has executed at least one search.
  bool _hasSearched = false;

  /// Current autocomplete suggestions returned by backend.
  List<SuggestionModel> _suggestions = [];

  /// Current search results returned by backend.
  List<SearchResultModel> _results = [];

  @override
  void initState() {
    super.initState();

    /// Listen to search field changes so we can trigger suggestions.
    _searchController.addListener(_onSearchTextChanged);

    /// Rebuild UI when focus changes so suggestions can be shown/hidden
    /// depending on whether the user is actively editing.
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
  ///
  /// UX strategy:
  /// - update UI immediately for fast feel
  /// - call backend API in background
  /// - revert UI if API fails
  Future<void> _toggleBookmark(SearchResultModel result) async {
    final int index =
    _results.indexWhere((element) => element.itemId == result.itemId);

    if (index == -1) return;

    final bool oldValue = _results[index].isBookmarked;
    final bool newValue = !oldValue;

    // Optimistic UI update for fast product feel.
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
        await _bucketListService.addToBucketList(
          userId: UserSession.userId,
          itemId: result.itemId,
        );
      } else {
        await _bucketListService.removeFromBucketList(
          userId: UserSession.userId,
          itemId: result.itemId,
        );
      }
    } catch (e) {
      // Revert UI if backend call fails.
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

  /// Called whenever the text in the search field changes.
  ///
  /// This method:
  /// - rebuilds UI for clear/search icon changes
  /// - clears suggestions for very short queries
  /// - uses debounce before calling autocomplete API
  /// - shows suggestions even after a previous search
  void _onSearchTextChanged() {
    setState(() {});

    final query = _searchController.text.trim();

    // Do not show suggestions for very short input.
    if (query.length < 2) {
      _debounce?.cancel();

      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // User is typing a new query, so suggestions should be visible.
    setState(() {
      _showSuggestions = true;
    });

    // Debounce suggestion API calls for better UX and lower backend load.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _loadSuggestions(query);
    });
  }

  /// Loads autocomplete suggestions from backend.
  ///
  /// Backend endpoint:
  /// GET /search/suggestions?query=...
  Future<void> _loadSuggestions(String query) async {
    try {
      final suggestions = await _searchService.fetchSuggestions(query);

      if (!mounted) return;

      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _suggestions = [];
      });
    }
  }

  /// Executes smart search using backend.
  ///
  /// Backend endpoint:
  /// GET /search/items/smart?query=...
  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();

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
      final results = await _searchService.fetchSmartSearch(
        query: trimmedQuery,
        userId: UserSession.userId,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  /// Clears the current search and resets the tab to initial state.
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

  /// Handles suggestion tap.
  ///
  /// If backend provides canonical value, we search using it.
  /// This is especially useful for aliases like:
  /// Golgappa -> Pani Puri
  void _onSuggestionTap(SuggestionModel suggestion) {
    final valueToSearch =
        suggestion.canonicalValue ?? suggestion.displayText;

    _searchController.text = valueToSearch;

    setState(() {
      _showSuggestions = false;
    });

    _performSearch(valueToSearch);
  }

  /// Handles quick search chip tap.
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

  /// Builds the fixed top search area.
  ///
  /// This stays visible before and after search.
  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
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
    );
  }

  /// Builds the main body below the search bar.
  ///
  /// Depending on current UI state, this shows:
  /// - loading state
  /// - suggestions
  /// - search results
  /// - empty state
  /// - initial discover view
  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    // Show suggestions only when:
    // 1. user is actively typing
    // 2. suggestions are available
    // 3. search field is focused
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

  /// Builds the initial discover state before user performs search.
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
            'Find the best food items by name, alias, or area.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickSearches
                .map(
                  (text) => GestureDetector(
                onTap: () => _onQuickSearchTap(text),
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
                    text,
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
    );
  }

  /// Builds the autocomplete suggestion list.
  Widget _buildSuggestionsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];

        return GestureDetector(
          onTap: () => _onSuggestionTap(suggestion),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowXs,
            ),
            child: Row(
              children: [
                _buildSuggestionIcon(suggestion.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.displayText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                      if (suggestion.secondaryText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          suggestion.secondaryText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.stone,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds one icon for a suggestion type.
  Widget _buildSuggestionIcon(String type) {
    IconData icon;

    switch (type) {
      case 'ALIAS':
        icon = Icons.sync_alt_rounded;
        break;
      case 'AREA':
        icon = Icons.location_on_rounded;
        break;
      case 'CITY':
        icon = Icons.location_city_rounded;
        break;
      default:
        icon = Icons.search_rounded;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppTheme.ink),
    );
  }

  /// Builds loading state while search request is in progress.
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2,
          ),
          const SizedBox(height: 14),
          Text(
            'Searching...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state when no results are found.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 42,
              color: AppTheme.pebble,
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another item name, alias, or area.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.stone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the final result list after search is completed.
  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = _results[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(summary: result),
              ),
            );
          },
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
                    Icons.restaurant_rounded,
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
                          color: AppTheme.stone,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.areaName}, ${result.city}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.pebble,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFF9F0A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.avgItemRating?.toStringAsFixed(1) ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}