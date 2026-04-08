import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Registration screen for launch.
///
/// Rule:
/// - name required
/// - public name required
/// - password required
/// - either email or phoneNumber should be filled
/// - public name defaults from original name until manually edited
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _publicNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _publicNameEditedManually = false;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final publicName = _publicNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter your name.');
      return;
    }

    if (publicName.isEmpty) {
      _showSnack('Please enter public name.');
      return;
    }

    if (email.isEmpty && phone.isEmpty) {
      _showSnack('Please enter either email or phone number.');
      return;
    }

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: name,
        publicUsername: publicName,
        email: email.isEmpty ? null : email,
        phoneNumber: phone.isEmpty ? null : phone,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNameChanged(String value) {
    if (_publicNameEditedManually) return;
    _publicNameController.text = value;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _publicNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
          'Create account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 18),
            _buildField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter your name',
              onChanged: _onNameChanged,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _publicNameController,
              label: 'Public Name',
              hint: 'Visible in reviews and app',
              onChanged: (_) {
                _publicNameEditedManually = true;
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email',
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _phoneController,
              label: 'Phone number',
              hint: 'Enter phone number',
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Minimum 6 characters',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
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
                  'Create account',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
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
            'Create your Spotzy account',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Public Name will be visible in reviews and app surfaces. You can edit it later in Settings.',
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
    ValueChanged<String>? onChanged,
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
          onChanged: onChanged,
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