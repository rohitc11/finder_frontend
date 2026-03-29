import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {  
  String? _healthStatus;
  bool _loading = false;
  bool _healthOk = false;

  final _name     = 'Rohit Chaudhary';
  final _username = '@rohitchaudhary';
  final _bio      = 'Explorer. Builder. Finder of good things.';

  Future<void> _checkHealth() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse(ApiConfig.healthEndpoint));
      setState(() {
        _healthOk = res.statusCode == 200;
        _healthStatus = res.statusCode == 200 ? res.body : 'Error ${res.statusCode}';
      });
    } catch (e) {
      setState(() {
        _healthOk = false;
        _healthStatus = 'Connection failed';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildTop()),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildHealthSection()),
          SliverToBoxAdapter(child: _buildMenu()),
          SliverToBoxAdapter(child: _buildFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ─── TOP (avatar + name) ─────────────────
  Widget _buildTop() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.charcoal,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppTheme.shadowMd,
                  ),
                  child: const Center(
                    child: Text(
                      'RC',
                      style: TextStyle(
                        color: AppTheme.snow,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(letterSpacing: -0.8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.stone,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.snow,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 18, color: AppTheme.slate),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _bio,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.slate,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Premium tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified_rounded,
                      size: 15, color: AppTheme.accent),
                  SizedBox(width: 6),
                  Text(
                    'Premium Member',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
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

  // ─── STATS ROW ───────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            _statItem('42', 'Saved', Icons.bookmark_rounded,
                const Color(0xFF5E5CE6)),
            _dividerLine(),
            _statItem('18', 'Reviews', Icons.star_rounded,
                const Color(0xFFFF9F0A)),
            _dividerLine(),
            _statItem('1.2k', 'Followers', Icons.people_rounded,
                AppTheme.accent),
          ],
        ),
      ),
    );
  }

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
              letterSpacing: -0.5,
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

  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.silver.withValues(alpha: 0.5),
    );
  }

  // ─── HEALTH SECTION ──────────────────────
  Widget _buildHealthSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Button
          GestureDetector(
            onTap: _loading ? null : _checkHealth,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: _loading ? AppTheme.lightGray : AppTheme.charcoal,
                borderRadius: BorderRadius.circular(10),
                boxShadow: _loading
                    ? []
                    : [
                        BoxShadow(
                          color: AppTheme.charcoal.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        )
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.stone,
                      ),
                    )
                  else ...[
                    const Icon(Icons.cloud_done_rounded,
                        size: 20, color: AppTheme.snow),
                    const SizedBox(width: 10),
                    const Text(
                      'Check Backend Health',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.snow,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Result
          if (_healthStatus != null) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _healthOk
                    ? AppTheme.success.withValues(alpha: 0.08)
                    : AppTheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _healthOk
                      ? AppTheme.success.withValues(alpha: 0.25)
                      : AppTheme.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _healthOk
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    size: 18,
                    color: _healthOk ? AppTheme.success : AppTheme.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _healthStatus!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _healthOk ? AppTheme.success : AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── MENU ────────────────────────────────
  Widget _buildMenu() {
    final items = [
      _MenuItem('Saved Places', Icons.bookmark_rounded,
          const Color(0xFF5E5CE6)),
      _MenuItem('My Reviews', Icons.star_rounded,
          const Color(0xFFFF9F0A)),
      _MenuItem('Settings', Icons.settings_rounded,
          AppTheme.slate),
      _MenuItem('Help & Support', Icons.help_rounded,
          const Color(0xFF34C759)),
      _MenuItem('Sign Out', Icons.logout_rounded,
          AppTheme.error),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final m = items[i];
            final isLast = i == items.length - 1;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 15),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: m.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(m.icon, size: 18, color: m.color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isLast
                                  ? AppTheme.error
                                  : AppTheme.ink,
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Icon(Icons.chevron_right_rounded,
                              size: 20, color: AppTheme.silver),
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

  // ─── FOOTER ──────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Environment: ${ApiConfig.environmentDisplay}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.pebble,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Finder v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.pebble,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Model ───────────────────────────────

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  _MenuItem(this.label, this.icon, this.color);
}


