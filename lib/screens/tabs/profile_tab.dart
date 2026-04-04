import 'package:flutter/material.dart';

import '../../config/user_session.dart';
import '../../models/user_model.dart';
import '../../models/user_profile_summary_model.dart';
import '../../services/auth_service.dart';
import '../../services/bucket_list_service.dart';
import '../../services/contribution_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../contributions/my_contributions_screen.dart';
import '../contributions/suggest_item_screen.dart';
import '../home_screen.dart';
import 'saved_tab.dart';
import '../saved/bucket_list_page.dart';
import '../admin/pending_suggestions_screen.dart';

/// Profile tab.
///
/// Goals:
/// - show guest preview when user is not logged in
/// - show real live counts when user is logged in
/// - avoid mismatch between profile counts and actual pages
/// - provide logout option
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final UserService _userService = UserService();
  final ContributionService _contributionService = ContributionService();
  final BucketListService _bucketListService = BucketListService();
  final AuthService _authService = AuthService();

  UserModel? _user;
  UserProfileSummaryModel? _summary;

  int _bucketListCount = 0;
  int _reviewCount = 0;
  int _contributionCount = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (UserSession.isLoggedIn) {
      _loadProfileData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _userService.fetchCurrentUser(),
        _contributionService.fetchUserSummary(),
        _bucketListService.fetchSavedItems(),
      ]);

      final user = results[0] as UserModel;
      final summary = results[1] as UserProfileSummaryModel;
      final savedItems = results[2] as List<dynamic>;

      if (!mounted) return;

      setState(() {
        _user = user;
        _summary = summary;
        _bucketListCount = savedItems.length;
        _reviewCount = user.totalReviewsGiven ?? 0;
        _contributionCount = summary.totalContributions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _user = null;
        _summary = null;
        _bucketListCount = 0;
        _reviewCount = 0;
        _contributionCount = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _openLoginFromProfile() async {
    final bool? loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    if (loggedIn == true && mounted) {
      await _loadProfileData();
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn) {
      return _buildGuestProfileView(context);
    }

    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2,
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadProfileData,
          color: AppTheme.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 18),
                _buildTopStats(),
                const SizedBox(height: 18),
                _buildAddItemCard(context),
                const SizedBox(height: 18),
                _buildImpactCard(),
                const SizedBox(height: 18),
                _buildMenuCard(context),
                const SizedBox(height: 18),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfileView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.snow,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTheme.offWhite,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.ink,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest user',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Login to save items, track contributions, and manage your profile.',
                            style: TextStyle(
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
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.snow,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _topStatTile(
                        icon: Icons.bookmark_rounded,
                        iconBg: const Color(0xFFEDEBFF),
                        iconColor: const Color(0xFF6C63FF),
                        value: '0',
                        label: 'Bucket List',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _topStatTile(
                        icon: Icons.star_rounded,
                        iconBg: const Color(0xFFFFF2E2),
                        iconColor: const Color(0xFFF5A623),
                        value: '0',
                        label: 'Reviews',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _topStatTile(
                        icon: Icons.lightbulb_rounded,
                        iconBg: const Color(0xFFFFEEE9),
                        iconColor: AppTheme.accent,
                        value: '0',
                        label: 'Contributions',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: _openLoginFromProfile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_rounded, color: AppTheme.snow),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add Item',
                          style: TextStyle(
                            color: AppTheme.snow,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppTheme.snow),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.snow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  children: [
                    _guestMenuTile('My Contributions'),
                    _guestDivider(),
                    _guestMenuTile('Bucket List'),
                    _guestDivider(),
                    _guestMenuTile('My Reviews'),
                    _guestDivider(),
                    _guestMenuTile('Settings'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openLoginFromProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: AppTheme.snow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Login / Register',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _user;
    final displayName = (user?.name ?? 'User').trim();
    final displayEmail = (user?.email ?? '').trim();
    final initial =
    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.snow,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail.isNotEmpty ? displayEmail : 'Finder user',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.stone,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Discovering and saving the best food items.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.slate,
          ),
        ),
      ],
    );
  }

  Widget _buildTopStats() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _topStatTile(
              icon: Icons.bookmark_rounded,
              iconBg: const Color(0xFFEDEBFF),
              iconColor: const Color(0xFF6C63FF),
              value: '$_bucketListCount',
              label: 'Bucket List',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _topStatTile(
              icon: Icons.star_rounded,
              iconBg: const Color(0xFFFFF2E2),
              iconColor: const Color(0xFFF5A623),
              value: '$_reviewCount',
              label: 'Reviews',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _topStatTile(
              icon: Icons.lightbulb_rounded,
              iconBg: const Color(0xFFFFEEE9),
              iconColor: AppTheme.accent,
              value: '$_contributionCount',
              label: 'Contributions',
            ),
          ),
        ],
      ),
    );
  }

  Widget _topStatTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
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

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.silver.withOpacity(0.45),
    );
  }

  Widget _buildAddItemCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SuggestItemScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.snow.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppTheme.snow,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.snow,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Help others discover standout dishes you’ve tried.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.snow,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.snow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    final approved = _summary?.approvedContributions ?? 0;
    final pending = _summary?.pendingContributions ?? 0;
    final rejected = _summary?.rejectedContributions ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your impact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 14),
          _impactRow('Approved suggestions', '$approved'),
          const SizedBox(height: 10),
          _impactRow('Pending review', '$pending'),
          const SizedBox(height: 10),
          _impactRow('Rejected', '$rejected'),
        ],
      ),
    );
  }

  Widget _impactRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.slate,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          _menuTile(
            icon: Icons.lightbulb_rounded,
            iconBg: const Color(0xFFFFEEE9),
            iconColor: AppTheme.accent,
            title: 'My Contributions',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyContributionsScreen(),
                ),
              );
            },
          ),
          _divider(),
          _menuTile(
            icon: Icons.bookmark_rounded,
            iconBg: const Color(0xFFEDEBFF),
            iconColor: const Color(0xFF6C63FF),
            title: 'Bucket List',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BucketListPage(),
                ),
              );
            },
          ),
          _divider(),
          _menuTile(
            icon: Icons.star_rounded,
            iconBg: const Color(0xFFFFF2E2),
            iconColor: const Color(0xFFF5A623),
            title: 'My Reviews',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('My Reviews screen can be added next.'),
                ),
              );
            },
          ),

          /// Show admin-only moderation entry.
          if ((UserSession.role ?? '').toUpperCase() == 'ADMIN') ...[
            _divider(),
            _menuTile(
              icon: Icons.admin_panel_settings_rounded,
              iconBg: const Color(0xFFEAF4FF),
              iconColor: const Color(0xFF1565C0),
              title: 'Review Items',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PendingSuggestionsScreen(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.silver,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.ink,
          side: const BorderSide(color: AppTheme.silver),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _guestMenuTile(String label) {
    return InkWell(
      onTap: _openLoginFromProfile,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.silver,
            ),
          ],
        ),
      ),
    );
  }

  Widget _guestDivider() {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: AppTheme.silver.withOpacity(0.45),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: AppTheme.silver.withOpacity(0.45),
    );
  }
}