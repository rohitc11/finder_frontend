import 'package:flutter/material.dart';

import '../config/user_session.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

class ApiGuard {
  static Future<void> handleUnauthorized(BuildContext context) async {
    await UserSession.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (route) => false,
    );

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(replaceCurrent: true),
      ),
    );
  }
}