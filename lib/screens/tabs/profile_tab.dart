import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../config/user_session.dart';

/// Profile tab of the application.
///
/// Responsibility:
/// - show user identity
/// - show product-focused stats
/// - prepare for rewards and contributions
/// - stay minimal for launch phase
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  /// Service used to fetch user data from backend.
  final UserService _userService = UserService();

  /// Current user loaded from backend.
  UserModel? _user;

  /// Loading state for profile API.
  bool _isLoading = true;

  /// Loads profile data from backend.
  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.fetchUserById(UserSession.userId);

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _user = null;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(context)
            : _user == null
            ? _buildErrorState(context)
            : RefreshIndicator(
          onRefresh: _loadUser,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildTop(context, _user!)),
              SliverToBoxAdapter(child: _buildStats(_user!)),
              SliverToBoxAdapter(child: _buildRewardsCard(context)),
              SliverToBoxAdapter(child: _buildImpactSection(context, _user!)),
              SliverToBoxAdapter(child: _buildMenu()),
              SliverToBoxAdapter(child: _buildFooter()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds profile header with image, name and bio.
  Widget _buildTop(BuildContext context, UserModel user) {
    final initials = _buildInitials(user.name);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(user, initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email.isNotEmpty ? user.email : user.phoneNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.stone,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.bio.isNotEmpty
                ? user.bio
                : 'Discovering and saving the best food items.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds profile avatar using image URL if available,
  /// otherwise falls back to initials.
  Widget _buildAvatar(UserModel user, String initials) {
    if (user.profileImageUrl.isNotEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppTheme.offWhite,
          boxShadow: AppTheme.shadowSm,
          image: DecorationImage(
            image: NetworkImage(user.profileImageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppTheme.snow,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  /// Builds the main stats row.
  ///
  /// Launch phase stats:
  /// - Bucket List
  /// - Reviews
  /// - Contributions
  Widget _buildStats(UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            _statItem(
              '6',
              'Bucket List',
              Icons.bookmark_rounded,
              const Color(0xFF5E5CE6),
            ),
            _dividerLine(),
            _statItem(
              '${user.totalReviewsGiven}',
              'Reviews',
              Icons.star_rounded,
              const Color(0xFFFF9F0A),
            ),
            _dividerLine(),
            _statItem(
              '3',
              'Contributions',
              Icons.lightbulb_rounded,
              AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds rewards card.
  ///
  /// Values are placeholders for now and can later come from backend.
  Widget _buildRewardsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rewards',
              style: TextStyle(
                color: AppTheme.snow,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 10),
                const Text(
                  '30 points',
                  style: TextStyle(
                    color: AppTheme.snow,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '100 to claim',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.snow.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Earn 10 points for every approved food suggestion.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.snow.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds contribution/impact summary section.
  ///
  /// Some values are placeholders now and should later come from backend.
  Widget _buildImpactSection(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowXs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your impact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _impactRow('Approved suggestions', '3'),
            const SizedBox(height: 12),
            _impactRow('Pending review', '2'),
            const SizedBox(height: 12),
            _impactRow('Cities contributed', '${user.citiesVisitedCount}'),
          ],
        ),
      ),
    );
  }

  /// Builds menu section for profile actions.
  Widget _buildMenu() {
    final items = [
      _MenuItem('Bucket List', Icons.bookmark_rounded, const Color(0xFF5E5CE6)),
      _MenuItem('My Reviews', Icons.star_rounded, const Color(0xFFFF9F0A)),
      _MenuItem('My Suggestions', Icons.lightbulb_rounded, AppTheme.accent),
      _MenuItem('Rewards', Icons.card_giftcard_rounded, const Color(0xFF34C759)),
      _MenuItem('Settings', Icons.settings_rounded, AppTheme.slate),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, size: 18, color: item.color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppTheme.silver,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 18,
                    color: AppTheme.silver.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Builds footer area.
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: const Center(
        child: Text(
          'Finder v1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.pebble,
          ),
        ),
      ),
    );
  }

  /// Builds loading state while profile is being fetched.
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
            'Loading profile...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.stone,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds profile load error state.
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_rounded,
              size: 42,
              color: AppTheme.pebble,
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please pull to refresh or try again later.',
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

  /// Builds one stat item for the top stats row.
  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds divider line between stats.
  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.silver.withValues(alpha: 0.5),
    );
  }

  /// Builds one impact row entry.
  Widget _impactRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Builds initials from full name.
  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

/// Small menu item view model.
class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;

  _MenuItem(this.label, this.icon, this.color);
}