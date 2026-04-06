import 'package:flutter/material.dart';

import '../router/app_router.dart';
import '../config/user_session.dart';

class ApiGuard {
  static Future<void> handleUnauthorized(BuildContext context) async {
    await UserSession.clear();

    if (!context.mounted) return;

    AppRouter.goHome(context);
    await AppRouter.openLogin(context);
  }
}