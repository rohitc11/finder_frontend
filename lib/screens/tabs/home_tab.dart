import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Home tab shown as the first screen inside the app shell.
///
/// Responsibility:
/// - gives users a clean landing experience
/// - highlights the main value of the app
/// - provides quick entry points to search and rewards
///
/// Design goals:
/// - minimal
/// - fast feeling
/// - production-friendly
/// - easy to connect with real backend data later
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
              _buildRewardsCard(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Popular searches'),
              const SizedBox(height: 12),
              _buildPopularSearchChips(),
              const SizedBox(height: 28),
              _buildSectionHeader(context, 'Why use Finder?'),
              const SizedBox(height: 12),
              _buildValueCards(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top greeting/title area.
  ///
  /// This should quickly communicate what the app helps users do.
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finder',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover the best food items around you.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.stone,
          ),
        ),
      ],
    );
  }

  /// Builds the main search entry card.
  ///
  /// This is intentionally placed near the top because search is the
  /// core action of the product.
  Widget _buildSearchCard(BuildContext context) {
    return Container(
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  /// Builds the rewards teaser card.
  ///
  /// This is a strong login/contribution motivator and should remain visible.
  Widget _buildRewardsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earn rewards for verified suggestions',
                  style: TextStyle(
                    color: AppTheme.snow,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add useful food discoveries and unlock points.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.snow.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds quick action buttons.
  ///
  /// These are simple entry points and can later be connected to real
  /// navigation and backend-driven sections.
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickActionData('Best Near Me', Icons.near_me_rounded),
      _QuickActionData('Must Try', Icons.local_fire_department_rounded),
      _QuickActionData('Saved', Icons.bookmark_rounded),
      _QuickActionData('Rewards', Icons.card_giftcard_rounded),
    ];

    return Row(
      children: actions
          .map(
            (action) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: action == actions.last ? 0 : 10,
            ),
            child: _buildQuickActionTile(action),
          ),
        ),
      )
          .toList(),
    );
  }

  /// Builds one quick action tile.
  Widget _buildQuickActionTile(_QuickActionData action) {
    return Container(
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
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds small section headers used across the page.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Builds static popular search chips.
  ///
  /// Later these can come from search logs or backend analytics.
  Widget _buildPopularSearchChips() {
    final suggestions = [
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
            (text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      )
          .toList(),
    );
  }

  /// Builds small product value cards.
  ///
  /// These help explain the app simply without making the screen heavy.
  Widget _buildValueCards() {
    final cards = [
      _ValueCardData(
        'Item-first search',
        'Find the best food items, not just restaurants.',
        Icons.search_rounded,
      ),
      _ValueCardData(
        'Real local discovery',
        'Explore famous items in areas like Navrangpura or Law Garden.',
        Icons.location_on_rounded,
      ),
      _ValueCardData(
        'Community powered',
        'Users can suggest places and earn rewards after verification.',
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

  /// Builds one product value card.
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
}

/// Small view model for quick action tiles.
class _QuickActionData {
  final String label;
  final IconData icon;

  _QuickActionData(this.label, this.icon);
}

/// Small view model for value cards.
class _ValueCardData {
  final String title;
  final String subtitle;
  final IconData icon;

  _ValueCardData(this.title, this.subtitle, this.icon);
}