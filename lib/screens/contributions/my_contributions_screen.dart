import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../models/user_profile_summary_model.dart';
import '../../models/user_suggestion_model.dart';
import '../../router/app_router.dart';
import '../../services/contribution_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import 'suggest_item_screen.dart';
import '../../config/feature_flags.dart';

/// Main screen for viewing user's contribution summary and submitted suggestions.
///
/// Navigation behavior:
/// - Opened as a normal pushed screen from Profile.
/// - Uses a standard AppBar so Android/iOS users can easily go back.
class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({super.key});

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final ContributionService _contributionService = ContributionService();

  bool _isLoading = true;
  UserProfileSummaryModel? _summary;
  List<UserSuggestionModel> _suggestions = [];
  SuggestionStatus? _selectedFilter;
  int _activeLoadId = 0;

  @override
  void initState() {
    super.initState();
    UserSession.sessionVersion.addListener(_handleSessionChanged);
    _loadData();
  }

  @override
  void dispose() {
    UserSession.sessionVersion.removeListener(_handleSessionChanged);
    super.dispose();
  }

  void _handleSessionChanged() {
    if (!mounted) return;

    if (!UserSession.isLoggedIn) {
      _clearContributionState();
      return;
    }

    _loadData();
  }

  void _clearContributionState() {
    _activeLoadId++;

    setState(() {
      _isLoading = false;
      _summary = null;
      _suggestions = [];
      _selectedFilter = null;
    });
  }

  Future<void> _loadData() async {
    if (!UserSession.isLoggedIn) {
      if (mounted) {
        _clearContributionState();
      }
      return;
    }

    final loadId = ++_activeLoadId;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _contributionService.fetchUserSummary(),
        _contributionService.fetchUserSuggestions(),
      ]);

      if (!mounted || !UserSession.isLoggedIn || loadId != _activeLoadId) {
        return;
      }

      setState(() {
        _summary = results[0] as UserProfileSummaryModel;
        _suggestions = (results[1] as List<UserSuggestionModel>)
          ..sort((a, b) {
            final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
            final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
            return bTime.compareTo(aTime);
          });
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || loadId != _activeLoadId) return;
      _clearContributionState();
    }
  }

  List<UserSuggestionModel> get _filteredSuggestions {
    if (_selectedFilter == null) return _suggestions;
    return _suggestions.where((s) => s.status == _selectedFilter).toList();
  }

  Future<void> _openSuggestItem() async {
    if (!UserSession.isLoggedIn) {
      await _openLogin();
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SuggestItemScreen()),
    );

    if (created == true) {
      await _loadData();
    }
  }

  Future<void> _openLogin() async {
    final bool? loggedIn = await AppRouter.openLogin(context);

    if (loggedIn == true && mounted) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Background color of the screen
      backgroundColor: AppTheme.fog,

      /// 🔹 ADDING APP BAR (THIS FIXES YOUR BACK NAVIGATION ISSUE)
      ///
      /// Why:
      /// - When this screen is opened using Navigator.push(),
      ///   Flutter automatically shows a back arrow in AppBar.
      /// - This allows user to go back to Profile/Home without restarting app.
      appBar: AppBar(
        title: const Text(
          'My Contributions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        centerTitle: false,
      ),

      /// 🔹 Floating button for quick contribution
      ///
      /// Why:
      /// - Frequent contributors should not scroll up to find action
      /// - Always visible CTA improves engagement
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSuggestItem,
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.snow,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Suggest item',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      /// 🔹 Main body content
      body: SafeArea(
        child: !UserSession.isLoggedIn
            ? _buildLoggedOutState()
            : _isLoading
            ? _buildLoading()

        /// Error state (API failed / no data)
            : _summary == null
            ? _buildError()

        /// Main content
            : RefreshIndicator(
          /// Pull-to-refresh support
          onRefresh: _loadData,
          color: AppTheme.accent,

          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: kMaxContentWidth),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),

                slivers: [
                  /// Header section (title + description)
                  SliverToBoxAdapter(child: _buildHeader()),

                  /// Reward points + stats summary
                  SliverToBoxAdapter(
                      child: _buildSummaryCards(_summary!)),

                  /// Additional quick insights (approval rate etc.)
                  SliverToBoxAdapter(
                      child: _buildQuickInsights(_summary!)),

                  /// Filter chips (All / Pending / Approved / Rejected)
                  SliverToBoxAdapter(child: _buildFilterRow()),

                  /// Suggestions list
                  _buildSuggestionList(),

                  /// Bottom spacing (important for FAB overlap)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOutState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to view your contribution summary and suggestion history.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.stone,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.snow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the contributions page header.
  ///
  /// Messaging rule:
  /// - keep contribution language always visible
  /// - mention rewards only when rewards are enabled
  Widget _buildHeader() {
    final subtitle = FeatureFlags.isRewardsEnabled
        ? 'Track your food suggestions, reward points, and moderation status.'
        : 'Track your food suggestions and moderation status.';

    return centeredContent(
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contributions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    ),
    );
  }

  /// Builds contribution summary cards.
  ///
  /// Behavior:
  /// - contribution counters are always shown
  /// - reward points card is shown only when rewards are enabled
  Widget _buildSummaryCards(UserProfileSummaryModel summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          if (FeatureFlags.isRewardsEnabled) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
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
                          'Reward points',
                          style: TextStyle(
                            color: AppTheme.snow,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${summary.rewardPoints}',
                          style: const TextStyle(
                            color: AppTheme.snow,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.snow.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '100 to claim',
                      style: TextStyle(
                        color: AppTheme.snow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: _miniStatCard(
                  label: 'Approved',
                  value: '${summary.approvedContributions}',
                  color: AppTheme.success,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStatCard(
                  label: 'Pending',
                  value: '${summary.pendingContributions}',
                  color: AppTheme.warning,
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStatCard(
                  label: 'Rejected',
                  value: '${summary.rejectedContributions}',
                  color: AppTheme.error,
                  icon: Icons.cancel_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.stone,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds lightweight contribution insights.
  ///
  /// Behavior:
  /// - always shows contribution insights
  /// - does not depend on rewards being enabled
  Widget _buildQuickInsights(UserProfileSummaryModel summary) {
    final total = summary.totalContributions;
    final approvalRate = total == 0
        ? 0
        : ((summary.approvedContributions / total) * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.shadowXs,
        ),
        child: Row(
          children: [
            Expanded(
              child: _insightTile('Total suggestions', '$total'),
            ),
            Container(
              width: 1,
              height: 42,
              color: AppTheme.silver.withValues(alpha: 0.45),
            ),
            Expanded(
              child: _insightTile('Approval rate', '$approvalRate%'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.stone,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _filterChip(label: 'All', value: null),
            _filterChip(
              label: 'Pending',
              value: SuggestionStatus.pendingReview,
            ),
            _filterChip(
              label: 'Approved',
              value: SuggestionStatus.approvedNew,
              alsoMatches: SuggestionStatus.approvedMerged,
            ),
            _filterChip(
              label: 'Rejected',
              value: SuggestionStatus.rejected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required SuggestionStatus? value,
    SuggestionStatus? alsoMatches,
  }) {
    final selected = value == null
        ? _selectedFilter == null
        : (_selectedFilter == value || _selectedFilter == alsoMatches);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: selected,
        showCheckmark: false,
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? AppTheme.snow : AppTheme.ink,
          ),
        ),
        selectedColor: AppTheme.ink,
        backgroundColor: AppTheme.snow,
        side: BorderSide(
          color: selected ? AppTheme.ink : AppTheme.silver,
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildSuggestionList() {
    final items = _filteredSuggestions;

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.snow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.shadowXs,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 44,
                  color: AppTheme.pebble,
                ),
                const SizedBox(height: 12),
                Text(
                  'No suggestions yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by suggesting a food item that is missing near you.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.stone,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _openSuggestItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.snow,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Suggest an item',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SuggestionCard(item: items[index]),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.accent,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: AppTheme.pebble,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load contributions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again in a moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.stone,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final UserSuggestionModel item;

  const _SuggestionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      SuggestionStatus.pendingReview => AppTheme.warning,
      SuggestionStatus.approvedNew => AppTheme.success,
      SuggestionStatus.approvedMerged => AppTheme.success,
      SuggestionStatus.rejected => AppTheme.error,
      SuggestionStatus.unknown => AppTheme.stone,
    };

    final subtitle = item.restaurantName.isNotEmpty
        ? item.restaurantName
        : 'Restaurant not provided';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.slate,
            ),
          ),
          if (item.locationLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppTheme.stone,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.stone,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.slate,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (item.rewardPointsGranted > 0)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.accentDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${item.rewardPointsGranted} points',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.fog,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No points yet',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.stone,
                    ),
                  ),
                ),
              const Spacer(),
              if (item.createdAt != null)
                Text(
                  _formatDate(item.createdAt!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.pebble,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month]}';
  }
}