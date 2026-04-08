import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/app_info.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? user;

  const SettingsScreen({
    super.key,
    this.user,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  late final TextEditingController _publicUsernameController;

  bool _isSaving = false;
  String _appVersion = '-';

  @override
  void initState() {
    super.initState();
    _publicUsernameController =
        TextEditingController(text: widget.user?.publicUsername?? '');
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  Future<void> _savePublicUsername() async {
    if (_isSaving) return;

    final value = _publicUsernameController.text.trim();
    if (value.isEmpty) {
      _showSnack('Public username is required');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _userService.updatePublicUsername(value);
      if (!mounted) return;
      _showSnack('Public username updated');
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showTextDialog(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _publicUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fog,
      appBar: AppBar(
        backgroundColor: AppTheme.fog,
        foregroundColor: AppTheme.ink,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          if (widget.user != null) ...[
            _sectionCard(
              title: 'Public username',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This name will be shown publicly in reviews and other app surfaces.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.stone,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _publicUsernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter public username',
                      filled: true,
                      fillColor: AppTheme.fog,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePublicUsername,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.snow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Save public username',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            _sectionCard(
              title: 'Personalize your profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign in to set your public name and personalize your profile.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.stone,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign in from Profile',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          _menuCard([
            _menuTile(
              title: 'Contact Us',
              onTap: () => _showTextDialog(
                'Contact Us',
                'Email us at: ${AppInfo.contactEmail}',
              ),
            ),
            _divider(),
            _menuTile(
              title: 'About Us',
              onTap: () => _showTextDialog('About Us', AppInfo.aboutUs),
            ),
            _divider(),
            _menuTile(
              title: 'Privacy Policy',
              onTap: () => _showTextDialog('Privacy Policy', AppInfo.privacyPolicy),
            ),
            _divider(),
            _menuTile(
              title: 'Terms & Conditions',
              onTap: () => _showTextDialog(
                'Terms & Conditions',
                AppInfo.termsAndConditions,
              ),
            ),
            _divider(),
            _menuTile(
              title: 'App Version',
              trailing: Text(
                _appVersion,
                style: const TextStyle(
                  color: AppTheme.stone,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: children),
    );
  }

  Widget _menuTile({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
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
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.silver,
                ),
          ],
        ),
      ),
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