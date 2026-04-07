import 'package:flutter/material.dart';

import '../../config/feature_flags.dart';
import '../../config/user_session.dart';
import '../../models/search_result_model.dart';
import '../../services/location_service.dart';
import '../../services/search_service.dart';
import '../../theme/app_theme.dart';
import '../contributions/my_contributions_screen.dart';
import '../contributions/suggest_item_screen.dart';
import '../item_detail_screen.dart';
import 'search_tab.dart';

/// Home tab shown as the first screen inside the app shell.
///
/// Responsibility:
/// - give users a clean first impression
/// - keep discovery as the main focus
/// - avoid duplicating profile/rewards/saved information
/// - remain lightweight with almost no extra network usage
///
/// Launch design choice:
/// - Home should be discovery-first
/// - Profile should remain the main place for rewards, stats and contribution history
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchCard(context),
              const SizedBox(height: 20),
              _buildContributionBanner(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Quick actions'),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Popular searches'),
              const SizedBox(height: 12),
              _buildPopularSearchChips(context),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Why use Spotzy?'),
              const SizedBox(height: 12),
              _buildValueCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spotzy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover the iconic dishes around you.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.stone,
          ),
        ),
      ],
    );
  }

  /// Builds the main search entry card.
  ///
  /// Behavior:
  /// - clicking the search card opens the search page directly
  Widget _buildSearchCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const _SearchPageWrapper(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search food by item, place or area',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.silver),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: AppTheme.pebble),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Best pani puri near me',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.pebble,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        color: AppTheme.snow,
                        fontWeight: FontWeight.w600,
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

  /// Builds the main contribution banner.
  ///
  /// Behavior:
  /// - contribution message always stays visible
  /// - reward-specific wording appears only when rewards are enabled
  Widget _buildContributionBanner(BuildContext context) {
    const Color bannerColor = Color(0xFF4B2E83);

    final subtitle = FeatureFlags.isRewardsEnabled
        ? 'Help others discover truly exceptional dishes you’ve experienced, and earn points after approval.'
        : 'Help others discover truly exceptional dishes you’ve experienced.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Know a dish that stands out?',
            style: TextStyle(
              color: AppTheme.snow,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.snow.withOpacity(0.82),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SuggestItemScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_rounded, size: 18),
                  label: const Text(
                    'Add Item',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.snow,
                    side: BorderSide(
                      color: AppTheme.snow.withOpacity(0.22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyContributionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: Text(
                    FeatureFlags.isRewardsEnabled ? 'My Impact' : 'Contributions',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.snow,
                    foregroundColor: bannerColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds quick actions for launch.
  ///
  /// Launch decision:
  /// - only Best Near Me is enabled for now
  /// - Top Rated and Must Try remain visible but disabled until rating/ranking is ready
  Widget _buildQuickActions(BuildContext context) {
    final List<_QuickActionData> actions = [];

    // Add only enabled actions
    if (FeatureFlags.isBestNearMeQuickActionEnabled) {
      actions.add(
        _QuickActionData(
          label: 'Best Near Me',
          icon: Icons.near_me_rounded,
          subtitle: 'Find standout dishes nearby',
          query: 'near me',
        ),
      );
    }

    if (FeatureFlags.isTopRatedQuickActionEnabled) {
      actions.add(
        _QuickActionData(
          label: 'Top Rated',
          icon: Icons.star_rounded,
          subtitle: 'Search best-rated dishes',
          query: 'best',
        ),
      );
    }

    if (FeatureFlags.isMustTryQuickActionEnabled) {
      actions.add(
        _QuickActionData(
          label: 'Must Try',
          icon: Icons.local_fire_department_rounded,
          subtitle: 'Explore famous food picks',
          query: 'must try',
        ),
      );
    }

    // Safety fallback (in case all are false)
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: actions
          .map(
            (action) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: action == actions.last ? 0 : 10,
            ),
            child: _buildQuickActionTile(context, action),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildQuickActionTile(
      BuildContext context,
      _QuickActionData action,
      ) {
    return InkWell(
      onTap: () {
        _openQuickSearchResults(
          context,
          title: action.label,
          query: action.query,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.shadowXs,
        ),
        child: Column(
          children: [
            Icon(action.icon, color: AppTheme.ink, size: 22),
            const SizedBox(height: 10),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              action.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.stone,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Builds clickable popular search chips.
  ///
  /// Launch note:
  /// - Best Near Me is intentionally repeated here because it already works well
  Widget _buildPopularSearchChips(BuildContext context) {
    final suggestions = [
      'Best Near Me',
      'Pani Puri',
      'Khaman',
      'Fafda Jalebi',
      'Pav Bhaji',
      'Navrangpura',
      'Law Garden',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: suggestions
          .map(
            (text) => InkWell(
          onTap: () {
            final query = text == 'Best Near Me' ? 'near me' : text;
            _openQuickSearchResults(
              context,
              title: text,
              query: query,
            );
          },
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
    );
  }

  Widget _buildValueCards() {
    final cards = [
      _ValueCardData(
        'Item-first search',
        'Find the best food items, not just restaurants.',
        Icons.search_rounded,
      ),
      _ValueCardData(
        'Standout discoveries',
        'Explore exceptional dishes people genuinely recommend.',
        Icons.location_on_rounded,
      ),
      _ValueCardData(
        'Community powered',
        'Users can suggest remarkable finds and earn rewards after approval.',
        Icons.groups_rounded,
      ),
    ];

    return Column(
      children: cards
          .map(
            (card) => Padding(
          padding: EdgeInsets.only(bottom: card == cards.last ? 0 : 12),
          child: _buildValueCard(card),
        ),
      )
          .toList(),
    );
  }

  Widget _buildValueCard(_ValueCardData card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(card.icon, color: AppTheme.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.stone,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openQuickSearchResults(
      BuildContext context, {
        required String title,
        required String query,
      }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QuickSearchResultsScreen(
          title: title,
          query: query,
        ),
      ),
    );
  }
}

class _QuickActionData {
  final String label;
  final IconData icon;
  final String subtitle;
  final String query;

  _QuickActionData({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.query,
  });
}

class _ValueCardData {
  final String title;
  final String subtitle;
  final IconData icon;

  _ValueCardData(this.title, this.subtitle, this.icon);
}

class _SearchPageWrapper extends StatelessWidget {
  const _SearchPageWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const SearchTab(),
    );
  }
}

class _QuickSearchResultsScreen extends StatefulWidget {
  final String title;
  final String query;

  const _QuickSearchResultsScreen({
    required this.title,
    required this.query,
  });

  @override
  State<_QuickSearchResultsScreen> createState() =>
      _QuickSearchResultsScreenState();
}

class _QuickSearchResultsScreenState extends State<_QuickSearchResultsScreen> {
  final SearchService _searchService = SearchService();

  bool _isLoading = true;
  String? _errorMessage;
  List<SearchResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double? latitude;
      double? longitude;

      if (LocationService.hasNearMeIntent(widget.query)) {
        final location = await LocationService.getCurrentLocationWithAddress();

        if (location == null) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _results = [];
            _errorMessage = 'Please enable current location for nearby search.';
          });
          return;
        }

        latitude = location.latitude;
        longitude = location.longitude;
      }

      final results = await _searchService.fetchSmartSearch(
        query: widget.query,
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
        _isLoading = false;
        _results = [];
        _errorMessage = 'Could not load search results right now.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accent,
          strokeWidth: 2,
        ),
      )
          : _errorMessage != null
          ? _buildMessageCard(_errorMessage!)
          : _results.isEmpty
          ? _buildMessageCard('No items found for this search.')
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = _results[index];
          return _QuickSearchResultCard(item: item);
        },
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.snow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowXs,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.stone,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickSearchResultCard extends StatelessWidget {
  final SearchResultModel item;

  const _QuickSearchResultCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(summary: item),
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
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.restaurantName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [item.areaName, item.city]
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
          ],
        ),
      ),
    );
  }
}