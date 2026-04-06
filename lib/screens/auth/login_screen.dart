import 'package:flutter/material.dart';

import '../../config/dev_login_defaults.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/seo_meta.dart';
import '../../utils/responsive.dart';

/// Login screen for Finder.
///
/// Launch scope:
/// - email or phone + password
/// - keeps UI simple
/// - returns to app after successful login
class LoginScreen extends StatefulWidget {
  final bool replaceCurrent;

  const LoginScreen({
    super.key,
    this.replaceCurrent = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocalDefaults();
    updateSeoMeta(
      title: 'Login | Finder',
      description:
          'Login to Finder to save items, write reviews, and manage your food discovery profile.',
      robots: 'noindex,nofollow',
    );
  }

  Future<void> _loadLocalDefaults() async {
    final prefill = await DevLoginDefaults.load();

    if (!mounted) {
      return;
    }

    if (_emailOrPhoneController.text.trim().isEmpty) {
      _emailOrPhoneController.text = prefill.identifier;
    }

    if (_passwordController.text.trim().isEmpty) {
      _passwordController.text = prefill.password;
    }
  }

  Future<void> _login() async {
    final identifier = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnack('Please enter email/phone and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEmail = identifier.contains('@');

      await _authService.login(
        email: isEmail ? identifier : null,
        phoneNumber: isEmail ? null : identifier,
        password: password,
      );

      await DevLoginDefaults.saveLastUsed(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      if (!widget.replaceCurrent && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        AppRouter.goHome(context);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Login failed. Please check your credentials.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
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
          'Login',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: centeredContent(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: _emailOrPhoneController,
                    label: 'Email or phone number',
                    hint: 'Enter email or phone',
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.snow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final created = await AppRouter.openRegister(context);

                      if (!context.mounted || created != true) {
                        return;
                      }

                      if (!widget.replaceCurrent && navigator.canPop()) {
                        navigator.pop(true);
                      } else {
                        AppRouter.goHome(context);
                      }
                    },
                    child: const Text('Create new account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Login to add items, bookmark dishes, write reviews, and track your contributions.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.stone,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.snow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}